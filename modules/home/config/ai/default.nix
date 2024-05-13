{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.my.roles.ai.enable = lib.mkEnableOption "Enable AI tools";

  config = lib.mkIf config.my.roles.ai.enable {
    home.packages = with pkgs; [
      # backgroundremover
    ];
  };
}
