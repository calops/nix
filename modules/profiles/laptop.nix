{ den, lib, ... }:
{
  den.default.defineOptions.profiles.laptop.enable = lib.mkEnableOption "Laptop";

  den.aspects.laptop = {
    setOptions.profiles.laptop.enable = true;

    includes = [
      den.aspects.graphical
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.input.base
    ];
  };
}
