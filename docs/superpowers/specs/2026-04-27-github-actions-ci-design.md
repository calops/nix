# GitHub Actions CI for Nix Flake

## Overview

Automated CI pipeline that builds all Nix configurations, pushes to Cachix, and maintains an auto-updating PR with fresh flake inputs.

## Architecture

### Files to create/modify

| File | Purpose |
|------|---------|
| `.github/workflows/build.yml` | Reusable workflow: build configs & push to cachix |
| `.github/workflows/ci.yml` | Trigger on push to main, call build.yml |
| `.github/workflows/update.yml` | Scheduled input updates with PR management |
| `modules/outputs.nix` | Add devShell output for cache bootstrapping |
| `.github/workflows/cachix.yml` | Delete (replaced by new workflows) |

### Files left untouched

| File | Reason |
|------|--------|
| `garnix.yaml` | User wants to keep as secondary CI |

---

## Component 1: DevShell for Cache Bootstrapping

### Purpose

A `devShells.default` output that configures `NIX_CONFIG` with all substituters and trusted-public-keys from the flake's own configuration. This enables:

- Anyone cloning the repo gets caches immediately via `nix develop`
- CI workflows inherit cache configuration without hardcoding
- Single source of truth for cache configuration

### Implementation

In `modules/outputs.nix`, add a `perSystem` devShell that reads the substituters and trusted-public-keys from the nix settings already configured by the `den` framework (via `modules/den.nix` and `modules/nix.nix`).

The devShell sets `NIX_CONFIG` as an environment variable with:
- `extra-substituters = <space-separated list of URLs>`
- `extra-trusted-public-keys = <space-separated list of keys>`

These values are derived from the same options that feed into the NixOS/home-manager/darwin configurations, ensuring consistency.

The caches to include:
- `https://cache.garnix.io`
- `https://cache.nixos.org`
- `https://calops.cachix.org`
- `https://nix-community.cachix.org`
- `https://anyrun.cachix.org`
- `https://niri.cachix.org`
- `https://nix-darwin.cachix.org`

### Considerations

- The devShell should NOT require any special tools beyond `nix` itself — it's purely a cache configuration wrapper
- The devShell can include `nixfmt-tree` (the formatter) for convenience

---

## Component 2: Reusable Build Workflow (`build.yml`)

### Purpose

A `workflow_call`-compatible reusable workflow that builds all configurations and pushes results to Cachix.

### Trigger

```yaml
on:
  workflow_call:
```

### Inputs (from caller)

- None needed — discovers everything from the flake

### Secrets

- `cachix_auth_token` — for pushing to cachix

### Steps

1. **Checkout** — `actions/checkout@v4`
2. **Install Nix** — `DeterminateSystems/nix-installer-action@main` (supports modern Nix features like pipe-operators)
3. **Configure caches** — Use the devShell's `NIX_CONFIG` to set up all substituters, OR extract them via `nix eval` on the devShell output
4. **Authenticate with Cachix** — `cachix/cachix-action@master` with `name: calops` and `authToken`
5. **Discover build targets** — Run `nix flake show --json --allow-import-from-derivation` and parse the JSON to extract:
   - `nixosConfigurations.*`
   - `darwinConfigurations.*`
   - `homeConfigurations.*`
   
   De-duplication: Skip `homeConfigurations` entries that correspond to users within NixOS configs (the NixOS build already caches the embedded home-manager closure). Concretely: if a `homeConfigurations."user@host"` exists and there's a matching `nixosConfigurations."host"`, skip the home-manager build.

6. **Build each target** — For each discovered target, run `nix build .#<attr-path>`. Use `--accept-flake-config --option keep-going true` for robustness.
7. **Push to Cachix** — Cachix action auto-pushes on build via its watch-store mode

### Build matrix

Since all current configs are `x86_64-linux`, everything runs on a single `ubuntu-latest` runner. If darwin configs are added in the future, a separate darwin job on `macos-latest` would be added.

### Output

- `build-success` — boolean, whether all builds succeeded
- `build-summary` — text summary of what was built and results
- `failed-targets` — list of any failed build targets

---

## Component 3: Main CI Workflow (`ci.yml`)

### Purpose

Build and cache all configurations after every push to main.

### Trigger

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

### Steps

Single job that calls the reusable `build.yml` workflow. Nothing else.

### Failure handling

If builds fail, the GitHub Action run is marked as failed. No PR management needed here.

---

## Component 4: Scheduled Update Workflow (`update.yml`)

### Purpose

Daily update of all flake inputs with automatic PR management.

### Trigger

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2AM UTC daily
  workflow_dispatch:
```

### Steps

#### Job: update-and-build

1. **Checkout** — `actions/checkout@v4` with full history for diff generation
2. **Install Nix** — `DeterminateSystems/nix-installer-action@main`
3. **Update flake inputs** — `nix flake update --commit-lock-file-summary "flake.lock: update all inputs"`
   - Do NOT commit yet — we need to build first
   - Capture the diff of `flake.lock` for the PR body
4. **Call reusable build workflow** — Uses `build.yml` to build everything with the updated lockfile
5. **Generate input change summary** — Parse the `flake.lock` diff to show which inputs changed and their old/new revisions
6. **Manage PR**:

   **On build success:**
   - Force-push the updated `flake.lock` to branch `update-flake-inputs`
   - Create or update PR to `main` from `update-flake-inputs`
   - PR body includes the input change summary
   - Mark as ready for review (convert from draft if it was)

   **On build failure, no existing open PR on branch:**
   - Force-push the updated `flake.lock` to branch `update-flake-inputs`
   - Create a **draft** PR with failure details in the body
   - Include link to the failed CI run: `${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}`

   **On build failure, existing ready (non-draft) PR on branch:**
   - Do NOT push the new lockfile — preserve the known-good PR
   - Comment on the existing PR with:
     - Failure details (which targets failed)
     - Link to the failed CI run
     - List of which inputs would have changed

### PR content

The PR body includes:
- Summary of input changes (table: input name, old rev, new rev)
- Build status and CI run link
- Instructions: "Merge to apply these updates"

### Branch management

- Fixed branch name: `update-flake-inputs`
- Force-push to keep the branch updated
- When merged, the branch is deleted by GitHub (default behavior), and the next scheduled run recreates it

---

## Secrets Required

| Secret | Purpose | Already configured |
|--------|---------|--------------------|
| `CACHIX_AUTH_TOKEN` | Push to calops.cachix.org | Yes |

---

## Security Considerations

- No secrets in workflow files — all auth via GitHub Secrets
- `DeterminateSystems/nix-installer-action` is well-maintained and widely used in the Nix community
- Force-push only to the `update-flake-inputs` branch, never to `main`
- PRs require manual merge — no auto-merge

---

## Future Considerations

- If darwin configurations are added, add a parallel job on `macos-latest` runner
- Could add `nix flake check` as a pre-build validation step
- Could add automatic closing of stale draft PRs after N days of failure
