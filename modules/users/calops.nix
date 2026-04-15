{ inputs, den, lib, ... }:
{
  den.aspects.calops = {
    includes = [
      den.aspects.terminal
      den.aspects.base-home
    ];
  };
}
