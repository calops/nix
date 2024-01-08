{roles, ...}: {
  programs.btop = {
    enable = roles.terminal.enable;
    settings = {
      color_theme = "Default";
      theme_background = false;
    };
  };
}
