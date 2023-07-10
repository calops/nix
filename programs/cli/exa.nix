{config, ...}: {
  programs.exa = {
    enable = config.my.roles.terminal.enable;
    icons = true;
    git = true;
  };
}
