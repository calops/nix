{roles, ...}: {
  programs.direnv = {
    enable = roles.terminal.enable;
    nix-direnv.enable = true;
  };
}
