{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.my.roles.gaming.enable = lib.mkEnableOption "Enable gaming configuration";

  config = lib.mkIf config.my.roles.gaming.enable {
    programs.gamemode.enable = true;
    programs.coolercontrol.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    hardware.graphics = {
      extraPackages = [ pkgs.mangohud ];
      extraPackages32 = [ pkgs.mangohud ];
    };

    hardware.xpadneo.enable = true; # Xbox One controller driver

    environment.systemPackages = [
      pkgs.protontricks
    ];
  };
}
