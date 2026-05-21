{ ... }:
{
  den.aspects.programs.provides.opencode = {
    homeManager =
      {
        pkgs,
        lib,
        self',
        ...
      }:
      {
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
              "opencode-firecrawl"
              "opencode-supermemory"
              "opencode-worktree"
              "opencode-dynamic-context-pruning"
              "opencode-openai-codex-auth"
              "opencode-cursor"
              "superpowers@git+https://github.com/obra/superpowers.git"
            ];
          };

          agents = ./agents;
        };
      };
  };
}
