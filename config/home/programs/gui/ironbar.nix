{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    services.ironbar = {
      enable = true;
      package = pkgs.ironbar.overrideAttrs (oldAttrs: rec {
        src = pkgs.fetchFromGitHub {
          owner = "calops";
          repo = "ironbar";
          rev = "vertical-tray";
          hash = "sha256-1nSg80bVasxqFqZSghczAxjR4zgZR3xo0xALOzi/ZNA=";
        };
        cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
          name = "ironbar-custom-vendor.tar.gz";
          inherit src;
          outputHash = "sha256-/80u16JYST9hDe81mq9unvob5VoraGmiSgBi3tZATSM=";
        });
      });
      settings = let
        mkCustomWidget = class: {
          bar ? null,
          popup ? null,
          tooltip ? null,
        }: {
          type = "custom";
          inherit class bar popup tooltip;
        };

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

        notifications = mkCustomWidget "notifications" {
          bar = [
            (mkVerticalBox "notifications-button" [
              (mkCmdButton "" "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t")
            ])
          ];
        };

        clock = let
          date = lib.getExe' pkgs.coreutils "date";
        in
          mkCustomWidget "clock" {
            bar = [
              (mkHorizontalBox "clock-button" [(mkPopupButton "{{${date} +'%H\n%M'}}")])
            ];
            popup = [
              (mkHorizontalBox "clock-popup" [(mkLabel "date" "{{${date} +'%A, %d %B %Y'}}")])
            ];
          };

        workspaces = {
          type = "workspaces";
          on_scroll_up = "hyprctl dispatch workspace -1";
          on_scroll_down = "hyprctl dispatch workspace +1";
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
          };
        };

        tray = {
          type = "tray";
          direction = "top_to_bottom";
        };
      in {
        name = "status";
        position = "left";
        start = [
          notifications
          tray
        ];
        center = [
          workspaces
        ];
        end = [
          clock
        ];
      };

      style = let
        palette = config.my.colors.palette.withHashtag;
      in
        # CSS
        ''
          * {
            font-family: "Iosevka Comfy";
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
          .notifications button {
            min-width: 24px;
            min-height: 35px;
            border-radius: 50px;
            background: ${palette.base};
          }
          .notifications label {
            font-size: 20px;
            margin-left: -0.4em;
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

          /* Misc */
          button:hover {
            background: ${palette.violet};
            color: ${palette.surface0};
          }
        '';
    };
  };
}
