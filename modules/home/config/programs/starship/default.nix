{config, ...}: {
  programs.starship = {
    enable = config.my.roles.terminal.enable;
    settings = {
      nix_shell = {
        symbol = " ";
        heuristic = true;
      };
      rust.symbol = " ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      aws.symbol = " ";
      python.symbol = " ";
      git_branch.symbol = "󰘬 ";
      hostname = {
        ssh_symbol = "󰌘 ";
        style = "bold blink bright-red";
      };
    };
  };
}
