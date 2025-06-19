{
  pkgs,
  config,
  lib,
  ...
}:
let
  palette = config.my.colors.palette.asHexWithHashtag;
in
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [
      pkgs.git-crypt
      pkgs.difftastic
    ];

    programs.lazygit = {
      enable = true;
      settings = {
        nerdFontsVersion = 3;
        git.paging.externalDiffCommand = "difft --color=always --syntax-highlight=on";
      };
    };

    programs.git = {
      enable = true;
      userName = "Rémi Labeyrie";
      userEmail = "calops@tocards.net";
      lfs.enable = true;

      # signing = {
      #   signByDefault = true;
      #   key = "1FAB C23C 7766 D833 7C4D  C502 5357 919C 06FD 9147";
      # };
      # FIXME: 1P is bugged
      signing = {
        signByDefault = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5fbZ1KwrHKB+ItUQ5CRhjDVztrVBs4ZgULBkZHs2Iw";
        format = "ssh";
        signer =
          if pkgs.stdenv.isLinux then
            lib.getExe' pkgs._1password-gui "op-ssh-sign"
          else
            "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          features = "catppuccin,sidebyside";
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
        pom = "pull origin main --no-rebase";
        dv = ''! args=$@; shift $#; nvim -c "DiffviewOpen $args"'';
        db = ''! args=$@; shift $#; nvim -c "DiffviewOpen origin/HEAD...HEAD --imply-local)"'';
      };

      ignores = [
        ".aws"
        ".direnv"
        ".envrc"
        ".lsp.lua"
        ".venv"
        ".vim"
        ".yarn"
        ".yarnrc"
        ".nvim.lua"
        ".elixir-tools"
        "Session.vim"
        "__pycache__"
        "target"
        "tmp"
        "typings"
      ];

      extraConfig = {
        color.ui = "auto";
        core.whitespace = "-trailing-space";
        grep.extendedRegexp = true;
        log.abbrevCommit = true;
        mergetool.prompt = true;
        pull.rebase = "true";
        tag.sort = "version:refname";

        diff = {
          tool = "difftastic";
          renames = true;
          mnemonicPrefix = true;
          colorMoved = "default";
        };

        difftool = {
          prompt = false;
          difftastic.cmd = "${lib.getExe pkgs.difftastic} $LOCAL $REMOTE";
        };

        merge = {
          tool = "vimdiff";
          log = true;
          conflictstyle = "diff3";
        };

        rerere = {
          enabled = true;
          autoUpdate = true;
        };

        status = {
          submoduleSummary = true;
          showUntrackedFiles = "all";
        };

        push = {
          autoSetupRemote = true;
          default = "upstream";
        };

        delta.catppuccin = {
          dark = true;
          true-color = "always";
          commit-decoration-style = "omit";
          file-decoration-style = "omit";
          file-style = "bold yellow";
          hunk-header-style = "omit";
          line-numbers-left-format = "┃{nm:^5}";
          line-numbers-left-style = "#45475a";
          line-numbers-right-format = "┃{np:^5}";
          line-numbers-right-style = "#45475a";
          line-numbers-minus-style = "${palette.red} #302330";
          line-numbers-plus-style = "${palette.green} #2b3436";
          line-numbers-zero-style = "#45475a";
          minus-emph-style = "syntax #5b435b";
          minus-style = "syntax #302330";
          plus-emph-style = "syntax #475659";
          plus-style = "syntax #2b3436";
          syntax-theme = "catppuccin";
        };

        delta.sidebyside = {
          side-by-side = true;
        };
      };
    };
  };
}
