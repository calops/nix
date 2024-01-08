{
  lib,
  pkgs,
  roles,
  ...
}: {
  config = lib.mkIf roles.gaming.enable {
    home.packages = [pkgs.discord];
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
    };
  };
}
