{
  lib,
  config,
  perSystem,
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

  # boot.plymouth = lib.mkIf config.my.roles.graphical.enable {
  #   enable = true;
  # };

  services.kmscon = lib.mkIf config.my.roles.graphical.enable {
    enable = true;
    hwRender = true;
    useXkbConfig = true;
    fonts = [
      {
        name = perSystem.self.fonts.terminess.name;
        package = perSystem.self.fonts.terminess.package;
      }
    ];
  };
}
