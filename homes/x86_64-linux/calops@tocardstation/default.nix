{
  config,
  pkgs,
  ...
}:
{
  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;
  my.roles.graphical = {
    fonts.monospace = config.my.fonts.iosevka;
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };

  home.packages = [
    pkgs.rustdesk
  ];
}
