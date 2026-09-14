{ lib, ... }:
{
  flake-file.inputs = {
    maki.url = "github:tontinton/maki";
    maki.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.programs.provides.maki =
    { ... }:
    {
      homeManager =
        {
          config,
          inputs',
          pkgs,
          ...
        }:
        let
          makiConfigDir = "${config.home.configDir}/modules/programs/maki/config";

          # Render the same `programs.mcp.servers` every other agent reads into
          # maki's own mcp.toml. Two shape differences to bridge: maki expands
          # `${VAR}` from the environment where llm-agents spells it `{env:VAR}`,
          # and maki has no `{ file = ...; }` env syntax, so a file-backed value
          # becomes a wrapper script that reads it at startup.
          makiEnvRef = builtins.replaceStrings [ "{env:" ] [ "\${" ];
          isFileRef = value: lib.isAttrs value && value ? file;
          resolveEnabled = server: if server.enabled or null != null then server.enabled else null;

          envFilesWrapper =
            name: server:
            let
              files = lib.filterAttrs (_: isFileRef) (server.env or { });
            in
            pkgs.writeShellScript "mcp-${name}-wrapper" ''
              ${lib.concatStrings (
                lib.mapAttrsToList (var: ref: ''
                  if ${var}=$(cat ${lib.escapeShellArg ref.file}); then
                    export ${var}
                  else
                    printf '[${name} wrapper] cannot read %s from %s\n' \
                      ${lib.escapeShellArg var} ${lib.escapeShellArg ref.file} >&2
                  fi
                '') files
              )}
              exec ${lib.escapeShellArgs ([ server.command ] ++ (server.args or [ ]))}
            '';

          asMakiServer =
            name: server:
            let
              env = server.env or { };
              wrapped = lib.filterAttrs (_: isFileRef) env != { };
              literalEnv = lib.filterAttrs (_: value: !(isFileRef value)) env;
              enabled = resolveEnabled server;
              transport =
                if (server.url or null) != null then
                  {
                    url = server.url;
                  }
                  // lib.optionalAttrs ((server.headers or { }) != { }) {
                    headers = lib.mapAttrs (_: makiEnvRef) server.headers;
                  }
                else
                  {
                    command = [
                      (toString (if wrapped then envFilesWrapper name server else server.command))
                    ]
                    ++ (if wrapped then [ ] else (server.args or [ ]));
                  }
                  // lib.optionalAttrs (literalEnv != { }) {
                    environment = literalEnv;
                  };
            in
            transport
            // lib.optionalAttrs (enabled != null) { enabled = enabled; }
            // lib.filterAttrs (key: _: lib.elem key [ "timeout" "always_load" "oauth" ]) server;

          mcpServers = lib.mapAttrs asMakiServer config.programs.mcp.servers;
        in
        {
          home.packages = [ inputs'.maki.packages.default ];

          # Keep ~/.config/maki pointed at the checkout instead of a store
          # copy. The directory holds init.lua and plugin.toml as editable
          # files, and plugins resolve out of its lua/ dir, so Lua changes take
          # effect with /reload and no rebuild.
          xdg.configFile."maki".source = config.lib.file.mkOutOfStoreSymlink makiConfigDir;

          home.file = lib.optionalAttrs (config.programs.mcp.enable && mcpServers != { }) {
            "${makiConfigDir}/mcp.toml".source =
              (pkgs.formats.toml { }).generate "maki-mcp.toml" { mcp = mcpServers; };
          };
        };
    };
}
