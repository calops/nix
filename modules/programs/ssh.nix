{ ... }:
{
  den.aspects.programs.provides.ssh = {
    homeManager =
      { ... }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "*" = { };
            tocardland = {
              HostName = "tocards.net";
              User = "calops";
            };
            tocardstation = {
              HostName = "station.tocards.net";
              User = "calops";
            };
          };
        };
      };
  };
}
