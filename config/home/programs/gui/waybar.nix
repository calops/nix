{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.waybar = {
      enable = true;
    };
  };
}
