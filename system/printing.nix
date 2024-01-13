{
  lib,
  config,
  ...
}: {
  options = {
    my.roles.printing.enable = lib.mkEnableOption "Printing";
  };

  config = lib.mkIf config.my.roles.printing.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
