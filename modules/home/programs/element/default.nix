# This isn't in a flat element.nix file because the automatic import from Snowfall somehow results in an
# infinite recursion. No idea why.
{
  pkgs,
  config,
  lib,
  nixosConfig ? null,
  ...
}:
let
  cfg = config.my.roles.graphical;
  palette = config.my.colors.palette.withHashtag;
  font = config.my.fonts.iosevka-comfy.name;

  # Electron doesn't play nice with the Wayland/NVidia combo
  # FIXME: this removes desktop entries and probably other stuff, find a better way to wrap this
  elementPkg =
    if nixosConfig.my.roles.nvidia.enable or false then
      pkgs.writeShellScriptBin "element-desktop" ''
        NIXOS_OZONE_WL=0 ${lib.getExe pkgs.element-desktop} --ozone-platform-hint=auto
      ''
    else
      pkgs.element-desktop;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ elementPkg ];

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
            colors = {
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
              secondary-content = "${palette.subtext0}";
              tertiary-content = "${palette.coral}";
              timeline-text-secondary-color = "${palette.subtext0}";
              timeline-highlights-color = "${palette.mantle}";
              reaction-row-button-selected-bg-color = "${palette.surface2}";
              menu-selected-color = "${palette.surface1}";
              focus-bg-color = "${palette.surface2}";
              room-highlight-color = "${palette.teal}";
              togglesw-off-color = "${palette.overlay2}";
              other-user-pill-bg-color = "${palette.tangerine}";
            };
            compound = lib.mapAttrs' (name: value: lib.nameValuePair "--cpd-color-${name}" value) {
              text-decorative-2 = "${palette.green}";
              text-decorative-1 = "${palette.blue}";
              text-decorative-3 = "${palette.mauve}";
              text-decorative-4 = "${palette.teal}";
              text-decorative-5 = "${palette.coral}";
              text-decorative-6 = "${palette.peach}";

              bg-decorative-1 = "${palette.forest}";
              bg-decorative-2 = "${palette.navy}";
              bg-decorative-3 = "${palette.violet}";
              bg-decorative-4 = "${palette.turquoise}";
              bg-decorative-5 = "${palette.cherry}";
              bg-decorative-6 = "${palette.tangerine}";
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
