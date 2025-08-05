{ lib, ... }:
{
  my.roles.terminal.enable = true;
  my.roles.graphical = {
    enable = true;
    fonts.sizes.terminal = 12;
    installAllFonts = true;
  };
  programs.kitty.enable = lib.mkForce true;

  programs.git.includes = [
    {
      condition = "gitdir:~/kiro/";
      contents = {
        user = {
          name = "Rémi Labeyrie";
          email = "remi.labeyrie-ext@kiro.bio";
        };
      };
    }
  ];
}
