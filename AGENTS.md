# AGENTS.md

## Project Overview

Personal Nix repository managing configurations for all machines, using the **den** (dendritic) aspect-oriented framework within a **flake-parts** flake.

## Architecture

### Core Principle: File Tree = Module System

Every `.nix` file under `modules/` is **automatically imported** via `import-tree`. There are no manual import lists. Adding a new `.nix` file anywhere in `modules/` makes it immediately available to the module system.

`flake.nix` is **auto-generated** by `flake-file` — each module declares its own flake inputs via `flake-file.inputs`, and `nix run .#write-flake` regenerates `flake.nix` from those scattered declarations. **Never edit `flake.nix` directly.**

### Den Framework

Den is an aspect-oriented, context-driven configuration framework. Instead of hosts pulling in modules, **features (aspects) are the primary unit**, and hosts compose them.

Key den concepts:

- **`den.hosts.<system>.<name>`** — declares a NixOS host with its users
- **`den.homes.<system>."user@host"`** — declares a standalone Home Manager config (no full OS)
- **`den.aspects.<name>`** — composable configuration units. Each aspect can contain `nixos`, `darwin`, `homeManager`, `homeManagerLinux`, `homeManagerDarwin` blocks
- **`includes`** — aspect composition (dependency chain). `den.aspects.laptop` includes `den.aspects.desktop`, which includes `den.aspects.graphical`, etc.
- **`den.aspects.<namespace>.provides.<name>`** — lazy/optional aspect definition; referenced via `den.aspects.<namespace>._.<name>`
- **`den._.forward`** — cross-platform forwarding (e.g., `homeManager` → `homeManagerLinux`/`homeManagerDarwin`)
- **`den.default.includes`** — applied to all hosts/users globally
- **`den.provides.*`** — built-in providers (hostname, define-user, inputs', self', primary-user, user-shell)

### Aspect Hierarchy

```
profiles/ (machine-type presets)
├── laptop       → desktop + logind lid settings
├── desktop      → graphical + audio + bluetooth + printing + input
├── gaming       → steam, gamescope, gamemode, lutris, openrgb + programs (mangohud, discord)
├── audio        → pipewire + mopidy
└── virtualization → waydroid + virtualbox

programs/ (individual app configs as lazy aspects)
├── Each program uses den.aspects.programs.provides.<name>
└── Referenced via den.aspects.programs._.<name>

hardware/ (hardware-specific configs as lazy aspects)
├── Each uses den.aspects.hardware.provides.<name>
└── Referenced via den.aspects.hardware._.<name>
```

### Profile Helper

`modules/profiles/_helpers.nix` exports `mkProfileAspect`, which creates a `profiles.<name>.enable` option across all platforms (nixos, homeManager, darwin) and sets it to `true` when the profile is included.

## Machines

| Host | Type | Key Aspects | Notes |
|------|------|-------------|-------|
| `tb-laptop` | NixOS x86\_64 | laptop + terabase work | ThinkPad P14s Gen5, Intel, LUKS |
| `tocardstation` | NixOS x86\_64 | desktop + gaming + nvidia + logitech + nuphy | Gaming desktop, Samsung 990 Pro 4TB, LUKS |
| `tocardland` | Home Manager only | calops user | Likely macOS, standalone home-manager |

## Directory Structure

```
modules/
├── den.nix              # Den framework setup (imports, schemas, defaults, caches)
├── outputs.nix          # Flake outputs (formatter, devShells, perSystem host discovery)
├── nix.nix              # Nix daemon settings (experimental features, trusted users)
├── nixos.nix            # Base NixOS config (boot, locale, docker, fish, gnupg)
├── darwin.nix           # nix-darwin base config (homebrew, fish, dock, finder)
├── home.nix             # Base home-manager config + hmPlatforms forwarder
├── colors.nix           # Catppuccin Mocha palette (asHex, asRgb, asCss, asGtkCss, asScss, asLua)
├── fonts.nix            # Font definitions (Aporetic Mono, Noto, Nerd Symbols)
├── stylix.nix           # Stylix theme engine (base16 from Catppuccin Mocha)
├── hosts/               # Per-machine configuration
│   ├── tb-laptop/       #   default.nix + _hardware.nix (auto-generated scan)
│   ├── tocardstation/   #   default.nix + _hardware.nix
│   └── tocardland/      #   default.nix
├── profiles/            # Machine-type presets (laptop, desktop, gaming, etc.)
├── programs/            # Individual program configurations (~30 programs)
├── hardware/            # Hardware-specific configs (nvidia, bluetooth, printing, etc.)
├── users/               # User definitions (calops = Remi Labeyrie)
└── work/                # Work-specific overlays (terabase)
```

## Key Conventions

- **Formatter**: `nixfmt-tree` (run via `nix fmt`)
- **Nix style**: 2-space indentation
- **Shell**: Fish is the primary shell on all machines
- **Editor**: Neovim (`$EDITOR`)
- **Compositor**: Niri (Wayland)
- **Bar/Panel**: Quickshell (QML-based, heavily customized at `modules/programs/quickshell/`)
- **Font**: Aporetic (custom Iosevka build)
- **Theme**: Catppuccin Mocha via Stylix
- **Locale**: French (`fr_FR`) with English UI (`en_US.UTF-8`), timezone `Europe/Paris`
- **Disk**: LUKS encryption on all NixOS machines
- **Nixpkgs**: follows `nixos-unstable`

## Common Operations

```bash
# Rebuild a host (e.g., tb-laptop)
sudo nixos-rebuild switch --flake .#tb-laptop

# Rebuild via nh (if available)
nh os switch .#tb-laptop

# Format all nix files
nix fmt

# Regenerate flake.nix after changing flake-file.inputs
nix run .#write-flake

# Update flake inputs
nix flake update

# Enter dev shell (sets up cachix substituters)
nix develop
```

## CI

- **ci.yml**: Builds all hosts on push to main
- **update.yml**: Daily cron updates flake inputs, builds all targets, creates/updates PR (draft if build fails)
- Caches to `calops.cachix.org`

## Adding a New Program

1. Create `modules/programs/<name>.nix`
2. Use `den.aspects.programs.provides.<name>` to define the aspect with `homeManager`, `nixos`, etc. blocks
3. If the program needs a flake input, add `flake-file.inputs.<name>.url = "..."` in the same file
4. Include the program in relevant profiles (e.g., add `den.aspects.programs._.<name>` to `den.aspects.graphical.includes`)
5. Run `nix run .#write-flake` to regenerate `flake.nix`

## Module Authoring Reference

### Program Aspect (`modules/programs/<name>.nix`)

Minimal skeleton:
```nix
{
  den.aspects.programs.provides.<name> = {
    # Optional: declare flake inputs this program needs
    # flake-file.inputs.<input>.url = "github:...";

    nixos = { pkgs, ... }: { ... };
    homeManagerLinux = { pkgs, inputs', colors, ... }: { ... };
    homeManagerDarwin = { ... }: { ... };
  };
}
```

- **Top-level binding**: `den.aspects.programs.provides.<name>` (not `programs._.<name>` — `._.` is the lazy reference path, `provides` is the definition point)
- **Reference from profiles**: `den.aspects.programs._.<name>` (den's `_` forwarding resolves `provides.<name>` lazily)
- **`inputs'`**: resolved flake inputs — available inside `nixos`/`homeManager*` blocks, NOT at the module top level (where it's just `inputs`)
- **`colors`**: Catppuccin Mocha palette, passed to `homeManager*` blocks. Methods: `.palette.asHex`, `.palette.asRgbIntTuple`, etc.
- **No registration needed**: `import-tree ./modules` auto-discovers every `.nix` file

### Profile Aspect (`modules/profiles/<name>.nix`)

Uses the `mkProfileAspect` helper which auto-creates `profiles.<name>.enable` options:
```nix
{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "<name>" {
  includes = [
    den.aspects.programs._.some-program
    # inline aspect blocks also work:
    # { nixos = { ... }; }
  ];
  nixos = { pkgs, lib, ... }: { ... };
  homeManagerLinux = { pkgs, inputs', colors, ... }: { ... };
}
```

### Adding a Flake Input

A program that needs a new flake input (e.g. a third-party Nix module) declares it in its own file:
```nix
{
  flake-file.inputs.foo.url = "github:owner/repo";
  flake-file.inputs.foo.inputs.nixpkgs.follows = "nixpkgs";

  den.aspects.programs.provides.foo = { ... };
}
```
Then run `nix run .#write-flake` to regenerate `flake.nix`. Never edit `flake.nix` by hand.

## Adding a New Host

1. Create `modules/hosts/<hostname>/default.nix`
2. Declare `den.hosts.<system>.<hostname>` with users and `configDir`
3. Declare `den.aspects.<hostname>` with the appropriate profile includes
4. Add `flake-file.inputs` for any new inputs if needed
5. Run `nix run .#write-flake`
