{ ... }:
{
  den.aspects.programs.provides.oh-my-pi = { ... }: {
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
        herdrPackage = inputs'.llm-agents.packages.herdr;
        ompConfig = "${config.home.configDir}/modules/programs/oh-my-pi/config/config.yml";
        ompExtensionsSrc = "${config.home.configDir}/modules/programs/oh-my-pi/extensions";
        # herdr's omp integration extension, bundled in the pinned herdr
        # binary. Extracted at build time: declarative, version-synced with the
        # flake lock, no fetchUrl dependency. The file is read by the agent at
        # runtime and never written, so the store copy is fine.
        herdrOmpStateExt =
          pkgs.runCommand "herdr-omp-agent-state.ts"
            {
              nativeBuildInputs = [ herdrPackage ];
            }
            ''
              export HOME="$TMPDIR/home"
              # herdr ≥0.8.0 refuses to install the omp integration when Pi and
              # OMP resolve to the same extensions dir, and PI_CODING_AGENT_DIR
              # drives both — so leave it unset and point OMP at its own scratch
              # dir via PI_CONFIG_DIR (extension dir = <PI_CONFIG_DIR>/agent/extensions;
              # the agent parent dir must pre-exist). Only the file content
              # matters; the runtime location is managed by xdg.configFile below.
              mkdir -p "$HOME" "$TMPDIR/omp/agent"
              PI_CONFIG_DIR="$TMPDIR/omp" herdr integration install omp >/dev/null
              cp "$TMPDIR/omp/agent/extensions/herdr-omp-agent-state.ts" "$out"
            '';

      in
      {
        home.packages = [
          (pkgs.writeShellApplication {
            name = "omp";
            runtimeInputs = [ pkgs.python3 ];
            text = ''
              # XDG-compatible OMP agent directory
              export PI_CODING_AGENT_DIR="${config.xdg.configHome}/omp/agent"

              # API credentials from 1Password
              eval "$(${lib.getExe self'.packages.op-credential} "Gemini API" GEMINI_API_KEY)"
              eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
              eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"

              exec ${lib.getExe inputs'.llm-agents.packages.omp} "$@"
            '';
          })
        ];
        xdg.configFile = {
          "omp/agent/config.yml".source = config.lib.file.mkOutOfStoreSymlink ompConfig;
          # Add a matching entry here for each new repo-managed extension.
          "omp/agent/extensions/self-review.ts".source =
            config.lib.file.mkOutOfStoreSymlink "${ompExtensionsSrc}/self-review.ts";
          "omp/agent/extensions/herdr-omp-agent-state.ts".source = herdrOmpStateExt;
        };

        home.activation.removeOmpExtensionsDirSymlink = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
          if [[ -L "${config.xdg.configHome}/omp/agent/extensions" ]]; then
            rm "${config.xdg.configHome}/omp/agent/extensions"
          fi
        '';
      };
  };
}
