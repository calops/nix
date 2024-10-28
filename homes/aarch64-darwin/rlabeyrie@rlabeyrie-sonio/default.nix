{ pkgs, lib, ... }:
{
  my.roles.terminal.enable = true;
  my.roles.graphical = {
    enable = true;
    fonts.sizes.terminal = 12;
    installAllFonts = true;
  };
  programs.kitty.enable = lib.mkForce true;

  programs.fish.plugins = [
    {
      name = "asp"; # AWS Profile Manager
      src = pkgs.fetchFromGitHub {
        owner = "tanmng";
        repo = "omf-aws-asp";
        rev = "eb4f8517d87216af4751e1640b6c360a2a104bd9";
        sha256 = "sha256-eLWSWencDGmHgceRWHYG3PMM1vkBdFx0Uvy2bvBblD0=";
      };
    }
  ];

  programs.git.includes = [
    {
      condition = "gitdir:~/sonio/";
      contents = {
        user = {
          name = "Rémi Labeyrie";
          email = "remi.labeyrie@sonio.ai";
          signingKey = "BC3E47212B5DA44E";
        };
      };
    }
  ];
}
