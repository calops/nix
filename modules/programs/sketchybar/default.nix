{ config, ... }:
{
  den.aspects.programs.provides.sketchybar = {
    homeManagerDarwin =
      { pkgs, colors, ... }:
      {
        home.packages = [ pkgs.sketchybar ];

        xdg.configFile."sketchybar/sketchybarrc" = {
          text =
            # lua
            ''
              #! ${pkgs.lua5_4_compat}/bin/lua
              package.cpath = package.cpath .. ";${pkgs.sbarlua}/lib/lua/5.4/?.so"
              package.path = package.path
                .. ";${config.xdg.configHome}/sketchybar/?/init.lua"
                .. ";${config.xdg.configHome}/sketchybar/config/?.lua"

              require("config")
            '';
          executable = true;
        };

        xdg.configFile."sketchybar/config/from_nix.lua".text = ''
          return {
            fonts = {
              text = "${config.fonts.monospace.name}",
              symbols = "${config.fonts.symbols.name}",
            },
            palette = ${colors.palette.asLua},
          }
        '';

        xdg.configFile."sketchybar/config" = {
          source = ./config;
          recursive = true;
        };
      };
  };
}
