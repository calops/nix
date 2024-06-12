{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot = {
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max"; # TODO: check if this is necessary
      };
    };
  };

  # boot.plymouth = lib.mkIf config.my.roles.graphical.enable {
  #   enable = true;
  # themePackages = [pkgs.catppuccin-plymouth];
  # theme = "catppuccin-mocha";
  # };
}
