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
            font-family: ${roles.graphical.fonts.monospace.name};
          }

          .control-center {
            background-color: rgba(30, 30, 46, 0.8); /* palette.base */
          }

          .notification {
            background-color: ${palette.surface0};
          }
        '';
    };
  };
}
