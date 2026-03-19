{
  lib,
  config,
  pkgs,
  ...
}:
let
  enabled = config.my.roles.graphical.enable && config.programs.firefoxpwa.enable;
  profileId = "01KM3AB7E8CC2YRN85SEK03REX";
in
{
  config = lib.mkIf enabled {
    programs.firefoxpwa.profiles.${profileId} = {
      name = "sable";

      sites."01KM38RYD60VZEV7QB5KSK5JYF" = {
        name = "Sable";
        url = "https://app.sable.moe";
        manifestUrl = "https://app.sable.moe/manifest.json";

        desktopEntry = {
          enable = true;
          categories = [
            "Network"
            "Chat"
          ];

          icon = pkgs.fetchurl {
            url = "https://app.sable.moe/assets/favicon-CemZgig7.png";
            hash = "sha256-XzeHJiij2JC15ZsH5GwAYHIToKEX4Kg+2BkqV5P4wy8=";
          };
        };
      };
    };

    xdg.dataFile = {
      "firefoxpwa/profiles/${profileId}/user.js".text = ''
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      '';

      "firefoxpwa/profiles/${profileId}/chrome/userContent.css".text =
        # css
        ''
          body, p, div, span, section {
              font-family: "Aporetic Sans" !important;
          }

          code, pre, kbd, samp {
              font-family: "Aporetic Sans Mono" !important;
          }
        '';
    };
  };
}
