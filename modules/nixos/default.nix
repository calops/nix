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
    inputs.nh-darwin.nixosModules.default
    inputs.madness.nixosModules.default
    inputs.lix.nixosModules.default
  ] ++ lib.snowfall.fs.get-non-default-nix-files ./.;

  options = {
    my.configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      apply = toString;
      description = "Location of the nix config directory (this repo)";
    };
  };

  config = {
    system.stateVersion = "24.11";
    hardware.enableAllFirmware = true;

    nix = {
      optimise.automatic = true;
      gc = {
        # automatic = true;
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

    stylix.homeManagerIntegration.autoImport = false;

    services.udisks2.enable = true;
    services.openssh.enable = true;

    programs.fish.enable = true;
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = config.my.configDir;
    };

    # Support for dynamic linking in NixOS
    # programs.nix-ld.enable = true;
  };
}
