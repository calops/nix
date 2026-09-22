{ ... }:
{
  den.aspects.programs.provides.sable = {
    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        profileId = "01KM3AB7E8CC2YRN85SEK03REX";
      in
      {
        programs.firefoxpwa.profiles.${profileId} = lib.mkIf config.programs.firefoxpwa.enable {
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

              # The /assets/ names are content-hashed by Vite, so they change on
              # every Sable deploy and rot the pin. /public/ is stable.
              icon = pkgs.fetchurl {
                url = "https://app.sable.moe/public/logo-maskable/logo-maskable-512x512.png";
                hash = "sha256-osszM1f+cMn+dC9E6TlRNB62/eqGe3cO6Jj9kc4eHSU=";
              };
            };
          };
        };

        xdg.dataFile = lib.mkIf config.programs.firefoxpwa.enable {
          "firefoxpwa/profiles/${profileId}/user.js".text = ''
            user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          '';

          "firefoxpwa/profiles/${profileId}/chrome/userContent.css".text = ''
            body, p, div, span, section {
                font-family: "Aporetic Sans" !important;
            }

            code, pre, kbd, samp {
                font-family: "Aporetic Sans Mono" !important;
            }
          '';
        };
      };
  };
}
