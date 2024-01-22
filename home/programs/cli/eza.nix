{config, ...}: {
  programs.eza = {
    enable = config.my.roles.terminal.enable;
    icons = true;
    git = true;
  };
}
