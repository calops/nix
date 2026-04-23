{ ... }:
{
  den.aspects.programs.provides.ai-dev = {
    homeManager =
      {
        pkgs,
        lib,
        self',
        ...
      }:
      {
        home.packages = [
          pkgs.gemini-cli
          pkgs.nodejs
          (pkgs.writeShellScriptBin "zai" ''
            eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"
            export ANTHROPIC_AUTH_TOKEN=$ZAI_API_KEY
            export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
            export API_TIMEOUT_MS="3000000"
            export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
            export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
            export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"
            exec claude "$@"
          '')
        ];

        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;
        };

        programs.opencode = {
          enable = true;
          enableMcpIntegration = true;
          package = pkgs.writeShellScriptBin "opencode" ''
            eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"
            exec ${lib.getExe pkgs.opencode} "$@"
          '';

          settings = {
            provider.zai-coding-plan.options.apiKey = "{env:ZAI_API_KEY}";
            plugin = [
              "opencode-notify"
              "opencode-dynamic-context-pruning"
              "superpowers@git+https://github.com/obra/superpowers.git"
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
      };
  };
}
