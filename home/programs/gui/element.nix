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
        setting_defaults = {
          custom_themes = [
            {
              name = "Catppuccin Mocha";
              is_dark = true;
              fonts = {
                general = "Iosevka Comfy";
                monospace = "Iosevka Comfy";
              };
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
          ];
          use_system_theme = false;
          default_theme = "custom-Catppuccin Mocha";
          useSystemFont = true;
          systemFont = cfg.fonts.monospace.name;
          layout = "irc";
        };
        useSystemFont = true;
        systemFont = cfg.fonts.monospace.name;
        default_theme = "custom-Catppuccin Mocha";
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
