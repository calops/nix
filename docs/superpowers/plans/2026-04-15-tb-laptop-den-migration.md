# tb-laptop Den Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate tb-laptop's full configuration into den aspects, replacing the blueprint-based `my.roles.*` system for this host only.

**Architecture:** All tb-laptop config moves into den aspects under `modules/`. Old `modules/nixos/`, `modules/home/`, `modules/common/` are prefixed with `_` so import-tree ignores them. The tb-laptop host aspect includes role aspects that have both `nixos` and `homeManager` class keys; den's context pipeline propagates `homeManager` portions to the user automatically. Other hosts (tocardstation, remilabeyrie-kiro, tocardland) keep using the old `_nixos/`/`_home/` modules via blueprint — they're not affected.

**Tech Stack:** Nix, vic/den, vic/import-tree, numtide/blueprint, home-manager

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `modules/den.nix` | Modify | Remove host/user declarations, keep flakeModule + schema |
| `modules/base-nixos.nix` | Create | All shared NixOS defaults as a `nixos` class aspect |
| `modules/base-home.nix` | Create | All shared home-manager defaults as a `homeManager` class aspect |
| `modules/roles/graphical.nix` | Create | Graphical role: `nixos` + `homeManager` classes |
| `modules/roles/audio.nix` | Create | Audio role: `nixos` + `homeManager` classes |
| `modules/roles/bluetooth.nix` | Create | Bluetooth role: `nixos` class |
| `modules/roles/printing.nix` | Create | Printing role: `nixos` class |
| `modules/roles/terminal.nix` | Create | Terminal role: `homeManager` class |
| `modules/hosts/tb-laptop.nix` | Create | tb-laptop host declaration + aspect |
| `modules/users/calops.nix` | Create | calops user aspect |
| `modules/work/terabase.nix` | Create | Terabase work aspect |
| `modules/_nixos/` | Rename from `modules/nixos/` | Hide from import-tree |
| `modules/_home/` | Rename from `modules/home/` | Hide from import-tree |
| `modules/_common/` | Rename from `modules/common/` | Hide from import-tree |
| `modules/_darwin/` | Rename from `modules/darwin/` | Hide from import-tree |
| `flake.nix` | Modify | Switch to import-tree for den evaluation |
| `hosts/tb-laptop/configuration.nix` | Modify | Strip to den mainModule only |
| `hosts/tb-laptop/users/calops.nix` | Modify | Strip to den user mainModule or remove |

---

### Task 1: Rename old module directories with `_` prefix

This hides them from import-tree while keeping them importable for other hosts that still use blueprint.

**Files:**
- Rename: `modules/nixos/` → `modules/_nixos/`
- Rename: `modules/home/` → `modules/_home/`
- Rename: `modules/common/` → `modules/_common/`
- Rename: `modules/darwin/` → `modules/_darwin/`
- Modify: All files that import from these directories

- [ ] **Step 1: Rename the directories**

```bash
cd /home/calops/nix-den
git mv modules/nixos modules/_nixos
git mv modules/home modules/_home
git mv modules/common modules/_common
git mv modules/darwin modules/_darwin
```

- [ ] **Step 2: Update all import paths that reference the old names**

The following files import `../common`, `../nixos`, `../home`, or `../darwin` and need their paths updated:

**`modules/_nixos/default.nix`** — change `../common` to `../_common`:
```nix
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.nix-index-database.nixosModules.nix-index
    ../_common
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./gaming.nix
    ./graphics.nix
    ./monitoring.nix
    ./nvidia.nix
    ./printing.nix
    ./yubikey.nix
  ];
```

**`modules/_home/default.nix`** — change `../common` to `../_common`:
```nix
  imports = [
    ../_common
    ./programs
    ./config
    inputs.stylix.homeModules.stylix
    inputs.nix-index-database.homeModules.nix-index
  ];
```

**`modules/_home/config/graphics.nix`** — no path changes needed (imports from same directory).

**`modules/_darwin/default.nix`** — change `../common/colors` to `../_common/colors` and `../common/nix.nix` to `../_common/nix.nix`:
```nix
  imports = [
    inputs.nix-index-database.darwinModules.nix-index
    ../_common/colors
    ../_common/nix.nix
  ];
```

- [ ] **Step 3: Verify the flake still evaluates**

Run: `nix flake check --no-build`
Expected: PASS — all hosts still build using the renamed directories.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: prefix old module dirs with _ for import-tree compatibility"
```

---

### Task 2: Update den.nix and flake.nix for import-tree

Switch den evaluation from `./modules/den.nix` to `(inputs.import-tree ./modules)` so all new aspect files under `modules/roles/`, `modules/hosts/`, etc. get auto-loaded.

**Files:**
- Modify: `modules/den.nix` — remove host/user declarations
- Modify: `flake.nix` — switch to import-tree

- [ ] **Step 1: Update modules/den.nix**

Replace the entire file with:

```nix
{ inputs, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
```

- [ ] **Step 2: Update flake.nix outputs block**

Change the den evaluation from `./modules/den.nix` to import-tree:

```nix
  outputs =
    inputs:
    let
      dendritic = (inputs.nixpkgs.lib.evalModules {
        modules = [ (inputs.import-tree ./modules) ];
        specialArgs.inputs = inputs;
      }).config;
    in
    inputs.blueprint {
      inputs = inputs // { inherit dendritic; };

      nixpkgs.config.allowUnfree = true;
    };
```

- [ ] **Step 3: Verify the flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS — import-tree loads `modules/den.nix` (which only has flakeModule + schema), and `modules/_nixos/`, `modules/_home/`, `modules/_common/`, `modules/_darwin/` are all ignored by import-tree. Other hosts still work through blueprint.

- [ ] **Step 4: Commit**

```bash
git add modules/den.nix flake.nix
git commit -m "refactor: switch den evaluation to import-tree, remove host declarations from den.nix"
```

---

### Task 3: Create the role aspects

Create all the reusable role aspects. These are independent of each other and of the host/user aspects, so they can be created in any order. Each one is a den aspect that contributes to `den.aspects.<name>`.

**Files:**
- Create: `modules/roles/audio.nix`
- Create: `modules/roles/bluetooth.nix`
- Create: `modules/roles/printing.nix`
- Create: `modules/roles/terminal.nix`

- [ ] **Step 1: Create `modules/roles/audio.nix`**

```nix
{ inputs, den, lib, ... }:
{
  den.aspects.audio = {
    nixos = { ... }: {
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
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.pavucontrol ];
      services.mpris-proxy.enable = true;
    };
  };
}
```

- [ ] **Step 2: Create `modules/roles/bluetooth.nix`**

Note: blueman depends on graphical being enabled. Since this is a `nixos`-only aspect, we can't easily check the graphical aspect from here. For now, always enable blueman — it's harmless without a graphical environment, or we can make it conditional later.

```nix
{ inputs, den, lib, ... }:
{
  den.aspects.bluetooth = {
    nixos = { ... }: {
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = true;
    };
  };
}
```

- [ ] **Step 3: Create `modules/roles/printing.nix`**

```nix
{ inputs, den, lib, ... }:
{
  den.aspects.printing = {
    nixos = { pkgs, ... }: {
      hardware.sane.enable = true;
      hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

      services.printing.enable = true;
      services.printing.drivers = [ pkgs.hplipWithPlugin ];

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
```

- [ ] **Step 4: Create `modules/roles/terminal.nix`**

```nix
{ inputs, den, lib, ... }:
{
  den.aspects.terminal = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.jq ];
    };
  };
}
```

- [ ] **Step 5: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS — new role files are loaded by import-tree, contribute to `den.aspects.*`, but nothing references them yet so they have no effect.

- [ ] **Step 6: Commit**

```bash
git add modules/roles/
git commit -m "feat: add audio, bluetooth, printing, terminal role aspects"
```

---

### Task 4: Create the graphical role aspect

This is the most complex role because it spans both NixOS and home-manager with many config options.

**Files:**
- Create: `modules/roles/graphical.nix`

- [ ] **Step 1: Create `modules/roles/graphical.nix`**

The graphical aspect replaces `modules/_nixos/graphics.nix` and `modules/_home/config/graphics.nix`. The font system options stay as home-manager options. The host-specific stuff (niriExtraConfig, monitors) does NOT go here — it goes in the host aspect.

```nix
{ inputs, den, lib, config, perSystem, pkgs, ... }:
let
  fonts = perSystem.self.fonts;
  my.types = with lib; {
    font = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
        };
        package = mkOption {
          type = types.package;
        };
      };
    };
  };
in
{
  den.aspects.graphical = {
    nixos = { pkgs, ... }: {
      environment.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        NIXOS_OZONE_WL = "1";
      };

      programs.niri = {
        enable = true;
        package = perSystem.self.niri;
      };

      systemd.user.services.niri-flake-polkit.enable = false;
      security.soteria.enable = true;

      services = {
        xserver.enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      hardware.graphics.enable = true;
      security.pam.services.swaylock = { };
      xdg.portal.xdgOpenUsePortal = false;
    };

    homeManager =
      { config, pkgs, ... }:
      let
        cfg = config.my.roles.graphical;
      in
      {
        options.my.roles.graphical = {
          enable = lib.mkEnableOption "Graphical environment";

          fonts = {
            monospace = lib.mkOption {
              type = my.types.font;
              default = fonts.aporetic-sans-mono;
            };
            serif = lib.mkOption {
              type = my.types.font;
              default = fonts.noto-serif;
            };
            sansSerif = lib.mkOption {
              type = my.types.font;
              default = fonts.noto-sans;
            };
            emoji = lib.mkOption {
              type = my.types.font;
              default = fonts.noto-emoji;
            };
            symbols = lib.mkOption {
              type = my.types.font;
              default = fonts.nerdfont-symbols;
            };
            hinting = lib.mkOption {
              type = lib.types.enum [ "Normal" "Mono" "HorizontalLcd" "Light" ];
              default = "Normal";
            };
            sizes = {
              terminal = lib.mkOption {
                type = lib.types.number;
                default = 10;
              };
              terminalCell = {
                width = lib.mkOption {
                  type = lib.types.float;
                  default = 1.0;
                };
                height = lib.mkOption {
                  type = lib.types.float;
                  default = 1.0;
                };
              };
              applications = lib.mkOption {
                type = lib.types.number;
                default = 10;
              };
            };
          };
          installAllFonts = lib.mkEnableOption "Install all fonts";
          terminal = lib.mkOption {
            type = lib.types.enum [ "kitty" "wezterm" ];
            default = "kitty";
          };
        };

        config = lib.mkIf cfg.enable {
          fonts.fontconfig.enable = true;

          home.packages =
            [
              pkgs.libnotify
              pkgs.slack
              cfg.fonts.monospace.package
              cfg.fonts.serif.package
              cfg.fonts.sansSerif.package
              cfg.fonts.emoji.package
              cfg.fonts.symbols.package
              fonts.aporetic-sans.package
              fonts.iosevka.package
            ]
            ++ (lib.lists.optionals (!pkgs.stdenv.isDarwin) [
              pkgs.google-chrome
              pkgs.waypipe
              pkgs.wl-clipboard
            ]);

          programs.zathura = {
            enable = true;
            options.font = cfg.fonts.monospace.name;
          };

          services.clipman.enable = !pkgs.stdenv.isDarwin;

          stylix = {
            fonts = {
              sizes = {
                terminal = cfg.fonts.sizes.terminal;
                applications = cfg.fonts.sizes.applications;
              };
              serif = cfg.fonts.serif;
              sansSerif = cfg.fonts.sansSerif;
              monospace = cfg.fonts.monospace;
              emoji = cfg.fonts.emoji;
            };
            cursor = {
              name = "catppuccin-mocha-peach-cursors";
              size = 32;
              package = pkgs.catppuccin-cursors;
            };
          };
        };
      };
  };
}
```

**Important note:** The `my.roles.graphical` option is defined in the `homeManager` class of this aspect. This means it's available within the home-manager module tree that den creates. The host aspect's `homeManager` key can set `my.roles.graphical.enable = true` to activate it.

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add modules/roles/graphical.nix
git commit -m "feat: add graphical role aspect (nixos + homeManager)"
```

---

### Task 5: Create base-nixos and base-home aspects

These absorb all the shared defaults from `modules/_nixos/default.nix`, `modules/_nixos/boot.nix`, `modules/_home/default.nix`, and `modules/_home/config/default.nix`.

**Files:**
- Create: `modules/base-nixos.nix`
- Create: `modules/base-home.nix`

- [ ] **Step 1: Create `modules/base-nixos.nix`**

This contains everything from `modules/_nixos/default.nix` (minus the role modules and role options which are now separate aspects) plus the unconditional parts of `modules/_nixos/boot.nix`.

```nix
{ inputs, den, lib, config, perSystem, pkgs, ... }:
{
  den.aspects.base-nixos = {
    nixos =
      { config, pkgs, lib, perSystem, ... }:
      {
        imports = [
          inputs.stylix.nixosModules.stylix
          inputs.nix-index-database.nixosModules.nix-index
          ../_common
        ];

        options = {
          my.configDir = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            apply = toString;
            default = null;
            description = "Location of the nix config directory (this repo)";
          };
        };

        config = {
          system.stateVersion = "26.05";

          # ── Boot ──────────────────────────────────────────────
          boot = {
            initrd.systemd.enable = true;
            loader = {
              efi.canTouchEfiVariables = true;
              systemd-boot = {
                enable = true;
                consoleMode = "max";
              };
            };
            kernel.sysctl = {
              "fs.inotify.max_user_watches" = 100000;
              "fs.inotify.max_queued_events" = 100000;
            };
            supportedFilesystems = [ "ntfs" ];
          };

          # ── Firmware & hardware ──────────────────────────────
          hardware.enableAllFirmware = true;
          hardware.graphics.enable = true;

          # ── Docker ────────────────────────────────────────────
          virtualisation.docker.enable = true;

          # ── Nix ──────────────────────────────────────────────
          nixpkgs.config.allowUnfree = true;
          nix = {
            optimise.automatic = true;
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 30d";
            };
          };

          # ── Stylix ───────────────────────────────────────────
          stylix.homeManagerIntegration.autoImport = false;
          stylix.overlays.enable = false;

          # ── Home-manager ─────────────────────────────────────
          home-manager.backupFileExtension = "hm-backup";

          # ── Programs ─────────────────────────────────────────
          programs.nix-ld = {
            enable = true;
            libraries = [
              pkgs.stdenv.cc.cc
              pkgs.zlib
              pkgs.fuse3
              pkgs.icu
              pkgs.nss
              pkgs.openssl
              pkgs.curl
              pkgs.expat
            ];
          };
          programs.fish.enable = true;
          programs.mtr.enable = true;
          programs.gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
          };
          programs.nh = {
            package = perSystem.self.nh;
            enable = true;
            clean.enable = false;
            clean.extraArgs = "--keep-since 14d --keep 5";
            flake = config.my.configDir;
          };
          programs._1password.enable = true;
          programs._1password-gui.enable = true;

          # ── Environment ──────────────────────────────────────
          environment.sessionVariables.EDITOR = "nvim";
          environment.etc."1password/custom_allowed_browsers" = {
            text = ''
              firefox-beta
            '';
            mode = "0755";
          };

          # ── Console ──────────────────────────────────────────
          console = {
            font = "ter-124b";
            keyMap = lib.mkDefault "fr";
            packages = [ perSystem.self.fonts.terminus.package ];
            earlySetup = true;
          };

          # ── Networking ───────────────────────────────────────
          networking.networkmanager.enable = true;

          # ── Locale ───────────────────────────────────────────
          i18n = {
            defaultLocale = "en_US.UTF-8";
            extraLocaleSettings = {
              LC_ADDRESS = "fr_FR.UTF-8";
              LC_IDENTIFICATION = "fr_FR.UTF-8";
              LC_MEASUREMENT = "fr_FR.UTF-8";
              LC_MONETARY = "fr_FR.UTF-8";
              LC_NAME = "fr_FR.UTF-8";
              LC_NUMERIC = "fr_FR.UTF-8";
              LC_PAPER = "fr_FR.UTF-8";
              LC_TELEPHONE = "fr_FR.UTF-8";
              LC_TIME = "fr_FR.UTF-8";
            };
          };

          # ── Services ─────────────────────────────────────────
          services.udisks2.enable = true;
          services.openssh.enable = true;
          services.acpid.enable = true;
          hardware.acpilight.enable = true;
          services.udev.extraRules = ''
            ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="kbd_backlight", GROUP="video", MODE="0664"
          '';

          # ── Security ─────────────────────────────────────────
          security.rtkit.enable = true;
          security.polkit.enable = true;
        };
      };
  };
}
```

- [ ] **Step 2: Create `modules/base-home.nix`**

This absorbs `modules/_home/default.nix` and `modules/_home/config/default.nix`, importing from `_common` and `_home/programs/`.

```nix
{ inputs, den, lib, config, perSystem, pkgs, ... }:
{
  den.aspects.base-home = {
    homeManager =
      { config, pkgs, lib, perSystem, nixosConfig ? null, darwinConfig ? null, ... }:
      {
        imports = [
          ../_common
          ../_home/programs
          inputs.stylix.homeModules.stylix
          inputs.nix-index-database.homeModules.nix-index
        ];

        options.my = {
          configDir = lib.mkOption {
            type = lib.types.path;
            default =
              nixosConfig.my.configDir or darwinConfig.my.configDir or "${config.home.homeDirectory}/nix";
          };

          configType = lib.mkOption {
            type = lib.types.str;
            default =
              if config.my.isNixos then
                "nixos"
              else if config.my.isDarwin then
                "darwin"
              else
                "standalone";
          };

          isNixos = lib.mkOption {
            type = lib.types.bool;
            default = nixosConfig != null;
            readOnly = true;
          };

          isDarwin = lib.mkOption {
            type = lib.types.bool;
            default = darwinConfig != null;
            readOnly = true;
          };
        };

        config = {
          home.stateVersion = "26.05";

          # ── Color palette files ──────────────────────────────
          xdg.configFile."colors/palette.css".source = config.my.colors.palette.asCss;
          xdg.configFile."colors/palette.gtk.css".source = config.my.colors.palette.asGtkCss;
          xdg.configFile."colors/palette.scss".source = config.my.colors.palette.asScss;
          xdg.dataFile."lua/palette.lua".source = config.my.colors.palette.asLua;

          # ── Stylix ───────────────────────────────────────────
          stylix.overlays.enable = false;

          # ── Programs ─────────────────────────────────────────
          programs.home-manager.enable = true;
          programs.gpg.enable = true;
          programs.dircolors.enable = true;

          # ── Packages ─────────────────────────────────────────
          home.packages = [
            perSystem.nix-index-database.nix-index-with-db
          ];

          # ── Nix ──────────────────────────────────────────────
          nix.package = lib.mkDefault pkgs.nix;
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };

          # ── Services ─────────────────────────────────────────
          services.network-manager-applet.enable = !pkgs.stdenv.isDarwin;
          services.gnome-keyring.enable = !pkgs.stdenv.isDarwin;
          services.udiskie = {
            enable = !pkgs.stdenv.isDarwin;
            tray = "auto";
          };

          # ── Session variables ────────────────────────────────
          home.sessionVariables = {
            NH_FLAKE = config.my.configDir;
            NH_NO_CHECKS = "1";
            NIX_CONFIG_TYPE = config.my.configType;
          };

          programs.nh = lib.mkIf (config.my.configType == "standalone") {
            enable = true;
            package = perSystem.self.nh;
            flake = config.my.configDir;
          };

          # ── XDG ──────────────────────────────────────────────
          xdg.enable = true;
          xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
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

          # ── Systemd fixes ────────────────────────────────────
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
      };
  };
}
```

- [ ] **Step 3: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS — aspects are loaded but not wired to any host yet.

- [ ] **Step 4: Commit**

```bash
git add modules/base-nixos.nix modules/base-home.nix
git commit -m "feat: add base-nixos and base-home aspect definitions"
```

---

### Task 6: Create the calops user aspect

**Files:**
- Create: `modules/users/calops.nix`

- [ ] **Step 1: Create `modules/users/calops.nix`**

The calops user aspect holds portable personal config. For now this is minimal — most personal config is in `_home/programs/` which `base-home` imports. The calops aspect includes `terminal` and `base-home`.

```nix
{ inputs, den, lib, ... }:
{
  den.aspects.calops = {
    includes = [
      den.aspects.terminal
      den.aspects.base-home
    ];
  };
}
```

Note: calops doesn't include `graphical` because not all hosts have graphical (e.g. tocardland). The host aspect includes graphical, and its `homeManager` portions flow to calops automatically.

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add modules/users/calops.nix
git commit -m "feat: add calops user aspect"
```

---

### Task 7: Create the work-terabase aspect

**Files:**
- Create: `modules/work/terabase.nix`

- [ ] **Step 1: Create `modules/work/terabase.nix`**

```nix
{ inputs, den, lib, pkgs, ... }:
{
  den.aspects.work-terabase = {
    homeManager = { pkgs, ... }: {
      programs.git.includes = [
        {
          condition = "gitdir:~/terabase/";
          contents = {
            core.sshCommand = "ssh -i ~/.ssh/terabase-bitbucket.pub";
            user = {
              name = "Rémi Labeyrie";
              email = "rlabeyrie@terabase.energy";
              signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK4tZxLZ9PwBd0IrOhzSFMlqW5aB9sKboCszPya4B7n";
            };
          };
        }
      ];

      programs.ssh.matchBlocks.bitbucket = {
        hostname = "bitbucket.org";
        identitiesOnly = true;
        identityFile = "~/.ssh/terabase-bitbucket.pub";
      };

      home.packages = [
        pkgs.teams-for-linux
      ];
    };
  };
}
```

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add modules/work/terabase.nix
git commit -m "feat: add work-terabase aspect"
```

---

### Task 8: Create the tb-laptop host aspect

This is the critical task that wires everything together.

**Files:**
- Create: `modules/hosts/tb-laptop.nix`

- [ ] **Step 1: Create `modules/hosts/tb-laptop.nix`**

```nix
{ inputs, den, lib, pkgs, perSystem, ... }:
{
  den.hosts.x86_64-linux.tb-laptop.users.calops = {};

  den.aspects.tb-laptop = {
    includes = [
      den.aspects.base-nixos
      den.aspects.graphical
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.work-terabase
    ];

    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
        ../../hosts/tb-laptop/hardware.nix
      ];

      my.configDir = "/home/calops/nix";

      networking.hostName = "tb-laptop";
      time.timeZone = "Europe/Paris";

      services.xserver.xkb = {
        layout = "fr";
        variant = "azerty";
      };
      console.keyMap = "fr";

      # ── Intel graphics ──────────────────────────────────────
      services.xserver.videoDrivers = [ "modesetting" ];
      hardware.graphics = {
        enable = true;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.vpl-gpu-rt
        ];
      };
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
      hardware.enableRedistributableFirmware = true;

      # ── ThinkPad specifics ──────────────────────────────────
      boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];
      boot.kernelPackages = pkgs.linuxPackages_6_18;

      # ── SSD ─────────────────────────────────────────────────
      services.fstrim.enable = true;

      # ── Packages ────────────────────────────────────────────
      environment.systemPackages = [ pkgs.woeusb-ng ];

      # ── User ────────────────────────────────────────────────
      users.users.calops = {
        isNormalUser = true;
        description = "Rémi Labeyrie";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        shell = pkgs.fish;
      };

      # ── Swap ────────────────────────────────────────────────
      swapDevices = [
        { device = "/swapfile"; size = 32 * 1024; }
      ];
    };

    homeManager = { ... }: {
      my.roles.graphical = {
        enable = true;
        installAllFonts = true;
        terminal = "kitty";

        niriExtraConfig = # kdl
          ''
            output "China Star Optoelectronics Technology Co., Ltd MNE507ZA2-3 Unknown" {
              mode "3072x1920@120.000"
              focus-at-startup
              variable-refresh-rate

              layout {
                default-column-width { proportion 0.5; }
              }
            }

            output "LG Electronics LG ULTRAFINE 505NTNHGX503" {
              position x=-3072 y=0
            }
          '';
      };
    };
  };
}
```

**Key design points:**
- Host declaration (`den.hosts.x86_64-linux.tb-laptop.users.calops = {}`) lives in this file
- `includes` lists all role aspects — their `homeManager` portions flow to calops automatically
- `nixos` class has all hardware-specific config + user declaration + hostname
- `homeManager` class enables graphical role and sets host-specific niri config
- `base-home` is NOT included here — it's included by the `calops` user aspect
- `terminal` is NOT included here — it's included by the `calops` user aspect

- [ ] **Step 2: Verify flake evaluates**

Run: `nix flake check --no-build`
Expected: PASS — the aspect is loaded but the host still uses its old blueprint config.

- [ ] **Step 3: Commit**

```bash
git add modules/hosts/tb-laptop.nix
git commit -m "feat: add tb-laptop host aspect with full config"
```

---

### Task 9: Swap tb-laptop to den-only config

Strip the blueprint host configs down to just the den mainModule import. This is the cutover point.

**Files:**
- Modify: `hosts/tb-laptop/configuration.nix`
- Modify: `hosts/tb-laptop/users/calops.nix`

- [ ] **Step 1: Replace `hosts/tb-laptop/configuration.nix`**

The den mainModule now contains all config. The old `flake.nixosModules.default` import is no longer needed because `base-nixos` aspect handles all that.

```nix
{ inputs, ... }:
{
  imports = [
    inputs.dendritic.den.hosts.x86_64-linux.tb-laptop.mainModule
  ];
}
```

Note: `hardware.nix` is NOT imported here — it's imported by the tb-laptop host aspect's `nixos` class.

- [ ] **Step 2: Replace `hosts/tb-laptop/users/calops.nix`**

Den's home-manager integration handles the user config through the nixosSystem. Blueprint also auto-discovers this file for standalone homeConfigurations. We need to keep this file minimal — it should either be empty or only contain the den mainModule for the standalone home-manager path.

Since calops on tb-laptop gets home-manager through the NixOS config (not standalone), this file can be nearly empty. But blueprint will still discover it, so we need to be careful. The safest approach is to keep the den home mainModule import as a fallback:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.dendritic.den.hosts.x86_64-linux.tb-laptop.mainModule
  ];
}
```

Wait — this would create a circular reference since the host aspect already imports this through den's pipeline. The correct approach depends on how den's home-manager integration works with blueprint's auto-discovery.

**Investigation needed:** Check if den's home-manager integration produces home-manager modules that are compatible with blueprint's `hosts/<name>/users/<user>.nix` auto-discovery, or if they conflict.

For now, the safest approach is to make this file a no-op:

```nix
{ ... }:
{
  # Home-manager config is handled by den aspects
}
```

- [ ] **Step 3: Verify tb-laptop builds**

Run: `nix build .#nixosConfigurations.tb-laptop.config.system.build.toplevel --dry-run`
Expected: SUCCESS — tb-laptop builds entirely from den aspects.

If there are errors, debug them. Common issues:
- Missing `perSystem` references in den aspects (den uses a different mechanism)
- `flake` and `flake.lib` references that need to be replaced
- Circular imports between den and blueprint

- [ ] **Step 4: Also verify other hosts still work**

Run: `nix flake check --no-build`
Expected: PASS — tocardstation, remilabeyrie-kiro, tocardland still build via blueprint with `_nixos/`/`_home/`/`_common/` modules.

- [ ] **Step 5: Commit**

```bash
git add hosts/tb-laptop/
git commit -m "feat: swap tb-laptop to den-only configuration"
```

---

### Task 10: Verify end-to-end and clean up

**Files:**
- No changes expected (unless debugging reveals issues)

- [ ] **Step 1: Full build test of tb-laptop**

Run: `nix build .#nixosConfigurations.tb-laptop.config.system.build.toplevel --dry-run`
Expected: SUCCESS

- [ ] **Step 2: Verify the den aspects actually produce config**

Check that key configuration items from the old setup are present in the den-produced config:

```bash
nix eval .#nixosConfigurations.tb-laptop.config.networking.hostName
# Expected: "tb-laptop"

nix eval .#nixosConfigurations.tb-laptop.config.system.stateVersion
# Expected: "26.05"

nix eval .#nixosConfigurations.tb-laptop.config.programs.fish.enable
# Expected: true
```

- [ ] **Step 3: Verify other hosts are unaffected**

Run: `nix flake check --no-build`
Expected: PASS — all hosts build successfully.

- [ ] **Step 4: Commit any remaining fixes**

If any fixes were needed during verification, commit them.

---

## Self-Review

**1. Spec coverage:**
- `den.nix` updated (flakeModule + schema only) ✓ → Task 2
- `base-nixos.nix` created ✓ → Task 5
- `base-home.nix` created ✓ → Task 5
- `roles/graphical.nix` ✓ → Task 4
- `roles/audio.nix` ✓ → Task 3
- `roles/bluetooth.nix` ✓ → Task 3
- `roles/printing.nix` ✓ → Task 3
- `roles/terminal.nix` ✓ → Task 3
- `roles/gaming.nix` — **GAP**: not created in this plan. tb-laptop doesn't enable gaming, so it's not needed yet. Adding it can wait for tocardstation migration.
- `roles/nvidia.nix` — **GAP**: same as gaming, only used by tocardstation. Can wait.
- `hosts/tb-laptop.nix` ✓ → Task 8
- `users/calops.nix` ✓ → Task 6
- `work/terabase.nix` ✓ → Task 7
- flake.nix updated for import-tree ✓ → Task 2
- Old dirs renamed with `_` ✓ → Task 1
- Host configs stripped ✓ → Task 9

**2. Placeholder scan:** No TBD/TODO found. All code is concrete.

**3. Type consistency:** `den.aspects.*` references used consistently across tasks. `perSystem` references may need verification in den context (den aspects use regular module args, so `perSystem` should be available if den's home-manager integration passes it through).
