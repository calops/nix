{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  palette = config.my.colors.palette.asHex;
in
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
        dl = "curl -O";
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

      plugins = [
        {
          name = "tide";
          src = inputs.fish-tide;
        }
      ];
    };

    home.activation.tide =
      let
        tideConfigure =
          pkgs.writeText "tide-configure" # fish
            ''
              tide configure \
                --auto \
                --style=Lean \
                --prompt_colors='True color' \
                --show_time=No \
                --lean_prompt_height='Two lines' \
                --prompt_connection=Disconnected \
                --prompt_spacing=Sparse \
                --icons='Many icons' \
                --transient=No

              set -U tide_git_icon_stash "  "
              set -U tide_git_icon_staged "  "
              set -U tide_git_icon_dirty "  "
              set -U tide_git_icon_untracked "  "
              set -U tide_git_icon_upstream_behind '  '
              set -U tide_git_icon_upstream_ahead '  '

              set -U tide_aws_color                ${palette.yellow}
              set -U tide_bun_color                ${palette.flamingo}
              set -U tide_character_color          ${palette.green}
              set -U tide_character_color_failure  ${palette.red}
              set -U tide_cmd_duration_color       ${palette.overlay0}
              set -U tide_context_color_default    ${palette.text}
              set -U tide_context_color_root       ${palette.cherry}
              set -U tide_context_color_ssh        ${palette.tangerine}
              set -U tide_crystal_color            ${palette.overlay2}
              set -U tide_distrobox_color          ${palette.coral}
              set -U tide_direnv_color             ${palette.gold}
              set -U tide_docker_color             ${palette.blue}
              set -U tide_elixir_color             ${palette.purple}
              set -U tide_git_color_branch         ${palette.lime}
              set -U tide_git_color_conflicted     ${palette.red}
              set -U tide_git_color_dirty          ${palette.sand}
              set -U tide_git_color_operation      ${palette.tangerine}
              set -U tide_git_color_staged         ${palette.green}
              set -U tide_git_color_stash          ${palette.peach}
              set -U tide_git_color_untracked      ${palette.teal}
              set -U tide_git_color_upstream       ${palette.navy}
              set -U tide_go_color                 ${palette.sky}
              set -U tide_java_color               ${palette.orange}
              set -U tide_jobs_color               ${palette.pink}
              set -U tide_kubectl_color            ${palette.blue}
              set -U tide_nix_shell_color          ${palette.navy}
              set -U tide_node_color               ${palette.forest}
              set -U tide_php_color                ${palette.blue}
              set -U tide_private_mode_color       ${palette.purple}
              set -U tide_pulumi_color             ${palette.mauve}
              set -U tide_pwd_color_anchors        ${palette.mint}
              set -U tide_pwd_color_dirs           ${palette.turquoise}
              set -U tide_pwd_color_truncated_dirs ${palette.turquoise}
              set -U tide_python_color             ${palette.yellow}
              set -U tide_ruby_color               ${palette.pink}
              set -U tide_rustc_color              ${palette.orange}
              set -U tide_status_color             ${palette.green}
              set -U tide_status_color_failure     ${palette.red}
              set -U tide_terraform_color          ${palette.navy}
              set -U tide_time_color               ${palette.surface2}
              set -U tide_toolbox_color            ${palette.purple}
              set -U tide_zig_color                ${palette.gold}
            '';
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] # bash
        ''
          echo "Configuring tide prompt"
          $DRY_RUN_CMD ${config.programs.fish.package}/bin/fish ${tideConfigure}
        '';

    home.packages = [ pkgs.oh-my-fish ];
  };
}
