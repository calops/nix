{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  ...
}: {
  imports = [
    ./gaming.nix
    ./terminal.nix
    ./graphical.nix
    ./audio.nix
    ./programs
  ];

  config = {
    programs.home-manager.enable = true;
    my = {isNixOs = false;} // lib.mkIf (nixosConfig != null) nixosConfig.my;
    home.stateVersion = config.my.stateVersion;

    programs.gpg.enable = true;
    programs.dircolors.enable = true;
    services.udiskie = {
      enable = true;
      settings.program_options = {
        tray = false; # FIXME: tray icon isn't working on ironbar
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
