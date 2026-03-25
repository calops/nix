{ pkgs, ... }:
let
  zai = pkgs.writeShellScriptBin "zai" ''
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/zai"
    api_key_file="$state_dir/api-key"

    if [ ! -f "$api_key_file" ]; then
    	echo "Fetching z.ai API key from 1Password..." >&2
    	mkdir -p "$state_dir"
    	chmod 700 "$state_dir"
    	api_key="$(op item get "z.ai API key" --fields credential --reveal 2>/dev/null)"
    	if [ -z "$api_key" ]; then
    		echo "Error: failed to fetch z.ai API key from 1Password" >&2
    		exit 1
    	fi
    	printf '%s' "$api_key" >"$api_key_file"
    	chmod 600 "$api_key_file"
    fi

    export ANTHROPIC_AUTH_TOKEN="$(cat "$api_key_file")"
    export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
    export API_TIMEOUT_MS="3000000"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5"
    exec claude "$@"
  '';
in
{
  home.packages = [
    pkgs.beads
    pkgs.gemini-cli
    zai
  ];

  programs.claude-code = {
    enable = true;
    mcpServers = {
      linear = {
        type = "sse";
        url = "https://mcp.linear.app/sse";
      };
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp/oauth";
      };
      notion = {
        type = "http";
        url = "https://mcp.notion.com/mcp";
      };
    };
  };

  programs.mcp = {
    enable = true;
    servers.context7.url = "https://mcp.context7.com/mcp/oauth";
  };
}
