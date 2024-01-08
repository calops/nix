{
  roles,
  lib,
  ...
}: {
  config = lib.mkIf roles.terminal.enable {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        nv = "nvim";
        cat = "bat";
        hm = "home-manager";
        hs = "home-manager switch --impure";
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
        ns = "sudo nixos-rebuild switch";
      };
      shellAliases = {
        copy = "xclip -selection clipboard";
        ls = "eza";
        ll = "ls -lH --time-style=long-iso";
        la = "ll -a";
        lt = "ll -T";
      };
      functions = {
        dev = ''nix develop "$HOME/nix#$argv[1]" --command fish'';
        run = ''nix run nixpkgs#"$argv[1]" -- $argv[2..-1]'';
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
    stylix.targets.fish.enable = true;
  };
}
