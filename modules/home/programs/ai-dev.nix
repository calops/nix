{ pkgs, lib, ... }:
let
  zaiApiKeySetup =
    #bash
    ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/zai"
      api_key_file="$state_dir/api-key"

      if [ ! -f "$api_key_file" ]; then
      	echo "Fetching z.ai API key from 1Password..." >&2
      	mkdir -p "$state_dir" --mode 700
      	api_key="$(op item get "z.ai API key" --fields credential --reveal 2>/dev/null)"
      	if [ -z "$api_key" ]; then
      		echo "Error: failed to fetch z.ai API key from 1Password" >&2
      		exit 1
      	fi
      	printf '%s' "$api_key" >"$api_key_file"
      	chmod 600 "$api_key_file"
      fi

      export ZAI_API_KEY="$(cat "$api_key_file")"
    '';

  zaiClaude = pkgs.writeShellScriptBin "zai" ''
    ${zaiApiKeySetup}
    export ANTHROPIC_AUTH_TOKEN=$ZAI_API_KEY
    export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
    export API_TIMEOUT_MS="3000000"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"
    exec claude "$@"
  '';

  zaiOpencode = pkgs.writeShellScriptBin "opencode" ''
    ${zaiApiKeySetup}
    exec ${lib.getExe pkgs.opencode} "$@"
  '';
in
{
  home.packages = [
    pkgs.beads
    pkgs.gemini-cli
    pkgs.nodejs
    zaiClaude
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = zaiOpencode;

    settings = {
      provider.zai-coding-plan.options.apiKey = "{env:ZAI_API_KEY}";
      plugin = [
        "opencode-notify"
        "opencode-snip"
        "oh-my-opencode"
      ];
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      context7.url = "https://mcp.context7.com/mcp/oauth";
      notion.url = "https://mcp.notion.com/mcp";
      linear.url = "https://mcp.linear.app/sse";
    };
  };
}
