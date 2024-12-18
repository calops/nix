{
  inputs,
  config,
  ...
}:
{
  imports = [
    ../common
    inputs.stylix.homeManagerModules.stylix
    inputs.nix-index-database.hmModules.nix-index
    inputs.nixcord.homeManagerModules.nixcord
  ];

  config = {
    xdg.configFile."colors/palette.css".source = config.my.colors.palette.asCss;
    xdg.configFile."colors/palette.gtk.css".source = config.my.colors.palette.asGtkCss;
    xdg.configFile."colors/palette.scss".source = config.my.colors.palette.asScss;
    xdg.dataFile."lua/palette.lua".source = config.my.colors.palette.asLua;
  };
}
