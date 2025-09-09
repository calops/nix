{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [
      pkgs.material-icons # for uosc
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
}
