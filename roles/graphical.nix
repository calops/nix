{
  config,
  lib,
  pkgs,
  ...
}: let
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
          type = types.enum ["left" "right" "above" "below" "center"];
          default = "center";
          description = "Monitor position";
        };
      };
    };
  };
in
  with lib; {
    options = {
      my.roles.graphical = {
        enable = mkEnableOption "Graphical environment";
        nvidia.enable = mkEnableOption "Nvidia tweaks";
        fonts = {
          monospace = mkOption {
            type = my.types.font;
            default = lib.my.fonts.iosevka-comfy;
            description = "Monospace font";
          };
          serif = mkOption {
            type = my.types.font;
            default = lib.my.fonts.noto-serif;
            description = "Serif font";
          };
          sansSerif = mkOption {
            type = my.types.font;
            default = lib.my.fonts.noto-sans;
            description = "Sans-serif font";
          };
          emoji = mkOption {
            type = my.types.font;
            default = lib.my.fonts.noto-emoji;
            description = "Emoji font";
          };
          hinting = mkOption {
            type = types.enum ["Normal" "Mono" "HorizontalLcd" "Light"];
            default = "Normal";
            description = "Font hinting strategy";
          };
          sizes = {
            terminal = mkOption {
              type = types.int;
              default = 10;
              description = "Terminal font size";
            };
            terminalCell = {
              width = mkOption {
                type = types.float;
                default = 1.0;
                description = "Terminal cell width";
              };
              height = mkOption {
                type = types.float;
                default = 1.0;
                description = "Terminal cell height";
              };
            };
            applications = mkOption {
              type = types.int;
              default = 10;
              description = "Application font size";
            };
          };
        };
        installAllFonts = mkEnableOption "Install all fonts";
        terminal = mkOption {
          type = types.enum ["kitty" "wezterm"];
          default = "wezterm";
          description = "Terminal emulator";
        };
        monitors = {
          primary = mkOption {
            type = my.types.monitor;
            default = {
              id = "eDP-1";
              position = "center";
            };
            description = "Primary monitor";
          };
          secondary = mkOption {
            type = my.types.monitor;
            default = null;
            description = "Secondary monitor";
          };
        };
      };
    };
  }
