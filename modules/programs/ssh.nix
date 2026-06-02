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
            tocards = {
              HostName = "tocards.net";
              User = "calops";
            };
          };
        };
      };
  };
}
