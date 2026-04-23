{ ... }:
{
  den.aspects.programs.provides.nushell =
    { host, ... }:
    {
      homeManager =
        { pkgs, config, ... }:
        let
          nuScripts = "${pkgs.nu_scripts}/share/nu_scripts";
        in
        {
          programs.nushell = {
            enable = true;

            extraConfig =
              #nu
              ''
                $env.config.hooks.env_change.PWD = (
                  append (source ${nuScripts}/nu-hooks/nu-hooks/direnv/config.nu)
                )

                source ./config/config.nu
              '';

            plugins = [
            ];
          };

          xdg.configFile."nushell/config".source =
            config.lib.file.mkOutOfStoreSymlink "${host.configDir}/modules/home/programs/nushell/_config";

          home.packages = [
            pkgs.oh-my-posh
          ];

          programs.oh-my-posh.enableNushellIntegration = true;

          programs.carapace = {
            enable = true;
            enableNushellIntegration = false;
          };

          programs.vivid = {
            enable = true;
            activeTheme = "catppuccin-mocha";
          };
          stylix.targets.vivid.enable = false;
        };
    };
}
