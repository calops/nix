{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [ pkgs.process-compose ];
    xdg.configFile."process-compose/theme.yaml".source = "${pkgs.my.catppuccin-process-compose-theme}/share/catppuccin-mocha.yaml";
  };
}
