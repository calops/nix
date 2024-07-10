{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  darwinConfig ? null,
  ...
}:
{
  options.my = {
    configDir = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default =
        nixosConfig.my.configDir or darwinConfig.my.configDir or "${config.home.homeDirectory}/nix";
      description = "Location of the nix config directory (this repo)";
    };

    configType = lib.mkOption {
      type = lib.types.str;
      default =
        if config.my.isNixos then
          "nixos"
        else if config.my.isDarwin then
          "darwin"
        else
          "standalone";
    };

    isNixos = lib.mkOption {
      type = lib.types.bool;
      default = nixosConfig != null;
      readOnly = true;
    };

    isDarwin = lib.mkOption {
      type = lib.types.bool;
      default = darwinConfig != null;
      readOnly = true;
    };
  };

  config = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.11";
    home.sessionVariables.FLAKE = config.my.configDir;

    programs.gpg.enable = true;
    programs.dircolors.enable = true;

    services.network-manager-applet.enable = true;
    services.udiskie = lib.mkIf (!config.my.isDarwin) {
      enable = true;
      settings.program_options = {
        tray = true; # FIXME: tray icon isn't working on ironbar
      };
    };

    programs.nh = {
      enable = true;
      flake = config.my.configDir;
    };

    nix.gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };

    xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      defaultApplications =
        let
          firefox = "firefox-beta.desktop";
        in
        {
          "text/html" = firefox;
          "x-scheme-handler/http" = firefox;
          "x-scheme-handler/https" = firefox;
          "x-scheme-handler/about" = firefox;
          "x-scheme-handler/unknown" = firefox;
        };
    };
  };
}
