{ ... }:
{
  den.aspects.programs.nh =
    { host, pkgs, ... }:
    {
      nixos.programs.nh = {
        enable = true;
        flake = host.configDir;
      };

      homeManager = {
        programs.nh = {
          enable = true;
          flake = host.configDir;
        };

        home.sessionVariables = {
          NH_NO_CHECKS = "1";
        };
      };

      darwin.systemPackages.programs = pkgs.nh;
    };
}
