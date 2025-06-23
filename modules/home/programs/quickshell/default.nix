{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.programs.quickshell = {
    enable = lib.mkEnableOption "Enable quickshell";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nightly.quickshell;
      description = ''
        The quickshell package to use.
      '';
    };
  };

  config =
    let
      package = config.programs.quickshell.package;
    in
    lib.mkIf config.my.roles.graphical.enable {
      home.packages = [ package ];

      xdg.configFile."quickshell".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/quickshell/config";

      systemd.user.services.quickshell = lib.my.mkGraphicalSessionService {
        description = "Quickshell";
        command = "${lib.getExe' package "quickshell"}";
      };
    };
}
