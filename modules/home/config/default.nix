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
    home.stateVersion = "25.05";
    home.sessionVariables.FLAKE = config.my.configDir;

    programs.gpg.enable = true;
    programs.dircolors.enable = true;

    services.network-manager-applet.enable = !pkgs.stdenv.isDarwin;

    services.udiskie = {
      enable = !pkgs.stdenv.isDarwin;
      tray = "auto";
    };

    programs.nh = lib.mkIf (config.my.configType == "standalone") {
      enable = true;
      flake = config.my.configDir;
    };

    nix.gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };

    xdg.enable = true;
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
          "application/pdf" = "org.pwmt.zathura.desktop";
        };
    };

    # Fix systemd order of some targets so that they play nice with most compositors
    systemd.user.targets.tray.Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
    systemd.user.services.swayidle.Unit.After = lib.mkForce [ "graphical-session.target" ];
    systemd.user.services.udiskie.Unit.After = lib.mkForce [
      "graphical-session.target"
      "tray.target"
    ];
    systemd.user.services.network-manager-applet.Unit.After = lib.mkForce [
      "graphical-session.target"
      "tray.target"
    ];
  };
}
