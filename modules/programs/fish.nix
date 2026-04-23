{ ... }:
{
  den.aspects.programs.provides.fish = {
    homeManager =
      {
        pkgs,
        nixosConfig ? null,
        darwinConfig ? null,
        ...
      }:
      let
        configType =
          if (!isNull nixosConfig) then
            "nixos"
          else if (!isNull darwinConfig) then
            "darwin"
          else
            "standalone";
      in
      {
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
              .${configType};
            ga = "git add -v";
            gu = "git add -vu";
            gp = "git push";
            st = "git status -bs";
            di = "git diff";
            lg = "git lg";
            cc = "cargo check";
            rm = "rip";
            sd = "dev rust";
            df = "dysk";
            du = "dust";
            rrm = "rm -rf";
            sr = "steam-run";
            devinit = "nix flake init --template github:cachix/devenv";
            x = "dtrx";
            dl = "curl -O";
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
            shell = "nix shell (string replace -r '(.*)' 'nixpkgs#$1' $argv)";
            runi = ''nix run --impure nixpkgs#"$argv[1]" -- $argv[2..-1]'';
            gc = ''git commit -m "$argv"'';
          };

          interactiveShellInit = # fish
            ''
              set fish_greeting
            '';
        };

        programs.carapace.enableFishIntegration = false;
        programs.oh-my-posh.enableFishIntegration = true;

        home.packages = [ pkgs.oh-my-fish ];
      };
  };
}
