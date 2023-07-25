{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.roles.graphical;
  lua = lib.generators.toLua {} {
    nvidia = cfg.nvidia.enable;
    font = {
      name = cfg.fonts.monospace.name;
      size = cfg.fonts.sizes.terminal;
      hinting = cfg.fonts.hinting;
      cell_width = cfg.fonts.sizes.terminalCell.width;
      cell_height = cfg.fonts.sizes.terminalCell.height;
    };
  };
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

      xdg.configFile."wezterm/nix.lua".text = ''return ${lua}'';
    };
  }