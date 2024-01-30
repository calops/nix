{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.atuin = {
      enable = false;
      enableFishIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
        show_preview = true;
      };
    };
  };
}
