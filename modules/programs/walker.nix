{ ... }:
{
  den.aspects.programs.provides.walker = {
    homeManagerLinux =
      { ... }:
      {
        services.walker = {
          enable = true;
          systemd.enable = true;
        };
      };
  };
}
