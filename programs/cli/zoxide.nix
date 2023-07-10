{config, ...}: {
  programs.zoxide = {
    enable = config.my.roles.terminal;
    enableFishIntegration = true;
  };
}
