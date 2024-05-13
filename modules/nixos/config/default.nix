{ pkgs, lib, ... }:
{
  config = {
    system.stateVersion = "24.05";
    hardware.enableAllFirmware = true;

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      # package = pkgs.nixVersions.nix_2_17; # TODO: remove once OOS symlinks are fixed, broken as of 2.19
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
  };
}
