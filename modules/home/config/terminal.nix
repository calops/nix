{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.my.roles.terminal.enable = lib.mkEnableOption "Terminal utilities";

  config = lib.mkIf config.my.roles.terminal.enable { home.packages = with pkgs; [ jq ]; };
}
