# Den Scaffolding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add den scaffolding to the existing blueprint-based flake so that dendritic modules can be added incrementally alongside the existing host/module structure, without disrupting current builds.

**Architecture:** The migration follows the "From Flake to Den" guide's hybrid approach: add `den` and `import-tree` as inputs, create a `modules/den.nix` that declares hosts/users/aspects, and wire `host.mainModule` into the existing `nixosConfigurations`/`darwinConfigurations` via blueprint's module injection. Existing modules remain untouched — den aspects are additive. The `tocardland` host (standalone home-manager only) will use `den.homes` instead of `den.hosts`.

**Tech Stack:** Nix, vic/den, vic/import-tree, numtide/blueprint, home-manager, nix-darwin

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `flake.nix` | Modify | Add `den` and `import-tree` inputs |
| `modules/den.nix` | Create | Den entry point: imports `flakeModule`, declares hosts/users/aspects |
| `hosts/tocardstation/configuration.nix` | Modify | Import den host's `mainModule` |
| `hosts/tb-laptop/configuration.nix` | Modify | Import den host's `mainModule` |
| `hosts/remilabeyrie-kiro/darwin-configuration.nix` | Modify | Import den host's `mainModule` |
| `hosts/tocardland/users/calops.nix` | Modify | Import den home's `mainModule` |

No other files change. All existing modules, packages, devshells, and lib remain as-is.

---

### Task 1: Add den and import-tree flake inputs

**Files:**
- Modify: `flake.nix:4-87` (inputs block)

- [ ] **Step 1: Add the two new inputs to flake.nix**

Add these entries to the `inputs` block in `flake.nix`, after the existing inputs:

```nix
    # Dendritic module system
    den.url = "github:vic/den";
    den.inputs.nixpkgs.follows = "nixpkgs";

    # Auto-import tree for den modules
    import-tree.url = "github:vic/import-tree";
    import-tree.inputs.nixpkgs.follows = "nixpkgs";
```

The full `inputs` block will now include these two new inputs. All other inputs remain unchanged.

- [ ] **Step 2: Verify the flake evaluates with new inputs**

Run: `nix flake lock --update-input den --update-input import-tree`
Expected: flake.lock updated with den and import-tree entries

Run: `nix flake check --no-build`
Expected: PASS (no evaluation errors)

- [ ] **Step 3: Commit**

```bash
git add flake.nix flake.lock
git commit -m "feat: add den and import-tree flake inputs"
```

---

### Task 2: Create the den entry point module

**Files:**
- Create: `modules/den.nix`

This module is the single dendritic configuration point. It declares all hosts and users from the existing setup, and initially has **no aspects** beyond the auto-generated ones and a minimal battery include for hostname. This keeps the scaffold non-disruptive.

The key insight: `den.hosts` declarations produce `host.mainModule` attributes that, when imported into the existing blueprint host configs, inject the den aspect resolution into the existing `nixosSystem`/`darwinSystem` call. This is the bridge between old and new.

For the `tocardland` host (standalone home-manager, no NixOS/darwin system), we use `den.homes` instead.

- [ ] **Step 1: Create `modules/den.nix`**

```nix
{ inputs, den, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # ── NixOS hosts ──────────────────────────────────────────────
  den.hosts.x86_64-linux.tocardstation.users.calops = {};
  den.hosts.x86_64-linux.tb-laptop.users.calops = {};

  # ── Darwin hosts ─────────────────────────────────────────────
  den.hosts.aarch64-darwin.remilabeyrie-kiro.users.remilabeyrie = {};

  # ── Standalone home-manager ──────────────────────────────────
  den.homes.x86_64-linux.tocardland = {
    userName = "calops";
  };
}
```

**What this does:**
- Imports `den.flakeModule` which provides all `den.*` options
- Sets `homeManager` as the default user class (matches current setup where all users use home-manager)
- Declares each host with its system, name, and users — den auto-derives `class` from the system string (`x86_64-linux` → `nixos`, `aarch64-darwin` → `darwin`)
- Declares the standalone home-manager config for tocardland
- Den auto-generates aspects for each host, user, and home — these are initially empty shells that we can incrementally fill with aspects later

- [ ] **Step 2: Verify the den module evaluates in isolation**

This step is a sanity check. Since the den module isn't wired into flake.nix yet, we can't test it through a build. Instead, verify the file parses:

Run: `nix-instantiate --parse modules/den.nix > /dev/null`
Expected: No parse errors (silent output)

- [ ] **Step 3: Commit**

```bash
git add modules/den.nix
git commit -m "feat: add den entry point module with host/user declarations"
```

---

### Task 3: Wire den into flake.nix outputs

**Files:**
- Modify: `flake.nix:89-95` (outputs block)

This is the critical bridge. We need to evaluate the den modules alongside blueprint, then pass the den-evaluated host `mainModule` into each existing blueprint host configuration.

The approach from the guide:

```nix
let
  den = (inputs.nixpkgs.lib.evalModules {
    modules = [ (inputs.import-tree ./modules) ];
    specialArgs.inputs = inputs;
  }).config;
in
```

However, there's a conflict: `import-tree` auto-loads ALL `.nix` files in `modules/`, but `modules/` already contains `common/`, `nixos/`, `darwin/`, `home/` which are regular NixOS/home-manager/darwin modules — NOT dendritic modules. Loading them through `evalModules` would fail because they use options like `my.roles.*` that only exist in the context of a `nixosSystem`/`homeManagerConfiguration` evaluation.

**Solution:** Use `import-tree`'s filtering to only load `modules/den.nix`:

```nix
let
  den = (inputs.nixpkgs.lib.evalModules {
    modules = [ (inputs.import-tree ./modules).den ];
    specialArgs.inputs = inputs;
  }).config;
in
```

Wait — `import-tree` returns an attribute set where each key is the filename (without `.nix`) and each value is the module. But it also recurses into subdirectories. We need to check whether `(inputs.import-tree ./modules).den` works to load just `modules/den.nix`.

Actually, `import-tree` recursively loads ALL `.nix` files in a directory tree into a nested attrset. Files starting with `_` are excluded. So `(inputs.import-tree ./modules)` would load `modules/den.nix` as `.den`, `modules/common/default.nix` as `.common`, etc.

We should use the `.den` key to get just the den module:

```nix
den = (inputs.nixpkgs.lib.evalModules {
  modules = [ ((inputs.import-tree ./modules).den or {}) ];
  specialArgs.inputs = inputs;
}).config;
```

But actually, for the initial scaffolding, we could also just directly import `modules/den.nix` without import-tree:

```nix
den = (inputs.nixpkgs.lib.evalModules {
  modules = [ ./modules/den.nix ];
  specialArgs.inputs = inputs;
}).config;
```

This is simpler and avoids loading non-den modules. We can switch to `import-tree` later when more dendritic modules exist in a dedicated subdirectory.

Let's use the direct import approach for now — it's cleaner for the scaffolding phase.

- [ ] **Step 1: Modify flake.nix outputs to evaluate den and expose mainModules**

Replace the current outputs block:

```nix
  outputs =
    inputs:
    let
      den = (inputs.nixpkgs.lib.evalModules {
        modules = [ ./modules/den.nix ];
        specialArgs.inputs = inputs;
      }).config;
    in
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;

      # Make den host mainModules available to blueprint host configs
      moduleInputs = {
        inherit den;
      };
    };
```

The `moduleInputs` is a blueprint feature that passes extra arguments to all host/user/package modules. This makes `den` available as a parameter in host `configuration.nix` files.

**Note:** We need to verify that `moduleInputs` is the correct blueprint API for passing extra args. If blueprint doesn't support this, we'll need an alternative approach (see Step 2).

- [ ] **Step 2: Verify the flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS — the den module evaluates, and blueprint still works as before. The `den` attrset is now available to host modules.

If `moduleInputs` is not a valid blueprint API, we need an alternative. Blueprint passes `inputs` to all modules, so we can also access `den` through the nixpkgs lib we just computed. Let's check the blueprint API first.

Alternative approach: Instead of `moduleInputs`, we can make the den config available through the `inputs` attrset by adding it there:

```nix
  outputs =
    inputs:
    let
      den = (inputs.nixpkgs.lib.evalModules {
        modules = [ ./modules/den.nix ];
        specialArgs.inputs = inputs;
      }).config;
    in
    inputs.blueprint {
      inputs = inputs // { inherit den; };
      nixpkgs.config.allowUnfree = true;
    };
```

This adds a `den` key to the `inputs` attrset that's available in all modules. Host configurations can then access `inputs.den.den.hosts.x86_64-linux.tocardstation.mainModule`.

This is the cleanest approach — it doesn't require any blueprint-specific API.

- [ ] **Step 3: Commit**

```bash
git add flake.nix
git commit -m "feat: evaluate den modules and expose via inputs"
```

---

### Task 4: Import den mainModules into existing host configurations

**Files:**
- Modify: `hosts/tocardstation/configuration.nix`
- Modify: `hosts/tb-laptop/configuration.nix`
- Modify: `hosts/remilabeyrie-kiro/darwin-configuration.nix`
- Modify: `hosts/tocardland/users/calops.nix`

Now we add the den-generated `mainModule` to each existing host configuration. This is the bridge from the guide's Step 2:

```nix
nixosConfigurations.igloo = nixosSystem {
  modules = [
    <all your current NixOS modules>
    igloo.mainModule
  ];
};
```

In our case, blueprint handles the `nixosSystem` call automatically based on `hosts/<name>/configuration.nix`. So we just need to add the `mainModule` to the imports list.

- [ ] **Step 1: Add den mainModule to tocardstation**

In `hosts/tocardstation/configuration.nix`, add the den host mainModule to the imports list:

```nix
  imports = [
    inputs.solaar.nixosModules.default
    inputs.disko.nixosModules.disko
    flake.nixosModules.default
    ./hardware.nix
    inputs.den.den.hosts.x86_64-linux.tocardstation.mainModule
  ];
```

- [ ] **Step 2: Add den mainModule to tb-laptop**

In `hosts/tb-laptop/configuration.nix`, add:

```nix
  imports = [
    flake.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
    ./hardware.nix
    inputs.den.den.hosts.x86_64-linux.tb-laptop.mainModule
  ];
```

- [ ] **Step 3: Add den mainModule to remilabeyrie-kiro**

In `hosts/remilabeyrie-kiro/darwin-configuration.nix`, add:

```nix
  imports = [
    flake.darwinModules.default
    inputs.den.den.hosts.aarch64-darwin.remilabeyrie-kiro.mainModule
  ];
```

- [ ] **Step 4: Add den mainModule to tocardland**

In `hosts/tocardland/users/calops.nix`, this is a standalone home-manager config. We need to use `den.homes` instead of `den.hosts`:

```nix
  imports = [
    flake.homeModules.default
    inputs.den.den.homes.x86_64-linux.tocardland.mainModule
  ];
```

- [ ] **Step 5: Verify all hosts build**

Run: `nix flake check --no-build`
Expected: PASS — all hosts and home configurations evaluate without errors. The den mainModules are empty shells (no aspects configured yet), so they add no configuration.

If any build fails, debug by building individual hosts:
- `nixos-rebuild build --flake .#tocardstation --no-build`
- `nixos-rebuild build --flake .#tb-laptop --no-build`
- `darwin-rebuild build --flake .#remilabeyrie-kiro --no-build`

- [ ] **Step 6: Commit**

```bash
git add hosts/tocardstation/configuration.nix hosts/tb-laptop/configuration.nix hosts/remilabeyrie-kiro/darwin-configuration.nix hosts/tocardland/users/calops.nix
git commit -m "feat: wire den mainModules into existing host configurations"
```

---

### Task 5: Verify end-to-end with a trivial aspect

**Files:**
- Modify: `modules/den.nix`

To verify the scaffolding works end-to-end, add a trivial aspect that produces visible but harmless configuration. This validates that the den → host mainModule → nixosSystem pipeline is working.

- [ ] **Step 1: Add a trivial aspect to modules/den.nix**

Add a simple aspect that sets the hostname (using den's hostname battery) and a trivial system package:

```nix
{ inputs, den, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # ── NixOS hosts ──────────────────────────────────────────────
  den.hosts.x86_64-linux.tocardstation.users.calops = {};
  den.hosts.x86_64-linux.tb-laptop.users.calops = {};

  # ── Darwin hosts ─────────────────────────────────────────────
  den.hosts.aarch64-darwin.remilabeyrie-kiro.users.remilabeyrie = {};

  # ── Standalone home-manager ──────────────────────────────────
  den.homes.x86_64-linux.tocardland = {
    userName = "calops";
  };

  # ── Verification aspect ──────────────────────────────────────
  # This trivial aspect confirms the den pipeline is working.
  # Remove after scaffolding is verified.
  den.aspects.tocardstation = {
    includes = [ den.provides.hostname ];
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.hello ];
    };
  };
}
```

**Note:** The `den.aspects.tocardstation` entry extends the auto-generated aspect for the tocardstation host. The `includes = [ den.provides.hostname ]` battery sets `networking.hostName` from the host definition. However, since tocardstation's configuration.nix already sets `networking.hostName = "tocardstation"`, this may produce a duplicate definition warning. If so, remove the `networking.hostName` line from the host's `configuration.nix` or skip the hostname battery for now.

- [ ] **Step 2: Verify tocardstation builds with the aspect**

Run: `nix build .#nixosConfigurations.tocardstation.config.system.build.toplevel --dry-run`
Expected: SUCCESS — the build plan resolves. The `hello` package should appear in the system packages.

If there are conflicts with existing `networking.hostName`, either:
1. Remove `includes = [ den.provides.hostname ]` and keep just the `environment.systemPackages` line
2. Or remove `networking.hostName = "tocardstation"` from `hosts/tocardstation/configuration.nix`

- [ ] **Step 3: Remove the verification aspect**

Once verified, remove the `den.aspects.tocardstation` block from `modules/den.nix`, restoring it to the clean scaffolding state. The verification was just to confirm the pipeline works.

- [ ] **Step 4: Commit**

```bash
git add modules/den.nix
git commit -m "feat: verify den scaffolding with trivial aspect"
```

---

## Summary of what this achieves

After completing all tasks:

1. **Den is integrated** alongside blueprint without disrupting any existing configuration
2. **All hosts have a den aspect** (initially empty) that can be incrementally populated
3. **The den module system is accessible** via `inputs.den` in all host/user configurations
4. **No existing modules are modified** — only host configurations gain one extra import line each
5. **Future migration path** is clear: move configuration from `modules/nixos/*.nix` into dendritic aspects in `modules/den/` one at a time

## What to migrate next (not in this plan)

After scaffolding is complete, incremental migration steps could include:
- Move `networking.hostName` settings into den aspects (using `den.provides.hostname`)
- Move user declarations (`users.users.*`) into den aspects (using `den.provides.define-user`)
- Create shared aspects for common roles (graphical, audio, gaming, etc.)
- Migrate `modules/nixos/*.nix` into den aspects
- Eventually, when all config is in den aspects, switch to den-only flake outputs
