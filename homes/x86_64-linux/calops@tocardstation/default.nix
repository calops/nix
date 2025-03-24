{
  config,
  ...
}:
{
  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;

  my.roles.graphical = {
    fonts.monospace = config.my.fonts.aporetic-sans-mono;
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };

  nix.settings.cores = 30; # keep two cores for the system
}
