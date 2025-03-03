{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.aerospace = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    userSettings = {
      start-at-login = true;
      after-startup-command = [ "exec-and-forget ${lib.getExe pkgs.sketchybar}" ];

      gaps = {
        outer = {
          left = 10;
          bottom = 10;
          top = 10;
          right = 10;
        };

        inner = {
          horizontal = 10;
          vertical = 10;
        };
      };

      # AZERTY mappings
      key-mapping.key-notation-to-key-code = {
        a = "q";
        z = "w";
        q = "a";
        w = "z";
        m = "semicolon";
        at = "backtick";
        degree = "minus";
        minus = "equal";
        caret = "leftSquareBracket";
        dollar = "rightSquareBracket";
        percent = "quote";
        comma = "m";
        semicolon = "comma";
        slash = "period";
        equal = "slash";
      };

      workspace-to-monitor-force-assignment = {
        "1" = [ "main" ];
        "2" = [ "main" ];
        "3" = [ "main" ];
        "4" = [ "main" ];
        "5" = [ "main" ];
        "6" = [ "main" ];
        "7" = [ "main" ];
        "8" = [
          "secondary"
          "main"
        ];
        "9" = [
          "secondary"
          "main"
        ];
        "10" = [
          "secondary"
          "main"
        ];
      };

      mode.main.binding = {
        cmd-ctrl-c = "reload-config";
        cmd-backspace = "layout tiles horizontal vertical";
        cmd-equal = "layout accordion horizontal vertical";
        cmd-enter = "exec-and-forget ${lib.getExe config.programs.kitty.package}";

        cmd-left = "focus left";
        cmd-right = "focus right";
        cmd-up = "focus up";
        cmd-down = "focus down";

        cmd-shift-f = "fullscreen";
        cmd-shift-ctrl-f = "macos-native-fullscreen";
        cmd-ctrl-f = "layout floating tiling";
        cmd-shift-q = "close";
        cmd-shift-b = "balance-sizes";

        cmd-shift-left = "move left";
        cmd-shift-right = "move right";
        cmd-shift-up = "move up";
        cmd-shift-down = "move down";

        alt-r = "mode resize";

        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";
        cmd-0 = "workspace 10";

        cmd-shift-1 = "move-node-to-workspace 1";
        cmd-shift-2 = "move-node-to-workspace 2";
        cmd-shift-3 = "move-node-to-workspace 3";
        cmd-shift-4 = "move-node-to-workspace 4";
        cmd-shift-5 = "move-node-to-workspace 5";
        cmd-shift-6 = "move-node-to-workspace 6";
        cmd-shift-7 = "move-node-to-workspace 7";
        cmd-shift-8 = "move-node-to-workspace 8";
        cmd-shift-9 = "move-node-to-workspace 9";
        cmd-shift-0 = "move-node-to-workspace 10";
      };

      mode.resize.binding = {
        "esc" = "mode main";
        "down" = "resize smart -50";
        "up" = "resize smart 50";
      };

      on-window-detected = [
        {
          "if".app-id = "sh.kunkun.desktop";
          run = [ "layout floating" ];
        }
      ];
    };
  };
}
