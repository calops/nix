{
  pkgs,
  config,
  lib,
  ...
}: {
  boot = {
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
    initrd.systemd.enable = true;
  };

  # boot.plymouth = lib.mkIf config.my.roles.graphical.enable {
  #   enable = true;
  # themePackages = [pkgs.catppuccin-plymouth];
  # theme = "catppuccin-mocha";
  # };
}
