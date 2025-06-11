{
  inputs,
  config,
  ...
}:
{
  imports = [
    ../common
    inputs.stylix.homeModules.stylix
    inputs.nix-index-database.hmModules.nix-index
  ];

  config = {
    xdg.configFile."colors/palette.css".source = config.my.colors.palette.asCss;
    xdg.configFile."colors/palette.gtk.css".source = config.my.colors.palette.asGtkCss;
    xdg.configFile."colors/palette.scss".source = config.my.colors.palette.asScss;
    xdg.dataFile."lua/palette.lua".source = config.my.colors.palette.asLua;
  };
}
