{config, ...}: {
  programs.starship = {
    enable = config.my.roles.terminal.enable;
    settings = {
      nix_shell.symbol = " ";
      rust.symbol = " ";
      nodejs.symbol = " ";
      package.symbol = " ";
      aws.symbol = " ";
      git_branch.symbol = "שׂ ";
      hostname = {
        ssh_symbol = " ";
        style = "bold blink bright-red";
      };
    };
  };
}
