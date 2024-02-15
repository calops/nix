{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  };
}
