# tb-laptop Migration to Den Aspects

## Goal

Migrate the tb-laptop host configuration (and its shared role/user modules) from the current blueprint-based `my.roles.*` system into den aspects. This covers all hosts in scope, but tb-laptop is the first and serves as the reference pattern.

## Architecture

Everything becomes a den aspect. No plain NixOS/home-manager modules — all config goes into aspect files with `nixos` / `homeManager` / `darwin` class keys. For now, files are flat with comment-delimited sections; splitting happens later.

Hosts declare which role aspects they include. Role aspects have both `nixos` and `homeManager` keys. Den's context pipeline automatically propagates the `homeManager` portions to the host's users. No redundancy.

The user aspect (`calops`) only includes portable personal config (terminal preference, font sizes, etc.). Host-specific user stuff (monitor layouts, work config) lives in the host aspect or work aspects.

## Aspect Map

### `modules/den.nix`
- Imports `inputs.den.flakeModule`
- Sets `den.schema.user.classes = [ "homeManager" ]`
- No host/user declarations — each module declares its own

### `modules/base-nixos.nix`
- Aspect name: `base-nixos`
- Classes: `nixos` only
- Contains everything currently in `modules/nixos/default.nix`:
  - system.stateVersion, firmware, docker, fish, 1password, nh, locale, nix gc, nix-ld, console, networkmanager, i18n, ssh, acpid, gnupg agent, polkit, kernel sysctl, udisks2, stylix integration, nix-index
  - Also absorbs the unconditional parts of `modules/nixos/boot.nix` (systemd-boot, efi) and the graphical-conditional kmscon
  - Imports from `_common/` (colors, nix settings) directly
  - All in one file with comment sections, no submodules

### `modules/base-home.nix`
- Aspect name: `base-home`
- Classes: `homeManager` only
- Contains everything currently in `modules/home/default.nix` and `modules/home/config/default.nix`:
  - home.stateVersion, home-manager, gpg, dircolors, network-manager-applet, gnome-keyring, udiskie, xdg/mimeApps, session vars (NH_FLAKE, etc.), nix gc, systemd target fixes
  - my.configDir, my.isNixos, my.isDarwin, my.configType options
  - Imports from `_common/` and `_home/programs/` directly
  - All in one file with comment sections

### `modules/roles/graphical.nix`
- Aspect name: `graphical`
- Classes: `nixos` + `homeManager`
- `nixos`: WLR_NO_HARDWARE_CURSORS, NIXOS_OZONE_WL, niri, soteria, gdm/gnome, xserver, graphics, swaylock pam, xdg portal
- `homeManager`: font system (my.roles.graphical.fonts.*), monospace/serif/sansSerif/emoji/symbols fonts, font sizes, terminal choice, monitor config, installAllFonts, niriExtraConfig, packages (libnotify, slack, chrome, waypipe, wl-clipboard), zathura, clipman, stylix fonts/cursor config
- Note: the host-specific niriExtraConfig and monitor setup moves from the user aspect into the host aspect's `homeManager` key

### `modules/roles/audio.nix`
- Aspect name: `audio`
- Classes: `nixos` + `homeManager`
- `nixos`: pipewire (alsa, pulse, wireplumber, airplay)
- `homeManager`: pavucontrol, mpris-proxy

### `modules/roles/bluetooth.nix`
- Aspect name: `bluetooth`
- Classes: `nixos` only (blueman depends on graphical, handled via `mkIf` or parametric include)
- `nixos`: hardware.bluetooth, blueman (conditional on graphical)

### `modules/roles/printing.nix`
- Aspect name: `printing`
- Classes: `nixos` only
- `nixos`: sane, hplip, cups, avahi, scanner/lp groups for calops

### `modules/roles/terminal.nix`
- Aspect name: `terminal`
- Classes: `homeManager` only
- `homeManager`: jq and other CLI utilities

### `modules/roles/gaming.nix`
- Aspect name: `gaming`
- Classes: `homeManager` only
- `homeManager`: MangoHud config (with color palette), gaming packages (protonup-qt, lutris, steamcmd, steam-run, wine, winetricks)

### `modules/roles/nvidia.nix`
- Aspect name: `nvidia`
- Classes: `nixos` + `homeManager`
- From current `modules/nixos/nvidia.nix`
- Any home-manager env vars or configs related to nvidia

### `modules/hosts/tb-laptop.nix`
- Declares `den.hosts.x86_64-linux.tb-laptop.users.calops = {}`
- Aspect name: `tb-laptop` (auto-generated from host declaration, extended here)
- `includes = [ base-nixos base-home graphical audio bluetooth printing work-terabase terminal ]`
- `nixos` class: hardware-specific config
  - Intel graphics (modesetting, intel-media-driver, vpl-gpu-rt, LIBVA_DRIVER_NAME)
  - ThinkPad P14s hardware module import
  - `hardware.nix` import
  - `psmouse.synaptics_intertouch=1` kernel param
  - `linuxPackages_6_18` kernel pin
  - fstrim
  - swap device
  - NTFS support
  - `woeusb-ng`
  - `networking.hostName`, `timeZone`, keyboard layout
  - User declaration (`users.users.calops`)
  - `my.configDir`
- `homeManager` class: host-specific user overrides
  - Niri monitor/output config for tb-laptop's display
  - `installAllFonts = true`

### `modules/users/calops.nix`
- Aspect name: `calops` (auto-generated from user declaration, extended here)
- `includes = [ terminal base-home ]`
- `homeManager` class: portable personal config
  - Terminal preference (kitty)
  - Any personal program configs that are host-independent

### `modules/work/terabase.nix`
- Aspect name: `work-terabase`
- Classes: `homeManager` only
- `homeManager`: git identity override for `~/terabase/`, SSH key for Bitbucket, SSH match block, `teams-for-linux`

## Wiring

```
den.aspects.tb-laptop.includes = [
  base-nixos base-home graphical audio bluetooth printing work-terabase terminal
];
```

Den's context pipeline:
1. Host context: `tb-laptop` + includes → `nixos` class → NixOS config
2. User context: `calops` + includes → `homeManager` class → home-manager config
3. `work-terabase.homeManager` flows to calops automatically because the host includes it

## File Layout

```
modules/
  _common/              ← ignored by import-tree (kept for base-*.nix to import)
  _darwin/              ← ignored by import-tree
  _home/                ← ignored by import-tree
  den.nix               ← flakeModule + schema defaults only (no host/user declarations)
  base-nixos.nix        ← all shared NixOS defaults (flat, comment-sectioned)
  base-home.nix         ← all shared home defaults (flat, comment-sectioned)
  hosts/
    tb-laptop.nix       ← declares den.hosts + defines tb-laptop aspect
  users/
    calops.nix          ← defines calops user aspect (portable personal config)
  roles/
    graphical.nix       ← nixos + homeManager
    audio.nix           ← nixos + homeManager
    bluetooth.nix       ← nixos
    printing.nix        ← nixos
    terminal.nix        ← homeManager
    gaming.nix          ← homeManager
    nvidia.nix          ← nixos + homeManager
  work/
    terabase.nix        ← homeManager
```

Old `modules/nixos/` stays as `modules/_nixos/` (ignored) until fully replaced. `base-nixos.nix` may import from it temporarily if needed during incremental migration.

## What Changes in flake.nix

The den evaluation switches from `./modules/den.nix` to `(inputs.import-tree ./modules)` to auto-load the new directory structure. The `specialArgs.inputs` stays the same.

## What Changes in Host Configurations

`hosts/tb-laptop/configuration.nix` becomes minimal:
```nix
{ inputs, ... }:
{
  imports = [
    inputs.dendritic.den.hosts.x86_64-linux.tb-laptop.mainModule
  ];
}
```

`hosts/tb-laptop/hardware.nix` stays as-is (imported by the tb-laptop host aspect).

`hosts/tb-laptop/users/calops.nix` is emptied (user config moves to den aspects):
```nix
{ inputs, ... }:
{
  imports = [
    inputs.dendritic.den.homes.x86_64-linux.tocardland.mainModule
  ];
}
```
Wait — calops on tb-laptop is NOT a standalone home. The home-manager config comes through the nixosSystem via den's home-manager integration. So `hosts/tb-laptop/users/calops.nix` may not be needed at all, or becomes just an empty import of the den user module.

Actually, blueprint auto-discovers `hosts/<name>/users/<user>.nix` and wires them as homeConfigurations. We need to check if den's home-manager integration conflicts with blueprint's. For now, the user file stays but gets simplified.

## Scope for This Plan

- Migrate tb-laptop fully to den aspects
- Create the shared role aspects (graphical, audio, bluetooth, printing, terminal, gaming)
- Create base-nixos and base-home
- Create work-terabase aspect
- Create calops user aspect
- Other hosts (tocardstation, remilabeyrie-kiro, tocardland) remain as-is — they just need the den scaffolding updated to point at the new `import-tree` load

## Out of Scope

- Migrating tocardstation to aspects (next iteration)
- Migrating remilabeyrie-kiro to aspects (next iteration)
- Migrating tocardland to aspects (next iteration)
- Migrating individual home-manager programs (`modules/home/programs/`) into aspects
- Migrating the color system (`modules/common/colors/`) into a den aspect
- Removing the `_common/`, `_home/` directories (happens when all their content is migrated)
- Packages, devshells, formatter (stay in blueprint for now)
