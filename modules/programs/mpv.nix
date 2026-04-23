{ ... }:
{
  den.aspects.programs.provides.mpv = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.material-icons
        ];

        programs.mpv = {
          enable = true;
          scripts = [
            pkgs.mpvScripts.sponsorblock
            pkgs.mpvScripts.thumbfast
            pkgs.mpvScripts.uosc
            pkgs.mpvScripts.autosubsync-mpv
          ];
        };
      };
  };
}
