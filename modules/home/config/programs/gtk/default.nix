{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    gtk = {
      enable = true;
      iconTheme = lib.mkIf (!config.my.isDarwin) {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = lib.mkIf (!config.my.isDarwin) {
      enable = true;
      platformTheme = "gtk";
    };
  };
}
