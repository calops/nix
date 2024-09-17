{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ pkgs.sketchybar ];

    xdg.configFile."sketchybar/sketchybarrc" = {
      text =
        # lua
        ''
          #! ${pkgs.lua5_4_compat}/bin/lua
          package.cpath = package.cpath .. ";${pkgs.my.sbarlua}/lib/?.so"
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
          text = "${config.my.roles.graphical.fonts.monospace.name}",
          symbols = "${config.my.roles.graphical.fonts.symbols.name}",
        },
        palette = ${lib.my.asLua config.my.colors.palette.withoutHashtag},
      }
    '';

    xdg.configFile."sketchybar/config" = {
      source = ./config;
      recursive = true;
    };
  };
}
