{
  pkgs,
  config,
  ...
}:
let
  nuScripts = "${pkgs.nu_scripts}/share/nu_scripts";

in
{
  config = {
    programs.nushell = {
      enable = true;

      extraConfig =
        #nu
        ''
          $env.config.hooks.env_change.PWD = (
            append (source ${nuScripts}/nu-hooks/nu-hooks/direnv/config.nu)
          )

          source ./extraConfig.nu

          oh-my-posh init nu --config ${config.my.oh-my-posh.theme}
        '';

      plugins = [
        pkgs.nushellPlugins.highlight
        pkgs.nushellPlugins.skim
      ];
    };

    xdg.configFile."nushell/extraConfig.nu".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.configDir}/modules/home/programs/nushell/config.nu";

    home.packages = [
      pkgs.oh-my-posh
    ];

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.vivid = {
      enable = true;
      activeTheme = "catppuccin-mocha";
    };
  };
}
