{ den, ... }:
{
  den.aspects.calops = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    user.description = "Rémi Labeyrie";
    user.extraGroups = [ "docker" ];
  };
}
