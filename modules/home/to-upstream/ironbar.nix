{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.ironbar;
in
{
  options.services.ironbar = {
    enable = lib.mkEnableOption "Ironbar, a status bar for wayland compositors";
    package = lib.mkPackageOption pkgs "ironbar" { };

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      example = "sway-session.target";
      description = ''
        The systemd target that will automatically start the ironbar service.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      example = ''
        settings = {
          general = {
            position = "top";
            height = 30;
          };
      '';
      description = ''
        JSON configuration to be passed to ironbar.
      '';
    };

    style = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = ''
        style = ".background { background-color: #000000; }";
      '';
      description = ''
        CSS style to be passed to ironbar.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.home-manager.hm.assertions.assertPlatform "services.ironbar" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    systemd.user.services.ironbar = {
      Unit = {
        Description = "Ironbar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/ironbar";
        ExecReload = "${cfg.package}/bin/ironbar reload";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
    };

    xdg.configFile."ironbar/config.json" = lib.mkIf (cfg.settings != null) {
      onChange = ''
        ${cfg.package}/bin/ironbar reload
      '';
      text = builtins.toJSON cfg.settings;
    };
    xdg.configFile."ironbar/style.css".text = lib.mkIf (cfg.style != null) cfg.style;
  };
}
