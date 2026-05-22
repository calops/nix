{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "ai-dev" {
  includes = [ den.aspects.programs._.opencode ];

  homeManager =
    { pkgs, ... }:
    let
      skills = {
        "python-dev" =
          # markdown
          ''
            ---
            name: python-dev
            description: Use when writing, reviewing or specifying python code
            ---
            # Be idiomatic

            Put a special importance on being *idiomatic*, in particular *relativee to the current python version used*.
            Don't rely on old best practices and idioms, use modern constructs when relevant. For example:

            - Don't use the "lambdas in dicts" dispatching pattern, use pattern matching instead when available.
            - Don't use juxtaposition of strings for multiline strings, use triple quotes instead.
            ```

            # Correctness

            Always strive to be correct. That means using the standard, idiomatic constructs of the language and
            frameworks you're using. Don't take shortcuts by disabling lints with #noqa.
          '';
      };
    in
    {
      home.packages = [
        pkgs.gemini-cli
        pkgs.nodejs
        pkgs.cursor-cli
      ];

      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
        inherit skills;
      };

      programs.opencode.skills = skills;

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
