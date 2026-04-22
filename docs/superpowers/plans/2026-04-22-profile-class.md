# Profile Class Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `mkHostProfile`/`den.schema.host` with a `defineOptions`/`setOptions` class pair that leverages the NixOS module system's options/config separation.

**Architecture:** Two new den classes — `defineOptions` (forwards to `*.options`) and `setOptions` (forwards to `*.config`) — registered in `den.ctx.user.includes`. Each profile module defines its own option via `den.default.defineOptions` and sets it to true via `den.aspects.<name>.setOptions`.

**Tech Stack:** Nix, vic/den framework, dendritic module system

---

### Task 1: Add `defineOptions` and `setOptions` classes to `modules/den.nix`

**Files:**
- Modify: `modules/den.nix`

- [ ] **Step 1: Add the two class definitions and register them**

Add to `modules/den.nix`, inside the existing `let ... in` block or at the top level. The pattern follows `modules/nix.nix` exactly — using `den._.forward` with `fromClass`/`intoClass`/`intoPath`.

```nix
# In the let block, after existing bindings:
defineOptionsClass =
  { aspect-chain, ... }:
  den._.forward {
    each = [ "nixos" "homeManager" "darwin" ];
    fromClass = _: "defineOptions";
    intoClass = lib.id;
    intoPath = _: [ "options" ];
    fromAspect = _: lib.head aspect-chain;
    adaptArgs = lib.id;
  };

setOptionsClass =
  { aspect-chain, ... }:
  den._.forward {
    each = [ "nixos" "homeManager" "darwin" ];
    fromClass = _: "setOptions";
    intoClass = lib.id;
    intoPath = _: [ "config" ];
    fromAspect = _: lib.head aspect-chain;
    adaptArgs = lib.id;
  };
```

Then in the attrset body, extend the existing `den.ctx.user.includes`:

```nix
den.ctx.user.includes = [
  den._.mutual-provider
  defineOptionsClass
  setOptionsClass
];
```

- [ ] **Step 2: Verify the change**

Run: `nix run .#write-flake 2>&1 | tail -5`

The error should be the same or different — the classes are defined but not yet used.

---

### Task 2: Rewrite `modules/profiles/graphical.nix`

**Files:**
- Modify: `modules/profiles/graphical.nix`

- [ ] **Step 1: Replace `mkHostProfile` with direct aspect definition**

Replace the entire file content:

```nix
{ den, lib, ... }:
{
  den.default.defineOptions.profiles.graphical.enable = lib.mkEnableOption "Graphical";

  den.aspects.graphical = {
    setOptions.profiles.graphical.enable = true;

    includes = [
      den.aspects.fonts

      den.aspects.programs.niri
      den.aspects.programs.anyrun
      den.aspects.programs.zed
      den.aspects.programs.walker
      den.aspects.programs.sable
      den.aspects.programs.neovide
      den.aspects.programs.mpv
      den.aspects.programs.gtk
      den.aspects.programs.element
      den.aspects.programs.wezterm
      den.aspects.programs.quickshell
      den.aspects.programs.firefox
      den.aspects.programs.kitty
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        environment.sessionVariables = {
          WLR_NO_HARDWARE_CURSORS = "1";
          NIXOS_OZONE_WL = "1";
        };

        security.soteria.enable = true;

        services = {
          xserver.enable = true;
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
        };

        hardware.graphics.enable = true;
        security.pam.services.swaylock = { };

        services.kmscon = {
          enable = true;
          hwRender = true;
          useXkbConfig = true;
          fonts = [
            {
              name = "Terminess Nerd Font";
              package = pkgs.nerd-fonts.terminess-ttf;
            }
          ];
        };

        console = {
          font = "ter-124b";
          keyMap = lib.mkDefault "fr";
          packages = [ pkgs.terminus ];
          earlySetup = true;
        };
      };

    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        home.packages = [
          pkgs.libnotify
          pkgs.slack
        ];

        programs.zathura = {
          enable = true;
          options.font = config.stylix.fonts.monospace.name;
        };

        stylix = {
          cursor = {
            name = "catppuccin-mocha-peach-cursors";
            size = 32;
            package = pkgs.catppuccin-cursors;
          };
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              firefox = "firefox-beta.desktop";
            in
            {
              "text/html" = firefox;
              "x-scheme-handler/http" = firefox;
              "x-scheme-handler/https" = firefox;
              "x-scheme-handler/about" = firefox;
              "x-scheme-handler/unknown" = firefox;
              "application/pdf" = "org.pwmt.zathura.desktop";
              "text/plain" = "nvim.desktop";
            };
        };

        systemd.user.targets.tray.Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
        systemd.user.services.swayidle.Unit.After = lib.mkForce [ "graphical-session.target" ];
        systemd.user.services.udiskie.Unit.After = lib.mkForce [
          "graphical-session.target"
          "tray.target"
        ];
        systemd.user.services.network-manager-applet.Unit.After = lib.mkForce [
          "graphical-session.target"
          "tray.target"
        ];
      };

    homeManagerLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.google-chrome
          pkgs.waypipe
          pkgs.wl-clipboard
        ];

        services.clipman.enable = true;
      };
  };
}
```

- [ ] **Step 2: Verify**

Run: `nix run .#write-flake 2>&1 | tail -5`

---

### Task 3: Rewrite `modules/profiles/audio.nix`

**Files:**
- Modify: `modules/profiles/audio.nix`

- [ ] **Step 1: Replace `mkHostProfile` with direct aspect definition**

```nix
{ den, lib, ... }:
{
  den.default.defineOptions.profiles.audio.enable = lib.mkEnableOption "Audio";

  den.aspects.audio = {
    setOptions.profiles.audio.enable = true;

    includes = [
      den.aspects.programs.mopidy
    ];

    nixos =
      { ... }:
      {
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          wireplumber.enable = true;

          raopOpenFirewall = true;
          extraConfig.pipewire = {
            "10-airplay" = {
              "context.modules" = [
                { name = "libpipewire-module-raop-discover"; }
              ];
            };
          };
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.pavucontrol ];
        services.mpris-proxy.enable = true;
      };
  };
}
```

---

### Task 4: Rewrite `modules/profiles/gaming.nix`

**Files:**
- Modify: `modules/profiles/gaming.nix`

- [ ] **Step 1: Replace `mkHostProfile` with direct aspect definition**

```nix
{ den, colors, lib, ... }:
let
  palette = colors.palette.asHex;
in
{
  den.default.defineOptions.profiles.gaming.enable = lib.mkEnableOption "Gaming";

  den.aspects.gaming = {
    setOptions.profiles.gaming.enable = true;

    includes = [
      den.aspects.programs.discord
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        programs.gamemode.enable = true;
        programs.coolercontrol.enable = true;

        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          extraCompatPackages = [ pkgs.proton-ge-bin ];
        };

        programs.gamescope = {
          enable = true;
          capSysNice = true;
          args = [
            "--hdr-enabled"
            "--hdr-itm-enable"
            "--hide-cursor-delay=3000"
            "--fade-out-duration=200"
            "--xwayland-count=2"
          ];
        };

        hardware.graphics = {
          extraPackages = [ pkgs.mangohud ];
          extraPackages32 = [ pkgs.mangohud ];
        };

        hardware.xpadneo.enable = true;

        environment.systemPackages = [
          pkgs.protontricks
          pkgs.i2c-tools
        ];

        services.hardware.openrgb = {
          enable = true;
          motherboard = lib.mkDefault "intel";
        };
      };

    homeManagerLinux =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.protonup-qt
          pkgs.lutris
          pkgs.steamcmd
          pkgs.steam-run
          pkgs.wineWow64Packages.waylandFull
          pkgs.winetricks
        ];

        programs.mangohud = {
          enable = true;
          enableSessionWide = true;
        };

        stylix.targets.mangohud.enable = false;

        xdg.configFile."MangoHud/MangoHud.conf".text = # conf
          ''
            # Hidden by default
            no_display

            # Text
            font_size=14
            font_file=${inputs'.aporetic.packages.aporetic-sans-mono}/share/fonts/TTF/aporetic-sans-mono-normalregularupright.ttf
            text_outline
            text_color=${palette.text}

            # Layout
            horizontal
            hud_compact
            position=top-left
            background_color=${palette.base}
            background_alpha=0
            round_corners=0

            # Bindings
            toggle_hud=Shift_R+F12
            toggle_preset=Shift_R+F10

            # Clock
            time
            time_no_label

            # GPU
            gpu_stats
            gpu_temp
            gpu_load_change
            gpu_load_value=50,90
            gpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
            gpu_text=GPU
            gpu_color=${palette.green}

            # CPU
            cpu_stats
            cpu_temp
            cpu_load_change
            cpu_load_value=50,90
            cpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
            cpu_color=${palette.teal}
            cpu_text=CPU
            core_load_change

            # FPS
            fps
            engine_color=${palette.purple}

            # Graph
            frame_timing
            frametime_color=${palette.sand}
          '';
      };
  };
}
```

**Note:** The original gaming.nix had `homeManagerLinux` with `colors` and `inputs'` args. Since this is now a top-level aspect (not wrapped in `mkHostProfile`), `colors` comes from module args and `inputs'` from den's provides.

---

### Task 5: Rewrite `modules/profiles/laptop.nix`

**Files:**
- Modify: `modules/profiles/laptop.nix`

- [ ] **Step 1: Replace `mkHostProfile` with direct aspect definition**

```nix
{ den, lib, ... }:
{
  den.default.defineOptions.profiles.laptop.enable = lib.mkEnableOption "Laptop";

  den.aspects.laptop = {
    setOptions.profiles.laptop.enable = true;

    includes = [
      den.aspects.graphical
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.input.base
    ];
  };
}
```

---

### Task 6: Rewrite `modules/profiles/virtualization.nix`

**Files:**
- Modify: `modules/profiles/virtualization.nix`

- [ ] **Step 1: Replace `mkHostProfile` with direct aspect definition**

```nix
{ den, lib, ... }:
{
  den.default.defineOptions.profiles.virtualization.enable = lib.mkEnableOption "Virtualization";

  den.aspects.virtualization = {
    setOptions.profiles.virtualization.enable = true;

    nixos = {
      virtualisation.waydroid.enable = true;
      virtualisation.virtualbox = {
        host.enable = true;
        host.enableExtensionPack = true;
      };
      boot.blacklistedKernelModules = [ "kvm-intel" ];
    };
  };
}
```

---

### Task 7: Remove `mkHostProfile` from `lib/default.nix`

**Files:**
- Modify: `lib/default.nix`

- [ ] **Step 1: Delete the `mkHostProfile` function**

Remove lines 3-15 (the `mkHostProfile` definition). Keep `mkGraphicalSessionService` and `replaceTrayIcons`.

---

### Task 8: Remove dead profile options from host configs

**Files:**
- Modify: `modules/hosts/tb-laptop/default.nix`
- Modify: `modules/hosts/tocardstation/default.nix`

- [ ] **Step 1: Remove `profiles.laptop.enable = true` from tb-laptop**

In `modules/hosts/tb-laptop/default.nix`, remove the `profiles.laptop.enable = true;` line. The host already includes `den.aspects.laptop` via `den.aspects.tb-laptop.includes`.

- [ ] **Step 2: Remove `profiles.desktop.enable` and `profiles.gaming.enable` from tocardstation**

In `modules/hosts/tocardstation/default.nix`, remove the `profiles.desktop.enable = true;` and `profiles.gaming.enable = true;` lines. The host already includes `den.aspects.graphical` and `den.aspects.gaming` via `den.aspects.tocardstation.includes`.

---

### Task 9: Update consumer: `modules/programs/1password.nix`

**Files:**
- Modify: `modules/programs/1password.nix`

- [ ] **Step 1: Replace `host.profiles.graphical.enable` with `config.profiles.graphical.enable`**

In the `nixos` block (lines 43-52), change:
```nix
      nixos =
        { host, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = host.profiles.graphical.enable;
          environment.etc."1password/custom_allowed_browsers" = lib.mkIf host.profiles.graphical.enable {
```
to:
```nix
      nixos =
        { config, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = config.profiles.graphical.enable;
          environment.etc."1password/custom_allowed_browsers" = lib.mkIf config.profiles.graphical.enable {
```

In the `darwin` block (lines 54-57), change:
```nix
      darwin = {
        programs._1password.enable = true;
        programs._1password-gui.enable = host.profiles.graphical.enable;
      };
```
to:
```nix
      darwin =
        { config, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = config.profiles.graphical.enable;
        };
```

Also change the top-level aspect function signature from `{ host, ... }:` to not take `host` at all, since it's no longer needed.

---

### Task 10: Remove legacy `config.my.roles.terminal.enable` from `modules/home.nix`

**Files:**
- Modify: `modules/home.nix`

- [ ] **Step 1: Remove `config.my.roles.terminal.enable` conditions**

In `modules/home.nix`, the `homeManager` block references `config.my.roles.terminal.enable` three times (lines 82, 90, 96, 103). Since the terminal profile is legacy and these programs should always be enabled, replace:

- `programs.btop.enable = config.my.roles.terminal.enable;` → `programs.btop.enable = true;` (or just remove the `enable` line since it defaults to false and needs explicit enable)
- `programs.direnv.enable = config.my.roles.terminal.enable;` → `programs.direnv.enable = true;`
- `programs.eza.enable = config.my.roles.terminal.enable;` → `programs.eza.enable = true;`
- `programs.zoxide.enable = config.my.roles.terminal.enable;` → `programs.zoxide.enable = true;`

Actually, since these are inside the `homeManager` block which is always included, and `enable = true` is the default intent, just set them all to `true`:

```nix
            programs.btop = {
              enable = true;
              package = pkgs.btop.override { cudaSupport = true; };
              settings = {
                theme_background = false;
              };
            };

            programs.direnv = {
              enable = true;
              nix-direnv.enable = true;
              config.global.hide_env_diff = true;
            };

            programs.eza = {
              enable = true;
              enableFishIntegration = false;
              icons = "auto";
              git = true;
            };

            programs.zoxide = {
              enable = true;
              enableFishIntegration = true;
            };
```

Also remove the `config` argument from the destructuring if it's no longer used elsewhere (check if `config.stylix` is still used — it is, in the zathura block inside graphical.nix, not here). In this file `config` is still used for `config.my.roles.terminal.enable` only, so after removal it can be dropped from the function args... but wait, check if `config` is used elsewhere in this block. Looking at line 53: `config = { ... }` — that's a different `config`. The outer `config` parameter on line 47 is only used for `config.my.roles.terminal.enable`. Remove it from the destructuring.

---

### Task 11: Verify the build

- [ ] **Step 1: Run `nix run .#write-flake` and verify**

Run: `nix run .#write-flake 2>&1 | tail -25`

Expected: either success or a new unrelated error (not profile-related).
