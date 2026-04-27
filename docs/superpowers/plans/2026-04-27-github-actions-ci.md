# GitHub Actions CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the dysfunctional cachix.yml with a proper CI pipeline that builds configs, pushes to Cachix, and maintains an auto-updating PR for flake input updates.

**Architecture:** Three GitHub Actions workflows — a reusable `build.yml` that builds and caches configs, a `ci.yml` that triggers on push to main, and an `update.yml` that runs daily to update flake inputs and manage a PR. A new devShell output bootstraps cache configuration via `NIX_CONFIG`.

**Tech Stack:** GitHub Actions, Nix, Cachix, flake-parts

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `modules/outputs.nix` | Modify | Add devShell with cache bootstrap |
| `.github/workflows/cachix.yml` | Delete | Replaced by new workflows |
| `.github/workflows/build.yml` | Create | Reusable build + cache workflow |
| `.github/workflows/ci.yml` | Create | Push-to-main build trigger |
| `.github/workflows/update.yml` | Create | Scheduled input update + PR management |

---

### Task 1: Add devShell with cache bootstrap

**Files:**
- Modify: `modules/outputs.nix`

This devShell sets `NIX_CONFIG` with all substituters and trusted-public-keys so that anyone cloning the repo (or the CI) gets cache hits immediately.

- [ ] **Step 1: Add devShell to `modules/outputs.nix`**

Add a `devShells.default` in the `perSystem` block. The cache values are hardcoded here (matching those in `modules/den.nix`, `modules/programs/anyrun.nix`, `modules/programs/niri.nix`, and `modules/darwin.nix`) because the `perSystem` block doesn't have access to the den framework's nix settings — these are NixOS-level options that only exist inside host configurations.

```nix
{ den, lib, ... }:
{
  systems = builtins.attrNames den.hosts;

  den.ctx.flake-system.into.host =
    { system }: lib.attrValues (den.hosts.${system} or { }) |> (host: { inherit host; });

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;

      devShells.default = pkgs.mkShell {
        NIX_CONFIG = ''
          extra-experimental-features = flakes nix-command pipe-operators
          extra-substituters = https://cache.garnix.io https://cache.nixos.org https://calops.cachix.org https://nix-community.cachix.org https://anyrun.cachix.org https://niri.cachix.org https://nix-darwin.cachix.org
          extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s= niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964= nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A=
        '';
      };
    };
};
```

- [ ] **Step 2: Verify the devShell evaluates**

Run: `nix develop --command echo "devShell works"`
Expected: prints "devShell works" with no errors

- [ ] **Step 3: Verify caches are configured in the devShell**

Run: `nix develop --command nix config show extra-substituters`
Expected: shows all 7 substituter URLs

- [ ] **Step 4: Commit**

```bash
git add modules/outputs.nix
git commit -m "feat: add devShell with cache bootstrap via NIX_CONFIG"
```

---

### Task 2: Create reusable build workflow

**Files:**
- Create: `.github/workflows/build.yml`

This is the core workflow that both `ci.yml` and `update.yml` call. It discovers all configs, builds them, and pushes to Cachix.

- [ ] **Step 1: Create `.github/workflows/build.yml`**

```yaml
name: Build configurations

on:
  workflow_call:
    outputs:
      build-success:
        description: "Whether all builds succeeded"
        value: ${{ jobs.build.outputs.success }}
      failed-targets:
        description: "List of failed build targets"
        value: ${{ jobs.build.outputs.failed }}

jobs:
  build:
    runs-on: ubuntu-latest
      success: ${{ steps.build-all.outputs.success }}
      failed: ${{ steps.build-all.outputs.failed }}
    steps:
      - uses: actions/checkout@v4

      - uses: DeterminateSystems/nix-installer-action@main

      - uses: cachix/cachix-action@master
        with:
          name: calops
          authToken: ${{ secrets.CACHIX_AUTH_TOKEN }}
          useDaemon: true

      - name: Discover build targets
        id: discover
        run: |
          # Get all flake outputs as JSON
          OUTPUTS=$(nix flake show --json --allow-import-from-derivation 2>/dev/null)

          TARGETS=()

          # Collect nixosConfigurations
          NIXOS=$(echo "$OUTPUTS" | jq -r '.nixosConfigurations // {} | keys[]' 2>/dev/null || true)
          for host in $NIXOS; do
            TARGETS+=("nixosConfigurations.\"$host\".config.system.build.toplevel")
          done

          # Collect darwinConfigurations
          DARWIN=$(echo "$OUTPUTS" | jq -r '.darwinConfigurations // {} | keys[]' 2>/dev/null || true)
          for host in $DARWIN; do
            TARGETS+=("darwinConfigurations.\"$host\".system")
          done

          # Collect homeConfigurations, but skip those that are subsets of NixOS configs
          HM_ALL=$(echo "$OUTPUTS" | jq -r '.homeConfigurations // {} | keys[]' 2>/dev/null || true)
          NIXOS_HOSTS_SET=$(echo "$OUTPUTS" | jq -r '.nixosConfigurations // {} | keys[]' 2>/dev/null | tr '\n' ' ')
          for hm in $HM_ALL; do
            # Extract hostname from "user@hostname" pattern
            HOSTNAME=$(echo "$hm" | cut -d'@' -f2)
            # Skip if hostname matches a NixOS config (the HM closure is already built)
            if echo " $NIXOS_HOSTS_SET " | grep -q " $HOSTNAME "; then
              echo "Skipping homeConfigurations.\"$hm\" (covered by nixosConfigurations.\"$HOSTNAME\")"
              continue
            fi
            TARGETS+=("homeConfigurations.\"$hm\".activationPackage")
          done

          # Output as JSON array for downstream steps
          TARGETS_JSON=$(printf '%s\n' "${TARGETS[@]}" | jq -R . | jq -sc .)
          echo "targets=$TARGETS_JSON" >> "$GITHUB_OUTPUT"
          echo "count=${#TARGETS[@]}" >> "$GITHUB_OUTPUT"
          echo ""
          echo "Found ${#TARGETS[@]} build targets:"
          for t in "${TARGETS[@]}"; do
            echo "  - $t"
          done

      - name: Build all targets
        id: build-all
        run: |
          TARGETS='${{ steps.discover.outputs.targets }}'
          FAILED=""
          FAILED_LIST=""

          for target in $(echo "$TARGETS" | jq -r '.[]'); do
            echo "::group::Building $target"
            if nix build ".#$target" --accept-flake-config --no-link; then
              echo "✅ $target"
            else
              echo "❌ $target"
              FAILED="true"
              FAILED_LIST="$FAILED_LIST
          - $target"
            fi
            echo "::endgroup::"
          done

          # Trim leading newline from failed list
          FAILED_LIST=$(echo "$FAILED_LIST" | sed '/^$/d')

          if [ -n "$FAILED" ]; then
            echo "success=false" >> "$GITHUB_OUTPUT"
            echo "failed<<EOF" >> "$GITHUB_OUTPUT"
            echo "$FAILED_LIST" >> "$GITHUB_OUTPUT"
            echo "EOF" >> "$GITHUB_OUTPUT"
            echo ""
            echo "Some builds failed:$FAILED_LIST"
          else
            echo "success=true" >> "$GITHUB_OUTPUT"
            echo "failed=" >> "$GITHUB_OUTPUT"
            echo ""
            echo "All builds succeeded!"
          fi

      - name: Summary
        if: always()
        run: |
          echo "## Build Summary" >> "$GITHUB_STEP_SUMMARY"
          echo "" >> "$GITHUB_STEP_SUMMARY"
          echo "Targets: ${{ steps.discover.outputs.count }}" >> "$GITHUB_STEP_SUMMARY"
          if [ -n "${{ steps.build-all.outputs.failed }}" ]; then
            echo "Status: ❌ Some builds failed" >> "$GITHUB_STEP_SUMMARY"
            echo "" >> "$GITHUB_STEP_SUMMARY"
            echo "### Failed targets" >> "$GITHUB_STEP_SUMMARY"
            echo "${{ steps.build-all.outputs.failed }}" >> "$GITHUB_STEP_SUMMARY"
          else
            echo "Status: ✅ All builds succeeded" >> "$GITHUB_STEP_SUMMARY"
          fi
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build.yml
git commit -m "ci: add reusable build workflow with auto-discovery"
```

---

### Task 3: Create push-to-main CI workflow

**Files:**
- Create: `.github/workflows/ci.yml`

Simple wrapper that calls the reusable build workflow on every push to main.

- [ ] **Step 1: Create `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    uses: ./.github/workflows/build.yml
    secrets: inherit
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add push-to-main build workflow"
```

---

### Task 4: Create scheduled update workflow

**Files:**
- Create: `.github/workflows/update.yml`

This is the most complex workflow. It updates flake inputs daily, builds everything, and manages the `update-flake-inputs` PR.

- [ ] **Step 1: Create `.github/workflows/update.yml`**

```yaml
name: Update flake inputs

on:
  schedule:
    - cron: "0 2 * * *"
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  update:
    runs-on: ubuntu-latest
    outputs:
      build-success: ${{ steps.build-result.outputs.build-success }}
      input-changes: ${{ steps.diff.outputs.changes }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: DeterminateSystems/nix-installer-action@main

      - name: Save current lockfile
        run: cp flake.lock flake.lock.old

      - name: Update flake inputs
        run: nix flake update

      - name: Generate input change summary
        id: diff
        run: |
          if diff -q flake.lock.old flake.lock > /dev/null 2>&1; then
            echo "changes=No changes detected in flake inputs." >> "$GITHUB_OUTPUT"
            echo "No changes detected."
          else
            {
              echo "changes<<EOF"
              git diff --no-color flake.lock.old flake.lock | \
                grep -E '^\+|^-' | \
                grep -E '(url|rev|narHash)' | \
                sed 's/^+/✅ /;s/^-/❌ /' || true
              echo "EOF"
            } >> "$GITHUB_OUTPUT"
            echo "Changes detected in flake inputs."
          fi

      - name: Build configurations
        id: build-result
        uses: ./.github/workflows/build.yml
        secrets: inherit

      - name: Check for existing PR
        id: check-pr
        if: always()
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          PR_DATA=$(gh pr list --head update-flake-inputs --state open --json number,isDraft,url --jq '.[0]' 2>/dev/null || echo "")
          if [ -n "$PR_DATA" ] && [ "$PR_DATA" != "null" ]; then
            echo "exists=true" >> "$GITHUB_OUTPUT"
            echo "number=$(echo "$PR_DATA" | jq -r '.number')" >> "$GITHUB_OUTPUT"
            echo "is-draft=$(echo "$PR_DATA" | jq -r '.isDraft')" >> "$GITHUB_OUTPUT"
            echo "url=$(echo "$PR_DATA" | jq -r '.url')" >> "$GITHUB_OUTPUT"
          else
            echo "exists=false" >> "$GITHUB_OUTPUT"
          fi

      - name: Handle build success
        if: success()
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          BRANCH="update-flake-inputs"

          # Configure git
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          # Commit the lockfile and force-push
          git checkout -b "$BRANCH"
          git add flake.lock
          git commit -m "flake.lock: update all inputs" || true
          git push origin "$BRANCH" --force

          # Build PR body
          BODY="## Input changes
          $(echo '${{ steps.diff.outputs.changes }}' | head -100)

          ---

          Built and cached successfully. Ready to merge."

          if [ "${{ steps.check-pr.outputs.exists }}" = "true" ]; then
            # Update existing PR
            gh pr edit "$BRANCH" --body "$BODY"
            # Convert from draft to ready if it was a draft
            if [ "${{ steps.check-pr.outputs.is-draft }}" = "true" ]; then
              gh pr ready "$BRANCH"
            fi
            echo "Updated existing PR: ${{ steps.check-pr.outputs.url }}"
          else
            # Create new PR
            PR_URL=$(gh pr create \
              --head "$BRANCH" \
              --base main \
              --title "flake.lock: update all inputs" \
              --body "$BODY")
            echo "Created PR: $PR_URL"
          fi

      - name: Handle build failure (no existing ready PR)
        if: failure() && steps.check-pr.outputs.exists != 'true'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          BRANCH="update-flake-inputs"

          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          # Still push the lockfile for inspection
          git checkout -b "$BRANCH"
          git add flake.lock
          git commit -m "flake.lock: update all inputs" || true
          git push origin "$BRANCH" --force

          # Build failure body
          BODY="## Input changes
          $(echo '${{ steps.diff.outputs.changes }}' | head -100)

          ---

          ⚠️ **Build failed.** This PR is a draft.

          Failed CI run: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"

          # Create as draft
          PR_URL=$(gh pr create \
            --head "$BRANCH" \
            --base main \
            --title "flake.lock: update all inputs (build failing)" \
            --body "$BODY" \
            --draft)
          echo "Created draft PR: $PR_URL"

      - name: Handle build failure (existing ready PR)
        if: failure() && steps.check-pr.outputs.exists == 'true' && steps.check-pr.outputs.is-draft == 'false'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Don't push — preserve the known-good PR
          COMMENT="⚠️ **Scheduled update failed** — this PR was not updated to preserve its known-good state.

          Failed CI run: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}

          $(echo '${{ steps.diff.outputs.changes }}' | head -50)"

          gh pr comment "${{ steps.check-pr.outputs.number }}" --body "$COMMENT"
          echo "Commented on existing PR #${{ steps.check-pr.outputs.number }}"

      - name: Handle build failure (existing draft PR)
        if: failure() && steps.check-pr.outputs.exists == 'true' && steps.check-pr.outputs.is-draft == 'true'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          BRANCH="update-flake-inputs"

          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          # Update the draft with the latest lockfile
          git checkout -b "$BRANCH"
          git add flake.lock
          git commit -m "flake.lock: update all inputs" || true
          git push origin "$BRANCH" --force

          BODY="## Input changes
          $(echo '${{ steps.diff.outputs.changes }}' | head -100)

          ---

          ⚠️ **Build failed.** This PR remains a draft.

          Failed CI run: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"

          gh pr edit "${{ steps.check-pr.outputs.number }}" --body "$BODY"
          echo "Updated existing draft PR #${{ steps.check-pr.outputs.number }}"
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/update.yml
git commit -m "ci: add scheduled flake input update workflow with PR management"
```

---

### Task 5: Remove old cachix workflow

**Files:**
- Delete: `.github/workflows/cachix.yml`

- [ ] **Step 1: Delete old workflow**

```bash
git rm .github/workflows/cachix.yml
git commit -m "ci: remove old cachix workflow (replaced by build/ci/update)"
```

---

### Task 6: Verify and clean up

- [ ] **Step 1: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: No evaluation errors

- [ ] **Step 2: Verify devShell**

Run: `nix develop --command echo ok`
Expected: prints "ok"

- [ ] **Step 3: Verify workflow YAML is valid**

Run: `python3 -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/build.yml', '.github/workflows/ci.yml', '.github/workflows/update.yml']]"` (or just visually inspect the YAML structure)
Expected: No parse errors

- [ ] **Step 4: Regenerate flake.nix if needed**

The `flake.nix` header says "DO-NOT-EDIT. Auto-generated by flake-file." Since we modified `modules/outputs.nix`, check if `flake.nix` needs regeneration:
Run: `nix run .#write-flake`
Then check if `flake.nix` changed and commit if so.
