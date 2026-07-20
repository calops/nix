{ ... }:
{
  den.aspects.programs.provides.oh-my-pi = { host, ... }: {
    homeManager =
      {
        pkgs,
        lib,
        config,
        self',
        inputs',
        ...
      }:
      let
        ompConfig = "${host.configDir}/modules/programs/oh-my-pi/config/config.yml";
      in
      {
        home.packages = [
          (pkgs.writeShellScriptBin "omp" ''
            # XDG-compatible OMP agent directory
            export PI_CODING_AGENT_DIR="${config.xdg.configHome}/omp/agent"

            # API credentials from 1Password
            eval "$(${lib.getExe self'.packages.op-credential} "Gemini API" GEMINI_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"

            exec ${lib.getExe inputs'.llm-agents.packages.omp} "$@"
          '')
        ];

        xdg.configFile."omp/agent/config.yml".source = config.lib.file.mkOutOfStoreSymlink ompConfig;
      };
  };
}
