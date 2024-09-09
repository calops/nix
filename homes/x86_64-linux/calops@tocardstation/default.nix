{ config, ... }:
{
  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;
  my.roles.graphical = {
    fonts.monospace = config.my.fonts.iosevka; # TODO: remove once iosevka-comfy is fixed
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };
}
