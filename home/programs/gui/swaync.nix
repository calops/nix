{
  lib,
  pkgs,
  roles,
  colors,
  ...
}: let
  palette = colors.palette;
in {
  config = lib.mkIf roles.graphical.enable {
    services.swaynotificationcenter = {
      enable = true;

      config = {
        control-center-margin-top = 20;
        control-center-margin-bottom = 20;
        control-center-margin-right = 20;
        widgets = [
          "inhibitors"
          "title"
          "dnd"
          "notifications"
          "menubar"
          "mpris"
          "volume"
        ];
      };

      style =
        # css
        ''
          @import url("file://${pkgs.catppuccin-mocha-swaync-theme}/style.css");

          * {
            font-family: ${lib.my.fonts.iosevka-comfy.name};
          }

          .control-center {
            opacity: 0.8;
            border: solid 2px ${palette.peach};
          }
        '';
    };
  };
}
