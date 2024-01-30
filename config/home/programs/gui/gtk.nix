{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    gtk.enable = true;
    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  };
}
