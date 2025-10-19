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
    inputs.niri.homeModules.config
  ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.niri = {
      package = nixosConfig.programs.niri.package or perSystem.self.niri;
      config =
        if pkgs.stdenv.isDarwin then
          null
        else
          # kdl
          ''
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

                keyboard {
                    xkb { layout "fr"; }
                    repeat-delay 600
                    repeat-rate 25
                    track-layout "global"
                }
            }

            // TODO: proper nix options for this
            output "DP-3" {
              mode "3440x1440@170.000"
              variable-refresh-rate
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
                // "DISPLAY" ":0"
                "ELECTRON_OZONE_PLATFORM_HINT" "auto"
                "GBM_BACKEND" "nvidia-drm"
                "LIBVA_DRIVER_NAME" "nvidia"
                "NIXOS_OZONE_WL" "1"
            }

            binds {
                Mod+Ampersand       { focus-workspace "web"; }
                Mod+Apostrophe      { focus-workspace "chat"; }
                Mod+Backspace       { switch-preset-column-width; }
                Mod+Tab             { toggle-overview; }
                Mod+C               { center-column; }
                Mod+T               { toggle-column-tabbed-display; }
                Mod+Ctrl+F          { fullscreen-window; }
                Mod+Ctrl+Left       { move-column-left; }
                Mod+Ctrl+Right      { move-column-right; }
                Mod+Ctrl+S          { screenshot-screen; }
                Mod+Down            { focus-window-or-workspace-down; }
                Mod+Eacute          { focus-workspace "dev"; }
                Mod+End             { focus-column-last; }
                Mod+Equal           { set-column-width "-10%"; }
                Mod+F               { maximize-column; }
                Mod+Home            { focus-column-first; }
                Mod+L               { spawn-sh "${lock}"; }
                Mod+Left            { focus-column-left; }
                Mod+Minus           { focus-workspace "misc"; }
                Mod+N               { spawn-sh "${lib.getExe' config.services.swaync.package "swaync-client"} -t"; }
                Mod+Page_Down       { focus-workspace-down; }
                Mod+Page_Up         { focus-workspace-up; }
                Mod+Parenleft       { focus-workspace "games"; }
                Mod+Plus            { set-column-width "+10%"; }
                Mod+Quotedbl        { focus-workspace "work"; }
                Mod+Return          { spawn-sh "kitty"; }
                Mod+Right           { focus-column-right; }
                Mod+S               { screenshot; }
                Mod+Shift+Comma     { show-hotkey-overlay; }
                Mod+Shift+Down      { move-window-down-or-to-workspace-down; }
                Mod+Shift+E         { quit; }
                Mod+Shift+End       { move-column-to-last; }
                Mod+Shift+F         { toggle-window-floating; }
                Mod+Shift+Home      { move-column-to-first; }
                Mod+Shift+Left      { consume-or-expel-window-left; }
                Mod+Shift+Page_Down { move-workspace-down; }
                Mod+Shift+Page_Up   { move-workspace-up; }
                Mod+Shift+Q         { close-window; }
                Mod+Shift+Right     { consume-or-expel-window-right; }
                Mod+Shift+S         { screenshot-window; }
                Mod+Shift+Up        { move-window-up-or-to-workspace-up; }
                Mod+Space           { spawn-sh "anyrun"; }
                Mod+Shift+Space     { spawn-sh "1password --quick-access"; }
                Mod+Up              { focus-window-or-workspace-up; }

                Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-column-right; }
                Mod+Shift+WheelScrollUp   cooldown-ms=150 { focus-column-left;  }

                Mod+WheelScrollDown  cooldown-ms=150 { focus-workspace-down; }
                Mod+WheelScrollLeft  cooldown-ms=150 { focus-column-left;    }
                Mod+WheelScrollRight cooldown-ms=150 { focus-column-right;   }
                Mod+WheelScrollUp    cooldown-ms=150 { focus-workspace-up;   }

                XF86AudioLowerVolume allow-when-locked=true { spawn-sh "swayosd-client --output-volume lower";       }
                XF86AudioMute        allow-when-locked=true { spawn-sh "swayosd-client --output-volume mute-toggle"; }
                XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "swayosd-client --output-volume raise";       }
                XF86AudioNext        allow-when-locked=true { spawn-sh "swayosd-client --playerctl next";        }
                XF86AudioPrev        allow-when-locked=true { spawn-sh "swayosd-client --playerctl prev";        }
                XF86AudioPlay        allow-when-locked=true { spawn-sh "swayosd-client --playerctl play-pause";  }
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

    # systemd.user.services.xwayland-satellite = {
    #   Unit = {
    #     Description = "XWayland Satellite";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #
    #   Service = {
    #     ExecStart = lib.getExe pkgs.xwayland-satellite;
    #     Restart = "on-failure";
    #     KillMode = "mixed";
    #   };
    #
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
