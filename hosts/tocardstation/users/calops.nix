{ flake, ... }:
{
  imports = [
    flake.homeModules.default
  ];

  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;

  my.roles.graphical = {
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };

  nix.settings.cores = 30; # keep two cores for the system
}
