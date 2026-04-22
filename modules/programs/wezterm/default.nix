{ ... }:
{
  den.aspects.programs.wezterm = {
    homeManager =
      { lib, config, ... }:
      {
        config = lib.mkIf (config.programs.wezterm.enable) {
          programs.wezterm = {
            extraConfig = builtins.readFile ./config.lua;
          };
          stylix.targets.wezterm.enable = false;

          xdg.configFile."wezterm/nix.lua".text = ''
            return ${
              lib.generators.toLua { } {
                font = {
                  name = config.my.fonts.fonts.monospace.name;
                  size = config.my.fonts.fonts.sizes.terminal;
                  hinting = config.my.fonts.fonts.hinting;
                  cell_width = config.my.fonts.fonts.sizes.terminalCell.width;
                  cell_height = config.my.fonts.fonts.sizes.terminalCell.height;
                  symbols = config.my.fonts.fonts.symbols.name;
                };
              }
            }
          '';
        };
      };
  };
}
