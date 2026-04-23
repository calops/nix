{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "audio" {
  includes = [
    den.aspects.programs._.mopidy
  ];

  nixos =
    { ... }:
    {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;

        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [
              { name = "libpipewire-module-raop-discover"; }
            ];
          };
        };
      };
    };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pavucontrol ];
      services.mpris-proxy.enable = true;
    };
}
