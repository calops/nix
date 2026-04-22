{ ... }:
{
  den.aspects.programs.walker = {
    homeManagerLinux =
      { ... }:
      {
        services.walker = {
          enable = true;
        };
      };
  };
}
