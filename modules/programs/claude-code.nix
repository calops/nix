{ ... }:
let
  skillsDir = ./../profiles/ai-dev/skills;
  skillsSubdirs = builtins.readDir skillsDir;
  skillNames =
    skillsSubdirs
    |> builtins.attrNames
    |> builtins.concatMap (n: if skillsSubdirs.${n} == "directory" then [ n ] else [ ]);
in
{
  den.aspects.programs.provides.claude-code = {
    homeManager =
      {
        config,
        colors,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        statusLineDeps = lib.makeBinPath [
          pkgs.bash
          pkgs.jq
          pkgs.git
          pkgs.coreutils
          pkgs.gh
        ];
        statusLinePalette = pkgs.writeText "claude-statusline-palette.scss" colors.palette.asScss;

        # Two lines of oh-my-posh style pills built from the statusLine JSON
        # payload. Kept as a plain shell script (not writeShellApplication) so
        # a missing/optional field never triggers `set -e`; PATH is pinned
        # explicitly so it doesn't depend on the caller's environment.
        statusLine = pkgs.writeShellScript "claude-code-statusline" ''
          export PATH="${statusLineDeps}:$PATH"
          export CLAUDE_STATUSLINE_PALETTE="''${CLAUDE_STATUSLINE_PALETTE:-${statusLinePalette}}"
          ${builtins.readFile ./claude-code-statusline.sh}
        '';

      in
      {
        programs.claude-code = {
          enable = true;
          package = inputs'.llm-agents.packages.claude-code;
          enableMcpIntegration = true;

          settings = {
            permissions.defaultMode = "auto";
            tui = "fullscreen";
            hooks = { };
            enabledPlugins = {
              "superpowers@claude-plugins-official" = true;
            };
            statusLine = {
              type = "command";
              command = "${statusLine}";
            };
          };
        };

        home.file =
          skillNames
          |> map (name: {
            name = ".claude/skills/${name}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${skillsDir}/${name}";
          })
          |> lib.listToAttrs;
      };
  };
}
