{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.graphical;
  palette = config.my.colors.palette.withHastag;
  font = config.my.fonts.iosevka-comfy.name;

  # Electron doesn't play nice with the Wayland/NVidia combo
  pkg = pkgs.writeShellScriptBin "element-desktop" ''
    NIXOS_OZONE_WL= ${lib.getExe pkgs.element-desktop} --use-gl=desktop
  '';
in
  with lib; {
    config = mkIf cfg.enable {
      home.packages = [
        pkg
      ];

      xdg.configFile."Element/config.json".text = builtins.toJSON {
        setting_defaults = {
          custom_themes = [
            {
              name = "Radiant";
              is_dark = true;
              fonts = {
                general = font;
                monospace = font;
              };
              colors = let
                rainbow = [
                  "${palette.purple}"
                  "${palette.red}"
                  "${palette.gold}"
                  "${palette.green}"
                  "${palette.blue}"
                  "${palette.teal}"
                  "${palette.coral}"
                  "${palette.orange}"
                ];
              in {
                accent-color = "${palette.violet}";
                primary-color = "${palette.violet}";
                warning-color = "${palette.cherry}";
                alert = "${palette.yellow}";
                sidebar-color = "${palette.crust}";
                roomlist-background-color = "${palette.mantle}";
                roomlist-text-color = "${palette.text}";
                roomlist-text-secondary-color = "${palette.base}";
                roomlist-highlights-color = "${palette.surface1}";
                roomlist-separator-color = "${palette.overlay0}";
                timeline-background-color = "${palette.base}";
                timeline-text-color = "${palette.text}";
                secondary-content = "${palette.flamingo}";
                tertiary-content = "${palette.coral}";
                timeline-text-secondary-color = "${palette.subtext0}";
                timeline-highlights-color = "${palette.mantle}";
                reaction-row-button-selected-bg-color = "${palette.surface2}";
                menu-selected-color = "${palette.surface1}";
                focus-bg-color = "${palette.surface2}";
                room-highlight-color = "${palette.teal}";
                togglesw-off-color = "${palette.overlay2}";
                other-user-pill-bg-color = "${palette.tangerine}";
                username-colors = rainbow;
                avatar-background-colors = rainbow;
              };
            }
          ];
          use_system_theme = false;
          default_theme = "custom-Radiant";
          useSystemFont = true;
          systemFont = cfg.fonts.monospace.name;
          layout = "irc";
        };
        useSystemFont = true;
        systemFont = cfg.fonts.monospace.name;
        default_theme = "custom-Radiant";
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
