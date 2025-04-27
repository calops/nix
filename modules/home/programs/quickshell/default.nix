{
  pkgs,
  config,
  lib,
  ...
}:
let
  package = pkgs.nightly.quickshell.override {
    withJemalloc = true;
    withQtSvg = true;
    withWayland = true;
    withX11 = true;
    withPipewire = true;
    withPam = true;
  };
in
{
  options.programs.quickshell = {
    enable = lib.mkEnableOption "Enable quickshell";
    package = lib.mkOption {
      type = lib.types.package;
      default = package;
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

      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service =
          let
            quickshell = lib.getExe' package "quickshell";
          in
          {
            ExecStart = "${quickshell}";
            Restart = "on-failure";
            KillMode = "mixed";
          };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
