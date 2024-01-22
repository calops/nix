{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.my.roles.graphical;
  palette = config.my.colors.palette;
  monitors = rec {
    primary = cfg.monitors.primary.id;
    secondary = cfg.monitors.secondary.id or primary;
  };
  layout = "hy3";
  movefocus = "hy3:movefocus";
  movewindow = "hy3:movewindow";
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hy3
      ];
      settings = {
        #monitor = ",preferred,auto,1";
        #wsbind = [
        #"1,${monitors.primary}"
        #"3,${monitors.primary}"
        #"2,${monitors.primary}"
        #"4,${monitors.primary}"
        #"5,${monitors.primary}"
        #"6,${monitors.primary}"
        #"7,${monitors.primary}"
        #"8,${monitors.primary}"
        #"9,${monitors.primary}"
        #"10,${monitors.secondary}"
        #];
        exec-once = [
          #(lib.getExe pkgs.hyprpaper)
          "eww -c ${config.xdg.configHome}/eww/bar open bar"
          (lib.getExe pkgs.firefox)
          (lib.getExe' pkgs.ulauncher "ulauncher")
          (lib.getExe pkgs.element-desktop)
        ];
        windowrulev2 = [
          "workspace 1 silent,class:firefox"
          "workspace 6 silent,class:Steam"
          "workspace 9 silent,class:Element"
          "workspace 9 silent,class:Discord"
          "workspace 10 silent,class:Slack"
          "float,class:ulauncher"
          "float,class:pavucontrol"
        ];
        layerrule = [
          "blur, swaync-control-center"
          "ignorealpha 0.5, swaync-control-center"
          "blur, swaync-notification-window"
          "ignorealpha 0.5, swaync-notification-window"
        ];
        input = {
          kb_layout = "fr";
          follow_mouse = 1;
          float_switch_override_focus = 0;
          touchpad = {
            natural_scroll = true;
          };
        };
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.inactive_border" = lib.mkForce "rgba(59595900)";
          layout = layout;
        };
        decoration = {
          rounding = 10;
          blur.size = 3;
          drop_shadow = true;
          shadow_range = 20;
          shadow_render_power = 10;
          "col.shadow" = lib.mkForce "rgba(1a1a1abb)";
        };
        animations = {
          enabled = true;
          animation = [
            "windows, 1, 7, default"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        dwindle = {
          preserve_split = true;
          force_split = 2;
        };
        master.new_is_master = false;
        gestures.workspace_swipe = true;
        misc = {
          enable_swallow = true;
          swallow_regex = "^(${cfg.terminal})$";
        };
        bind = [
          "SUPER, return, exec, ${cfg.terminal}"
          "SUPER, L, exec, swaylock -S"
          "SUPER SHIFT, Q, killactive,"
          "SUPER, M, exit,"
          "SUPER, E, exec, firefox"
          "SUPER, V, pin,"
          "SUPER, F, fullscreen,"
          "SUPER, N, exec, ${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t"
          "SUPER SHIFT, F, togglefloating,"
          "SUPER, space, exec, ulauncher"
          "SUPER, P, pseudo,"
          "SUPER, backspace, togglesplit,"
          "SUPER, R, exec, grimblast copy area"
          "SUPERSHIFT, delete, exec, scratchpad"
          "SUPER, delete, exec, scratchpad -g"
          "SUPER, left, ${movefocus}, l"
          "SUPER, right, ${movefocus}, r"
          "SUPER, up, ${movefocus}, u"
          "SUPER, down, ${movefocus}, d"
          "SUPER SHIFT, left, ${movewindow}, l"
          "SUPER SHIFT, right, ${movewindow}, r"
          "SUPER SHIFT, up, ${movewindow}, u"
          "SUPER SHIFT, down, ${movewindow}, d"
          "SUPER, 10, workspace, 1"
          "SUPER, 11, workspace, 2"
          "SUPER, 12, workspace, 3"
          "SUPER, 13, workspace, 4"
          "SUPER, 14, workspace, 5"
          "SUPER, 15, workspace, 6"
          "SUPER, 16, workspace, 7"
          "SUPER, 17, workspace, 8"
          "SUPER, 18, workspace, 9"
          "SUPER, 19, workspace, 10"
          "SUPER CONTROL, right, workspace, e+1"
          "SUPER CONTROL, left, workspace, e-1"
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          "SUPER SHIFT, 10, movetoworkspacesilent, 1"
          "SUPER SHIFT, 11, movetoworkspacesilent, 2"
          "SUPER SHIFT, 12, movetoworkspacesilent, 3"
          "SUPER SHIFT, 13, movetoworkspacesilent, 4"
          "SUPER SHIFT, 14, movetoworkspacesilent, 5"
          "SUPER SHIFT, 15, movetoworkspacesilent, 6"
          "SUPER SHIFT, 16, movetoworkspacesilent, 7"
          "SUPER SHIFT, 17, movetoworkspacesilent, 8"
          "SUPER SHIFT, 18, movetoworkspacesilent, 9"
          "SUPER SHIFT, 19, movetoworkspacesilent, 10"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
        # binde = [
        #   "XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        #   "XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        #   "XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        # ];
      };
    };
    programs.swaylock = {
      enable = true;
      settings = {
        clock = true;
        effect-pixelate = 7;
        ring-color = lib.mkForce "ffffff00";
        line-color = lib.mkForce "ffffff00";
      };
    };
    services.clipman.enable = true;
    home.packages = with inputs.hyprland-contrib.packages.${pkgs.system}; [
      grimblast
      hyprprop
      scratchpad
    ];
  };
}
