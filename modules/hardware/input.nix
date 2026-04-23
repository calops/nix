{ den, ... }:
{
  den.schema.host =
    { lib, ... }:
    {
      options.keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "fr";
      };
    };

  den.aspects.input.provides = {
    base.includes = [
      den.aspects.input._.keyboard
    ];

    keyboard =
      { host, ... }:
      {
        nixos = {
          services.xserver.xkb.layout = host.keyboardLayout;
          console.keyMap = host.keyboardLayout;
        };
      };
  };
}
