{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  palette = config.my.colors.palette.asHexWithHashtag;
  wallpaper = config.stylix.image;
in
{
  imports = [ inputs.niri-caelestia-shell.homeManagerModules.default ];

  config = lib.mkIf (config.my.roles.graphical.enable && !pkgs.stdenv.isDarwin) {
    programs.quickshell = {
      enable = true;
      activeConfig = null;
      systemd.enable = true;
    };

    programs.caelestia = {
      enable = true;
      cli.enable = true;
      cli.settings.theme.enableGtk = false;
      settings = {
        appearance.transparency.enabled = false;
        font.family.mono = config.my.roles.graphical.fonts.monospace.name;
        general.apps.terminal = config.my.roles.graphical.terminal;
        background.enabled = true;
        background.visualiser.enabled = true;
        background.desktopClock.enabled = true;
        bar.entries = [
          {
            id = "logo";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "workspaces";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "power";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
          }
          {
            id = "idleInhibitor";
            enabled = true;
          }
        ];
        bar.persistent = true;
        bar.status.showBattery = false;
        bar.status.showMicrophone = true;
        bar.status.showAudio = true;
        bar.tray.background = true;
        bar.workspaces.windowIconSize = 20;
        bar.workspaces.focusedWindowBlob = false;
      };
    };

    # xdg.configFile."quickshell".source =
    #   config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/quickshell/config";
  };
}
