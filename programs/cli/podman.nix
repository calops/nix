{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.roles.terminal;
in
  with lib; {
    config = mkIf cfg.enable {
      home.packages = [
        pkgs.podman
      ];

      xdg.configFile."containers/registries.conf".text = ''
        [registries.search]
        registries = ['docker.io']
      '';
      xdg.configFile."containers/policy.json".text = builtins.toJSON {
        default = [
          {
            type = "insecureAcceptAnything";
          }
        ];
      };
    };
  }
