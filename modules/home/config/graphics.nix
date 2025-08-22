{
  lib,
  config,
  nixosConfig ? null,
  perSystem,
  pkgs,
  ...
}:
let
  cfg = config.my.roles.graphical;
  fonts = perSystem.self.fonts;
  my.types = with lib; {
    font = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Font name";
        };
        package = mkOption {
          type = types.package;
          description = "Font package";
        };
      };
    };
    monitor = types.submodule {
      options = {
        id = mkOption {
          type = types.str;
          description = "Monitor name";
        };
        position = mkOption {
          type = types.enum [
            "left"
            "right"
            "above"
            "below"
            "center"
          ];
          default = "center";
          description = "Monitor position";
        };
      };
    };
  };
in
{
  options.my = {
    roles.graphical = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = nixosConfig.my.roles.graphical.enable or false;
        description = "Enable graphical environment";
      };

      fonts = {
        monospace = lib.mkOption {
          type = my.types.font;
          default = fonts.aporetic-sans-mono;
          description = "Monospace font";
        };
        serif = lib.mkOption {
          type = my.types.font;
          default = fonts.noto-serif;
          description = "Serif font";
        };
        sansSerif = lib.mkOption {
          type = my.types.font;
          default = fonts.noto-sans;
          description = "Sans-serif font";
        };
        emoji = lib.mkOption {
          type = my.types.font;
          default = fonts.noto-emoji;
          description = "Emoji font";
        };
        symbols = lib.mkOption {
          type = my.types.font;
          default = fonts.nerdfont-symbols;
          description = "Symbols font";
        };
        hinting = lib.mkOption {
          type = lib.types.enum [
            "Normal"
            "Mono"
            "HorizontalLcd"
            "Light"
          ];
          default = "Normal";
          description = "Font hinting strategy";
        };

        sizes = {
          terminal = lib.mkOption {
            type = lib.types.number;
            default = 10;
            description = "Terminal font size";
          };

          terminalCell = {
            width = lib.mkOption {
              type = lib.types.float;
              default = 1.0;
              description = "Terminal cell width";
            };
            height = lib.mkOption {
              type = lib.types.float;
              default = 1.0;
              description = "Terminal cell height";
            };
          };

          applications = lib.mkOption {
            type = lib.types.number;
            default = 10;
            description = "Application font size";
          };
        };
      };
      installAllFonts = lib.mkEnableOption "Install all fonts";
      terminal = lib.mkOption {
        type = lib.types.enum [
          "kitty"
          "wezterm"
        ];
        default = "kitty";
        description = "Terminal emulator";
      };

      monitors = {
        primary = lib.mkOption {
          type = my.types.monitor;
          default = {
            id = "eDP-1";
            position = "center";
          };
          description = "Primary monitor";
        };
        secondary = lib.mkOption {
          type = lib.types.nullOr my.types.monitor;
          default = null;
          description = "Secondary monitor";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = [
      pkgs.libnotify
      pkgs.slack
    ]
    ++ (lib.lists.optionals (!pkgs.stdenv.isDarwin) [
      pkgs.google-chrome
      pkgs.rquickshare
      pkgs.waypipe
      pkgs.wl-clipboard
    ])
    ++ [
      cfg.fonts.monospace.package
      cfg.fonts.serif.package
      cfg.fonts.sansSerif.package
      cfg.fonts.emoji.package
      cfg.fonts.symbols.package
      fonts.aporetic-sans.package
      fonts.iosevka.package
    ];

    programs.mpv = {
      enable = pkgs.stdenv.isLinux;
      # FIXME: this mess
      scripts = [
        # pkgs.mpvScripts.sponsorblock
        # pkgs.mpvScripts.thumbfast
        # pkgs.mpvScripts.mpv-webm
        # pkgs.mpvScripts.uosc
      ];
    };

    programs.zathura = {
      enable = true;
      options.font = cfg.fonts.monospace.name;
    };

    services.clipman.enable = !pkgs.stdenv.isDarwin;
    services.swayosd.enable = !pkgs.stdenv.isDarwin;

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
        package = pkgs.catppuccin-cursors.mochaPeach;
      };
    };
  };
}
