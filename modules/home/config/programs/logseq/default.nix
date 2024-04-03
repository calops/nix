{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.roles.graphical;

  # TODO: remove once nixpkgs fixes the ozone setting for electron 27
  logseqPkg = pkgs.logseq.overrideAttrs (oldAttrs: {
    postFixup = ''
      makeWrapper ${pkgs.electron_27}/bin/electron $out/bin/${oldAttrs.pname} \
        --add-flags $out/share/${oldAttrs.pname}/resources/app \
        --add-flags "--use-gl=desktop" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}"
    '';
  });
in {
  config = lib.mkIf (cfg.enable && !config.my.isDarwin) {
    programs.logseq = let
      customCss = pkgs.fetchurl {
        url = "https://logseq.catppuccin.com/ctp-mocha.css";
        hash = "sha256-VnywyLsQwK5TSVaKhpt7P0lDHC2HigYyH+/11VS+NVY=";
      };
    in {
      enable = true;
      package = logseqPkg;
      # TODO: make a custom package for this and fetch from github
      customCss = builtins.readFile customCss;
    };
  };
}
