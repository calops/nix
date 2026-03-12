{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  inputs,
  perSystem,
  ...
}:
let
  palette = config.my.colors.palette.asHexWithHashtag;
  wallpaper = config.stylix.image;
  lock = lib.getExe config.programs.swaylock.package;
  niri = lib.getExe config.programs.niri.package;
  pidof = lib.getExe' pkgs.sysvinit "pidof";
in
{
  imports = [
    # TODO: update my niri-flake fork so that this can work again for standalone hm
    # inputs.niri.homeModules.config
  ];

  options.my.roles.graphical.niriExtraConfig = lib.mkOption {
    type = lib.types.str;
    default = "";
  };

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.niri = {
      package = nixosConfig.programs.niri.package or perSystem.self.niri;
      config =
        if pkgs.stdenv.isDarwin then
          null
        else
          # kdl
          ''
            ${config.my.roles.graphical.niriExtraConfig}

            screenshot-path "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png"
            hotkey-overlay
            prefer-no-csd
            animations { slowdown 1.000000; }
            overview { zoom 0.25; }

            input {
                mouse { accel-speed 0.000000; }
                trackpoint { accel-speed 0.000000; }
                trackball { accel-speed 0.000000; }
                focus-follows-mouse max-scroll-amount="0%"

                touchpad {
                  tap
                  natural-scroll
                  drag true
                  drag-lock
                  click-method "clickfinger"
                }

                keyboard {
                    xkb { layout "fr"; }
                    repeat-delay 600
                    repeat-rate 25
                    track-layout "global"
                }
            }

            layout {
                gaps 16
                focus-ring { off; }
                insert-hint { color "rgba(127 200 255 50%)"; }
                center-focused-column "on-overflow"
                always-center-single-column
                default-column-width

                struts {
                    left 40
                    right 40
                    top 0
                    bottom 0
                }

                border {
                    width 4
                    active-gradient angle=45 from="${palette.red}" in="oklch longer hue" relative-to="window" to="${palette.green}"
                    inactive-color "#6c7086"
                }

                shadow {
                    on
                    softness 40
                    spread 0
                    offset x=0 y=0
                    draw-behind-window false
                    color "${palette.text}cc"
                    inactive-color "${palette.text}cc"
                }

                tab-indicator {
                  corner-radius 5
                  position "left"
                }

                preset-column-widths {
                    proportion 0.333330
                    proportion 0.500000
                    proportion 0.666670
                }
            }

            cursor {
                xcursor-theme "catppuccin-mocha-peach-cursors"
                xcursor-size 32
            }

            environment {
                "ELECTRON_OZONE_PLATFORM_HINT" "auto"
                "NIXOS_OZONE_WL" "1"
            }

            binds {
                Mod+Ctrl+S          { screenshot-screen; }
                Mod+S               { screenshot; }
                Mod+Shift+S         { screenshot-window; }
                Mod+Ctrl+Shift+S    { spawn-sh "wl-paste | ${pkgs.satty} --filename -"; }

                Mod+Ampersand       { focus-workspace "web"; }
                Mod+Eacute          { focus-workspace "dev"; }
                Mod+Quotedbl        { focus-workspace "work"; }
                Mod+Apostrophe      { focus-workspace "chat"; }
                Mod+Parenleft       { focus-workspace "games"; }
                Mod+Minus           { focus-workspace "misc"; }

                Mod+Down            { focus-window-or-workspace-down; }
                Mod+Up              { focus-window-or-workspace-up; }
                Mod+Left            { focus-column-left; }
                Mod+Right           { focus-column-right; }
                Mod+Page_Down       { focus-workspace-down; }
                Mod+Page_Up         { focus-workspace-up; }
                Mod+Shift+Down      { move-window-down-or-to-workspace-down; }
                Mod+Shift+Up        { move-window-up-or-to-workspace-up; }
                Mod+Shift+Left      { move-column-left-or-to-monitor-left; }
                Mod+Shift+Right     { move-column-right-or-to-monitor-right; }
                Mod+Ctrl+Right      { consume-or-expel-window-right; }
                Mod+Ctrl+Left       { consume-or-expel-window-left; }
                Mod+Shift+Page_Down { move-workspace-down; }
                Mod+Shift+Page_Up   { move-workspace-up; }

                Mod+T               { toggle-column-tabbed-display; }
                Mod+Shift+F         { toggle-window-floating; }
                Mod+C               { center-column; }
                Mod+Home            { focus-column-first; }
                Mod+End             { focus-column-last; }
                Mod+Shift+End       { move-column-to-last; }
                Mod+Shift+Home      { move-column-to-first; }
                Mod+Shift+Q         { close-window; }

                Mod+Backspace       { switch-preset-column-width; }
                Mod+Ctrl+F          { fullscreen-window; }
                Mod+Equal           { set-column-width "-10%"; }
                Mod+F               { maximize-column; }

                Mod+Tab             { toggle-overview; }
                Mod+L               { spawn-sh "${lock}"; }
                Mod+N               { spawn-sh "${lib.getExe' config.services.swaync.package "swaync-client"} -t"; }
                Mod+Plus            { set-column-width "+10%"; }
                Mod+Return          { spawn-sh "kitty"; }
                Mod+Shift+Comma     { show-hotkey-overlay; }
                Mod+Shift+E         { quit; }
                Mod+Space           { spawn-sh "shell toggleRunner \"\""; }
                Mod+Shift+Space     { spawn-sh "1password --quick-access"; }

                Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-column-right; }
                Mod+Shift+WheelScrollUp   cooldown-ms=150 { focus-column-left;  }

                Mod+WheelScrollDown  cooldown-ms=150 { focus-workspace-down; }
                Mod+WheelScrollLeft  cooldown-ms=150 { focus-column-left;    }
                Mod+WheelScrollRight cooldown-ms=150 { focus-column-right;   }
                Mod+WheelScrollUp    cooldown-ms=150 { focus-workspace-up;   }

                XF86AudioRaiseVolume  { spawn-sh "shell setVolume +0.05"; }
                XF86AudioLowerVolume  { spawn-sh "shell setVolume -0.05"; }
                XF86AudioMute         { spawn-sh "shell setMuted toggle"; }
                XF86MonBrightnessUp   { spawn-sh "shell setBrightness +0.05"; }
                XF86MonBrightnessDown { spawn-sh "shell setBrightness -0.05"; }
            }

            workspace "web"
            workspace "dev"
            workspace "work"
            workspace "chat"
            workspace "games"
            workspace "misc"

            spawn-sh-at-startup "swww-daemon"
            spawn-sh-at-startup "swww img ${wallpaper}"
            spawn-sh-at-startup "${lib.getExe config.programs.firefox.package}"
            spawn-sh-at-startup "${lib.getExe config.programs.element.package}"

            window-rule {
                geometry-corner-radius 8.000000 8.000000 8.000000 8.000000
                clip-to-geometry true
            }
            window-rule {
                match is-floating=false
                shadow { off; }
            }
            window-rule {
                match app-id="^1Password$"
                match app-id="org.kde.polkit-kde-authentication-agent-1"
                open-floating true
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
                match app-id="^Element$"
                match app-id="^Slack$"
                match app-id="^discord$"
                default-column-width { proportion 0.500000; }
                open-on-workspace "chat"
            }

            layer-rule {
              match namespace="quickshell"
              background-effect {
                xray false
                blur true
              }
            }

            layer-rule {
              match namespace="niri-backdrop"
              place-within-backdrop true
            }
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
        {
          timeout = 36000;
          command = "systemctl suspend";
        }
      ];
    };

    home.packages = [
      pkgs.swww
      pkgs.nautilus
      pkgs.xwayland-satellite
    ];
  };
}
