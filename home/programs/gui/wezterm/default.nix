{
  lib,
  roles,
  pkgs,
  ...
}: let
  cfg = roles.graphical;
  lua = lib.generators.toLua {} {
    nvidia = cfg.nvidia.enable;
    font = {
      name = cfg.fonts.monospace.name;
      size = cfg.fonts.sizes.terminal;
      hinting = cfg.fonts.hinting;
      cell_width = cfg.fonts.sizes.terminalCell.width;
      cell_height = cfg.fonts.sizes.terminalCell.height;
      symbols = cfg.fonts.symbols.name;
    };
  };
in
  {
    config = lib.mkIf (cfg.enable && cfg.terminal == "wezterm") {
      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./config.lua;
      };

      xdg.configFile."wezterm/nix.lua".text = ''return ${lua}'';
    };
  }
