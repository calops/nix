{ pkgs, ... }:
{
  home.packages = [
    pkgs.beads
    pkgs.gemini-cli
  ];

  programs.claude-code = {
    enable = true;
    mcpServers = {
      linear = {
        type = "sse";
        url = "https://mcp.linear.app/sse";
      };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
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
