{
  lib,
  config,
  pkgs,
  nixosConfig ? null,
  ...
}:
{
  options.my.roles.audio.enable = lib.mkOption {
    default = nixosConfig.my.roles.audio.enable or false;
    description = "Enable audio role";
  };

  config = lib.mkIf config.my.roles.audio.enable {
    home.packages = [ pkgs.pavucontrol ];
    services.mpris-proxy.enable = true;
  };
}
