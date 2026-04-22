{ den, config, ... }:
{
  den.schema.host =
    { lib, ... }:
    {
      options.my.keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "fr";
      };
    };

  den.aspects.input = {
    base.includes = [
      den.aspects.input.keyboard
      den.aspects.input.mouse
    ];

    keyboard = {
      nixos = {
        services.xserver.xkb.layout = config.my.keyboardLayout;
        console.keyMap = config.my.keyboardLayout;
      };
    };

    mouse = { };
  };
}
