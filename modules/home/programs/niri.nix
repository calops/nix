{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  ...
}:
let
  palette = config.my.colors.palette.withHashtag;
  wallpaper = config.stylix.image;
  lock = lib.getExe config.programs.swaylock.package;
  niri = lib.getExe config.programs.niri.package;
  pidof = lib.getExe' pkgs.sysvinit "pidof";
in
{
  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.niri = {
      package = if pkgs.stdenv.isDarwin then null else nixosConfig.programs.niri.package;
      config = # kdl
        ''
          input {
              keyboard {
                  xkb {
                      layout "fr"
                  }
                  repeat-delay 600
                  repeat-rate 25
                  track-layout "global"
              }
              mouse { accel-speed 0.000000; }
              trackpoint { accel-speed 0.000000; }
              trackball { accel-speed 0.000000; }
              focus-follows-mouse max-scroll-amount="0%"
          }
          screenshot-path "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png"
          prefer-no-csd
          layout {
              gaps 16
              struts {
                  left 40
                  right 40
                  top 0
                  bottom 0
              }
              focus-ring { off; }
              border {
                  width 4
                  active-gradient angle=45 from="${palette.red}" in="oklch longer hue" relative-to="window" to="${palette.green}"
                  inactive-color "#6c7086"
              }
              shadow {
                  on
                  softness 30
                  spread 5
                  offset x=0 y=0
                  draw-behind-window false
                  color "${palette.text}"
              }
              insert-hint { color "rgba(127 200 255 50%)"; }
              default-column-width
              preset-column-widths {
                  proportion 0.333330
                  proportion 0.500000
                  proportion 0.666670
              }
              center-focused-column "on-overflow"
              always-center-single-column
          }
          cursor {
              xcursor-theme "catppuccin-mocha-peach-cursors"
              xcursor-size 32
          }
          hotkey-overlay
          environment {
              DISPLAY ":0"
              "ELECTRON_OZONE_PLATFORM_HINT" "auto"
              "GBM_BACKEND" "nvidia-drm"
              "LIBVA_DRIVER_NAME" "nvidia"
              "NIXOS_OZONE_WL" "1"
              "NVD_BACKEND" "direct"
              "__GLX_VENDOR_LIBRARY_NAME" "nvidia"
          }
          binds {
              Mod+Ampersand { focus-workspace "web"; }
              Mod+Apostrophe { focus-workspace "chat"; }
              Mod+Backspace { switch-preset-column-width; }
              Mod+C { center-column; }
              Mod+Ctrl+F { fullscreen-window; }
              Mod+Ctrl+Left { move-column-left; }
              Mod+Ctrl+Right { move-column-right; }
              Mod+Ctrl+S { screenshot-screen; }
              Mod+Down { focus-window-or-workspace-down; }
              Mod+Eacute { focus-workspace "dev"; }
              Mod+End { focus-column-last; }
              Mod+Equal { set-column-width "-10%"; }
              Mod+F { maximize-column; }
              Mod+Home { focus-column-first; }
              Mod+L { spawn "${lock}"; }
              Mod+Left { focus-column-left; }
              Mod+Minus { focus-workspace "misc"; }
              Mod+N { spawn "${lib.getExe' config.services.swaync.package "swaync-client"}" "-t"; }
              "Mod+Page_Down" { focus-workspace-down; }
              "Mod+Page_Up" { focus-workspace-up; }
              Mod+Parenleft { focus-workspace "games"; }
              Mod+Plus { set-column-width "+10%"; }
              Mod+Quotedbl { focus-workspace "work"; }
              Mod+Return { spawn "kitty"; }
              Mod+Right { focus-column-right; }
              Mod+S { screenshot; }
              Mod+Shift+Comma { show-hotkey-overlay; }
              Mod+Shift+Down { move-window-down-or-to-workspace-down; }
              Mod+Shift+E { quit; }
              Mod+Shift+End { move-column-to-last; }
              Mod+Shift+F { toggle-window-floating; }
              Mod+Shift+Home { move-column-to-first; }
              Mod+Shift+Left { consume-or-expel-window-left; }
              "Mod+Shift+Page_Down" { move-workspace-down; }
              "Mod+Shift+Page_Up" { move-workspace-up; }
              Mod+Shift+Q { close-window; }
              Mod+Shift+Right { consume-or-expel-window-right; }
              Mod+Shift+S { screenshot-window; }
              Mod+Shift+Up { move-window-up-or-to-workspace-up; }
              Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-column-right; }
              Mod+Shift+WheelScrollUp cooldown-ms=150 { focus-column-left; }
              Mod+Space { spawn "anyrun"; }
              Mod+Up { focus-window-or-workspace-up; }
              Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
              Mod+WheelScrollLeft cooldown-ms=150 { focus-column-left; }
              Mod+WheelScrollRight cooldown-ms=150 { focus-column-right; }
              Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
              XF86AudioLowerVolume allow-when-locked=true { spawn "swayosd-client" "--output-volume" "lower"; }
              XF86AudioMute allow-when-locked=true { spawn "swayosd-client" "--output-volume" "mute-toggle"; }
              XF86AudioRaiseVolume allow-when-locked=true { spawn "swayosd-client" "--output-volume" "raise"; }
          }
          workspace "web"
          workspace "dev"
          workspace "work"
          workspace "chat"
          workspace "games"
          workspace "misc"
          spawn-at-startup "swww-daemon"
          spawn-at-startup "swww" "img" "${wallpaper}"
          spawn-at-startup "${lib.getExe config.programs.firefox.package}"
          spawn-at-startup "${lib.getExe pkgs.slack}"
          spawn-at-startup "${lib.getExe config.programs.element.package}"
          window-rule {
              geometry-corner-radius 8.000000 8.000000 8.000000 8.000000
              clip-to-geometry true
          }
          window-rule {
              match is-floating=false
              shadow {
                  off
              }
          }
          window-rule {
              match app-id="^kitty$"
              default-column-width { proportion 0.333330; }
          }
          window-rule {
              match app-id="^firefox(-beta)?$"
              default-column-width { proportion 0.666670; }
              open-on-workspace "web"
          }
          window-rule {
              match app-id="^discord$"
              default-column-width { proportion 0.500000; }
              open-on-workspace "chat"
          }
          window-rule {
              match app-id="^Element$"
              default-column-width { proportion 0.500000; }
              open-on-workspace "chat"
          }
          window-rule {
              match app-id="^Slack$"
              default-column-width { proportion 0.500000; }
              open-on-workspace "chat"
          }
          animations { slowdown 1.000000; }

        '';
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
          command = "${pidof} ${lock} || ${lock}";
        }
        {
          event = "lock";
          command = "${lock}";
        }
      ];
      timeouts = [
        {
          timeout = 900;
          command = "${pidof} ${lock} || ${lock}";
        }
        {
          timeout = 900;
          command = "${pidof} ${lock} && ${niri} msg action power-off-monitors";
        }
        {
          timeout = 1800;
          command = "${pidof} ${lock} && ${niri} msg action power-off-monitors";
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
