let
  serverPort = 6768;
  clientPort = 16768;
in
{
  den.aspects.programs.provides.orca = {
    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.orca;
        launcher = pkgs.writeShellApplication {
          name = "orca-ide";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.jq
            pkgs.openssh
            pkgs.util-linux
          ];
          runtimeEnv = {
            ORCA_GUI = lib.getExe cfg.package;
            ORCA_CLI = lib.getExe' cfg.package "orca";
            ORCA_SSH_HOST = cfg.sshHost;
            ORCA_SERVER_PORT = toString serverPort;
            ORCA_CLIENT_PORT = toString clientPort;
          };
          text = builtins.readFile ./orca/launcher.sh;
        };
        clientPackage = pkgs.symlinkJoin {
          name = "orca-ssh-${cfg.package.version}";
          paths = [ cfg.package ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            rm "$out/bin/orca-ide" "$out/bin/orca"
            ln -s ${lib.getExe launcher} "$out/bin/orca-ide"
            makeWrapper ${lib.getExe' cfg.package "orca"} "$out/bin/orca" \
              --set ORCA_OPEN_COMMAND "$out/bin/orca-ide"

            desktop="$out/share/applications/orca-ide.desktop"
            rm "$desktop"
            cp ${cfg.package}/share/applications/orca-ide.desktop "$desktop"
            chmod u+w "$desktop"
            substituteInPlace "$desktop" \
              --replace-fail "Exec=orca-ide" "Exec=$out/bin/orca-ide"
          '';
          meta = cfg.package.meta;
        };
      in
      {
        options.programs.orca.package = lib.mkOption {
          type = lib.types.package;
          default = inputs'.llm-agents.packages.orca;
          description = "Orca desktop and CLI package.";
        };

        options.programs.orca.sshHost = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "SSH target whose Orca server the desktop launcher connects to.";
        };

        options.services.orca.enable = lib.mkEnableOption "the persistent Orca runtime server";

        config = lib.mkIf config.profiles.graphical.enable {
          home.packages = [
            (if cfg.sshHost == null then cfg.package else clientPackage)
          ];
        };
      };

    homeManagerLinux =
      {
        config,
        lib,
        ...
      }:
      {
        systemd.user.services.orca =
          lib.mkIf (config.profiles.graphical.enable && config.services.orca.enable)
            {
              Unit = {
                Description = "Orca runtime (SSH access only)";
                StartLimitIntervalSec = 300;
                StartLimitBurst = 5;
              };
              Service = {
                ExecStart = "${lib.getExe' config.programs.orca.package "orca"} serve --port ${toString serverPort} --pairing-address ws://127.0.0.1:${toString clientPort} --json";
                WorkingDirectory = config.home.homeDirectory;
                Environment = [
                  "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
                  "LIBGL_ALWAYS_SOFTWARE=1"
                  "XDG_SESSION_TYPE=x11"
                ];
                UnsetEnvironment = [
                  "DISPLAY"
                  "WAYLAND_DISPLAY"
                  "NIXOS_OZONE_WL"
                ];
                Restart = "on-failure";
                RestartSec = 5;
                RestartPreventExitStatus = 3;
                KillMode = "mixed";
                UMask = "0077";

                # The ready record contains the pairing credential. Keep it out
                # of the journal and fetch it over SSH only on first client setup.
                StandardOutput = "truncate:%t/orca-serve-ready.json";
                StandardError = "journal";
              };
              Install.WantedBy = [ "default.target" ];
            };
      };

    nixos =
      { config, lib, ... }:
      let
        serverUsers = lib.filterAttrs (
          _: home: home.profiles.graphical.enable && (home.services.orca.enable or false)
        ) config.home-manager.users;
      in
      {
        # Start the enabled user service at boot and keep its terminal daemon
        # alive independently of graphical logins and SSH connections.
        users.users = lib.mapAttrs (_: _: { linger = true; }) serverUsers;

        # Upstream binds 0.0.0.0. Retain NixOS's default-deny ingress policy;
        # advertising loopback is not itself a bind or firewall restriction.
        assertions = lib.optional (serverUsers != { }) {
          assertion =
            config.networking.firewall.enable
            && lib.all (
              rules:
              !(builtins.elem serverPort rules.allowedTCPPorts)
              && lib.all (range: serverPort < range.from || serverPort > range.to) rules.allowedTCPPortRanges
            ) ([ config.networking.firewall ] ++ builtins.attrValues config.networking.firewall.interfaces);
          message = "Orca's runtime port ${toString serverPort} must stay closed in the NixOS firewall; use SSH forwarding.";
        };
      };
  };
}
