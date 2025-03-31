{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  options.my.roles.graphical.enable = lib.mkEnableOption "Graphical environment";

  imports = [ inputs.niri.nixosModules.niri ];

  config = lib.mkIf config.my.roles.graphical.enable {
    # Window manager
    programs.niri = {
      enable = true;
      package = pkgs.nightly.niri;
    };
    # systemd.user.services.niri-flake-polkit.enable = false;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    # Display manager
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # Misc
    hardware.graphics.enable = true;
    security.pam.services.swaylock = { };
    xdg.portal.xdgOpenUsePortal = false;
  };
}
