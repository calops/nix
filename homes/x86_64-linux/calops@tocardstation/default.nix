{
  config,
  pkgs,
  ...
}:
{
  my.roles.terminal.enable = true;
  my.roles.ai.enable = true;
  my.roles.graphical = {
    fonts.monospace = config.my.fonts.iosevka; # TODO: remove once iosevka-comfy is fixed
    fonts.sizes.terminalCell.width = 1.0;
    installAllFonts = true;
    terminal = "kitty";
    monitors.primary.id = "DP-2";
  };

  home.packages = [
    pkgs.rustdesk
    pkgs.freecad-wayland
    pkgs.nightly.cq-editor
  ];
}
