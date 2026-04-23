{ lib }:
{
  mkProfileAspect =
    profileName: aspect:
    let
      defineOption.profiles.${profileName}.enable = lib.mkEnableOption profileName;
      setOption.profiles.${profileName}.enable = true;
    in
    {
      den.default.includes = [
        {
          nixos.options = defineOption;
          homeManager.options = defineOption;
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
