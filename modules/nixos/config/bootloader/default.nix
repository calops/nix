{...}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
  };
}
