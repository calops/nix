{ ... }:
{
  den.aspects.programs.provides.nh =
    { host, ... }:
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

      darwin =
        { pkgs, ... }:
        {
          systemPackages.programs = pkgs.nh;
        };
    };
}
