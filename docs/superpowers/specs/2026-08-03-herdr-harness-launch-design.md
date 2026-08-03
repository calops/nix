# Transparent herdr-backed harness launch

Date: 2026-08-03
Status: approved (design discussion), awaiting implementation
Scope: `modules/programs/oh-my-pi/` only

## Problem

Typing `omp` today runs the agent as a child of the current terminal. The agent
dies with the terminal, cannot be reattached from elsewhere, and is invisible to
herdr's workspace model.

The goal: typing `omp` launches the agent inside the shared herdr instance — a
server-owned pane in a per-project workspace — while the invoking terminal
renders only that pane (no herdr UI). Detaching returns the terminal to a shell;
the agent keeps running and can be reattached from any terminal or from the
herdr UI.

## Verified facts (herdr 0.7.5, observed 2026-08-03)

- `herdr agent attach <target>` attaches the current terminal directly to one
  agent's terminal, "instead of the full Herdr UI". Detach: `ctrl+b q`. Literal
  `ctrl+b`: `ctrl+b ctrl+b`. `--takeover` steals input from another direct
  attach client.
- `herdr agent start <name> --kind omp --pane <id> [--timeout MS] [-- ARGS]`
  runs the `omp` executable in an existing pane and blocks until herdr detects
  the agent ready. The pane must be at an interactive shell prompt. Default
  timeout 30 s, max 300 s.
- `herdr workspace create --cwd <path> --label <text> --no-focus` returns
  `.result.root_pane.pane_id`; a new workspace always comes with a first tab and
  a fresh root pane at a shell prompt.
- `herdr tab create --workspace <id> --cwd <path> --no-focus` returns a fresh
  root pane.
- Socket subcommands do **not** lazy-start the server: with the server down they
  fail (`Os NotFound` on the socket). Only bare `herdr` spawns it. The wrapper
  must ensure the server explicitly.
- `herdr status server` prints `status: running` when up.
- `herdr workspace list` returns records with `workspace_id`, `label`,
  `agent_status`; `herdr agent list` returns agents with `agent` (kind),
  `workspace_id`, `pane_id`, `agent_status`.
- Agent names must match `[a-z][a-z0-9_-]{0,31}` and be unique among live
  agents. Targets accept a unique live agent name or pane id.
- The omp integration file is bundled in the herdr binary:
  `PI_CODING_AGENT_DIR=<scratch> herdr integration install omp` writes
  `herdr-omp-agent-state.ts` (12.9 KB, `HERDR_INTEGRATION_VERSION=6`), and
  `herdr integration status` reports `omp: current (v6)` when that file is
  present at the resolved path. No server interaction involved in install.
- pi/omp keybindings contain no `ctrl+b`; the direct-attach prefix does not
  collide with the agent TUI.

## Decisions (locked)

| # | Decision |
|---|----------|
| 1 | Single shared herdr instance: the default session. One workspace per project. |
| 2 | Workspace label and agent name derived from project basename (sanitized to `[a-z][a-z0-9_-]{0,31}`); agent-name collision → `-2`, `-3`, … |
| 3 | Project = `git rev-parse --show-toplevel` when inside a repo, else `$PWD`. |
| 4 | Re-entry is idempotent: live omp agent in the project workspace → attach to it. `--new` forces a fresh agent. |
| 5 | Escape hatch: `--no-herdr` → current direct-exec behavior, unchanged. |
| 6 | Server bootstrap is lazy and in-wrapper: `herdr status server` → spawn `herdr server` detached → poll until running. |
| 7 | omp integration shipped declaratively: extract the bundled `herdr-omp-agent-state.ts` from the pinned herdr package at build time, place it in the store-backed extensions dir. No fetchUrl, no runtime writes, no activation script. |
| 8 | No migration of existing workspaces (they are transient). |
| 9 | pi is out of scope (legacy). |

## Wrapper behavior

`omp` becomes a launcher. `omp [--no-herdr | --new] [ARGS...]`

```text
if HERDR_ENV=1 or --no-herdr:
    exec omp "$@"                       # already inside herdr / escape hatch

ensure server:
    herdr status server | grep -q "status: running"  ||  spawn herdr server detached
    poll herdr status server until running (bounded)

project = git root inside a repo, else $PWD
name    = sanitize(basename(project))

ws = workspace list | select label == name

if ws exists and not --new and ws has a live omp agent (agent list, kind omp in ws):
    agent attach <that agent>           # idempotent re-entry
    exit

if ws missing:
    created = workspace create --cwd "$project" --label "$name" --no-focus
    pane    = created.root_pane.pane_id
else:
    pane    = root pane of ws             # pane list | select workspace_id == ws | first

agent start "$name" --kind omp --pane "$pane" --timeout 60000 -- "$@"
if start failed and ws existed:          # root pane not at a shell prompt
    tab = tab create --workspace "$ws" --cwd "$project" --no-focus
    agent start "$name" --kind omp --pane "$tab.root_pane.pane_id" --timeout 60000 -- "$@"
agent attach "$name"                     # transparent view; ctrl+b q detaches
```

Notes:

- The "root pane reuse" branch degrades gracefully: `agent start` fails with a
  clear error (exit 1) when the pane is not at a shell prompt; the wrapper then
  creates a fresh tab and retries. This keeps the state machine from needing
  process introspection. Existing workspace root panes are resolved via
  `herdr pane list` (records carry `workspace_id`; no pane ids in
  `workspace get`/`tab list`).
- `agent start` runs the nix `omp` wrapper inside the pane, so
  `PI_CODING_AGENT_DIR` and the 1Password credential evals happen in-pane at
  launch. API keys never enter herdr session state.
- Agent name collision (two dirs with the same basename): append `-2`, `-3`.
  Workspace labels do not need uniqueness but follow the same scheme.

## Module changes

`modules/programs/oh-my-pi/default.nix`:

1. **Integration file** — build-time extraction:

   ```nix
   herdrOmpStateExt = pkgs.runCommand "herdr-omp-agent-state.ts" {
     nativeBuildInputs = [ inputs'.llm-agents.packages.herdr ];
   } ''
     mkdir -p "$TMPDIR/scratch"
     PI_CODING_AGENT_DIR="$TMPDIR/scratch" herdr integration install omp >/dev/null
     cp "$TMPDIR/scratch/extensions/herdr-omp-agent-state.ts" "$out"
   '';
   ```

   The extracted file is merged into the store-backed extensions dir with
   `symlinkJoin` (a nested `xdg.configFile` entry under the already-managed
   `extensions/` symlink is impossible — home-manager cannot write through a
   store symlink):

   ```nix
   ompExtensionsDir = pkgs.symlinkJoin {
     name = "omp-agent-extensions";
     paths = [
       "${host.configDir}/modules/programs/oh-my-pi/extensions"
       herdrOmpStateExt
     ];
   };

   xdg.configFile."omp/agent/extensions".source = ompExtensionsDir;
   ```

   The dir stays store-backed (as today); the file is read by the agent at
   runtime, never written, so immutability is fine. `herdr integration status`
   reports `current (v6)`. Version stays in sync with the flake-locked herdr
   automatically.

   Risk (mitigated): `herdr integration install` must work in the nix sandbox
   (no herdr server, no `$HOME` config). The command writes a bundled asset
   locally and was observed to need only `PI_CODING_AGENT_DIR`; verify in the
   sandbox during implementation. Fallback if sandbox breaks: extract the
   embedded bytes from the binary with `strings`/asset extraction at build
   time.

2. **Wrapper** — the launcher flow above, replacing the direct `exec omp`.

   Runtime inputs: `herdr` (already in profile via `programs.herdr`),
   `jq`, `git`. All present.

3. No changes to `config.yml`, `herdr.nix`, or `pi.nix`.

## Error handling

| Failure | Behavior |
|---------|----------|
| Server down | Spawn `herdr server` detached (`nohup`/`setsid`, log to `~/.local/state/herdr/`), poll `herdr status server` up to ~15 s, then fail with instructions. |
| `workspace create` / `tab create` error | Print the herdr JSON error, exit 1. |
| `agent start` timeout / pane not at prompt | Retry once in a fresh tab; if still failing, print the error and exit 1 (no fallback to direct exec — except via `--no-herdr`). |
| Agent-name collision | Append `-2`, `-3`, … until free (checked against `agent list`). |
| Two terminals attach simultaneously | Second attach uses `--takeover` (input ownership); both can view. |
| `omp` invoked inside herdr | `HERDR_ENV=1` → plain exec, current behavior. |

## Acceptance criteria

1. Typing `omp` in a terminal outside herdr launches the agent in the default
   herdr session, in a workspace labeled by the project basename, and the
   terminal shows only the agent TUI (no herdr chrome).
2. `ctrl+b q` returns the terminal to a shell; the agent keeps running in
   herdr (visible via `herdr agent list`).
3. Typing `omp` again in the same project attaches to the existing agent
   without spawning a second one.
4. `omp --new` spawns a second agent for the same project.
5. `omp --no-herdr` behaves exactly like today's `omp`.
6. With the herdr server stopped, `omp` starts it and proceeds.
7. `herdr integration status` reports `omp: current (v6)`.
8. Agent args pass through: `omp <args>` reaches the agent in the pane.

## Out of scope

- Migration/cleanup of existing workspaces (`oh_my_pi`, `claude` labels).
- pi and other harness kinds (same pattern later; `--kind` is the only diff).
- Remote herdr servers (`herdr --remote`); the wrapper targets the local
  default session.
