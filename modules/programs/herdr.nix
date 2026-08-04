{
  den.aspects.programs.provides.herdr = {
    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      {
        programs.herdr = {
          enable = true;
          package = inputs'.llm-agents.packages.herdr;
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
        home.packages = [
          (pkgs.writeShellApplication {
            name = "herdr-run";
            runtimeInputs = [
              pkgs.jq
              pkgs.git
              inputs'.llm-agents.packages.herdr
            ];
            text = ''
              set -euo pipefail

              herdr_bin="${lib.getExe inputs'.llm-agents.packages.herdr}"
              state_dir="${config.xdg.stateHome}/herdr"
              log_file="''${state_dir}/herdr-run-server.log"
              kinds="pi claude codex gemini cursor devin agy cline omp mastracode opencode copilot kimi kiro droid amp grok hermes kilo qodercli maki"

              # --- helpers ---
              # herdr CLI, hiding stderr for read-only queries (mutations stay raw so errors surface)
              hr() { "$herdr_bin" "$@" 2>/dev/null; }

              # lowercase, non [a-z0-9_-] → '-', strip leading non-[a-z], cap, strip trailing dashes
              sanitize() {
                local s="$1" cap="$2"
                s="$(printf '%s' "$s" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-')"
                [[ "$s" =~ ^[^a-z]+(.*)$ ]] && s="''${BASH_REMATCH[1]}"
                s="''${s:0:$cap}"
                while [[ "$s" == *- ]]; do s="''${s%-}"; done
                printf '%s' "$s"
              }

              server_up() { hr status server | grep -q "^status: running"; }

              # first pane of a workspace
              ws_pane() { hr pane list | jq -r --arg w "$1" 'first(.result.panes[] | select(.workspace_id == $w) | .pane_id) // empty'; }

              # release the project lock and hand the terminal to the agent
              attach() {
                flock -u 9 2>/dev/null || true
                exec 9>&-
                exec "$herdr_bin" agent attach "$1" --takeover
              }

              # --- argument parsing ---
              kind=""
              force_new=0
              dir_override=""
              timeout_ms=60000
              harness_args=()
              while [[ $# -gt 0 ]]; do
                case "$1" in
                  --new) force_new=1; shift ;;
                  --dir)
                    [[ $# -ge 2 && -n "$2" ]] || { echo "herdr-run: --dir requires a non-empty path" >&2; exit 2; }
                    dir_override="$2"; shift 2 ;;
                  --timeout)
                    [[ $# -ge 2 ]] || { echo "herdr-run: --timeout requires a value in ms" >&2; exit 2; }
                    timeout_ms="$2"; shift 2 ;;
                  --) shift; harness_args=("$@"); break ;;
                  -*) echo "herdr-run: unknown option: $1" >&2; exit 2 ;;
                  *)
                    [[ -z "$kind" ]] || { echo "herdr-run: unexpected extra argument: $1" >&2; exit 2; }
                    kind="$1"; shift ;;
                esac
              done

              [[ -n "$kind" && " $kinds " == *" $kind "* ]] || { echo "herdr-run: kind must be one of: $kinds" >&2; exit 2; }
              [[ "$timeout_ms" =~ ^[0-9]+$ && $timeout_ms -gt 3000 && $timeout_ms -le 300000 ]] || { echo "herdr-run: --timeout must be an integer in 3001..300000" >&2; exit 2; }
              if [[ "''${HERDR_ENV:-}" == "1" ]]; then
                echo "herdr-run: you are already inside herdr; run '$kind' directly in this pane" >&2
                exit 1
              fi

              # --- project identity ---
              if [[ -n "$dir_override" ]]; then
                project="$(realpath "$dir_override")"
              else
                project="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
              fi
              name="$(sanitize "$(basename "$project")" 28)"
              [[ -n "$name" ]] || name="harness"

              # --- ensure herdr server (lazy, in-wrapper) ---
              mkdir -p "$state_dir"
              if ! server_up; then
                nohup "$herdr_bin" server >>"$log_file" 2>&1 &
                for ((attempt = 0; attempt < 30; attempt++)); do
                  sleep 0.5
                  if server_up; then break; fi
                done
                if ! server_up; then
                  echo "herdr-run: herdr server did not start within 15s (log: $log_file)" >&2
                  exit 1
                fi
              fi

              # --- serialize concurrent launches for the same project ---
              exec 9>>"$state_dir/herdr-run-$name.lock"
              flock 9

              # --- unique agent name: <project>-<kind>, ≤32 chars, numeric suffix on collision ---
              proj_part="$(sanitize "$name" $((28 - ''${#kind})))"
              base_name="''${proj_part}-''${kind}"
              base_name="''${base_name:0:29}"
              final_name="$base_name"
              suffix=2
              while hr agent get "$final_name" >/dev/null 2>&1; do
                final_name="''${base_name:0:$((29 - ''${#suffix}))}-''${suffix}"
                suffix=$((suffix + 1))
              done

              # --- find the project workspace (label AND root-pane cwd) ---
              ws_id=""
              while read -r wid; do
                p="$(ws_pane "$wid")"
                [[ -n "$p" ]] || continue
                cwd="$(hr pane get "$p" | jq -r '.result.pane.cwd // empty')"
                if [[ "$cwd" == "$project" ]]; then
                  ws_id="$wid"
                  break
                fi
              done < <(hr workspace list | jq -r --arg l "$name" '.result.workspaces[] | select(.label == $l) | .workspace_id')

              # --- idempotent re-entry: attach a live agent of this kind ---
              ws_existed=$([[ -n "$ws_id" ]] && echo 1 || echo 0)
              if [[ -n "$ws_id" && "$force_new" -eq 0 ]]; then
                pane="$(hr agent list | jq -r --arg w "$ws_id" --arg k "$kind" \
                  'first(.result.agents[] | select(.workspace_id == $w and .agent == $k and (.agent_status == "idle" or .agent_status == "working" or .agent_status == "blocked" or .agent_status == "done")) | .pane_id) // empty')"
                if [[ -n "$pane" ]]; then
                  attach "$pane"
                fi
              fi

              if [[ -z "$ws_id" ]]; then
                created="$("$herdr_bin" workspace create --cwd "$project" --label "$name" --no-focus)"
                ws_id="$(printf '%s' "$created" | jq -r '.result.workspace.workspace_id')"
                pane="$(printf '%s' "$created" | jq -r '.result.root_pane.pane_id')"
              else
                pane="$(ws_pane "$ws_id")"
              fi

              # --- start; retry transient busy / name-taken, then once in a fresh tab (pre-existing workspace only) ---
              start_agent() {
                local pane="$1" attempt out
                for ((attempt = 0; attempt < 15; attempt++)); do
                  if out="$("$herdr_bin" agent start "$final_name" --kind "$kind" --pane "$pane" --timeout "$timeout_ms" -- "''${harness_args[@]}" 2>&1)"; then
                    return 0
                  fi
                  case "$out" in
                    *agent_pane_busy*) sleep 1 ;;
                    *agent_name_taken*) final_name="''${base_name:0:$((29 - ''${#suffix}))}-''${suffix}"; suffix=$((suffix + 1)) ;;
                    *) printf '%s\n' "$out" >&2; return 1 ;;
                  esac
                done
                echo "herdr-run: gave up after 15 attempts on pane $pane" >&2
                return 2
              }

              rc=0
              start_agent "$pane" || rc=$?
              if [[ "$rc" -ne 0 ]]; then
                if [[ "$rc" -eq 2 && "$ws_existed" -eq 1 ]]; then
                  tab="$("$herdr_bin" tab create --workspace "$ws_id" --cwd "$project" --no-focus)"
                  pane="$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')"
                  start_agent "$pane" || exit 1
                else
                  exit 1
                fi
              fi

              attach "$final_name"
            '';
          })
        ];
      };
  };
}
