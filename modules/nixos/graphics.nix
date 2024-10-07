{ lib, config, ... }:
{
  options.my.roles.graphical.enable = lib.mkEnableOption "Graphical environment";

  config = lib.mkIf config.my.roles.graphical.enable {
    # Window manager
    programs.hyprland.enable = true;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    # Display manager
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = false;
    };

    # Misc
    hardware.graphics.enable = true;

    security.pam.services.swaylock = { };
  };
}
