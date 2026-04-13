{ pkgs }:
pkgs.writeShellApplication {
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
}
