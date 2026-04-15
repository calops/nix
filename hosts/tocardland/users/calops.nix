{ flake, inputs, ... }:
{
  imports = [
    flake.homeModules.default
    inputs.dendritic.den.homes.x86_64-linux.tocardland.mainModule
  ];

  home = {
    username = "calops";
    homeDirectory = "/home/calops";
  };

  my.roles.terminal.enable = true;

  programs.git.extraConfig.safe.directory = [ "/home/docker" ];
}
