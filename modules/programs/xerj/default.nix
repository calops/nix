{
  den.aspects.programs.provides.xerj = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.services.xerj;
        expandHome =
          path:
          if lib.hasPrefix "~/" path then
            "${config.home.homeDirectory}/${lib.removePrefix "~/" path}"
          else
            path;
        directories = lib.mapAttrs (_: expandHome) cfg.indexedDirectories;
        package = pkgs.callPackage ./_package.nix { };
        settings = (pkgs.formats.toml { }).generate "xerj.toml" {
          auth.enabled = true;
          tls.enabled = false;
        };
        dataDir = "${config.xdg.stateHome}/xerj";
        client = pkgs.writeShellApplication {
          name = "xerj";
          text = ''
            export XERJ_URL="http://127.0.0.1:9200"
            export XERJ_DISABLE_FEEDBACK=true
            if [[ -r ${lib.escapeShellArg "${dataDir}/admin.key"} ]]; then
              XERJ_API_KEY="$(<${lib.escapeShellArg "${dataDir}/admin.key"})"
              export XERJ_API_KEY
              export XERJ_AUTH="ApiKey $XERJ_API_KEY"
            fi
            exec ${lib.getExe package} "$@"
          '';
        };
        server = {
          command = lib.getExe client;
          args = [ "mcp" ];
        };
      in
      {
        options.services.xerj.indexedDirectories = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            my-project = "~/projects/my-project";
          };
          description = ''
            Folders to index continuously, keyed by a stable lowercase index prefix.
            Paths must be absolute or start with ~/. Missing folders are skipped
            and watched for creation. Removing an entry stops watching but retains
            its existing index. Each prefix must identify exactly one folder.
          '';
        };

        config = {
          services.xerj.indexedDirectories.nix-config = lib.mkDefault config.home.configDir;
          assertions = lib.mapAttrsToList (name: path: {
            assertion = builtins.match "[a-z0-9]+(-[a-z0-9]+)*" name != null && lib.hasPrefix "/" path;
            message = "Xerj indexedDirectories.${name} needs a lowercase hyphenated prefix and an absolute or ~/ path.";
          }) directories;

          home.packages = [ client ];
          programs.mcp.servers.xerj = server;

          systemd.user.services = {
            xerj = {
              Unit.Description = "Xerj local search and agent memory";
              Service = {
                ExecStart = "${lib.getExe package} --config ${settings} --bind 127.0.0.1 --port 9200 --data-dir ${lib.escapeShellArg "${config.xdg.stateHome}/xerj"} --embed-mode neural --disable-feedback";
                ExecStartPost = "${lib.getExe pkgs.curl} --fail --silent --show-error --retry 900 --retry-delay 1 --retry-connrefused --max-time 2 http://127.0.0.1:9200/health/ready";
                TimeoutStartSec = "15min";
                WorkingDirectory = config.xdg.stateHome;
                StateDirectory = "xerj";
                StateDirectoryMode = "0700";
                UMask = "0077";
                Restart = "on-failure";
                RestartSec = 5;
                NoNewPrivileges = true;
              };
              Install.WantedBy = [ "default.target" ];
            };
          }
          // lib.mapAttrs' (
            name: path:
            let
              stateDir = "${dataDir}/autoindex-neural/${name}";
              migrate = pkgs.writeShellApplication {
                name = "xerj-neural-migrate-${name}";
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.jq
                ];
                text = ''
                  state=${lib.escapeShellArg stateDir}
                  [[ ! -e "$state/.neural-ready" ]] || exit 0
                  mkdir -p "$state"
                  plan="$(mktemp)"
                  trap 'rm -f "$plan"' EXIT
                  if ! ${lib.getExe client} autoindex remove \
                    --url http://127.0.0.1:9200 \
                    --prefix ${lib.escapeShellArg name} \
                    --root ${lib.escapeShellArg path} --yes > "$plan"; then
                    # A new folder has no catalog entry to remove.
                    if ! jq -e '.exit == 1 and .root_not_found == true and .error == null and .deleted == false' "$plan" > /dev/null; then
                      cat "$plan" >&2
                      exit 1
                    fi
                  fi
                  touch "$state/.neural-ready"
                '';
              };
            in
            lib.nameValuePair "xerj-index-${name}" {
              Unit = {
                Description = "Continuously index ${name} with Xerj";
                Requires = [ "xerj.service" ];
                After = [ "xerj.service" ];
                PartOf = [ "xerj.service" ];
                ConditionPathIsDirectory = path;
              };
              Service = {
                ExecStartPre = lib.getExe migrate;
                TimeoutStartSec = "15min";
                ExecStart = lib.escapeShellArgs [
                  (lib.getExe client)
                  "autoindex"
                  path
                  "--url"
                  "http://127.0.0.1:9200"
                  "--prefix"
                  name
                  "--state-dir"
                  stateDir
                  "--watch"
                  "--no-graph"
                  "--yes"
                  "--drop-indexed"
                  "--workers"
                  "2"
                  "--debounce"
                  "2000"
                ];
                Restart = "on-failure";
                RestartSec = 5;
                SuccessExitStatus = [ 3 ];
                UMask = "0077";
                NoNewPrivileges = true;
              };
              Install.WantedBy = [ "default.target" ];
            }
          ) directories;

          systemd.user.paths = lib.mapAttrs' (
            name: path:
            lib.nameValuePair "xerj-index-${name}" {
              Unit.Description = "Start Xerj indexing when ${name} exists";
              Path = {
                PathExists = path;
                Unit = "xerj-index-${name}.service";
              };
              Install.WantedBy = [ "default.target" ];
            }
          ) directories;
        };
      };
  };
}
