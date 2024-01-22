{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.roles.graphical.enable {
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = ./config;
    };

    home.packages = with pkgs; [
      brightnessctl
    ];
  };
}
