{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.gaming.enable {
    home.packages = [pkgs.discord];
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
    };
  };
}
