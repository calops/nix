{ ... }:
let
  skillsDir = ./../profiles/ai-dev/skills;
  skillsDirStr = toString skillsDir;
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
          };
        };

        home.file =
          skillNames
          |> map (name: {
            name = ".claude/skills/${name}";
            value.source = config.lib.file.mkOutOfStoreSymlink "${skillsDirStr}/${name}";
          })
          |> lib.listToAttrs;
      };
  };
}
