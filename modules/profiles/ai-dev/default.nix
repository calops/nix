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
  ];

  nix.extra-substituters = [ "https://cache.numtide.com" ];
  nix.extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gemini-cli
        pkgs.nodejs
        pkgs.cursor-cli
      ];

      xdg.dataFile."ai-dev/skills".source = ./skills;

      programs.mcp = {
        enable = true;
        servers = {
          context7.url = "https://mcp.context7.com/mcp/oauth";
          notion.url = "https://mcp.notion.com/mcp";
          linear.url = "https://mcp.linear.app/mcp";
        };
      };
    };
}
