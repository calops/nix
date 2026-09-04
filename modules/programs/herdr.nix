{ inputs, ... }:
{
  flake-file.inputs.herdr-link = {
    url = "github:LZHcode1986/herdr-link";
    flake = false;
  };

  den.aspects.programs.provides.herdr = {
    # Collie (herdr's phone PWA) is fronted by `tailscale serve` — Variant A of
    # the upstream README. The bridge itself only ever binds 127.0.0.1; this
    # oneshot publishes :8787 on the tailnet once the node is authenticated.
    nixos =
      { pkgs, ... }:
      {
        services.tailscale.enable = true;

        systemd.services.collie-tailscale-serve = {
          description = "Publish Collie bridge on the tailnet (tailscale serve)";
          after = [ "tailscaled.service" ];
          wants = [ "tailscaled.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          # Retry until `tailscale up` has authenticated the node; the serve
          # mapping then persists in tailscaled state across reboots.
          script = ''
            for i in $(seq 1 90); do
              if ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; then
                ${pkgs.tailscale}/bin/tailscale serve --bg 8787 && exit 0
              fi
              sleep 10
            done
            exit 0
          '';
        };
      };

    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        herdr = inputs'.llm-agents.packages.herdr;
        collie = inputs'.llm-agents.packages.collie;
        herdrLink = pkgs.stdenvNoCC.mkDerivation {
          pname = "herdr-link";
          version = (builtins.fromJSON (builtins.readFile "${inputs.herdr-link}/package.json")).version;
          src = inputs.herdr-link;
          nativeBuildInputs = [ pkgs.gnused ];
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib/herdr-link"
            cp -R . "$out/lib/herdr-link"
            substituteInPlace "$out/lib/herdr-link/herdr-plugin.toml" \
              --replace-fail '["node", "scripts/plugin-action.mjs", "doctor"]' \
              '["${lib.getExe pkgs.nodejs}", "scripts/plugin-action.mjs", "doctor"]'
            runHook postInstall
          '';
        };
        herdrLinkMcp = pkgs.writeShellApplication {
          name = "herdr-link";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''
            exec ${lib.getExe pkgs.nodejs} ${herdrLink}/lib/herdr-link/dist/herdr-link.mcp.js "$@"
          '';
        };
      in
      {
        # Tailscale systray applet (needs a graphical session + tray.target,
        # which the graphical profile provides on both hosts).
        services.tailscale-systray.enable = true;

        programs.herdr = {
          enable = true;
          package = herdr;
          settings = {
            onboarding = false;
            worktrees.directory = "${config.xdg.stateHome}/herdr/worktrees";
            experimental.kitty_graphics = true;

            theme.name = "terminal";
            ui.toast.delivery = "system";
            ui.sound.enabled = true;
            ui.pane_borders = true;
            ui.pane_gaps = false;
            ui.hide_tab_bar_when_single_tab = true;

            keys.prefix = "ctrl+b";
            keys.help = "prefix+?";
            keys.settings = "prefix+s";
            keys.detach = "prefix+q";
            keys.reload_config = "prefix+shift+r";
            keys.open_notification_target = "prefix+o";
            keys.remote_image_paste = "ctrl+v";

            keys.new_workspace = "prefix+shift+n";
            keys.new_worktree = "prefix+shift+g";
            keys.rename_workspace = "prefix+shift+w";
            keys.close_workspace = "prefix+shift+d";
            keys.workspace_picker = "prefix+w";
            keys.goto = "prefix+g";

            # keys.open_worktree = ...;
            # keys.remove_worktree = ...;
            # keys.previous_workspace = ...;
            # keys.next_workspace = ...;
            # keys.switch_workspace = ...;

            keys.navigate_workspace_up = "up";
            keys.navigate_workspace_down = "down";
            keys.navigate_pane_left = "h";
            keys.navigate_pane_down = "j";
            keys.navigate_pane_up = "k";
            keys.navigate_pane_right = "l";

            keys.new_tab = "prefix+c";
            keys.rename_tab = "prefix+shift+t";
            keys.previous_tab = "prefix+p";
            keys.next_tab = "prefix+n";
            keys.switch_tab = "prefix+1..9";
            keys.close_tab = "prefix+shift+x";

            keys.rename_pane = "prefix+shift+p";
            keys.edit_scrollback = "prefix+e";
            keys.copy_mode = "prefix+[";
            keys.split_vertical = "prefix+v";
            keys.split_horizontal = "prefix+minus";
            keys.close_pane = "prefix+x";
            keys.zoom = "prefix+z";
            keys.resize_mode = "prefix+r";
            keys.toggle_sidebar = "prefix+b";
            keys.cycle_pane_next = "prefix+tab";
            keys.cycle_pane_previous = "prefix+shift+tab";

            keys.focus_pane_left = "prefix+h";
            keys.focus_pane_down = "prefix+j";
            keys.focus_pane_up = "prefix+k";
            keys.focus_pane_right = "prefix+l";

            keys.swap_pane_left = "prefix+shift+h";
            keys.swap_pane_down = "prefix+shift+j";
            keys.swap_pane_up = "prefix+shift+k";
            keys.swap_pane_right = "prefix+shift+l";

            # Agent focus — unset by default:
            # keys.previous_agent = ...;
            # keys.next_agent = ...;
            # keys.focus_agent = "prefix+alt+1..9";

            # Indexed shortcuts — unset by default:
            # keys.indexed.tabs = ...;       # modifier for tab shortcuts 1-9
            # keys.indexed.workspaces = ...; # modifier for workspace shortcuts 1-9
            # keys.indexed.agents = ...;     # modifier for agent shortcuts 1-9

            # Cross-workspace pane focus — unset by default:
            # keys.last_pane = ...;
          };
        };

        programs.mcp.servers.herdr-link.command = lib.getExe herdrLinkMcp;
        # Collie bridge — runs the phone PWA server (loopback only; the
        # collie-tailscale-serve oneshot publishes it on the tailnet).
        systemd.user.services.collie = {
          Unit = {
            Description = "Collie";
            After = [ "default.target" ];
            # Never give up restarting — a phone-only operator can't run 'systemctl reset-failed'.
            StartLimitIntervalSec = 0;
          };
          Service = {
            Type = "simple";
            WorkingDirectory = "${collie}/lib/collie";
            ExecStart = "${lib.getExe collie}";
            Restart = "on-failure";
            RestartSec = 5;
            # Hardening: the bridge is remote shell access, so deny privilege
            # escalation and give it a private /tmp. ProtectSystem is
            # intentionally NOT set — the only write path is the env-driven
            # state dir, which Herdr may inject to an arbitrary location.
            NoNewPrivileges = true;
            PrivateTmp = true;
            Environment = [
              "HERDR_SOCKET_PATH=${config.xdg.configHome}/herdr/herdr.sock"
              "COLLIE_PORT=8787"
              "HERDR_PLUGIN_CONFIG_DIR=${config.xdg.configHome}/collie"
            ];
            EnvironmentFile = "-${config.xdg.configHome}/collie/.env";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };

        # Collie config — placeholders until the tailnet account exists
        # (see https://github.com/AltanS/collie README → Configure).
        # Permissions are fixed to 0600 in the collieSetup activation below
        # (this HM's file type has no mode option, and the file may later
        # hold COLLIE_VAPID_PRIVATE).
        xdg.configFile."collie/.env".text = ''
          # Collie configuration — managed by modules/programs/herdr.nix.
          # Fill these in once your tailnet account exists:
          # COLLIE_TRUSTED_USER=you@example.com   # tailnet login — rejects everyone else
          # COLLIE_PUBLIC_HOSTS=myhost.tail1234.ts.net  # MagicDNS name(s) you serve on
        '';

        # Register the plugin with herdr and tighten the .env. Herdr has no
        # declarative plugin config (plugins live in its
        # ~/.config/herdr/plugins.json registry), so link the nix-provided
        # plugin root on every switch — idempotent, and re-points the registry
        # when a package upgrade changes the store path.
        home.activation.collieSetup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          envFile="${config.xdg.configHome}/collie/.env"
          # xdg.configFile links into the read-only nix store, so materialize
          # a regular file before tightening permissions — chmod on the store
          # symlink fails with EROFS and aborts the whole activation.
          if [[ -L "$envFile" ]]; then
            tmp="$envFile.tmp.$$"
            cp "$envFile" "$tmp" && mv "$tmp" "$envFile"
          fi
          chmod 600 "$envFile"
          ${lib.getExe herdr} plugin link ${collie}/lib/collie \
            >/dev/null 2>&1 \
            || echo "collie: herdr plugin link failed" >&2
        '';

        home.activation.herdrLinkSetup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          ${lib.getExe herdr} plugin link ${herdrLink}/lib/herdr-link \
            >/dev/null 2>&1 \
            || echo "herdr-link: herdr plugin link failed" >&2
        '';

        home.packages = [
          collie
          herdrLinkMcp
        ];
      };
  };
}
