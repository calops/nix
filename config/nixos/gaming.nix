{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.gaming.enable {
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    hardware.opengl = {
      extraPackages = [pkgs.mangohud];
      extraPackages32 = [pkgs.mangohud];
    };
  };
}
