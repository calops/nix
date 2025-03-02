{
  lib,
  config,
  ...
}:
let
  cfg = config.my.roles.graphical;
  lua = lib.generators.toLua { } {
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
  config = lib.mkIf (cfg.enable) {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./config.lua;
    };
    stylix.targets.wezterm.enable = false;

    xdg.configFile."wezterm/nix.lua".text = ''return ${lua}'';
  };
}
