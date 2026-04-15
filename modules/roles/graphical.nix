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
