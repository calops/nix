{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "xerj";
  version = "1.0.0-rc.98";

  src = fetchurl {
    url = "https://github.com/xerj-org/xerj/releases/download/v${finalAttrs.version}/xerj-${finalAttrs.version}-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-VQcS6ePEnk9stGArVaBc5Sw8Hucl7UlDH11oZSvHENU=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 xerj "$out/bin/xerj"
    install -Dm644 LICENSE "$out/share/licenses/xerj/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "Local-first search engine, CLI and MCP server for AI agents";
    homepage = "https://github.com/xerj-org/xerj";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "xerj";
  };
})
