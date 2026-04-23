{ ... }:
{
  den.aspects.programs.provides.fzf = {
    homeManager =
      { pkgs, lib, ... }:
      {
        programs.fzf = {
          enable = true;
          defaultCommand = "fd --color=always";
          defaultOptions = lib.mkOrder 50000 [
            "--scheme=path"
            "--ansi"
            "--preview='${pkgs.writeShellScript "preview.sh" ''
              set -euo pipefail
              if [ -d "$1" ]; then
                ${lib.getExe pkgs.eza} --color=always --icons -lH --git "$1"
              elif [ -f "$1" ]; then
                ${lib.getExe pkgs.bat} --color=always -n "$1"
              fi
            ''} {}'"
            "--border=none"
            "--tabstop=4"
            "--preview-window=border-left"
            "--no-separator"
            "--no-scrollbar"
            "--color=hl:red:underline"
          ];
          fileWidgetCommand = "fd --color=always";
          changeDirWidgetCommand = "fd --type d --color=always";
        };
        stylix.targets.fzf.enable = false;
      };
  };
}
