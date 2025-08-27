{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  darwinConfig ? null,
  perSystem,
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

  imports = [
    ./ai.nix
    ./audio.nix
    ./graphics.nix
    ./gaming.nix
    ./terminal.nix
    ./darwin
  ];

  config = {
    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
    programs.gpg.enable = true;
    programs.dircolors.enable = true;

    services.network-manager-applet.enable = !pkgs.stdenv.isDarwin;
    services.gnome-keyring.enable = !pkgs.stdenv.isDarwin;

    services.udiskie = {
      enable = !pkgs.stdenv.isDarwin;
      tray = "auto";
    };

    home.sessionVariables = {
      NH_FLAKE = config.my.configDir;
      # Determinate nix removes flakes and command from experimental features, which NH checks for
      NH_NO_CHECKS = "1";
    };
    programs.nh = lib.mkIf (config.my.configType == "standalone") {
      enable = true;
      package = perSystem.self.nh;
      flake = config.my.configDir;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
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
