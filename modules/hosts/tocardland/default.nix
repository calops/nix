{ den, ... }:
{
  den.homes.x86_64-linux."calops@tocardland" = { };

  den.aspects.calops.provides.tocardland = {
    includes = [
      den.aspects.headless
      den.aspects.standalone
      den.aspects.ai-dev
    ];

    homeManager =
      { ... }:
      {
        programs.git.settings.safe.directory = [ "/home/docker" ];
      };
  };
}
