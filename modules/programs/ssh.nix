{ ... }:
{
  den.aspects.programs.provides.ssh = {
    homeManager =
      { ... }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "*" = { };
            tocards = {
              hostname = "tocards.net";
              user = "calops";
            };
          };
        };
      };
  };
}
