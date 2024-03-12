{...}: {
  my.configDir = "/home/calops/nix";
  my.roles.terminal.enable = true;
  my.roles.graphical = {
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };
}
