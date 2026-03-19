{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.my.roles.graphical.enable && pkgs.stdenv.isLinux) {
    services.walker = {
      enable = true;
    };
  };
}
