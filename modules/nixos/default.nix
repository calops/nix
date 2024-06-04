{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    inputs.stylix.nixosModules.stylix
  ] ++ lib.snowfall.fs.get-non-default-nix-files ./.;

  config = {
    system.stateVersion = "24.11";
    hardware.enableAllFirmware = true;

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

    # Support for dynamic linking in NixOS
    programs.nix-ld.enable = true;
  };
}
