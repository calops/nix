{
  lib,
  roles,
  ...
}: {
  config = lib.mkIf roles.graphical.enable {
    programs.waybar = {
      enable = true;
    };
  };
}
