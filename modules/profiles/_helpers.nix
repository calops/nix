{ lib }:
{
  mkProfileAspect =
    profileName: aspect:
    let
      defineOption.profiles.${profileName}.enable = lib.mkEnableOption profileName;
      setOption.profiles.${profileName}.enable = true;
    in
    {
      den.schema.user.includes = [
        { homeManager.options = defineOption; }
      ];

      den.schema.host.includes = [
        {
          nixos.options = defineOption;
          darwin.options = defineOption;
        }
      ];

      den.aspects.${profileName} = aspect // {
        includes = (aspect.includes or [ ]) ++ [
          {
            nixos.config = setOption;
            homeManager.config = setOption;
            darwin.config = setOption;
          }
        ];
      };
    };
}
