{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.audio.enable {
    home.packages = [pkgs.pavucontrol];
    services.mpris-proxy.enable = true;
  };
}
