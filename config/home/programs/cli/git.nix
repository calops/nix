{
  pkgs,
  config,
  lib,
  ...
}: let
  palette = config.my.colors.palette.withHashtag;
in {
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [pkgs.git-crypt];
    programs.git = {
      enable = true;
      userName = "Rémi Labeyrie";
      userEmail = "calops@tocards.net";
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
        llg = "log --graph --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ar)%Creset'";
        lg = "llg -n25";
        oops = "commit --amend --no-edit";
        pushf = "push --force-with-lease";
        mom = "merge origin/main --no-edit";
        pum = "pull upstream main";
      };
      ignores = [
        ".aws"
        ".direnv"
        ".envrc"
        ".lsp.lua"
        ".neoconf.json"
        ".venv"
        ".vim"
        ".yarn"
        ".yarnrc"
        "Session.vim"
        "__pycache__"
        "target"
        "tmp"
        "typings"
      ];
      extraConfig = {
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
        push = {
          autoSetupRemote = true;
          default = "upstream";
        };
      };
      includes = [
        {path = config.xdg.configHome + "/git/delta/themes.gitconfig";}
      ];
    };

    # TODO: remove hardcoded colors
    xdg.configFile."git/delta/themes.gitconfig".text =
      # gitconfig
      ''
        [delta "catppuccin"]
          dark = true
          true-color = always

          commit-decoration-style = omit;
          file-decoration-style = omit;
          file-style = bold yellow;
          hunk-header-style = omit

          line-numbers = true
          line-numbers-left-format = "┃:{nm:^5}"
          line-numbers-left-style = "#45475a"
          line-numbers-right-format = "┃{np:^5}"
          line-numbers-right-style = "#45475a"
          line-numbers-minus-style = "${palette.red}" "#302330"
          line-numbers-plus-style = "${palette.green}" "#2b3436"
          line-numbers-zero-style = "#45475a"

          minus-emph-style = syntax "#5b435b"
          minus-style = syntax "#302330"

          plus-emph-style = syntax "#475659"
          plus-style = syntax "#2b3436"

          syntax-theme = catppuccin
      '';
  };
}
