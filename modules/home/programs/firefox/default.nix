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
      pkgs.firefox-beta
    else
      pkgs.firefox-beta.override {
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

          settings = {
            "app.update.auto" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.link.open_newwindow" = 3;
            "browser.ml.chat.provider" = "https://gemini.google.com";
            "browser.tabs.groups.enabled" = true;
            "browser.uidensity" = 1;
            "browser.urlbar.resultMenu.keyboardAccessible" = false;
            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
            "devtools.toolbox.host" = "right";
            "sidebar.revamp.round-content-area" = true;
            "sidebar.verticalTabs" = true;
            "sidebar.visibility" = "always-show";
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          extensions.packages = [
            addons.ublock-origin
            addons.onepassword-password-manager
            addons.bitwarden
            addons.tridactyl
            addons.reddit-enhancement-suite
            addons.stylus
            addons.sponsorblock
            addons.firenvim
            addons.video-downloadhelper
            addons.pwas-for-firefox
          ];

          search = {
            default = "google";
            force = true;
          };

          userChrome =
            ''
              @import url("file:///${config.my.colors.palette.asCss}");
            ''
            + builtins.readFile ./userChrome.css;
        };

        gw = default // {
          name = "gw";
          id = 1;
          isDefault = false;
        };
      };
    };

    stylix.targets.firefox.profileNames = [
      "default"
      "gw"
    ];

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
