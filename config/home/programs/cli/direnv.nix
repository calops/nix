{config, ...}: {
  programs.direnv = {
    enable = config.my.roles.terminal.enable;
    nix-direnv.enable = true;
  };
}
