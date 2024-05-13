{
  pkgs,
  config,
  lib,
  ...
}:
let
  palette = config.my.colors.palette.withoutHashtag;
in
{
  config = lib.mkIf config.my.isDarwin {
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
        palette = ${lib.generators.toLua { } palette},
      }
    '';

    xdg.configFile."sketchybar/config" = {
      source = ./config;
      recursive = true;
    };
  };
}
