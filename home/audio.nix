{
  lib,
  roles,
  pkgs,
  ...
}: {
  config = lib.mkIf roles.audio.enable {
    home.packages = [pkgs.pavucontrol];
    services.mpris-proxy.enable = true;
  };
}
