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
              # colors = let
              #   rainbow = [
              #     "${palette.purple}"
              #     "${palette.red}"
              #     "${palette.gold}"
              #     "${palette.green}"
              #     "${palette.blue}"
              #     "${palette.teal}"
              #     "${palette.coral}"
              #     "${palette.orange}"
              #   ];
              # in {
              #   accent-color = "${palette.violet}";
              #   primary-color = "${palette.violet}";
              #   warning-color = "${palette.cherry}";
              #   alert = "${palette.yellow}";
              #   sidebar-color = "${palette.crust}";
              #   roomlist-background-color = "${palette.mantle}";
              #   roomlist-text-color = "${palette.text}";
              #   roomlist-text-secondary-color = "${palette.base}";
              #   roomlist-highlights-color = "${palette.surface1}";
              #   roomlist-separator-color = "${palette.overlay0}";
              #   timeline-background-color = "${palette.base}";
              #   timeline-text-color = "${palette.text}";
              #   secondary-content = "${palette.flamingo}";
              #   tertiary-content = "${palette.coral}";
              #   timeline-text-secondary-color = "${palette.subtext0}";
              #   timeline-highlights-color = "${palette.mantle}";
              #   reaction-row-button-selected-bg-color = "${palette.surface2}";
              #   menu-selected-color = "${palette.surface1}";
              #   focus-bg-color = "${palette.surface2}";
              #   room-highlight-color = "${palette.teal}";
              #   togglesw-off-color = "${palette.overlay2}";
              #   other-user-pill-bg-color = "${palette.tangerine}";
              #   username-colors = rainbow;
              #   avatar-background-colors = rainbow;
              # };
              compound = lib.mapAttrs' (name: value: lib.nameValuePair "--cpd-color-${name}" value) {
                text-primary = "${palette.text}";
                text-secondary = "${palette.subtext0}";
                text-placeholder = "${palette.overlay1}";
                text-disabled = "${palette.overlay0}";
                text-action-primary = "${palette.text}";
                text-action-accent = "${palette.forest}";
                text-link-external = "${palette.peach}";
                text-critical-primary = "${palette.cherry}";
                text-success-primary = "${palette.green}";
                text-info-primary = "${palette.blue}";
                text-on-solid-primary = "${palette.base}";
                text-decorative-2 = "${palette.green}";
                text-decorative-1 = "${palette.blue}";
                text-decorative-3 = "${palette.mauve}";
                text-decorative-4 = "${palette.teal}";
                text-decorative-5 = "${palette.coral}";
                text-decorative-6 = "${palette.peach}";

                bg-subtle-primary = "${palette.base}";
                bg-subtle-secondary = "${palette.mantle}";
                bg-canvas-default = "${palette.crust}";
                bg-canvas-disabled = "${palette.crust}";
                bg-action-primary-rest = "${palette.text}";
                bg-action-primary-hovered = "${palette.overlay2}";
                bg-action-primary-pressed = "${palette.overlay0}";
                bg-action-primary-disabled = "${palette.surface1}";
                bg-action-secondary-rest = "${palette.base}";
                bg-action-secondary-hovered = "${palette.surface1}";
                bg-action-secondary-pressed = "${palette.surface2}";
                bg-critical-primary = "${palette.cherry}";
                bg-critical-hovered = "${palette.red}";
                bg-critical-subtle = "${palette.cherry}"; # TODO: dark colors
                bg-critical-subtle-hovered = "${palette.red}"; # TODO: dark colors
                bg-success-subtle = "${palette.forest}"; # TODO: dark colors
                bg-info-subtle = "${palette.navy}"; # TODO: dark colors
                bg-decorative-1 = "${palette.forest}";
                bg-decorative-2 = "${palette.navy}";
                bg-decorative-3 = "${palette.violet}";
                bg-decorative-4 = "${palette.turquoise}";
                bg-decorative-5 = "${palette.cherry}";
                bg-decorative-6 = "${palette.tangerine}";
                bg-accent-rest = "${palette.turquoise}";
                bg-accent-hovered = "${palette.teal}";
                bg-accent-pressed = "${palette.mint}";

                border-disabled = "${palette.crust}";
                border-focused = "${palette.purple}";
                border-interactive-primary = "${palette.overlay0}";
                border-interactive-secondary = "${palette.overlay1}";
                border-interactive-hovered = "${palette.overlay2}";
                border-critical-primary = "${palette.cherry}";
                border-critical-hovered = "${palette.red}";
                border-critical-subtle = "${palette.cherry}"; # TODO: dark colors
                border-success-subtle = "${palette.forest}"; # TODO: dark colors
                border-info-subtle = "${palette.navy}"; # TODO: dark colors

                icon-primary = "${palette.text}";
                icon-secondary = "${palette.subtext0}";
                icon-tertiary = "${palette.overlay2}";
                icon-quaternary = "${palette.overlay1}";
                icon-disabled = "${palette.overlay0}";
                # icon-primary-alpha = "";
                # icon-secondary-alpha = "";
                # icon-tertiary-alpha = "";
                # icon-quaternary-alpha = "";
                icon-accent-tertiary = "${palette.turquoise}";
                icon-critical-primary = "${palette.red}";
                icon-success-primary = "${palette.green}";
                icon-info-primary = "${palette.blue}";
                icon-on-solid-primary = "${palette.base}";
              };
            }
          ];
          use_system_theme = false;
          default_theme = "custom-Radiant";
          useSystemFont = true;
          systemFont = font;
          layout = "irc";
        };
        useSystemFont = true;
        systemFont = font;
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
