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
          $env.config.show_banner = false

          # direnv hook
          $env.config.hooks.env_change.PWD = (
            append (source ${nuScripts}/nu-hooks/nu-hooks/direnv/config.nu)
          )

          # no table borders
          $env.config.table.mode = "none"

          # shell prompt
          oh-my-posh init nu --config ${config.my.oh-my-posh.theme}
        '';

      plugins = [
        pkgs.nushellPlugins.highlight
      ];
    };

    home.packages = [
      pkgs.oh-my-posh
    ];
  };
}
