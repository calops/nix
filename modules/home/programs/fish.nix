{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.fish = {
      enable = true;

      shellAbbrs = {
        nv = "nvim";
        cat = "bat";
        hm = "home-manager";
        hs = "nh home switch";
        ns =
          {
            nixos = "nh os switch";
            darwin = "nh darwin switch";
            standalone = "nh home switch";
          }
          .${config.my.configType};
        ga = "git add -v";
        gu = "git add -vu";
        gp = "git push";
        st = "git status -bs";
        di = "git diff";
        lg = "git lg";
        cc = "cargo check";
        rm = "rip";
        sd = "dev rust";
        cp = "xcp";
        df = "dysk";
        du = "dust";
        rrm = "rm -rf";
        sr = "steam-run";
        devinit = "nix flake init --template github:cachix/devenv";
        x = "dtrx";
      };

      shellAliases = {
        copy = "xclip -selection clipboard";
        ls = "eza";
        ll = "ls -lH --time-style=long-iso";
        la = "ll -a";
        lt = "ll -T";
        rg = if config.my.roles.graphical.terminal == "kitty" then "kitten hyperlinked-grep" else "rg";
      };

      functions = {
        dev = ''nix develop --impure "$HOME/nix#$argv[1]" $argv[2..-1] --command "$SHELL"'';
        run = ''nix run nixpkgs#"$argv[1]" -- $argv[2..-1]'';
        shell = ''nix shell (string replace -r '(.*)' 'nixpkgs#$1' $argv)'';
        runi = ''nix run --impure nixpkgs#"$argv[1]" -- $argv[2..-1]'';
        gc = ''git commit -m "$argv"'';
      };

      interactiveShellInit = # fish
        ''
          set fish_greeting

          if test -e ~/.nix-profile/etc/profile.d/nix.fish
            source ~/.nix-profile/etc/profile.d/nix.fish
          end

          # The builtin fish integration uses the wrong command-not-found instead of the faster one from nix-index-db
          # function fish_command_not_found
          #   command-not-found $argv
          # end
        '';
    };

    home.packages = [ pkgs.oh-my-fish ];
  };
}
