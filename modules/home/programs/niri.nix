{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  palette = config.my.colors.palette.withHashtag;
in
{
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.niri = {
      package = inputs.niri.packages.${pkgs.system}.niri-unstable;
      settings = {
        prefer-no-csd = false;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

        input = {
          keyboard.xkb.layout = "fr";
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
        };

        workspaces = {
          web = { };
          dev = { };
          work = { };
          games = { };
          chat = { };
          misc = { };
        };

        environment = {
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          NVD_BACKEND = "direct";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          NIXOS_OZONE_WL = "1";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };

        cursor = {
          theme = "catppuccino-mocha-peach-cursors";
          size = 32;
        };

        layout = {
          gaps = 16;
          always-center-single-column = true;
          center-focused-column = "on-overflow";

          border = {
            width = 4;
            active.gradient = {
              from = palette.red;
              to = palette.green;
              angle = 45;
              in' = "oklch longer hue";
            };
          };

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
        };

        spawn-at-startup = [
          { command = [ "${pkgs.xwayland-satellite}" ]; }
          { command = [ "${config.programs.firefox.package}" ]; }
        ];

        window-rules = [
          {
            clip-to-geometry = true;
            geometry-corner-radius =
              let
                r = 8.0;
              in
              {
                top-left = r;
                top-right = r;
                bottom-left = r;
                bottom-right = r;
              };
          }
          {
            matches = [ { app-id = "^kitty$"; } ];
            default-column-width.proportion = 0.33333;
          }
          {
            matches = [ { app-id = "^firefox(-beta)?$"; } ];
            open-on-workspace = "web";
            default-column-width.proportion = 0.66667;
          }
        ];

        binds =
          let
            act = config.lib.niri.actions;
          in
          {
            "Mod+Return".action = act.spawn "kitty";
            "Mod+Space".action = act.spawn "anyrun";
            "Mod+K".action = act.spawn "hyprlock";

            "Mod+Shift+E".action = act.quit;
            "Mod+Shift+Comma".action = act.show-hotkey-overlay;
            "Mod+Shift+Q".action = act.close-window;
            "Mod+Backspace".action = act.switch-preset-column-width;
            "Mod+F".action = act.maximize-column;
            "Mod+Shift+F".action = act.fullscreen-window;
            "Mod+C".action = act.center-column;

            "Mod+S".action = act.screenshot;
            "Mod+Shift+S".action = act.screenshot-window;
            "Mod+Ctrl+S".action = act.screenshot-screen;

            "Mod+Minus".action = act.set-column-width "-10%";
            "Mod+Plus".action = act.set-column-width "+10%";

            "Mod+Left".action = act.focus-column-left;
            "Mod+Right".action = act.focus-column-right;
            "Mod+Down".action = act.focus-window-or-workspace-down;
            "Mod+Up".action = act.focus-window-or-workspace-up;

            "Mod+Ctrl+Left".action = act.move-column-left;
            "Mod+Ctrl+Right".action = act.move-column-right;

            "Mod+Shift+Left".action = act.consume-or-expel-window-left;
            "Mod+Shift+Right".action = act.consume-or-expel-window-right;
            "Mod+Shift+Down".action = act.move-window-down-or-to-workspace-down;
            "Mod+Shift+Up".action = act.move-window-up-or-to-workspace-up;

            "Mod+Home".action = act.focus-column-first;
            "Mod+End".action = act.focus-column-last;
            "Mod+Shift+Home".action = act.move-column-to-first;
            "Mod+Shift+End".action = act.move-column-to-last;

            "Mod+Page_Down".action = act.focus-workspace-down;
            "Mod+Page_Up".action = act.focus-workspace-up;
            "Mod+Shift+Page_Down".action = act.move-workspace-down;
            "Mod+Shift+Page_Up".action = act.move-workspace-up;

            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action = act.focus-workspace-down;
            };
            "Mod+WheelScrollUp" = {
              cooldown-ms = 150;
              action = act.focus-workspace-up;
            };
            "Mod+Shift+WheelScrollDown" = {
              cooldown-ms = 150;
              action = act.focus-column-right;
            };
            "Mod+Shift+WheelScrollUp" = {
              cooldown-ms = 150;
              action = act.focus-column-left;
            };
            "Mod+WheelScrollLeft" = {
              cooldown-ms = 150;
              action = act.focus-column-left;
            };
            "Mod+WheelScrollRight" = {
              cooldown-ms = 150;
              action = act.focus-column-right;
            };

            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action = act.spawn [
                "swayosd-client"
                "--output-volume"
                "raise"
              ];
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action = act.spawn [
                "swayosd-client"
                "--output-volume"
                "lower"
              ];
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action = act.spawn [
                "swayosd-client"
                "--output-volume"
                "mute-toggle"
              ];
            };
          };
      };
    };
  };
}
