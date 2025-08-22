{
  inputs,
  config,
  perSystem,
  ...
}:
{
  imports = [
    ../common
    ./programs
    ./config
    inputs.stylix.homeModules.stylix
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = {
    xdg.configFile."colors/palette.css".source = config.my.colors.palette.asCss;
    xdg.configFile."colors/palette.gtk.css".source = config.my.colors.palette.asGtkCss;
    xdg.configFile."colors/palette.scss".source = config.my.colors.palette.asScss;
    xdg.dataFile."lua/palette.lua".source = config.my.colors.palette.asLua;

    home.packages = [
      perSystem.nix-index-database.nix-index-with-db
    ];
  };
}
