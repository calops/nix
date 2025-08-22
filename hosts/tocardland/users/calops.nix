{ flake }:
{
  imports = [ flake.homeModules.default ];

  home = {
    username = "calops";
    homeDirectory = "/home/calops";
  };

  my.roles.terminal.enable = true;

  programs.git.extraConfig.safe.directory = [ "/home/docker" ];
}
