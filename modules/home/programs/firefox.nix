{
  pkgs,
  config,
  lib,
  ...
}:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
  package =
    if pkgs.stdenv.isDarwin then
      pkgs.firefox-beta-bin.overrideAttrs {
        # nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
        # postInstall = ''
        #   wrapProgram $out/Applications/Firefox.app/Contents/MacOS/firefox --set MOZ_LEGACY_PROFILES 1
        # '';
      }
    else
      pkgs.firefox-beta-bin.override {
        nativeMessagingHosts = [
          pkgs.tridactyl-native
          pkgs.vdhcoapp
        ];
      };
in
{
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = lib.optional (!pkgs.stdenv.isDarwin) pkgs.firefoxpwa;
    programs.firefox = {
      enable = true;
      package = package;
      profiles = rec {
        default = {
          name = "default";
          id = 0;
          isDefault = true;
          extensions = [
            addons.ublock-origin
            addons.onepassword-password-manager
            addons.bitwarden
            addons.tridactyl
            addons.reddit-enhancement-suite
            addons.sidebery
            addons.stylus
            addons.sponsorblock
            addons.firenvim
            addons.video-downloadhelper
            addons.pwas-for-firefox
          ];
          search = {
            default = "Google";
            force = true;
          };
          userChrome =
            # css
            ''
              .titlebar-buttonbox {
                appearance: none !important;
                margin-inline: 0 !important;
                -moz-box-direction: reverse !important;
                flex-direction: row-reverse !important;
              }

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
                transition: height 0.3s 0.3s !important;
                height: 3em !important;
                visibility: visible !important;
              }
              #main-window[uidensity="touch"] #TabsToolbar { height: 3.35em !important; }
              #main-window[uidensity="compact"] #TabsToolbar { height: 2.7em !important; }
              #main-window[titlepreface*="[Sidebery]"] #TabsToolbar { visibility: collapse !important; }
            '';
        };

        gw = default // {
          name = "gw";
          id = 1;
          isDefault = false;
        };
      };
    };

    xdg.configFile."tridactyl/tridactylrc".text =
      # vim
      ''
        sanitise tridactyllocal tridactylsync

        set configversion 2.0
        set theme dark
        set searchengine google
        set editorcmd ${config.my.roles.graphical.terminal} -e nvim

        bind / fillcmdline find
        bind ? fillcmdline find -?
        bind n findnext
        bind N findnext -1
        bind ,<space> nohlsearch
        bind ;m composite hint -pipe img src | js -p tri.excmds.open('images.google.com/searchbyimage?image_url=' + JS_ARG)
        bind ;M composite hint -pipe img src | jsb -p tri.excmds.tabopen('images.google.com/searchbyimage?image_url=' + JS_ARG)
        bind gd tabdetach
        bind gD composite tabduplicate | tabdetach
        unbind C-f

        bindurl www.google.com f hint -Jc .rc > .r > a
        bindurl www.google.com F hint -Jbc .rc > .r > a

        autocmd TriStart .* source_quiet "${config.xdg.configHome}/tridactyl/tridactylrc"
      '';

    home.sessionVariables = lib.mkMerge [
      (lib.optionalAttrs pkgs.stdenv.isLinux {
        MOZ_ENABLE_WAYLAND = "1";
      })
      (lib.optionalAttrs pkgs.stdenv.isDarwin {
        MOZ_LEGACY_PROFILES = "1";
      })
    ];
  };
}
