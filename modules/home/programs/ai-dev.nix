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
    };
  };

  programs.mcp = {
    enable = true;
    servers.linear.url = "https://mcp.linear.app/mcp";
  };
}
