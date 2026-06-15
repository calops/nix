{ ... }:
{
  den.aspects.ai-dev.provides.skills =
    { host, ... }:
    {
      homeManager =
        { config, ... }:
        let
          skillsDir = config.lib.file.mkOutOfStoreSymlink "${host.configDir}/modules/profiles/ai-dev/skills";
        in
        {
          xdg.dataFile."ai-dev/skills".source = skillsDir;
        };
    };
}
