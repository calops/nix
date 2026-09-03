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
        ...
      }:
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
