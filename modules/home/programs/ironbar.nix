{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    services.ironbar = {
      enable = false;
      settings =
        let
          ironbarClient = lib.getExe config.services.ironbar.package;
          hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";

          mkCustomWidget =
            class: opts:
            {
              type = "custom";
              inherit class;
            }
            // opts;

          mkSlider =
            class: opts:
            {
              type = "slider";
              orientation = "vertical";
              inherit class;
            }
            // opts;

          mkHorizontalBox = class: widgets: {
            type = "box";
            orientation = "horizontal";
            inherit class widgets;
          };

          mkVerticalBox = class: widgets: {
            type = "box";
            orientation = "vertical";
            inherit class widgets;
          };

          mkLabel = class: label: {
            type = "label";
            inherit label class;
          };

          mkPopupButton = label: {
            type = "button";
            on_click = "popup:toggle";
            inherit label;
          };

          mkCmdButton = label: cmd: {
            type = "button";
            on_click = "!${cmd}";
            inherit label;
          };

          clipboard = {
            type = "clipboard";
            icon = "󰅍";
          };

          notifications = (
            mkVerticalBox "notifications-button" [
              (mkCmdButton "" "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t")
            ]
          );

          customTray = mkCustomWidget "custom-tray" {
            bar = [
              (mkVerticalBox "custom-tray-box" [
                notifications
                clipboard
              ])
            ];
          };

          clock =
            let
              date = lib.getExe' pkgs.coreutils "date";
            in
            mkCustomWidget "clock" {
              bar = [ (mkHorizontalBox "clock-button" [ (mkPopupButton "{{${date} +'%H\n%M'}}") ]) ];
              popup = [ (mkHorizontalBox "clock-popup" [ (mkLabel "date" "{{${date} +'%A, %d %B %Y'}}") ]) ];
            };

          workspaces = {
            type = "workspaces";
            on_scroll_up = "${hyprctl} dispatch workspace -1";
            on_scroll_down = "${hyprctl} dispatch workspace +1";
            name_map = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "󰭹";
              "10" = "";
              "special:scratchpad" = "";
              "special:scratch_term" = "";
            };
          };

          tray = {
            type = "tray";
            direction = "top_to_bottom";
          };

          volume-slider =
            let
              pamixer = lib.getExe pkgs.pamixer;
              setVolume = pkgs.writeScript "setVolume" ''
                ${pamixer} --set-volume $1
                ${ironbarClient} set volume $1
              '';
            in
            mkCustomWidget "volume-slider" {
              bar = [
                (mkSlider "volume-slider" {
                  show_if = "#show-volume-slider";
                  show_label = false;
                  length = 100;
                  max = 100;
                  value = "#volume";
                  on_change = "!${setVolume} $0";
                })
              ];
            };

          volume = {
            format = "{icon}";
            on_mouse_enter = "${ironbarClient} set show-volume-slider true";
            on_mouse_exit = "${ironbarClient} set show-volume-slider false";
            type = "volume";
          };
        in
        {
          name = "status";
          position = "left";
          start = [
            customTray
            tray
          ];
          center = [ workspaces ];
          end = [
            volume
            clock
          ];
        };

      style =
        let
          palette = config.my.colors.palette.withHashtag;
        in
        # CSS
        ''
          * {
            font-family: "Iosevka";
          }

          .background {
            background: ${palette.crust};
            min-width: 30px;
          }

          .container {
            padding: 3px;
          }

          .widget{
            min-width: 24px;
          }

          /* Workspaces */
          .workspaces {
            padding: 10px;
            border-radius: 50px;
            background: ${palette.base};
          }
          .workspaces .item {
            border-radius: 50px;
            min-width: 10px;
            min-height: 24px;
            padding: 0;
          }
          .workspaces .item:not(:last-child) {
            margin: 0 0 0.3em 0;
          }
          .workspaces button {
            background: ${palette.surface0};
          }
          .workspaces button.focused {
            background: ${palette.peach};
            color: ${palette.surface0};
          }
          .workspaces .item label  {
            margin-left: -0.4em;
          }

          /* Clock */
          .clock button {
            min-width: 24px;
            border-radius: 50px;
            background: ${palette.base};
          }
          .clock label {
            font-size: 20px;
          }

          /* Notifications */
          .notifications-button button {
            border-radius: 50px;
            min-height: 25px;
            padding: 0;
            background: ${palette.surface0};
          }
          .notifications-button label {
            margin-left: -0.4em;
          }

          /* Clipboard */
          .clipboard {
            border-radius: 50px;
            min-height: 25px;
            padding: 0;
            margin: 4px 0 0 0;
            background: ${palette.surface0};
          }
          .clipboard label {
            margin-left: -0.3em;
          }

          /* Custom Tray */
          .custom-tray {
            padding: 10px;
            border-radius: 50px;
            background: ${palette.base};
          }

          /* Tray */
          .tray {
            margin-top: 5px;
            padding: 10px;
            border-radius: 50px;
            background: ${palette.base};
          }
          .tray .item {
            border-radius: 50px;
            min-height: 25px;
            padding: 0;
            background: ${palette.surface0};
          }
          .tray .item:not(:first-child) {
            margin: 4px 0 0 0;
          }
          .tray .item:hover {
            background: ${palette.violet};
          }

          /* Volume */
          .volume {
            min-width: 24px;
            min-height: 35px;
            border-radius: 50px;
            margin-bottom: 5px;
            background: ${palette.base};
          }
          .volume label {
            font-size: 25px;
          }

          /* Misc */
          button:hover {
            background: ${palette.violet};
            color: ${palette.surface0};
          }
        '';
    };
  };
}
