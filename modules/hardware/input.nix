{ den, lib, ... }:
{
  den.schema.host =
    { lib, ... }:
    {
      options.keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "fr";
      };
      options.alternateKeyboardLayout = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Alternate keyboard layout to toggle to (e.g. 'us').";
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
          services.xserver.xkb.layout =
            if host.alternateKeyboardLayout != null
            then "${host.keyboardLayout},${host.alternateKeyboardLayout}"
            else host.keyboardLayout;
          console.keyMap = host.keyboardLayout;
        };
      };
  };
}
