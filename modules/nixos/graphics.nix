{
  lib,
  config,
  inputs,
  perSystem,
  ...
}:
{
  options.my.roles.graphical.enable = lib.mkEnableOption "Graphical environment";

  imports = [ inputs.niri.nixosModules.niri ];

  config = lib.mkIf config.my.roles.graphical.enable {
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      # TODO: needed with the current nvidia drivers, remove when fixed
      GSK_RENDERER = "ngl";
      NVD_BACKEND = "direct";
    };

    # Window manager
    programs.niri = {
      enable = true;
      package = perSystem.self.niri;
    };

    # Polkit agent
    systemd.user.services.niri-flake-polkit.enable = false;
    security.soteria.enable = true;

    # Display manager
    services = {
      xserver.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # Misc
    hardware.graphics.enable = true;
    security.pam.services.swaylock = { };
    xdg.portal.xdgOpenUsePortal = false;
  };
}
