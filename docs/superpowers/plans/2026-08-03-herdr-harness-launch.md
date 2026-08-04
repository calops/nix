# Transparent herdr-backed omp launch — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the `omp` command launch the omp agent inside the shared herdr instance (server-owned pane, per-project workspace) with the invoking terminal rendered transparently as that pane — plus build-time extraction of herdr's omp integration extension.

**Architecture:** One file changes, `modules/programs/oh-my-pi/default.nix`. (1) A `runCommand` extracts `herdr-omp-agent-state.ts` (bundled in the pinned herdr binary) and merges it into the store-backed `extensions/` dir via `symlinkJoin`. (2) The `omp` wrapper becomes a launcher that orchestrates the herdr socket CLI: ensure server → find/create project workspace → `agent start --kind omp` → `agent attach` (transparent view). `--no-herdr` and `HERDR_ENV=1` preserve today's direct-exec behavior.

**Tech Stack:** Nix (flake-parts/den modules, `writeShellApplication`, `runCommand`, `symlinkJoin`), bash, herdr 0.7.5 socket CLI, `jq`, `git`.

**Spec:** `docs/superpowers/specs/2026-08-03-herdr-harness-launch-design.md`

> **Implemented 2026-08-03 (branch `feat/herdr-harness-launch`).** Execution
> deviated from the code below: Task 1 uses per-file `xdg.configFile` entries
> (no `symlinkJoin` — pure eval forbids store-importing the checkout); Task 2
> adds `ws_existed` retry gating, strict name sanitization, per-project `flock`,
> `jq first() // empty`, explicit start-failure exits, `--takeover` after the
> attach target, and in-branch credential loading. The spec is authoritative.

**Commits:** per repo rule (CLAUDE.md), do NOT commit unless the user explicitly asks. Verification is build + store inspection + the manual acceptance checklist.

---

### Task 1: Extract the herdr omp integration at build time

**Files:**
- Modify: `modules/programs/oh-my-pi/default.nix` (module `let` block + `xdg.configFile`)

- [ ] **Step 1: Add the extraction derivation and the merged extensions dir**

In the `let` block of `modules/programs/oh-my-pi/default.nix` (next to `ompExtensionsDir`), add:

```nix
        # herdr's omp integration extension, bundled in the pinned herdr
        # binary. Extracted at build time: declarative, version-synced with the
        # flake lock, no fetchUrl dependency. The file is read by the agent at
        # runtime and never written, so the store copy is fine.
        herdrOmpStateExt = pkgs.runCommand "herdr-omp-agent-state.ts" {
          nativeBuildInputs = [ inputs'.llm-agents.packages.herdr ];
        } ''
          mkdir -p "$TMPDIR/scratch"
          PI_CODING_AGENT_DIR="$TMPDIR/scratch" herdr integration install omp >/dev/null
          cp "$TMPDIR/scratch/extensions/herdr-omp-agent-state.ts" "$out"
        '';

        # Merge the repo-managed extensions (e.g. self-review.ts) with herdr's
        # bundled omp extension into one store dir. A nested xdg.configFile
        # entry under the `extensions` symlink is impossible — home-manager
        # cannot write through a store symlink.
        ompExtensionsDir = pkgs.symlinkJoin {
          name = "omp-agent-extensions";
          paths = [
            ompExtensionsDir
            herdrOmpStateExt
          ];
        };
```

Note the shadowing: the new `ompExtensionsDir` replaces the existing `let` binding that pointed at `"${host.configDir}/modules/programs/oh-my-pi/extensions"`. If the original binding is named differently in the current file, rename accordingly — the `paths` list must reference the repo dir (rename the old binding to `ompExtensionsSrc` if needed).

- [ ] **Step 2: Point the config entry at the merged dir**

In the `xdg.configFile` attrset, the `"omp/agent/extensions"` entry changes from:

```nix
          "omp/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink ompExtensionsDir;
```

to:

```nix
          "omp/agent/extensions".source = ompExtensionsDir;
```

(`mkOutOfStoreSymlink` is for out-of-store repo paths; `ompExtensionsDir` is now a store path, so plain `.source` — home-manager symlinks it.)

- [ ] **Step 3: Verify the extraction logic standalone**

Run (this must succeed and print the version header — proof the sandbox command works):

```bash
rm -rf /tmp/omp-ext-verify && mkdir -p /tmp/omp-ext-verify
PI_CODING_AGENT_DIR=/tmp/omp-ext-verify herdr integration install omp
head -6 /tmp/omp-ext-verify/extensions/herdr-omp-agent-state.ts
```

Expected: `installed omp integration to /tmp/omp-ext-verify/extensions/herdr-omp-agent-state.ts` and a header containing `// HERDR_INTEGRATION_VERSION=6`. If `herdr` is not on PATH, use `$(nix eval /home/calops/nix#nixosConfigurations.tb-laptop.config.system.build.toplevel ... )` — simpler: `herdr` is on PATH (`/home/calops/.nix-profile/bin/herdr`).

- [ ] **Step 4: Verify the derivation evaluates in the sandbox**

```bash
nixos-rebuild build --flake /home/calops/nix#tb-laptop
```

Expected: build succeeds (this also runs `writeShellApplication`'s shellcheck on the wrapper from Task 2 — do Task 2 first if you are implementing sequentially; the build is the shared checkpoint for both tasks).

---

### Task 2: Launcher wrapper

**Files:**
- Modify: `modules/programs/oh-my-pi/default.nix` (the `writeShellApplication` in `home.packages`)

- [ ] **Step 1: Replace the wrapper text**

Replace the entire `text = ''...'';` body of the `omp` `writeShellApplication` with:

```nix
            text = ''
              set -euo pipefail

              omp_bin="${lib.getExe inputs'.llm-agents.packages.omp}"
              herdr_bin="${lib.getExe inputs'.llm-agents.packages.herdr}"
              state_dir="${config.xdg.stateHome}/herdr"
              log_file="''${state_dir}/omp-server.log"

              # XDG-compatible OMP agent directory
              export PI_CODING_AGENT_DIR="${config.xdg.configHome}/omp/agent"

              # API credentials from 1Password (consumed by the agent in-pane)
              eval "$(${lib.getExe self'.packages.op-credential} "Gemini API" GEMINI_API_KEY)"
              eval "$(${lib.getExe self'.packages.op-credential} "OpenCode GO" OPENCODE_API_KEY)"
              eval "$(${lib.getExe self'.packages.op-credential} "z.ai API key" ZAI_API_KEY)"

              no_herdr=0
              force_new=0
              args=()
              for a in "$@"; do
                case "$a" in
                  --no-herdr) no_herdr=1 ;;
                  --new) force_new=1 ;;
                  *) args+=("$a") ;;
                esac
              done

              # Escape hatch / already inside herdr: behave exactly like before.
              if [[ "$no_herdr" -eq 1 || "''${HERDR_ENV:-}" == "1" ]]; then
                exec "$omp_bin" "''${args[@]}"
              fi

              # --- ensure herdr server (lazy, in-wrapper) ---
              server_up() { "$herdr_bin" status server 2>/dev/null | grep -q "^status: running"; }
              if ! server_up; then
                mkdir -p "$state_dir"
                nohup "$herdr_bin" server >>"$log_file" 2>&1 &
                for ((attempt = 0; attempt < 30; attempt++)); do
                  sleep 0.5
                  server_up && break
                done
              fi
              if ! server_up; then
                echo "omp: herdr server did not start within 15s (log: $log_file); use 'omp --no-herdr' to run directly" >&2
                exit 1
              fi

              # --- project identity ---
              project="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
              name="$(basename "$project" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-')"
              name="''${name:0:31}"
              name="''${name#-}"
              name="''${name%-}"
              [[ -n "$name" ]] || name="omp"

              # --- find existing workspace by label ---
              ws_id="$("$herdr_bin" workspace list 2>/dev/null | jq -r --arg l "$name" \
                '.result.workspaces[] | select(.label == $l) | .workspace_id' | head -1)"

              # --- idempotent re-entry: attach to a live omp agent in this workspace ---
              if [[ "$force_new" -eq 0 && -n "$ws_id" ]]; then
                pane="$("$herdr_bin" agent list 2>/dev/null | jq -r --arg w "$ws_id" \
                  '.result.agents[] | select(.workspace_id == $w and .agent == "omp") | .pane_id' | head -1)"
                if [[ -n "$pane" ]]; then
                  exec "$herdr_bin" agent attach "$pane"
                fi
              fi

              # --- unique agent name ([a-z][a-z0-9_-]{0,31}, unique among live agents) ---
              final_name="$name"
              suffix=2
              while "$herdr_bin" agent get "$final_name" >/dev/null 2>&1; do
                final_name="''${name}-''${suffix}"
                suffix=$((suffix + 1))
              done

              # --- pick the pane ---
              if [[ -z "$ws_id" ]]; then
                created="$("$herdr_bin" workspace create --cwd "$project" --label "$name" --no-focus)"
                ws_id="$(printf '%s' "$created" | jq -r '.result.workspace.workspace_id')"
                pane="$(printf '%s' "$created" | jq -r '.result.root_pane.pane_id')"
              else
                pane="$("$herdr_bin" pane list 2>/dev/null | jq -r --arg w "$ws_id" \
                  '.result.panes[] | select(.workspace_id == $w) | .pane_id' | head -1)"
              fi

              # --- start; if the pane is not at a shell prompt, retry once in a fresh tab ---
              if ! "$herdr_bin" agent start "$final_name" --kind omp --pane "$pane" --timeout 60000 -- "''${args[@]}"; then
                if [[ -n "$ws_id" ]]; then
                  tab="$("$herdr_bin" tab create --workspace "$ws_id" --cwd "$project" --no-focus)"
                  pane="$(printf '%s' "$tab" | jq -r '.result.root_pane.pane_id')"
                  "$herdr_bin" agent start "$final_name" --kind omp --pane "$pane" --timeout 60000 -- "''${args[@]}"
                fi
              fi

              exec "$herdr_bin" agent attach "$final_name"
            '';
```

Also update `runtimeInputs` from `[ pkgs.python3 ]` to:

```nix
            runtimeInputs = [
              pkgs.python3
              pkgs.jq
              pkgs.git
              inputs'.llm-agents.packages.herdr
            ];
```

- [ ] **Step 2: Syntax-check the wrapper without a full build**

```bash
nix-instantiate --eval --strict --expr '
  let f = builtins.getFlake "/home/calops/nix";
  in builtins.toString (f.nixosConfigurations.tb-laptop.config.home-manager.users.calops.home.packages)
' 2>&1 | head -3
```

This is a sanity check that the module evaluates; it does not build. If the attr path differs in this repo, fall back to `nixos-rebuild build --flake /home/calops/nix#tb-laptop` as the evaluation check (Task 3).

- [ ] **Step 3: Full build + shellcheck**

```bash
nixos-rebuild build --flake /home/calops/nix#tb-laptop
```

Expected: succeeds. `writeShellApplication` runs shellcheck on the text — a failure surfaces here with the exact line. Common fixes if it fails: the `${...}` shell expansions inside the Nix string MUST be written `''${...}` (double-quote escape); the plan above already does this for every shell-side expansion (`''${HERDR_ENV:-}`, `''${name:0:31}`, `''${args[@]}`, ...).

- [ ] **Step 4: Verify the store outputs**

```bash
nix build --no-link /home/calops/nix#nixosConfigurations.tb-laptop.config.system.build.toplevel
result=$(nix path-info /home/calops/nix#nixosConfigurations.tb-laptop.config.system.build.toplevel)
grep -rl "agent attach" "$result"/sw/ 2>/dev/null | grep '/omp$'   # the generated wrapper
find /nix/store -maxdepth 1 -name '*omp-agent-extensions*' | head -1
```

Expected: a path for the `omp` wrapper containing `agent attach`, and a `omp-agent-extensions` store dir listing both `self-review.ts` and `herdr-omp-agent-state.ts`.

---

### Task 3: Deploy and manual acceptance

Deployment touches the live system and herdr — the user runs these steps (or approves you running them).

**Files:** none.

- [ ] **Step 1: Activate**

```bash
nixos-rebuild switch --flake /home/calops/nix#tb-laptop
```

- [ ] **Step 2: Verify integration status**

```bash
herdr integration status | grep omp
```

Expected: `omp: current (v6)`.

- [ ] **Step 3: Acceptance checklist (interactive — run in a real terminal)**

| # | Action | Expected |
|---|--------|----------|
| 1 | In a terminal outside herdr, `cd` into a project (e.g. `/home/calops/nix`) and type `omp` | Agent TUI fills the terminal; no herdr chrome. `herdr agent list` shows a new agent, kind `omp`, in a workspace labeled `nix`. |
| 2 | `ctrl+b q` | Terminal returns to a shell; `herdr agent list` still shows the agent. |
| 3 | Type `omp` again in the same project | Attaches to the same agent (no second agent spawned; `herdr agent list` still shows one). |
| 4 | `omp --new` | Second agent appears (`nix-2`) in the same workspace. |
| 5 | `omp --no-herdr` | Behaves exactly like today's `omp` (direct child of the terminal). |
| 6 | `herdr server stop` (accepting the live herdr UI/client will drop), then `omp` | Server restarts automatically (headless), then the agent launches. Restart any herdr client afterwards. |
| 7 | `omp` with an agent arg, e.g. `omp --version` style passthrough | The arg reaches the agent in the pane (verify in the pane's output/state). |

- [ ] **Step 4: Revert any leftover experiment state**

- If a test workspace/agent was created outside a real project (e.g. in `/tmp`), close it: `herdr workspace close <id>`.
- The empty named sessions from earlier experiments (`oh_my_pi-fcb7ce00`, `claude-fcb7ce000f`) may be stopped: `herdr --session <name> server stop` — optional, user's call.
- Remove `/tmp/omp-ext-verify` if still present.

---

## Self-Review (run after implementing)

1. **Spec coverage:** every acceptance criterion in the spec maps to a checklist row (Task 3) or a build check (Tasks 1–2). The `--no-herdr`/`HERDR_ENV` behaviors, per-project workspace, attach-if-exists, `--new`, lazy server, unique naming, and the integration file all have concrete code above.
2. **Placeholders:** none — every code step shows the full text.
3. **Type consistency:** `herdrOmpStateExt`, `ompExtensionsDir` (Task 1) are referenced consistently; the wrapper's `agent start`/`attach`/`workspace create`/`tab create` invocations match herdr 0.7.5 CLI flags verified in the spec.
