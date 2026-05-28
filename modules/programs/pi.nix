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
          # "npm:pi-powerline-footer"
          # TODO: requires pi >=0.75.0 (we have 0.74.2 via llm-agents); re-enable when updated
          # "npm:@gotgenes/pi-permission-system"
          "npm:pi-ask-user"
        ];

        settings = {
          defaultModel = "claude-sonnet-4";
          defaultThinkingLevel = "medium";
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
        };
      };
  };
}
