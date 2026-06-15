{ den, lib, ... }:
let
  inherit (import ../_helpers.nix { inherit lib; }) mkProfileAspect;
in
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };
}
// mkProfileAspect "ai-dev" {
  includes = [
    den.aspects.programs._.opencode
    den.aspects.programs._.claude-code
    den.aspects.programs._.pi
    den.aspects.ai-dev._.skills
  ];

  nix.extra-substituters = [ "https://cache.numtide.com" ];
  nix.extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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

        agentPkgs.gemini-cli
        agentPkgs.cursor-agent
        agentPkgs.codex
        agentPkgs.rtk
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
        };
      };
    };
}
