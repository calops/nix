{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max"; # TODO: check if this is necessary
      };
    };
  };

  boot.plymouth = lib.mkIf config.my.roles.graphical.enable {
    enable = true;
  };

  services.kmscon = lib.mkIf config.my.roles.graphical.enable {
    enable = true;
    hwRender = true;
    useXkbConfig = true;
    fonts = [
      {
        name = "Terminess Nerd Font";
        package = pkgs.nerd-fonts.terminess-ttf;
      }
    ];
  };
}
