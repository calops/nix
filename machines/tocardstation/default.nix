{
  home = {
    username = "calops";
    homeDirectory = "/home/calops";
  };

  my.roles = {
    terminal.enable = true;
    graphical = {
      enable = true;
      nvidia.enable = true;
      installAllFonts = true;
      terminal = "wezterm";
    };
    gaming.enable = true;
  };
}
