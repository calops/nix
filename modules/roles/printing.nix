{ inputs, den, lib, ... }:
{
  den.aspects.printing = {
    nixos = { pkgs, ... }: {
      hardware.sane.enable = true;
      hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

      services.printing.enable = true;
      services.printing.drivers = [ pkgs.hplipWithPlugin ];

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
