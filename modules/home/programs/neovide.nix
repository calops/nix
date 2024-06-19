{
  lib,
  config,
  pkgs,
  ...
}:
let
  darwinManifest =
    pkgs.writeText "Info.plist" # xml
      ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>English</string>

            <key>CFBundleExecutable</key>
            <string>neovide</string>

            <key>CFBundleIconFile</key>
            <string>neovide.icns</string>

            <key>CFBundleIconFiles</key>
            <array>
                <string>neovide.icns</string>
            </array>

            <key>CFBundleIdentifier</key>
            <string>org.nixos.Neovide</string>

            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>

            <key>CFBundleName</key>
            <string>Neovide</string>

            <key>CFBundlePackageType</key>
            <string>APPL</string>

            <key>CFBundleSignature</key>
            <string>???</string>
        </dict></plist>
      '';

  package =
    if config.my.isDarwin then
      pkgs.symlinkJoin {
        name = "neovide-darwin";
        paths = [ pkgs.neovide ];
        # Create the OSX `Application` bundle
        postBuild = ''
          dst=$out/Applications/Neovide.app/Contents
          mkdir -p $dst/{MacOS,Resources}
          cp "$out/bin/neovide" "$dst/MacOS/neovide"
          cp ${darwinManifest} "$out/Applications/neovide.app/Contents/Info.plist"

          mkdir -p $out/Neovide.iconset
          for size in 16 32 48 256; do
            cp $out/share/icons/hicolor/''${size}x''${size}/apps/neovide.png $out/Neovide.iconset/icon_''${size}x''${size}.png
          done
          /usr/bin/iconutil -c icns "$out/Neovide.iconset" -o "$dst/Resources/neovide.icns"
          rm -rf $out/Neovide.iconset
        '';
      }
    else
      pkgs.neovide;
in
{
  config = lib.mkIf config.my.roles.graphical.enable {
    home.packages = [ package ];

    xdg.desktopEntries.neovide = lib.mkIf (!config.my.isDarwin) {
      name = "Neovide";
      genericName = "Neovim GUI";
      exec = "neovide";
      terminal = false;
      categories = [
        "Application"
        "Development"
        "IDE"
      ];
    };

    xdg.configFile."neovide/config.toml".source =
      let
        symbols = {
          family = config.my.roles.graphical.fonts.symbols.name;
          style = "Normal";
        };
      in
      (pkgs.formats.toml { }).generate "config.toml" {
        frame = "buttonless";
        font = {
          size = 12;
          edging = "subpixelantialias";
          hinting = "full";
          normal = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "Thin";
            }
            symbols
          ];
          bold = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "SemiBold";
            }
            symbols
          ];
          italic = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "Thin Italic";
            }
            symbols
          ];
          bold_italic = [
            {
              family = config.my.roles.graphical.fonts.monospace.name;
              style = "SemiBold Italic";
            }
            symbols
          ];
        };
      };
  };
}
