{config, ...}: {
  programs.skim = {
    enable = config.my.roles.terminal.enable;
    defaultCommand = "fd --color=always";
    defaultOptions = ["--ansi"];
    fileWidgetCommand = "fd --color=always";
    fileWidgetOptions = ["--ansi" "--preview '~/scripts/preview.sh {}'"];
    changeDirWidgetCommand = "fd --type d --color=always";
  };
}
