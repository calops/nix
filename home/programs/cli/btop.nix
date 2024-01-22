{config, ...}: {
  programs.btop = {
    enable = config.my.roles.terminal.enable;
    settings = {
      color_theme = "Default";
      theme_background = false;
    };
  };
}
