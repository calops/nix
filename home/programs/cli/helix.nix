{
  roles,
  lib,
  ...
}: {
  config = lib.mkIf roles.terminal.enable {
    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";
      };
    };
    stylix.targets.helix.enable = false;
  };
}
