{ ... }:
{
  den.aspects.programs.provides.wezterm = {
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
                  name = config.fonts.monospace.name;
                  # FIXME:
                  size = config.fonts.sizes.terminal;
                  # hinting = config.fonts.hinting;
                  # cell_width = config.fonts.sizes.terminalCell.width;
                  # cell_height = config.fonts.sizes.terminalCell.height;
                  symbols = config.fonts.symbols.name;
                };
              }
            }
          '';
        };
      };
  };
}
