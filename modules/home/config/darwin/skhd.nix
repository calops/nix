{
  lib,
  pkgs,
  config,
  ...
}:
let
  window = args: "yabai -m window --" + args;
  space = args: "yabai -m space --" + args;

  mkSkhdrc =
    mappings:
    lib.strings.concatStrings (
      lib.attrsets.mapAttrsToList (name: value: "${name}: ${value}\n") mappings
    );
in
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [ pkgs.skhd ];

    xdg.configFile."skhd/skhdrc".text = mkSkhdrc {
      "cmd - return" = "${config.my.roles.graphical.terminal}";

      "cmd + shift - down" = window "warp south";
      "cmd + shift - up" = window "warp north";
      "cmd + shift - left" = window "warp west";
      "cmd + shift - right" = window "warp east";

      "cmd + ctrl - down" = window "resize rel:50:0";
      "cmd + ctrl - up" = window "resize rel:-50:0";
      "cmd + ctrl - left" = window "resize rel:0:-50";
      "cmd + ctrl - right" = window "resize rel:0:50";

      "cmd + shift - f" = window "toggle float";
      "cmd + ctrl - f" = window "toggle zoom-fullscreen";
      "cmd + shift - q" = window "close";
      "cmd + shift - b" = space "balance";
    };
  };
}
