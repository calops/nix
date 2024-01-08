{
  pkgs,
  roles,
  colors,
  lib,
  ...
}: let
  cfg = roles.graphical;
  palette = colors.palette; # TODO
in
  with lib; {
    config = mkIf cfg.enable {
      home.packages = [
        pkgs.element-desktop
      ];

      xdg.configFile."Element/config.json".text = builtins.toJSON {
        settingDefaults = {
          custom_themes = [
            {
              name = "Catppuccin Mocha";
              is_dark = true;
              colors = {
                accent-color = "#b4befe";
                primary-color = "#b4befe";
                warning-color = "#f38ba8";
                alert = "#e5c890";
                sidebar-color = "#11111b";
                roomlist-background-color = "#181825";
                roomlist-text-color = "#cdd6f4";
                roomlist-text-secondary-color = "#1e1e2e";
                roomlist-highlights-color = "#45475a";
                roomlist-separator-color = "#7f849c";
                timeline-background-color = "#1e1e2e";
                timeline-text-color = "#cdd6f4";
                secondary-content = "#cdd6f4";
                tertiary-content = "#cdd6f4";
                timeline-text-secondary-color = "#a6adc8";
                timeline-highlights-color = "#181825";
                reaction-row-button-selected-bg-color = "#585b70";
                menu-selected-color = "#45475a";
                focus-bg-color = "#585b70";
                room-highlight-color = "#89dceb";
                togglesw-off-color = "#9399b2";
                other-user-pill-bg-color = "#89dceb";
                username-colors = [
                  "#cba6f7"
                  "#eba0ac"
                  "#fab387"
                  "#a6e3a1"
                  "#94e2d5"
                  "#89dceb"
                  "#74c7ec"
                  "#b4befe"
                ];
                avatar-background-colors = [
                  "#89b4fa"
                  "#cba6f7"
                  "#a6e3a1"
                ];
              };
            }
            {
              name = "Catppuccin Latte";
              is_dark = false;
              colors = {
                accent-color = "#7287fd";
                primary-color = "#7287fd";
                warning-color = "#d20f39";
                alert = "#df8e1d";
                sidebar-color = "#dce0e8";
                roomlist-background-color = "#e6e9ef";
                roomlist-text-color = "#4c4f69";
                roomlist-text-secondary-color = "#4c4f69";
                roomlist-highlights-color = "#bcc0cc";
                roomlist-separator-color = "#8c8fa1";
                timeline-background-color = "#eff1f5";
                timeline-text-color = "#4c4f69";
                secondary-content = "#4c4f69";
                tertiary-content = "#4c4f69";
                timeline-text-secondary-color = "#6c6f85";
                timeline-highlights-color = "#bcc0cc";
                reaction-row-button-selected-bg-color = "#bcc0cc";
                menu-selected-color = "#bcc0cc";
                focus-bg-color = "#acb0be";
                room-highlight-color = "#04a5e5";
                togglesw-off-color = "#7c7f93";
                other-user-pill-bg-color = "#04a5e5";
                username-colors = [
                  "#8839ef"
                  "#e64553"
                  "#fe640b"
                  "#40a02b"
                  "#179299"
                  "#04a5e5"
                  "#209fb5"
                  "#7287fd"
                ];
                avatar-background-colors = [
                  "#1e66f5"
                  "#8839ef"
                  "#40a02b"
                ];
              };
            }
          ];
          default_theme = "Catppuccin Mocha";
          useSystemFont = true;
          systemFont = cfg.fonts.monospace.name;
          layout = "irc";
        };
        useSystemFont = true;
        systemFont = cfg.fonts.monospace.name;
        default_theme = "Catppuccin Mocha";
        show_labs_settings = true;
        features = {
          feature_spotlight = true;
          feature_video_rooms = true;
          feature_latex_maths = true;
          feature_pinning = true;
          feature_jump_to_date = true;
          feature_state_counters = true;
          feature_mjolnir = true;
          feature_bridge_state = true;
          feature_custom_themes = true;
          feature_extensible_events = true;
          feature_html_topic = true;
          feature_exploring_public_spaces = true;
        };
      };
    };
  }
