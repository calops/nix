{ den, ... }:
{
  den.aspects.ai-dev = {
    includes = [ den.aspects.programs._.opencode ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.gemini-cli
          pkgs.nodejs
        ];

        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;
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
