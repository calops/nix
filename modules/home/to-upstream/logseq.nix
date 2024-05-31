{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.logseq;
in
{
  options = {
    programs.logseq = {
      enable = lib.mkEnableOption "logseq";
      package = lib.mkPackageOption pkgs "logseq" { };
      customCss = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Custom CSS to be applied to the Logseq app.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".logseq/config/config.edn".text =
      let
        customCss = pkgs.writeText "custom.css" cfg.customCss;
      in
      lib.mkIf (cfg.customCss != null)
        # clojure
        ''
          {
            :custom-css-url "@import url('assets://${customCss}');"
          }
        '';
  };
}
