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
        inputs',
        lib,
        pkgs,
        ...
      }:
      {
        programs.claude-code = {
          enable = true;
          package = inputs'.llm-agents.packages.claude-code;
          enableMcpIntegration = true;

          settings = {
            permissions.defaultMode = "auto";
            hooks.PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = "${lib.getExe pkgs.rtk} hook claude";
                  }
                ];
              }
            ];
            enabledPlugins = {
              "superpowers@claude-plugins-official" = true;
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
