# Profile Class Design

## Problem

Profile enablement used `den.schema.host` submodule options with `mkIf` conditionals, causing infinite recursion. The `mkHostProfile` helper was broken and profile options (`host.profiles.*.enable`, `config.my.roles.*.enable`) were inconsistently named and scattered.

## Solution

Two new den classes — `defineOptions` and `setOptions` — that forward into the NixOS module system's `options` and `config` namespaces for nixos/homeManager/darwin.

### Class Definitions (in `modules/den.nix`)

```
defineOptions class → forwards to nixos.options, homeManager.options, darwin.options
setOptions class    → forwards to nixos.config, homeManager.config, darwin.config
```

Both registered via `den.ctx.user.includes`.

### Profile Module Pattern

Each profile module defines its own option and sets it when activated:

```nix
# modules/profiles/laptop.nix
den.default.defineOptions.profiles.laptop.enable = mkEnableOption "Laptop";

den.aspects.laptop = {
  setOptions.profiles.laptop.enable = true;
  includes = [ den.aspects.graphical den.aspects.audio ... ];
};
```

### Consumers

Any nixos/homeManager/darwin module reads `config.profiles.<name>.enable`.

### Profiles to implement

- `profiles/audio.nix` — audio (pipewire, mopidy)
- `profiles/gaming.nix` — gaming (steam, discord, mangohud)
- `profiles/graphical.nix` — graphical desktop (niri, browsers, etc.)
- `profiles/laptop.nix` — laptop (includes graphical + audio + bluetooth + printing + input)
- `profiles/virtualization.nix` — virtualization (waydroid, virtualbox)

### Changes

**`modules/den.nix`** — add `defineOptions` and `setOptions` classes

**`modules/profiles/*.nix`** — rewrite all 5 profile modules:
- Remove `mkHostProfile` usage
- Each defines its own `defineOptions.profiles.<name>.enable`
- Each creates a `den.aspects.<name>` with `setOptions` and `includes`
- `laptop.nix` includes graphical + audio + bluetooth + printing + input aspects
- `graphical.nix` includes all graphical program aspects
- `gaming.nix` includes discord + has nixos/homeManagerLinux config
- `audio.nix` includes mopidy + has nixos/homeManager config
- `virtualization.nix` includes waydroid/virtualbox nixos config

**`modules/hosts/tb-laptop/default.nix`** — remove `profiles.laptop.enable = true` (already includes `den.aspects.laptop`)

**`modules/hosts/tocardstation/default.nix`** — remove `profiles.desktop.enable = true` and `profiles.gaming.enable = true` (already includes `den.aspects.graphical` and `den.aspects.gaming`)

**`modules/programs/1password.nix`** — `host.profiles.graphical.enable` → `config.profiles.graphical.enable`

**`modules/home.nix`** — remove `config.my.roles.terminal.enable` references (terminal profile is legacy, bat/fzf/zellij always enabled)

**`modules/users/calops.nix`** — already cleaned (no `den.aspects.terminal`)

**`lib/default.nix`** — remove `mkHostProfile` helper

### Removed

- `mkHostProfile` from `lib/default.nix`
- `den.schema.host` profile options from host configs
- `config.my.roles.terminal.enable` references
