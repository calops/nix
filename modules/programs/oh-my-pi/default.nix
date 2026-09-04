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
        # Herdr Link targets Pi. OMP implements the compatible extension API,
        # but exposes TypeBox through `pi.typebox`; patch the upstream adapter
        # at build time instead of maintaining a fork.
        herdrLinkOmpExtension =
          pkgs.runCommand "herdr-link-omp-extension"
            {
              nativeBuildInputs = [ pkgs.python3 ];
            }
            ''
              mkdir -p "$out"
              cp ${inputs.herdr-link}/src/{herdr,protocol}.ts "$out"
              cp ${./inbound.ts} "$out/inbound.ts"
              cp ${inputs.herdr-link}/src/pi.ts "$out/index.ts"
              chmod u+w "$out/index.ts"
              python3 - "$out/index.ts" <<'PY'
              from pathlib import Path

              path = Path(__import__("sys").argv[1])
              source = path.read_text()
              source = source.replace(
                  "@earendil-works/pi-coding-agent",
                  "@oh-my-pi/pi-coding-agent",
              )
              source = source.replace('import { Type } from "typebox";\n', "")

              start = source.index("const GATEWAY_PARAMETERS")
              end = source.index("function toolResult")
              parameter_definitions = source[start:end]
              source = source[:start] + source[end:]

              marker = "export default function (pi: ExtensionAPI): void {"
              source = source.replace(
                  marker,
                  f"{marker}\n  const {{ Type }} = pi.typebox;\n"
                  + "\n".join(
                      f"  {line}" if line else line
                      for line in parameter_definitions.splitlines()
                  ),
                  1,
              )
              # OMP-native inbound presentation (additive glue, see inbound.ts).
              source = source.replace(
                  'import { COMMUNICATION_CONTRACT, formatAgentFacingError } from "./protocol.ts";\n',
                  'import { COMMUNICATION_CONTRACT, formatAgentFacingError } from "./protocol.ts";\nimport { installOmpInboundHandler } from "./inbound.ts";\n',
              )
              source = source.replace(
                  "  ) {\n    return;\n  }\n",
                  "  ) {\n    return;\n  }\n\n  installOmpInboundHandler(pi);\n",
              )
              path.write_text(source)
              PY
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
          ".omp/agent/extensions/self-review.ts".source =
            config.lib.file.mkOutOfStoreSymlink "${ompExtensionsSrc}/self-review.ts";
          ".omp/agent/extensions/herdr-omp-agent-state.ts".source = herdrOmpStateExt;
          ".omp/agent/extensions/herdr-link".source = herdrLinkOmpExtension;
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
