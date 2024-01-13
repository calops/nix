{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
