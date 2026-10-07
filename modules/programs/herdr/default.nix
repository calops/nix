{ inputs, ... }:
{
  flake-file.inputs = {
    herdr = {
      url = "github:calops/herdr/calops/sidebar-workspaces";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr-link = {
      url = "github:LZHcode1986/herdr-link";
      flake = false;
    };
  };

  den.aspects.programs.provides.herdr = {
    homeManager =
      {
        colors,
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        palette = colors.palette.asHexWithHashtag;
        herdr = inputs'.herdr.packages.herdr;
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
        herdrNvimSrc = pkgs.fetchFromGitHub {
          owner = "ChmaraX";
          repo = "herdr-nvim";
          rev = "5e849b5377fd409d2fd4be159c9c9fa36c251f7a";
          hash = "sha256-BdZygw+OdfNlcEmb6v6ic9HV8ImxU3bDCq+28qu8Er0=";
        };
        herdrNvimManifest = builtins.fromTOML (builtins.readFile "${herdrNvimSrc}/herdr-plugin.toml");
        # Nix builds the binary; Herdr must not run upstream's download/build hooks.
        herdrNvimManifestFile = (pkgs.formats.toml { }).generate "herdr-plugin.toml" (
          builtins.removeAttrs herdrNvimManifest [ "build" ]
          // {
            actions = lib.filter (action: action.id != "pick-file") herdrNvimManifest.actions;
            panes = lib.filter (pane: pane.id != "picker") herdrNvimManifest.panes;
          }
        );
        herdrNvim = pkgs.rustPlatform.buildRustPackage {
          pname = "herdr-nvim";
          inherit (herdrNvimManifest) version;
          src = herdrNvimSrc;
          cargoHash = "sha256-pImtQ1YiM47VvA8u9ER/lXtDVsZhQy38fkCbzmT/gc4=";
          patches = [ ./disable-file-picker.patch ];
          buildNoDefaultFeatures = true;
          # Avoid upstream's full LTO and release-mode test compilation.
          CARGO_PROFILE_RELEASE_LTO = "false";
          doCheck = false;
          nativeBuildInputs = [
            pkgs.neovim-unwrapped
          ];
          postInstall = ''
            cp -R lua plugin doc "$out/"
            cp ${herdrNvimManifestFile} "$out/herdr-plugin.toml"
            HOME="$TMPDIR" nvim --headless -u NONE -i NONE \
              -c "helptags $out/doc" -c quit
          '';
          # Neovim discovers help under runtimepath/doc, not share/doc.
          forceShare = [
            "man"
            "info"
          ];
          meta.mainProgram = "herdr-nvim";
        };
      in
      {
        programs.herdr = {
          enable = true;
          package = herdr;
          settings = {
            onboarding = false;
            worktrees.directory = "${config.xdg.stateHome}/herdr/worktrees";
            experimental.kitty_graphics = true;

            theme = {
              name = "terminal";
              custom = {
                # Terminal cells retain the host background; these tokens style chrome.
                panel_bg = palette.mantle;
                sidebar_bg = palette.mantle;
                surface_dim = palette.crust;
                active_row_bg = palette.surface0;
                selection_bg = palette.surface0;
                accent = palette.blue;
                inherit (palette)
                  surface0
                  surface1
                  overlay0
                  overlay1
                  text
                  subtext0
                  mauve
                  green
                  yellow
                  red
                  blue
                  teal
                  peach
                  ;
              };
            };
            ui.toast.delivery = "system";
            ui.sound.enabled = true;
            ui.pane_borders = true;
            ui.pane_outer_borders = false;
            ui.pane_gaps = false;
            ui.hide_tab_bar_when_single_tab = true;
            ui.agent_panel_sort = "spaces";
            ui.sidebar.agents.rows = [
              [
                "state_icon"
                {
                  token = "agent";
                  fg = palette.mauve;
                  bold = false;
                }
              ]
              [ "tab" "pane" ]
            ];
            ui.sidebar.spaces.rows = [
              [ "state_icon" "workspace" ]
            ];

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

            keys.command = [
              {
                key = "prefix+shift+e";
                type = "plugin_action";
                command = "chmarax.herdr-nvim.toggle";
                description = "nvim sidebar";
              }
            ];

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
        home.activation.herdrLinkSetup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          ${lib.getExe herdr} plugin link ${herdrLink}/lib/herdr-link \
            >/dev/null 2>&1 \
            || echo "herdr-link: herdr plugin link failed" >&2
        '';

        home.activation.herdrNvimSetup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          ${lib.getExe herdr} plugin link ${herdrNvim} \
            >/dev/null 2>&1 \
            || echo "herdr-nvim: herdr plugin link failed" >&2
        '';

        xdg.dataFile."nvim/nix/nix.lua".text = lib.mkAfter ''
          vim.g.herdr_nvim_root = '${herdrNvim}'
        '';
        xdg.configFile."herdr-nvim/config.toml".source =
          (pkgs.formats.toml { }).generate "herdr-nvim-config.toml"
            {
              sidebar.nvim_bin = lib.getExe config.programs.neovim.finalPackage;
            };

        home.packages = [
          herdrLinkMcp
          herdrNvim
        ];
      };
  };
}
