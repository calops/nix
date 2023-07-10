{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.my.roles.terminal;
in
  with lib; {
    home.packages = mkIf cfg.enable [pkgs.git-crypt];
    programs.git = {
      enable = cfg.enable;
      lfs.enable = true;
      signing = {
        signByDefault = true;
        key = "1FAB C23C 7766 D833 7C4D  C502 5357 919C 06FD 9147";
      };
      delta = {
        enable = true;
        options = {
          side-by-side = true;
          line-numbers = true;
          features = "catppuccin";
        };
      };
      aliases = {
        st = "status";
        ci = "commit";
        lg = "log --graph --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ar)%Creset' -n25";
        llg = "log --graph --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ar)%Creset'";
        oops = "commit --amend --no-edit";
        pushf = "push --force-with-lease";
        mom = "merge origin/master --no-edit";
      };
      ignores = [
        ".aws"
        ".lsp.lua"
        ".neoconf.json"
        ".venv"
        ".vim"
        ".yarn"
        ".yarnrc"
        "Cargo.lock"
        "Session.vim"
        "__pycache__"
        "settings.json"
        "target"
        "tmp"
        "typings"
      ];
      extraConfig = {
        user = {
          name = "Rémi Labeyrie";
          email = "calops@tocards.net";
        };
        diff = {
          renames = true;
          mnemonicPrefix = true;
          colorMoved = "default";
        };
        core = {
          whitespace = "-trailing-space";
        };
        color.ui = "auto";
        grep.extendedRegexp = true;
        log.abbrevCommit = true;
        merge = {
          tool = "vimdiff";
          log = true;
          conflictstyle = "diff3";
        };
        mergetool.prompt = true;
        difftool.prompt = false;
        diff.tool = "vimdiff";
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        status = {
          submoduleSummary = true;
          showUntrackedFiles = "all";
        };
        tag.sort = "version:refname";
        pull.rebase = "true";
        push.default = "upstream";
      };
      includes = [
        {path = config.xdg.configHome + "/git/delta/themes.gitconfig";}
        {
          condition = "gitdir:~/stockly/";
          contents = {
            user = {
              name = "Remi Labeyrie";
              email = "remi.labeyrie@stockly.ai";
              signingKey = "0C4A 765B BFDA 280C 47C1  73EE 8769 75DF 5890 0393";
            };
          };
        }
      ];
    };

    xdg.configFile."git/delta/themes.gitconfig".text = ''
      [delta "catppuccin"]
        dark = true
        true-color = always

        commit-decoration-style = omit;
        file-decoration-style = omit;
        file-style = bold yellow;
        hunk-header-style = omit

        line-numbers = true
        line-numbers-left-format = "┃{nm:^5}"
        line-numbers-left-style = "#45475a"
        line-numbers-right-format = "┃{np:^5}"
        line-numbers-right-style = "#45475a"
        line-numbers-minus-style = "#f38ba8" "#302330"
        line-numbers-plus-style = "#a6e3a1" "#2b3436"
        line-numbers-zero-style = "#45475a"

        minus-emph-style = syntax "#5b435b"
        minus-style = syntax "#302330"

        plus-emph-style = syntax "#475659"
        plus-style = syntax "#2b3436"

        syntax-theme = catppuccin
    '';
  }
