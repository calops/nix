{config, ...}: {
  imports = [
    ./gaming.nix
    ./graphical.nix
    ./bootloader.nix
    ./printing.nix
    ./bluetooth.nix
    ./audio.nix
  ];

  system.stateVersion = config.my.stateVersion;

  hardware.enableAllFirmware = true;

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
