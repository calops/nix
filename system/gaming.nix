{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.my.roles.gaming.enable {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
