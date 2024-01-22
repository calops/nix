{
  pkgs,
  config,
  lib,
  ...
}: let
  addons = pkgs.nur.repos.rycee.firefox-addons;
in {
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta-bin.override {
        nativeMessagingHosts = [pkgs.tridactyl-native];
      };
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
          firenvim
        ];
        search = {
          default = "Google";
          force = true;
        };
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

          /* Default state: Set initial height to enable animation */
          #main-window #titlebar { height: 3em !important; }
          #main-window[uidensity="touch"] #titlebar { height: 3.35em !important; }
          #main-window[uidensity="compact"] #titlebar { height: 2.7em !important; }
          /* Hidden state: Hide native tabs strip */
          #main-window[titlepreface*="[Sidebery]"] #titlebar { height: 0 !important; }
          /* Hidden state: Fix z-index of active pinned tabs */
          #main-window[titlepreface*="[Sidebery]"] #tabbrowser-tabs { z-index: 0 !important; }
        '';
      };
    };

    xdg.configFile."tridactyl/tridactylrc".text = ''
      guiset_quiet hoverlink left
      guiset_quiet statuspanel left

      colorscheme dark

      set searchengine google
      set editorcmd ${config.my.roles.graphical.terminal} -e nvim

      setpref browser.uidensity 1

      bind / fillcmdline find
      bind ? fillcmdline find -?
      bind n findnext
      bind N findnext -1
      bind ,<space> nohlsearch
      bind ;m composite hint -pipe img src | js -p tri.excmds.open('images.google.com/searchbyimage?image_url=' + JS_ARG)
      bind ;M composite hint -pipe img src | jsb -p tri.excmds.tabopen('images.google.com/searchbyimage?image_url=' + JS_ARG)
      bind gd tabdetach
      bind gD composite tabduplicate | tabdetach

      bindurl www.google.com f hint -Jc .rc > .r > a
      bindurl www.google.com F hint -Jbc .rc>.r>a

      autocmd TriStart .* source_quiet ${config.xdg.configHome}/tridactyl/tridactylrc
    '';

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
