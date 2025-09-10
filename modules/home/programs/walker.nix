{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  config = lib.mkIf (config.my.roles.graphical.enable && pkgs.stdenv.isLinux) {
    programs.walker = {
      enable = true;
      runAsService = true;
    };
  };
}
