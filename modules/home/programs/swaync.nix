{
  lib,
  pkgs,
  config,
  ...
}:
let
  palette = config.my.colors.palette.withHashtag;
in
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    services.swaync = {
      enable = true;

      settings = {
        control-center-positionX = "left";
        control-center-margin-top = 0;
        control-center-margin-bottom = 0;
        control-center-margin-right = 0;
        control-center-margin-left = 0;
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
          @import url("file://${pkgs.my.catppuccin-mocha-swaync-theme}/style.css");

          * {
            font-family: ${config.my.roles.graphical.fonts.monospace.name};
          }

          .control-center {
            background-color: rgba(30, 30, 46, 0.8); /* palette.base */
          }

          .notification {
            background-color: ${palette.surface0};
            box-shadow: 0px 0px 15px 0px rgba(0,0,0,0.75);
          }
        '';
    };
  };
}
