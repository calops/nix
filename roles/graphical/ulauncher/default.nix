{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.roles.graphical;
  configDir = "${config.home.homeDirectory}/.config/home-manager/roles/graphical/ulauncher/config";
in
  with lib; {
    config = mkIf cfg.enable {
      home.packages = [pkgs.ulauncher];

      xdg.configFile.ulauncher.source = config.lib.file.mkOutOfStoreSymlink configDir;
    };
  }
