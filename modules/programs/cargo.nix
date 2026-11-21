{ ... }:
{
  den.aspects.programs.provides.cargo = {
    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages = [ pkgs.sccache ];
        programs.cargo = {
          enable = true;
          package = null; # Leave toolchain selection to each project.
          settings.build.rustc-wrapper = lib.getExe pkgs.sccache;
        };
      };
  };
}
