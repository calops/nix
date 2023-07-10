{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
      };
    };
    stylix.targets.helix.enable = false;
  };
}
