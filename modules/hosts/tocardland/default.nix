{ den, ... }:
{
  den.homes.x86_64-linux."calops@tocardland" = { };

  den.aspects.calops.provides.tocardland = {
    includes = [ den.aspects.standalone ];

    homeManager =
      { ... }:
      {
        programs.git.settings.safe.directory = [ "/home/docker" ];
      };
  };
}
