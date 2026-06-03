{ ... }:
{
  den.aspects.programs.provides.pi = {
    homeManager =
      {
        pkgs,
        lib,
        config,
        self',
        inputs',
        colors,
        ...
      }:
      let
        palette = colors.palette.asHexWithHashtag;
        piConfigDir = "${config.xdg.configHome}/pi";

        piPackages = [
          "git:github.com/obra/superpowers"
          # "npm:pi-agent-extensions"  # replaced by dedicated packages below
          "npm:pi-subagents"
          "npm:pi-mcp-adapter"
          "npm:context-mode"
          "npm:pi-web-access"
          "npm:pi-simplify"
          "npm:pi-lens"
          "npm:pi-markdown-preview"
          "npm:pi-btw"
          "npm:pi-powerline-footer"
          "npm:@gotgenes/pi-permission-system"
          "npm:pi-ask-user"
        ];

        permissionConfig = {
          "$schema" =
            "https://raw.githubusercontent.com/gotgenes/pi-permission-system/main/schemas/permissions.schema.json";
          debugLog = false;
          permissionReviewLog = true;
          yoloMode = false;
          permission = {
            "*" = "ask";

            read = "allow";
            grep = "allow";
            find = "allow";
            ls = "allow";

            write = "ask";
            edit = "ask";

            web_search = "allow";
            code_search = "allow";
            fetch_content = "allow";
            get_search_content = "allow";

            ast_grep_search = "allow";
            lsp_diagnostics = "allow";
            lsp_navigation = "allow";
            preview_export = "allow";
            ask_user = "allow";

            ctx_execute = "allow";
            ctx_execute_file = "allow";
            ctx_batch_execute = "allow";
            ctx_search = "allow";
            ctx_stats = "allow";
            ctx_doctor = "allow";
            ctx_index = "allow";
            ctx_fetch_and_index = "allow";
            ctx_insight = "allow";

            ctx_upgrade = "ask";
            ctx_purge = "ask";

            ast_grep_replace = "ask";
            subagent = "ask";

            bash = {
              "*" = "ask";

              "cat *" = "allow";
              "cal" = "allow";
              "chmod *" = "ask";
              "chown *" = "ask";
              "cmake *" = "ask";
              "curl *" = "ask";
              "cargo *" = "ask";

              "date" = "allow";
              "dd *" = "deny";
              "docker *" = "ask";
              "darwin-rebuild *" = "ask";

              "echo *" = "allow";
              "env" = "allow";
              "export" = "allow";

              "false" = "allow";
              "fd" = "allow";
              "fd *" = "allow";
              "fdisk *" = "ask";
              "flatpak *" = "ask";

              "git *" = "allow";
              "git push *" = "ask";

              "head *" = "allow";

              "journalctl *" = "allow";

              "less *" = "allow";
              "ls *" = "allow";

              "make *" = "ask";
              "meson *" = "ask";
              "mount *" = "ask";
              "more *" = "allow";
              "mkfs*" = "deny";

              "nh *" = "ask";
              "ninja *" = "ask";
              "nix *" = "ask";
              "nix build *" = "ask";
              "nix develop *" = "ask";
              "nix eval *" = "allow";
              "nix flake show *" = "allow";
              "nix flake metadata *" = "allow";
              "nix flake update *" = "ask";
              "nix flake lock *" = "ask";
              "nix path-info *" = "allow";
              "nix profile *" = "ask";
              "nix run *" = "ask";
              "nix search *" = "allow";
              "nix store diff-closures *" = "allow";
              "nix why-depends *" = "allow";
              "nixos-rebuild *" = "ask";
              "npm *" = "ask";

              "parted *" = "ask";
              "pip *" = "ask";
              "pnpm *" = "ask";
              "podman *" = "ask";
              "poetry *" = "ask";
              "printf *" = "allow";
              "pwd" = "allow";

              "rg" = "allow";
              "rg *" = "allow";
              "rm *" = "ask";
              "rm -rf *" = "deny";
              "rsync *" = "ask";

              "scp *" = "ask";
              "ssh *" = "ask";
              "sudo *" = "ask";
              "systemctl *" = "ask";

              "tail *" = "allow";
              "test *" = "allow";
              "true" = "allow";
              "type *" = "allow";

              "umount *" = "ask";

              "wget *" = "ask";
              "which *" = "allow";
              "whoami" = "allow";

              "yarn *" = "ask";
            };

            mcp = {
              "*" = "allow";
              mcp_connect = "allow";
              mcp_describe = "allow";
              mcp_list = "allow";
              mcp_search = "allow";
              mcp_status = "allow";
            };

            skill = {
              "*" = "allow";
            };

            path = {
              "*" = "allow";

              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";

              "*.envrc" = "allow";
              "*.envrc.*" = "allow";

              "**/.gnupg/**" = "deny";
              "**/.password-store/**" = "deny";
              "**/.ssh/**" = "deny";
              "**/.ssh/authorized_keys" = "deny";
              "**/.ssh/config" = "allow";
              "**/.ssh/known_hosts" = "allow";

              "**/api.key" = "deny";
              "**/api_key" = "deny";
              "**/apikey*" = "deny";

              "**/config.json" = "allow";

              "**/id_ecdsa" = "deny";
              "**/id_ecdsa.pub" = "allow";
              "**/id_ecdsa_sk" = "deny";
              "**/id_ed25519" = "deny";
              "**/id_ed25519.pub" = "allow";
              "**/id_ed25519_sk" = "deny";
              "**/id_rsa" = "deny";
              "**/id_rsa.pub" = "allow";

              "**/secret/**" = "deny";
              "**/secrets/**" = "deny";
              "**/settings.json" = "allow";

              "**/tokens" = "deny";

              "**/vault/**" = "deny";
            };

            external_directory = {
              "*" = "ask";
              "/nix/store/*" = "allow";
              "~/.config/pi/*" = "allow";
              "~/.local/share/pi/*" = "allow";
              "~/.local/state/pi/*" = "allow";
            };
          };
        };

        rememberModelExtension =
          # js
          ''
            import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
            import { readFile, writeFile } from "node:fs/promises";
            import { join } from "node:path";

            export default function (pi: ExtensionAPI) {
              pi.on("model_select", async (event, ctx) => {
                if (event.source === "restore") return;

                const settingsPath = join(ctx.cwd, ".pi", "settings.json");

                try {
                  let settings: Record<string, unknown> = {};
                  try {
                    settings = JSON.parse(await readFile(settingsPath, "utf-8"));
                  } catch { }

                  settings.defaultModel = event.model.id;
                  settings.defaultProvider = event.model.provider;

                  await writeFile(settingsPath, JSON.stringify(settings, null, 2) + "\n");
                } catch { }
              });
            }
          '';

        settings = {
          defaultModel = "claude-sonnet-4";
          defaultThinkingLevel = "medium";
          enabledModels = [
            "anthropic/*"
            "openai/*"
            "opencode-go/*"
          ];
          hideThinkingBlock = false;
          theme = "catppuccin-mocha";
          quietStartup = false;
          doubleEscapeAction = "tree";
          treeFilterMode = "default";
          steeringMode = "one-at-a-time";
          followUpMode = "one-at-a-time";
          enableInstallTelemetry = false;
          skills = [ "${config.xdg.dataHome}/ai-dev/skills" ];
          packages = piPackages;

          compaction = {
            enabled = true;
            reserveTokens = 16384;
            keepRecentTokens = 20000;
          };

          retry = {
            enabled = true;
            maxRetries = 3;
            baseDelayMs = 2000;
          };

          powerline = {
            preset = "full";
            fixedEditor = false;
          };
        };

        keybindings = {
          tui.editor.deleteWordBackward = [
            "ctrl+w"
            "ctrl+backspace"
          ];
        };

        theme = {
          name = "catppuccin-mocha";
          vars = palette;
          colors = {
            # Core UI
            accent = "blue";
            border = "surface1";
            borderAccent = "blue";
            borderMuted = "surface0";
            success = "green";
            error = "red";
            warning = "peach";
            muted = "overlay1";
            dim = "overlay0";
            text = "";
            thinkingText = "overlay1";

            # Backgrounds & Content
            selectedBg = "surface0";
            userMessageBg = "surface0";
            userMessageText = "";
            customMessageBg = "surface0";
            customMessageText = "";
            customMessageLabel = "blue";
            toolPendingBg = "crust";
            toolSuccessBg = "#1a2a1e";
            toolErrorBg = "#2a1a1e";
            toolTitle = "blue";
            toolOutput = "";

            # Markdown
            mdHeading = "peach";
            mdLink = "blue";
            mdLinkUrl = "overlay1";
            mdCode = "teal";
            mdCodeBlock = "";
            mdCodeBlockBorder = "surface1";
            mdQuote = "overlay1";
            mdQuoteBorder = "overlay1";
            mdHr = "surface1";
            mdListBullet = "teal";

            # Tool diffs
            toolDiffAdded = "green";
            toolDiffRemoved = "red";
            toolDiffContext = "overlay1";

            # Syntax highlighting
            syntaxComment = "overlay1";
            syntaxKeyword = "mauve";
            syntaxFunction = "blue";
            syntaxVariable = "text";
            syntaxString = "green";
            syntaxNumber = "peach";
            syntaxType = "yellow";
            syntaxOperator = "sky";
            syntaxPunctuation = "overlay1";

            # Thinking level borders
            thinkingOff = "overlay1";
            thinkingMinimal = "blue";
            thinkingLow = "sky";
            thinkingMedium = "teal";
            thinkingHigh = "pink";
            thinkingXhigh = "red";

            # Bash mode
            bashMode = "peach";
          };
        };
      in
      {
        home.packages = [
          (pkgs.writeShellScriptBin "pi" ''
            # XDG-compatible config directory
            export PI_CODING_AGENT_DIR="${piConfigDir}"
            export PI_CODING_AGENT_SESSION_DIR="${config.xdg.dataHome}/pi/sessions"

            # API credentials from 1Password
            eval "$(${lib.getExe self'.packages.op-credential} "Gemini API" GEMINI_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
            eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"

            exec ${lib.getExe inputs'.llm-agents.packages.pi} "$@"
          '')
        ];

        xdg.configFile = {
          "pi/settings.json".text = builtins.toJSON settings;
          "pi/keybindings.json".text = builtins.toJSON keybindings;
          "pi/themes/catppuccin-mocha.json".text = builtins.toJSON theme;
          "pi/extensions/remember-model.ts".text = rememberModelExtension;
          "pi/extensions/pi-permission-system/config.json".text = builtins.toJSON permissionConfig;
        };
      };
  };
}
