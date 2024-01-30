{config, ...}: {
  programs.zoxide = {
    enable = config.my.roles.terminal.enable;
    enableFishIntegration = true;
  };
}
