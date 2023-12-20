{
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.my.roles.graphical;
  addons = inputs.firefox-addons.packages.${pkgs.system};
in {
  programs.firefox = {
    enable = cfg.enable;
    package = pkgs.firefox-beta-bin;
    profiles.default = {
      name = "default";
      id = 0;
      isDefault = true;
      extensions = with addons; [
        ublock-origin
        onepassword-password-manager
        bitwarden
        tridactyl
        reddit-enhancement-suite
        sidebery
        stylus
        sponsorblock
      ];
      search.default = "Google";
      userChrome = ''
        tabs {
          counter-reset: tab-counter;
        }

        #sidebar-header {
          display: none;
        }

        #nav-bar {
          box-shadow: 0 0 16px black !important;
          z-index: 1;
        }

        #urlbar {
          z-index: 2 !important;
        }

        @-moz-document url("chrome://browser/content/browser.xhtml"){
          #browser {
            overflow: hidden;
          }

          #sidebar-splitter {
            width: 1px !important;
          }

          #sidebar-box {
            box-shadow: 0 0 16px black;
            position: relative;
            z-index: 1;
          }
        }

        #main-window #TabsToolbar {
          overflow: hidden;
          transition: height .3s .3s !important;
        }
        #main-window[titlepreface*="[Sidebery]"] #TabsToolbar {
          height: 0 !important;
        }
        #main-window[titlepreface*="[Sidebery]"] #tabbrowser-tabs {
          z-index: 0 !important;
        }
      '';
    };
  };
}
