{pkgs, ...}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;

    loader.grub = {
      enable = true;
      efiSupport = true;
      useOSProber = false; # auto-detect other OSes
      device = "nodev"; # install in /boot for EFI
      theme = pkgs.catppuccin-mocha-grub-theme;
    };
  };

  stylix.targets.grub.enable = false;
}
