{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        nv = "nvim";
        cat = "bat";
        hm = "home-manager";
        hs = "nh home switch";
        ns = "nh os switch";
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
        bg = "batgrep";
        rrm = "rm -rf";
        sr = "steam-run";
        devinit = "nix flake init --template github:cachix/devenv";
      };
      shellAliases = {
        copy = "xclip -selection clipboard";
        ls = "eza";
        ll = "ls -lH --time-style=long-iso";
        la = "ll -a";
        lt = "ll -T";
      };
      functions = {
        dev = ''nix develop --impure "$HOME/nix#$argv[1]" $argv[2..-1] --command "$SHELL"'';
        run = ''nix run nixpkgs#"$argv[1]" -- $argv[2..-1]'';
        shell = ''nix shell (string replace -r '(.*)' 'nixpkgs#$1' $argv)'';
        runi = ''nix run --impure nixpkgs#"$argv[1]" -- $argv[2..-1]'';
        gc = ''git commit -m "$argv"'';
      };
      interactiveShellInit = ''
        set fish_greeting

        if test -e ~/.nix-profile/etc/profile.d/nix.fish
          source ~/.nix-profile/etc/profile.d/nix.fish
        end
      '';
    };
  };
}
