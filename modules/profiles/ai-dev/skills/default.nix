{ ... }:
{
  den.aspects.ai-dev.provides.skills = { ... }: {
    homeManager =
      { config, ... }:
      let
        skillsDir = config.lib.file.mkOutOfStoreSymlink "${config.home.configDir}/modules/profiles/ai-dev/skills";
      in
      {
        xdg.dataFile."ai-dev/skills".source = skillsDir;
      };
  };
}
