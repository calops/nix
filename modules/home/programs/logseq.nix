{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.roles.graphical;

  # TODO: remove once nixpkgs fixes the ozone setting for electron 27
  logseqPkg =
    if pkgs.stdenv.isLinux then
      pkgs.logseq.overrideAttrs (oldAttrs: {
        postFixup = ''
          makeWrapper ${pkgs.electron}/bin/electron $out/bin/${oldAttrs.pname} \
            --add-flags $out/share/${oldAttrs.pname}/resources/app \
            --add-flags "--use-gl=desktop" \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}"
        '';
      })
    else
      null;
in
{
  config = lib.mkIf cfg.enable {
    programs.logseq =
      let
        customCss = pkgs.fetchurl {
          url = "https://logseq.catppuccin.com/ctp-mocha.css";
          hash = "sha256-J8zX/X7lpPHaozkZYSF+ZrshDAZ2jILhCVFzljxvx0s=";
        };
      in
      {
        enable = true;
        package = logseqPkg;
        # TODO: make a custom package for this and fetch from github
        customCss =
          builtins.readFile customCss
          # css
          + ''
            * {
              font-family: ${config.my.roles.graphical.fonts.monospace.name};
            }
          '';
      };
  };
}
