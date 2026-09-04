{ den, lib, ... }:
let
  inherit (import ../_helpers.nix { inherit lib; }) mkProfileAspect;
in
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  caches.numtide = {
    url = "https://cache.numtide.com";
    key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
  };
}
// mkProfileAspect "ai-dev" {
  includes = [
    den.aspects.programs._.opencode
    den.aspects.programs._.claude-code
    den.aspects.programs._.pi
    den.aspects.programs._.oh-my-pi
    den.aspects.ai-dev._.skills
    den.aspects.programs._.herdr
  ];

  homeManager =
    { pkgs, inputs', ... }:
    let
      agentPkgs = inputs'.llm-agents.packages;
    in
    {
      home.packages = [
        # TODO: remove this, put it where it's needed only
        pkgs.nodejs

        agentPkgs.antigravity-cli
        agentPkgs.cursor-agent
        agentPkgs.codex
        agentPkgs.spec-kit
        agentPkgs.reasonix
      ];

      programs.git.ignores = [
        ".specify"
        ".claude/skills/speckit-*"
      ];

      programs.mcp = {
        enable = true;
        servers = {
          context7.url = "https://mcp.context7.com/mcp/oauth";
          notion.url = "https://mcp.notion.com/mcp";
          linear.url = "https://mcp.linear.app/mcp";
          sentry.url = "https://mcp.sentry.dev/mcp";
          grafana.url = "https://mcp.grafana.com/mcp";
        };
      };
    };
}
