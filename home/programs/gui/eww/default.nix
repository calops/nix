{
  lib,
  roles,
  pkgs,
  ...
}: {
  config = lib.mkIf roles.graphical.enable {
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
