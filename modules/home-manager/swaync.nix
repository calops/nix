{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.swaynotificationcenter;
in {
  options.services.swaynotificationcenter = {
    enable = lib.mkEnableOption "Sway notification center, a notification daemon for Wayland";

    package = lib.mkPackageOption pkgs "swaynotificationcenter" {};

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      example = "sway-session.target";
      description = ''
        The systemd target that will automatically start the swaynotificationcenter service.
      '';
    };

    config = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      example = ''
        config = {
          control-center-margin-top = 20;
          control-center-margin-bottom = 20;
          control-center-margin-right = 20;
        };
      '';
      description = ''
        JSON configuration to be passed to swaynotificationcenter.
      '';
    };

    style = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = ''
        style = ".control-center { background-color: #000000; }";
      '';
      description = ''
        Extra CSS style to be passed to swaynotificationcenter.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.swaynotificationcenter" pkgs lib.platforms.linux)
    ];

    home.packages = [cfg.package];

    systemd.user.services.swaynotificationcenter = {
      Unit = {
        Description = "Sway notification center";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/swaync";
        ExecReload = "${cfg.package}/bin/swaync-client -R -rs";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install = {WantedBy = [cfg.systemdTarget];};
    };

    xdg.configFile."swaync/config.json" = lib.mkIf (cfg.config != null) {
      onChange = ''
        ${cfg.package}/bin/swaync-client -R
      '';
      text = builtins.toJSON cfg.config;
    };

    xdg.configFile."swaync/style.css" = lib.mkIf (cfg.style != null) {
      onChange = ''
        ${pkgs.swaynotificationcenter}/bin/swaync-client -rs
      '';
      text = cfg.style;
    };
  };
}
