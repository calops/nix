{ config, lib, ... }:
let
  palette = config.my.colors.palette.withHashtag;
  mkPill =
    { color, format, ... }@args:
    builtins.removeAttrs args [ "color" ]
    // {
      format = lib.removeSuffix "\n" ''
        [](fg:${color} bg:${palette.base})[${format}](fg:${palette.base} bg:${color})[ ](bg:${palette.base} fg:${color})
      '';
    };
in
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.starship = {
      enable = config.my.roles.terminal.enable;
      settings = {
        rust.symbol = " ";
        python.symbol = " ";
        git_branch.symbol = "󰘬 ";

        elixir = mkPill {
          symbol = " ";
          color = palette.purple;
          format = ''$symbol($version  $otp_version)'';
        };

        lua = mkPill {
          symbol = " ";
          color = palette.teal;
          format = ''$symbol$version'';
        };

        nix_shell = mkPill {
          symbol = " ";
          color = palette.navy;
          format = ''$symbol($name)'';
          heuristic = true;
        };

        hostname = {
          ssh_symbol = "󰌘 ";
          style = "bold blink bright-red";
        };

        docker_context = mkPill {
          symbol = " ";
          color = palette.blue;
          format = ''$symbol$context'';
        };

        package = mkPill {
          symbol = "󰏗 ";
          color = palette.tangerine;
          format = ''$symbol$version'';
        };

        aws = mkPill {
          symbol = "󰸏 ";
          color = palette.sand;
          format = ''$symbol($profile)(\($region\))(\[$duration\])'';
        };

        nodejs = mkPill {
          symbol = " ";
          color = palette.green;
          format = ''$symbol$version'';
        };
      };
    };
  };
}
