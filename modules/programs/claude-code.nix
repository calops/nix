{ ... }:
{
  den.aspects.programs.provides.claude-code = {
    homeManager =
      { config, ... }:
      {
        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;
          skills = "${config.xdg.dataHome}/ai-dev/skills";
          settings.permissions.defaultMode = "auto";
        };
      };
  };
}
