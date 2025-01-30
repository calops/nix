{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixcord.homeManagerModules.nixcord
  ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.nixcord = {
      enable = true;
      vesktop.enable = true;
      config = {
        themeLinks = [ "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css" ];
        frameless = true;
        plugins = {
          alwaysAnimate.enable = true;
          alwaysTrust.enable = true;
          fakeNitro.enable = true;
        };
      };
    };
  };
}
