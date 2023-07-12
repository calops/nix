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
    ./git.nix
    ./helix.nix
    ./podman.nix
    ./skim.nix
    ./ssh.nix
    ./starship.nix
    ./zellij.nix
    ./zoxide.nix
    ./neovim
  ];
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = with pkgs; [
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
