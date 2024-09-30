{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ];
}
