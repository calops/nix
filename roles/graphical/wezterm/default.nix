{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.roles.graphical;
in
  with lib; {
    config = mkIf (cfg.enable && cfg.terminal == "wezterm") {
      programs.wezterm = {
        enable = true;
        package = lib.my.nixGlWrap {
          inherit config;
          pkg = pkgs.wezterm;
        };
        extraConfig = builtins.readFile ./config.lua;
      };

      xdg.configFile."wezterm/nix.lua" = {
        text = ''
          return {
            nvidia = ${boolToString cfg.nvidia.enable},
          	font = {
          		name = "${cfg.fonts.monospace.name}",
          		size = ${toString cfg.fonts.sizes.terminal},
              hinting = "${cfg.fonts.hinting}",
          	},
          }
        '';
      };
    };
  }
