{
  home = {
    username = "calops";
    homeDirectory = "/home/calops";
  };

  my.configDir = "/home/calops/nix";
  my.roles.terminal.enable = true;

  programs.git.extraConfig.safe.directory = ["/home/docker"];
}
