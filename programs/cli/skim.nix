{config, ...}: {
  programs.skim = {
    enable = config.my.terminal.enable;
    defaultCommand = "fd --color=always";
    defaultOptions = ["--ansi"];
    fileWidgetCommand = "fd --color=always";
    fileWidgetOptions = ["--ansi" "--preview '~/scripts/preview.sh {}'"];
    changeDirWidgetCommane = "fd --type d --color=always";
  };
}
