{ ... }:
{
  den.aspects.programs.provides.opencode = {
    homeManager =
      {
        pkgs,
        lib,
        config,
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

          skills = "${config.xdg.dataHome}/ai-dev/skills";

          settings = {
            provider.zai-coding-plan.options.apiKey = "{env:ZAI_API_KEY}";
            provider.cursor.name = "Cursor";
            plugin = [
              "opencode-notify"
              "opencode-firecrawl"
              "opencode-supermemory"
              "opencode-worktree"
              "opencode-dynamic-context-pruning"
              "opencode-openai-codex-auth"
              "opencode-cursor-oauth"
              "superpowers@git+https://github.com/obra/superpowers.git"
            ];
          };

          agents = {
            codex = ''
              ---
              description: Generic coding agent running OpenAI Codex
              mode: subagent
              model: openai/gpt-5.3-codex
              ---
            '';
            cursor = ''
              ---
              description: Generic coding agent running Cursor
              mode: subagent
              model: cursor/auto
              ---
            '';
          };
        };
      };
  };
}
