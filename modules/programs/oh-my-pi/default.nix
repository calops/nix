{ inputs, ... }:
{
  flake-file.inputs = {
    omp = {
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
        ompPackage = inputs'.llm-agents.packages.omp;
        ompConfigDir = "${config.home.homeDirectory}/.omp/agent";
        legacyOmpConfigDir = "${config.xdg.configHome}/omp/agent";
        ompExtensionsSrc = "${config.home.configDir}/modules/programs/oh-my-pi/extensions";
        ompWrapper = pkgs.writeShellApplication {
          name = "omp";
          runtimeInputs = [ pkgs.python3 ];
          text = ''
            eval "$(${lib.getExe self'.packages.op-credential} "Gemini API" GEMINI_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"

            exec ${lib.getExe ompPackage} "$@"
          '';
        };
        # herdr's OMP integration is bundled in the pinned herdr binary.
        # Extract it at build time so its version remains synchronized with the
        # flake lock, then deploy it declaratively as an OMP extension.
        herdrOmpStateExt =
          pkgs.runCommand "herdr-omp-agent-state.ts"
            {
              nativeBuildInputs = [ herdrPackage ];
            }
            ''
              export HOME="$TMPDIR/home"
              mkdir -p "$HOME" "$TMPDIR/omp/agent"
              PI_CONFIG_DIR="$TMPDIR/omp" herdr integration install omp >/dev/null
              cp "$TMPDIR/omp/agent/extensions/herdr-omp-agent-state.ts" "$out"
            '';
      in
      {
        imports = [ inputs.omp.homeManagerModules.default ];

        programs.omp = {
          enable = true;
          package = ompWrapper;
          settings = {
            symbolPreset = "nerd";
            theme.dark = "dark-catppuccin";
            setupVersion = 2;
            memory.backend = "local";
            advisor.enabled = false;
            astGrep.enabled = true;
            autolearn.enabled = true;
            checkpoint.enabled = true;
            github.enabled = true;
            task.enableLsp = true;
            modelRoles = {
              default = "openai-codex/gpt-5.6-terra";
              plan = "openai-codex/gpt-5.6-sol";
              task = "openai-codex/gpt-5.6-luna";
              smol = "opencode-go/deepseek-v4-flash";
              slow = "openai-codex/gpt-5.6-sol";
              vision = "openai-codex/gpt-5.6-terra";
              tiny = "opencode-go/deepseek-v4-flash";
            };
            enabledModels = [
              "opencode-go/*"
              "google/gemini-3*"
              "openai-codex/gpt-5.6*"
            ];
            defaultThinkingLevel = "auto";
            hideThinkingBlock = true;
            skills = {
              customDirectories = [ "~/.local/share/ai-dev/skills" ];
              enableClaudeUser = false;
              enableClaudeProject = true;
              enablePiUser = false;
              enablePiProject = false;
              enableCodexUser = false;
              enableAgentsUser = false;
              enableAgentsProject = true;
            };
            dev.autoqaConsent = "granted";
            composer.shape = "box";
          };
        };

        home.file = {
          ".omp/agent/extensions/self-review.ts" = {
            source = config.lib.file.mkOutOfStoreSymlink "${ompExtensionsSrc}/self-review.ts";
            force = true;
          };
          ".omp/agent/extensions/herdr-omp-agent-state.ts" = {
            source = herdrOmpStateExt;
            force = true;
          };
        };

        home.activation.migrateOmpAgentDir = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          if [[ ! -e "${ompConfigDir}" && -d "${legacyOmpConfigDir}" ]]; then
            run mkdir -p "$(dirname "${ompConfigDir}")"
            run cp -a "${legacyOmpConfigDir}" "${ompConfigDir}"
            if [[ -L "${ompConfigDir}/extensions" ]]; then
              run rm "${ompConfigDir}/extensions"
            fi
          fi
        '';
      };
  };
}
