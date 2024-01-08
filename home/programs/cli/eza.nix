{roles, ...}: {
  programs.eza = {
    enable = roles.terminal.enable;
    icons = true;
    git = true;
  };
}
