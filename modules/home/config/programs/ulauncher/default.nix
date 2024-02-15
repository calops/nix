{
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${config.my.configDir}/modules/home/config/programs/ulauncher/config";
in
  with lib; {
    config = mkIf config.my.roles.graphical.enable {
      home.packages = [pkgs.ulauncher];

      xdg.configFile.ulauncher.source = config.lib.file.mkOutOfStoreSymlink configDir;
    };
  }
