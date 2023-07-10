{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./exa.nix
    ./fish.nix
    ./helix.nix
    ./skim.nix
    ./starship.nix
    ./zoxide.nix
  ];
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = with pkgs; [
      bash
      fd
      ripgrep
      rm-improved
      xcp
      choose
      rargs
      sshfs
    ];
  };
}
