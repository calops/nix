{ lib, ... }:
{
  den.aspects.programs.provides._1password =
    { ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        {
          home.packages = [
            pkgs._1password-cli
          ];

          home.sessionVariables.SUDO_ASKPASS = toString (
            pkgs.writeShellScriptBin "1password-askpass" ''
              #!${pkgs.runtimeShell}
              op read 'op://Private/Sudo password/password'
            ''
          );

          programs.fish.shellAbbrs.s = "sudo --askpass";

          programs.ssh.extraConfig = lib.mkDefault ''
            IdentityAgent "~/.1password/agent.sock"
          '';

          programs.git.signing = {
            signByDefault = true;
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5fbZ1KwrHKB+ItUQ5CRhjDVztrVBs4ZgULBkZHs2Iw";
            format = "ssh";
            signer = lib.mkDefault (lib.getExe' pkgs._1password-gui "op-ssh-sign");
          };
        };

      homeManagerDarwin =
        { pkgs, ... }:
        {
          programs.git.signing.signer = "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          programs.ssh.extraConfig = ''
            IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          '';
        };

      nixos =
        { config, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = config.profiles.graphical.enable;
          environment.etc."1password/custom_allowed_browsers" = lib.mkIf config.profiles.graphical.enable {
            text = ''
              firefox-beta
            '';
            mode = "0755";
          };
        };

      darwin =
        { config, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = config.profiles.graphical.enable;
        };

    };

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        op-credential = pkgs.writeShellApplication {
          name = "op-credential";
          runtimeInputs = with pkgs; [ coreutils ];
          text = ''
            if [ $# -lt 1 ]; then
            	echo "Usage: op-credential <name> [env-var]" >&2
            	echo "  name:    1Password item name" >&2
            	echo "  env-var: environment variable to export (defaults to upper-snake-case of name)" >&2
            	exit 1
            fi

            item_name="$1"
            default_var="$(echo "$item_name" | tr '[:lower:]-' '[:upper:]_')_KEY"
            env_var="''${2:-$default_var}"

            state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/op-credentials"
            cache_key=$(echo "$item_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            cache_file="$state_dir/$cache_key"

            if [ ! -f "$cache_file" ]; then
            	echo "Fetching '$item_name' from 1Password..." >&2
            	mkdir -p "$state_dir"
            	chmod 700 "$state_dir"
            	value="$(op item get "$item_name" --fields credential --reveal 2>/dev/null)"
            	if [ -z "$value" ]; then
            		echo "Error: failed to fetch '$item_name' from 1Password" >&2
            		exit 1
            	fi
            	printf '%s' "$value" >"$cache_file"
            	chmod 600 "$cache_file"
            fi

            printf 'export %s=%q\n' "$env_var" "$(cat "$cache_file")"
          '';
        };
      };
    };
}
