{
  roles,
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${roles.configDir}/home/programs/gui/ulauncher/config";
in
  with lib; {
    config = mkIf roles.graphical.enable {
      home.packages = [pkgs.ulauncher];

      xdg.configFile.ulauncher.source = config.lib.file.mkOutOfStoreSymlink configDir;
    };
  }
