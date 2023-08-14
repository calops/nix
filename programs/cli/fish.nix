{
  config,
  lib,
  ...
}: let
  cfg = config.my.roles.terminal;
in {
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        nv = "nvim";
        cat = "bat";
        hm = "home-manager";
        hs =
          if config.my.roles.graphical.nvidia.enable # nixGLNvidia is always impure, unfortunately
          then "home-manager switch --impure"
          else "home-manager switch";
        ga = "git add -v";
        gu = "git add -vu";
        gp = "git push";
        st = "git status";
        di = "git diff";
        lg = "git lg";
        cc = "cargo check";
        rm = "rip";
        sd = "dev rust";
        cp = "xcp";
      };
      shellAliases = {
        copy = "xclip -selection clipboard";
        ls = "exa";
        ll = "ls -lH --time-style=long-iso";
        la = "ll -a";
        lt = "ll -T";
      };
      functions = {
        dev = ''nix develop "github:calops/nix#$argv[1]" --command fish'';
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
    stylix.targets.fish.enable = false;
  };
}
