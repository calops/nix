{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [
      pkgs.podman
    ];

    xdg.configFile."containers/registries.conf".text =
      # toml
      ''
        [registries.search]
        registries = ['docker.io']
      '';
    xdg.configFile."containers/policy.json".text = builtins.toJSON {
      default = [{type = "insecureAcceptAnything";}];
    };
  };
}
