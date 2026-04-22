{ den, ... }:
{
  den.aspects.programs.zed = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        programs.zed-editor = {
          enable = true;
          extensions = [
            "nix"
            "toml"
          ];
          userSettings = {
            assistant = {
              enabled = true;
              default_model = {
                provider = "anthropic";
                model = "claude-3-5-opus-latest";
              };
            };
            node = {
              path = lib.getExe pkgs.nodejs;
              npm_path = lib.getExe' pkgs.nodejs "npm";
            };
            hour_format = "hour24";
            auto_update = false;
            terminal = {
              font_family = config.my.roles.graphical.fonts.monospace.name;
            };
            mcp.linear.url = "https://mcp.linear.app/mcp";
            vim_mode = true;
            load_direnv = "shell_hook";
            base_keymap = "VSCode";
            show_whitespaces = "all";
          };
        };
      };
  };
}
