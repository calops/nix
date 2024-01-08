{roles, ...}: {
  programs.zoxide = {
    enable = roles.terminal.enable;
    enableFishIntegration = true;
  };
}
