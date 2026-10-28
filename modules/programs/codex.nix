{
  den.aspects.programs.provides.codex = {
    homeManager =
      { pkgs, inputs', ... }:
      let
        codex = inputs'.llm-agents.packages.codex;
      in
      {
        programs.codex = {
          enable = true;
          package = pkgs.symlinkJoin {
            name = "codex-osc52-${codex.version}";
            paths = [ codex ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              # Use terminal clipboard forwarding, including after SSH attachment.
              # Codex can under-detect color support inside terminal multiplexers.
              wrapProgram "$out/bin/codex" \
                --set FORCE_COLOR 3 \
                --unset DISPLAY \
                --unset WAYLAND_DISPLAY
            '';
            meta = codex.meta // {
              mainProgram = "codex";
            };
          };
          enableMcpIntegration = true;
          mutableSettings = true;
        };
      };
  };
}
