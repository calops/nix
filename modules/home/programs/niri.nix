{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  ...
}:
let
  palette = config.my.colors.palette.withHashtag;
  mkCommand = cmd: lib.strings.splitString " " cmd;
  wallpaper = config.stylix.image;
  lock = lib.getExe config.programs.swaylock.package;
in
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.niri = {
      settings = {
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

        input = {
          keyboard.xkb.layout = nixosConfig.services.xserver.xkb.layout or "fr";
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
        };

        workspaces = lib.mapAttrs' (index: name: lib.nameValuePair "${index}-${name}" { inherit name; }) (
          lib.my.enumerateList [
            "web"
            "dev"
            "work"
            "chat"
            "games"
            "misc"
          ]
        );

        environment = {
          DISPLAY = ":0";
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          NVD_BACKEND = "direct";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          NIXOS_OZONE_WL = "1";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };

        cursor = {
          theme = "catppuccin-mocha-peach-cursors";
          size = 32;
        };

        layout = {
          gaps = 16;
          always-center-single-column = true;
          center-focused-column = "on-overflow";
          struts.right = 40;
          struts.left = 40;

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
          { command = [ "swww-daemon" ]; }
          { command = mkCommand "swww img ${wallpaper}"; }
          { command = [ "${lib.getExe config.programs.firefox.package}" ]; }
          { command = [ "${lib.getExe pkgs.slack}" ]; }
          { command = [ "${lib.getExe config.programs.element.package}" ]; }
        ];

        window-rules =
          let
            mkRule = app-id: opts: { matches = [ { inherit app-id; } ]; } // opts;
          in
          [
            {
              clip-to-geometry = true;
              geometry-corner-radius =
                let
                  radius = 8.0;
                in
                {
                  top-left = radius;
                  top-right = radius;
                  bottom-left = radius;
                  bottom-right = radius;
                };
            }
            (mkRule "^kitty$" { default-column-width.proportion = 0.33333; })
            (mkRule "^firefox(-beta)?$" {
              default-column-width.proportion = 0.66667;
              open-on-workspace = "web";
            })
            (mkRule "^discord$" {
              default-column-width.proportion = 0.5;
              open-on-workspace = "chat";
            })
            (mkRule "^Element$" {
              default-column-width.proportion = 0.5;
              open-on-workspace = "chat";
            })
            (mkRule "^slack$" {
              default-column-width.proportion = 0.5;
              open-on-workspace = "chat";
            })
          ];

        binds =
          let
            act = if (!pkgs.stdenv.isDarwin) then config.lib.niri.actions else { };
          in
          {
            "Mod+Return".action = act.spawn "kitty";
            "Mod+Space".action = act.spawn "anyrun";
            "Mod+L".action = act.spawn lock;

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

            "Mod+Equal".action = act.set-column-width "-10%";
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

            # AZERTY mappings
            "Mod+Ampersand".action = act.focus-workspace "web";
            "Mod+Eacute".action = act.focus-workspace "dev";
            "Mod+Quotedbl".action = act.focus-workspace "work";
            "Mod+Apostrophe".action = act.focus-workspace "chat";
            "Mod+Parenleft".action = act.focus-workspace "games";
            "Mod+Minus".action = act.focus-workspace "misc";

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
              action = act.spawn (mkCommand "swayosd-client --output-volume raise");
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action = act.spawn (mkCommand "swayosd-client --output-volume lower");
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action = act.spawn (mkCommand "swayosd-client --output-volume mute-toggle");
            };
          };
      };
    };

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        screenshots = true;
        effect-pixelate = 7;
        fade-in = 1.0;
        grace = 5;
        grace-no-mouse = true;
      };
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "pidof ${lock} || ${lock}";
        }
        {
          event = "lock";
          command = "${lock}";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "pidof ${lock} || ${lock}";
        }
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
        }
        # FIXME: suspend is not reliable with my hardware
        # {
        #   timeout = 7200;
        #   command = "systemctl suspend";
        # }
        {
          timeout = 300;
          command = "pidof ${lock} && niri msg action power-off-monitors";
        }
      ];
    };

    home.packages = [
      pkgs.swww
      pkgs.nautilus
    ];

    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "XWayland Satellite";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = lib.getExe pkgs.xwayland-satellite;
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
