{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../common
    inputs.stylix.nixosModules.stylix
    inputs.madness.nixosModules.madness
  ] ++ lib.snowfall.fs.get-non-default-nix-files ./.;

  options = {
    my.configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      apply = toString;
      default = null;
      description = "Location of the nix config directory (this repo)";
    };
  };

  config = {
    system.stateVersion = "25.05";
    hardware.enableAllFirmware = true;
    security.rtkit.enable = true;
    virtualisation.docker.enable = true;
    stylix.homeManagerIntegration.autoImport = false;
    home-manager.backupFileExtension = "hm-backup";
    madness.enable = true;

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 100000;
      "fs.inotify.max_queued_events" = 100000;
    };

    console = {
      font = "ter-124b";
      keyMap = lib.mkDefault "fr";
      packages = [ pkgs.terminus_font ];
      earlySetup = true;
    };

    networking.networkmanager.enable = true;

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };

    services.udisks2.enable = true;
    services.openssh.enable = true;

    programs.fish.enable = true;
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.nh = {
      package = pkgs.nightly.nh;
      enable = true;
      clean.enable = false;
      clean.extraArgs = "--keep-since 14d --keep 5";
      flake = config.my.configDir;
    };
    environment.sessionVariables.EDITOR = "nvim";
  };
}
