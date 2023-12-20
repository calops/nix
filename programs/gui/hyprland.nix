{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.my.roles.graphical;
  hyprland-pkg-name =
    if cfg.nvidia.enable
    then "hyprland-nvidia"
    else "hyprland";
  monitors = rec {
    primary = cfg.monitors.primary.name;
    secondary = cfg.monitors.secondary.name or primary;
  };
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = cfg.enable;
      package = lib.my.nixGlWrap {
        inherit config;
        pkg = inputs.hyprland.packages.${pkgs.system}.${hyprland-pkg-name};
      };
      plugins = [
        inputs.hy3.packages.${pkgs.system}.hy3
      ];
      extraConfig = ''
        $wallpaper=~/Pictures/Wallpapers/z-w-gu-canal.jpg
        $term=${cfg.terminal}

        monitor=,preferred,auto,1

        wsbind = 1,${monitors.primary}
        wsbind = 3,${monitors.primary}
        wsbind = 2,${monitors.primary}
        wsbind = 4,${monitors.primary}
        wsbind = 5,${monitors.primary}
        wsbind = 6,${monitors.primary}
        wsbind = 7,${monitors.primary}
        wsbind = 8,${monitors.primary}
        wsbind = 9,${monitors.primary}
        wsbind = 10,${monitors.secondary}

        exec-once = hyprpaper & clipit & udiskie &
        exec-once = eww -c ~/.config/eww/bar open bar &
        exec-once = /usr/lib/polkit-kde-authentication-agent-1 &
        exec-once = firefox & element-desktop & slack &

        windowrulev2=workspace 1 silent,class:firefox
        windowrulev2=workspace 6 silent,class:Steam
        windowrulev2=workspace 9 silent,class:Element
        windowrulev2=workspace 9 silent,class:Discord
        windowrulev2=workspace 10 silent,class:Slack

        source = ~/.config/hypr/colors.conf

        input {
            kb_layout = fr
            follow_mouse = 1
            float_switch_override_focus = 0

            touchpad {
                natural_scroll = yes
            }
        }

        general {
            gaps_in = 5
            gaps_out = 10
            border_size = 2
            col.active_border = $mauve $yellow $teal $green $red $sapphire $peach 45deg
            col.inactive_border = rgba(59595900)

            layout = hy3
        }

        misc {
            enable_swallow = true
            swallow_regex = ""
        }

        decoration {
            rounding = 10
            multisample_edges = 1
            blur = yes
            blur_size = 3
            blur_passes = 1
            blur_new_optimizations = on

            drop_shadow = yes
            shadow_range = 20
            shadow_render_power = 10
            col.shadow = rgba(1a1a1abb)
        }

        animations {
            enabled = yes

            animation = windows, 1, 7, default
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }

        dwindle {
            preserve_split = yes
            force_split = 2
        }

        master {
            new_is_master = false
        }

        gestures {
            workspace_swipe = true
        }

        misc {
            enable_swallow = true
            swallow_regex = ^(kitty)$
        }

        windowrulev2 = float,class:^(ulauncher)$
        windowrulev2 = tile,class:^(neovide)$
        windowrulev2 = float,title:^(Firefox — Sharing Indicator)$
        windowrulev2 = float,title:^(.*Sharing Indicator.*)$

        $mainMod = SUPER

        bind = $mainMod, return, exec, kitty
        bind = $mainMod, L, exec, swaylock -S --clock --effect-pixelate=7 --ring-color=ffffff00 --line-color=ffffff00
        bind = $mainMod SHIFT, Q, killactive,
        bind = $mainMod, M, exit,
        bind = $mainMod, E, exec, firefox
        bind = $mainMod, V, pin,
        bind = $mainMod, F, fullscreen,
        bind = $mainMod SHIFT, F, togglefloating,
        bind = $mainMod, space, exec, ulauncher
        bind = $mainMod, P, pseudo, # dwindle
        bind = $mainMod, backspace, togglesplit,
        bind = $mainMod, R, exec, hyprshot -mregion
        bind = SUPERSHIFT, delete, exec, scratchpad
        bind = SUPER, delete, exec, scratchpad -g

        bind = $mainMod, left, hy3:movefocus, l
        bind = $mainMod, right, hy3:movefocus, r
        bind = $mainMod, up, hy3:movefocus, u
        bind = $mainMod, down, hy3:movefocus, d

        bind = $mainMod SHIFT, left, hy3:movewindow, l
        bind = $mainMod SHIFT, right, hy3:movewindow, r
        bind = $mainMod SHIFT, up, hy3:movewindow, u
        bind = $mainMod SHIFT, down, hy3:movewindow, d

        bind = $mainMod, 10, workspace, 1
        bind = $mainMod, 11, workspace, 2
        bind = $mainMod, 12, workspace, 3
        bind = $mainMod, 13, workspace, 4
        bind = $mainMod, 14, workspace, 5
        bind = $mainMod, 15, workspace, 6
        bind = $mainMod, 16, workspace, 7
        bind = $mainMod, 17, workspace, 8
        bind = $mainMod, 18, workspace, 9
        bind = $mainMod, 19, workspace, 10

        bind = $mainMod CONTROL, right, workspace, e+1
        bind = $mainMod CONTROL, left, workspace, e-1
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        bind = $mainMod SHIFT, 10, movetoworkspacesilent, 1
        bind = $mainMod SHIFT, 11, movetoworkspacesilent, 2
        bind = $mainMod SHIFT, 12, movetoworkspacesilent, 3
        bind = $mainMod SHIFT, 13, movetoworkspacesilent, 4
        bind = $mainMod SHIFT, 14, movetoworkspacesilent, 5
        bind = $mainMod SHIFT, 15, movetoworkspacesilent, 6
        bind = $mainMod SHIFT, 16, movetoworkspacesilent, 7
        bind = $mainMod SHIFT, 17, movetoworkspacesilent, 8
        bind = $mainMod SHIFT, 18, movetoworkspacesilent, 9
        bind = $mainMod SHIFT, 19, movetoworkspacesilent, 10

        bindm = $mainMod, mouse:272, hy3:movewindow
        bindm = $mainMod, mouse:273, resizewindow

        binde=, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        binde=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        binde=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

        exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      '';
    };
  };
}
