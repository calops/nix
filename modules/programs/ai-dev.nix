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
            eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
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
