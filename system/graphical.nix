{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.hyprland.enable = true;
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
