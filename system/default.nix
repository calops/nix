{...}: {
  imports = [
    ./gaming.nix
    ./graphical.nix
    ./bootloader.nix
    ./printing.nix
    ./bluetooth.nix
    ./audio.nix
  ];

  hardware.enableAllFirmware = true;
}
