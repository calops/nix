{ lib, ... }:
{
  den.aspects.programs.provides.onepassword = {
    homeManager =
      {
        pkgs,
        lib,
        self',
        config,
        ...
      }:
      {
        home.packages = [
          pkgs._1password-cli
          self'.packages.op-credential
          self'.packages.op-ssh-key
        ]
        ++ lib.optional config.profiles.headless.enable self'.packages.op-ssh-agent;

        home.sessionVariables.SUDO_ASKPASS = toString (
          pkgs.writeShellScript "1password-askpass" ''
            #!${pkgs.runtimeShell}
            op read 'op://Private/Sudo password/password'
          ''
        );

        programs.fish.shellAbbrs.s = "sudo --askpass";

        # On headless hosts there is no 1Password agent socket, so run a local
        # ssh-agent and lazily load the 1Password SSH keys into it. The agent
        # starts once and persists; `op signin` only prompts on first load.
        programs.fish.interactiveShellInit = lib.mkIf config.profiles.headless.enable ''
          if not set -q SSH_AUTH_SOCK
            set -gx SSH_AUTH_SOCK "$HOME/.ssh/op-agent.sock"
            op-ssh-agent >/dev/null
          end
        '';

        programs.ssh.extraConfig = lib.mkIf (!config.profiles.headless.enable) (
          lib.mkDefault ''
            IdentityAgent "~/.1password/agent.sock"
          ''
        );

        programs.git.signing = {
          signByDefault = true;
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5fbZ1KwrHKB+ItUQ5CRhjDVztrVBs4ZgULBkZHs2Iw";
          format = "ssh";
          signer = lib.mkMerge [
            # Headless hosts sign with the local ssh-agent, since the 1Password
            # desktop app (op-ssh-sign) isn't available there.
            (lib.mkIf config.profiles.headless.enable (lib.getExe' pkgs.openssh "ssh-keygen"))
            (lib.mkDefault (lib.getExe' pkgs._1password-gui "op-ssh-sign"))
          ];
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
        op-ssh-key = pkgs.writeShellApplication {
          name = "op-ssh-key";
          runtimeInputs = with pkgs; [ coreutils ];
          text = ''
            if [ $# -lt 1 ]; then
            	echo "Usage: op-ssh-key <item-name>" >&2
            	echo "  item-name: 1Password SSH Key item name" >&2
            	exit 1
            fi

            item_name="$1"
            key_dir="$HOME/.ssh"
            key_file="$key_dir/$(echo "$item_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-').pub"

            if [ ! -f "$key_file" ]; then
            	echo "Fetching '$item_name' public key from 1Password..." >&2
            	mkdir -p "$key_dir"
            	chmod 700 "$key_dir"
            	value="$(op signin && op read "op://Private/$item_name/public key" 2>/dev/null)"
            	if [ -z "$value" ]; then
            		echo "Error: failed to fetch '$item_name' public key from 1Password" >&2
            		exit 1
            	fi
            	printf '%s' "$value" > "$key_file"
            	chmod 600 "$key_file"
            fi

            printf '%s' "$key_file"
          '';
        };

        op-credential = pkgs.writeShellApplication {
          name = "op-credential";
          runtimeInputs = with pkgs; [
            coreutils
            jq
          ];
          text = ''
            raw_output=false
            field=credential
            while [ $# -gt 0 ]; do
            	case "$1" in
            		--raw | -r)
            			raw_output=true
            			shift
            			;;
            		--field)
            			if [ $# -lt 2 ]; then
            				echo "Error: --field requires a field name" >&2
            				exit 1
            			fi
            			field="$2"
            			shift 2
            			;;
            		--field=*)
            			field="''${1#--field=}"
            			shift
            			;;
            		*)
            			break
            			;;
            	esac
            done

            if [ $# -lt 1 ]; then
            	echo "Usage: op-credential [-r|--raw] [--field <field>] <name> [env-var]" >&2
            	echo "  name:    1Password item name" >&2
            	echo "  field:   1Password field name (defaults to credential)" >&2
            	echo "  env-var: environment variable to export (defaults to upper-snake-case of name)" >&2
            	exit 1
            fi

            item_name="$1"
            default_var="$(echo "$item_name" | tr '[:lower:]-' '[:upper:]_')_KEY"
            env_var="''${2:-$default_var}"

            state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/op-credentials"
            cache_key=$(echo "$item_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            cache_file="$state_dir/$cache_key"
            if [ "$field" != credential ]; then
            	field_cache_key=$(echo "$field" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            	cache_file="$cache_file-$field_cache_key"
            fi

            if [ ! -f "$cache_file" ]; then
            	echo "Fetching '$field' from '$item_name' in 1Password..." >&2
            	mkdir -p "$state_dir"
            	chmod 700 "$state_dir"
            	if ! value="$(op item get "$item_name" --format json --reveal 2>/dev/null | jq -er --arg field "$field" '.fields | map(select(.label == $field)) | if length == 1 then .[0].value else empty end' 2>/dev/null)"; then
            		echo "Error: failed to fetch '$field' from '$item_name' in 1Password" >&2
            		exit 1
            	fi
            	if [ -z "$value" ]; then
            		echo "Error: '$field' is empty in '$item_name'" >&2
            		exit 1
            	fi
            	printf '%s' "$value" >"$cache_file"
            	chmod 600 "$cache_file"
            fi
            if $raw_output; then
            	cat "$cache_file"
            else
            	printf 'export %s=%q\n' "$env_var" "$(cat "$cache_file")"
            fi
          '';
        };

        op-ssh-agent = pkgs.writeShellApplication {
          name = "op-ssh-agent";
          runtimeInputs = with pkgs; [
            coreutils
            openssh
          ];
          text = ''
            # Run a persistent local ssh-agent with the 1Password SSH keys loaded.
            # Used on headless hosts that can't run the 1Password desktop agent.
            socket="$HOME/.ssh/op-agent.sock"
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"

            rc=0
            SSH_AUTH_SOCK="$socket" ssh-add -l >/dev/null 2>&1 || rc=$?
            if [ "$rc" -ne 0 ] && [ "$rc" -ne 1 ]; then
            	rm -f "$socket"
            	ssh-agent -a "$socket" >/dev/null
            	rc=1
            fi

            export SSH_AUTH_SOCK="$socket"

            if [ "$rc" -ne 0 ]; then
            	if ! op whoami >/dev/null 2>&1; then
            		eval "$(op signin)"
            	fi
            	for item in "SSH Key" "SSH Key Git"; do
            		if ! op read "op://Private/$item/private key?ssh-format=openssh" | ssh-add - 2>/dev/null; then
            			echo "op-ssh-agent: failed to load '$item' from 1Password" >&2
            		fi
            	done
            fi
          '';
        };
      };
    };
}
