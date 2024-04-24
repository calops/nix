{
  config,
  lib,
  pkgs,
  ...
}:
let
  preview = pkgs.writeShellScript "preview.sh" ''
    set -euo pipefail
    if [ -d "$1" ]; then
      ${lib.getExe pkgs.eza} --color=always --icons -lH --git $1
    elif [ -f "$1" ]; then
      ${lib.getExe pkgs.bat} -n $1
    fi
  '';
in
{
  programs.fzf = {
    enable = config.my.roles.terminal.enable;
    defaultCommand = "fd --color=always";
    # Make sure this is added after the stylix options
    defaultOptions = lib.mkOrder 2000 [
      "--scheme=path"
      "--ansi"
      "--preview='${preview} {}'"
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
}
