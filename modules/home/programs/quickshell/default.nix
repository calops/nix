{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
  programs.quickshell = {
    enable = true;
    activeConfig = null;
    package = pkgs.nightly.quickshell;
    systemd.enable = true;
  };

  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/quickshell/config";
}
