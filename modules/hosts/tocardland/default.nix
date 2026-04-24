{ ... }:
{
  den.homes.x86_64-linux."calops@tocardland" = { };

  den.aspects.calops.provides.tocardland = {
    homeManager =
      { ... }:
      {
        programs.git.extraConfig.safe.directory = [ "/home/docker" ];
      };
  };
}
