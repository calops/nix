# nix

Personal flake for home-manager and nixos configuration.

## Profile isolation

`modules/home.nix` routes `homeManagerLinux` and `homeManagerDarwin` into
Home Manager within each user or standalone home's scope, selecting the class
from the target system. Platform-specific modules must not be forwarded from
the fleet-wide aggregate: that leaks packages between hosts.

The `gaming` profile is selected only by `tocardstation`. `tb-laptop` must not
receive its Lutris, Wine, Steam helpers, or MangoHud packages.

## Xerj

The `ai-dev` profile installs [Xerj](https://github.com/xerj-org/xerj)
`1.0.0-rc.98` from a hash-pinned upstream static Linux binary. The user
`xerj.service` runs a persistent search/indexing node; each harness launches
its own lightweight `xerj mcp` stdio bridge to that node.

Claude Code, OpenCode and Codex use the shared Home Manager MCP registry.
OMP opts into its built-in OpenCode discovery provider, so it inherits the
entire registry through `~/.config/opencode/opencode.json`, not a separate
Xerj-only `~/.omp/agent/mcp.json`. The provider also discovers other OpenCode
resources and settings. Codex settings remain writable and merge with
client-managed state. Cursor Agent and Antigravity are not installed.

The node binds only to `127.0.0.1`: Elasticsearch-compatible HTTP on `9200`,
native REST on `9201`, and gRPC on `9202`. HTTP API-key authentication stays
enabled; TLS is disabled for loopback traffic. Data lives in
`$XDG_STATE_HOME/xerj` (normally `~/.local/state/xerj`), with a private generated
`admin.key`. The installed CLI/MCP wrapper reads that key at runtime; no secret
is embedded in Nix. These harnesses share the user's node and memory, not
separate security boundaries.

After rebuilding/activating Home Manager, start or check the service and
restart harness sessions to load their new MCP configuration:

```sh
systemctl --user start xerj.service
systemctl --user status xerj.service
journalctl --user -u xerj.service
xerj search --prefix nix-config "SSH agent configuration"
```

`services.xerj.indexedDirectories` maps stable index prefixes to directory paths:

```nix
services.xerj.indexedDirectories = {
  my-project = "~/projects/my-project";
};
```

`nix-config` defaults to `config.home.configDir`. The Terabase work aspect adds
the backend, backend Nix environment, frontend C3, web, DT3 explorer and guide
checkouts; worktrees, dumps and performance traces are not included.
Absolute paths and `~/` are supported. A missing directory is skipped without
failing; its systemd path unit starts indexing if it appears later.

Each folder gets a `xerj-index-<prefix>.service` and `.path` unit. The service
waits for node readiness, indexes once, then watches filesystem events with a
two-second debounce and two indexing workers. Added, changed, renamed and
deleted files are reconciled automatically. Xerj's watch mode requires
`--no-graph`, so these indexes have no second-brain relationship graph.
Normal ignore rules apply. Indexing can consume substantial disk and memory;
even a small change currently involves corpus-wide work upstream.

Keep prefixes stable and use one per folder. Avoid prefixes that start with
another prefix followed by `-`: a search for `foo` also matches `foo-bar-*`.
Removing an option stops its watcher but deliberately retains indexed data.
Use `xerj autoindex remove --prefix <prefix>` to review and explicitly remove it.
Keep Xerj's data directory outside indexed folders.

The node uses built-in neural embeddings (`all-MiniLM-L6-v2`). Xerj downloads
the model from Hugging Face on first startup (about 90 MB), caches it, and
runs it in-process. No additional daemon or API key is needed; document text
is embedded locally. Startup allows up to 15 minutes for the initial download.
A model load failure fails startup rather than falling back to lexical vectors.

On first startup of each managed watcher after the neural cutover, it removes
only that configured prefix/source folder's old autoindex data, then rebuilds
using a separate neural resume journal. Search for that folder can be incomplete
until its rebuild finishes. A completion marker prevents repeated removal on
later restarts. Missing folders defer the migration until they exist.
Unrelated indexes and agent memory are not deleted or automatically re-embedded;
any pre-existing lexical vectors there need their own deliberate migration.

Semantic/hybrid MCP queries can use these embeddings on fields mapped as
`semantic_text`; autoindex infers those fields, so not every short/structured
dataset has them. External embedding providers, Corpus Hub downloads and
reference corpora are not provisioned here. Upstream feedback invitations
are disabled. Do not run `xerj init`: Nix supplies the MCP configuration.

## Quickshell brightness

The Quickshell Home Manager module installs `brightnessctl` for its backlight
controls. Monitor brightness through DDC uses the wrapped `ddcutil` dependency.

## Ghostty

`modules/programs/ghostty.nix` installs the
[pixel-scroll fork](https://github.com/parkers0405/ghostty-pixel-scroll) through
Home Manager, enabled only on `tb-laptop`. It follows the host's nixpkgs so
Ghostty and the graphics drivers use compatible runtime libraries. The aspect
restores Zig's configure phase to initialize its build cache and declares the
fork's binary cache. Stylix supplies the shared terminal font and theme.

Launch `ghostty` or select Ghostty in the application menu after rebuilding.
Kitty remains installed and the existing terminal keybindings are unchanged.

## SSH agent

Graphical Linux hosts disable GCR's SSH-agent socket. Home Manager sets
`SSH_AUTH_SOCK` to `~/.1password/agent.sock` in the user systemd manager, so
user services use 1Password even without an active graphical login. SSH logins
with agent forwarding keep the socket supplied by `sshd`; headless hosts retain
their local agent fallback. Rebuild and log out/in to replace the old user
manager environment; restart existing services and sessions to inherit it.

## Shell prompt

Oh My Posh shows the user and hostname in SSH sessions; non-root local sessions
omit that segment. The session template uses the case-sensitive `.HostName` field.
After applying prompt changes through Home Manager, start a new shell to discard
cached prompt templates.

## Neovim clipboard

Neovim uses OSC 52 for clipboard access. `,y` copies through the attached
terminal rather than the host's `wl-copy`/`xclip`, including over SSH. A local
Kitty terminal handles the system clipboard.

Yanky's `system_clipboard.sync_with_ring` is disabled so focus-loss/focus-gain
callbacks do not request clipboard reads. OSC 52 read support depends on the
attached terminal, and unanswered queries can cause a "Waiting for OSC 52
response" freeze when returning to Neovim. Normal yank history remains enabled,
but external clipboard changes are not automatically imported into the yank ring.

Use Kitty's `Ctrl+Shift+V` to paste without an OSC 52 read query; `"+p` requires
clipboard-read support. Restart Neovim to apply the focus-sync change; no Nix
rebuild is needed.

## Neovim picker input

Snacks picker input windows use `virtualedit = "onemore"` so the insertion
point stays valid when `modes.nvim` redraws during preview Normal-mode commands.
Without it, preview updates can move the prompt cursor left and reorder typed
characters. Other editor windows retain `virtualedit = "block"`.

Restart Neovim after changing the picker configuration; no Nix rebuild is needed.

## Orca

The `ai-dev` profile includes `modules/programs/orca.nix`. Orca is installed only
when `profiles.graphical.enable` is true, using the prebuilt package from the
locked `llm-agents` input.

- **tocardstation:** `services.orca.enable = true` starts `orca.service` in
  calops's user manager. Lingering starts it at boot and keeps it running without
  a graphical login. The service owns the normal Orca profile on this host;
  do not start a second desktop/server instance with that same profile.
- **tb-laptop:** `programs.orca.sshHost = "station"` wraps the desktop launcher
  and desktop entry. `orca open` also uses this launcher. The `station` SSH alias
  and the existing `tocardstation` alias both resolve to `station.tocards.net`.

Launch **Orca** from the application menu or run `orca-ide` or `orca open`.
The laptop launcher opens `127.0.0.1:16768` through SSH to the station's
`127.0.0.1:6768`, imports the server's pairing offer only if the saved `station`
environment is absent, and checks authenticated connectivity before opening
the GUI. It clears the CLI's `ELECTRON_RUN_AS_NODE` flag before executing the
desktop, including launches through `orca open`. SSH keys, host-key verification,
and agent configuration come from the existing SSH setup.

On the first launch, select **Settings → Remote Orca Servers → Advanced →
Active Server → station**. Orca currently has no supported CLI to set this GUI
preference. Install/authenticate coding-agent accounts on the station, not on
the laptop.

Upstream `orca serve` listens on `0.0.0.0`; its advertised loopback address does
not change that bind. The NixOS firewall remains unchanged and blocks the
runtime port. An assertion prevents explicitly allowing TCP 6768 while the
server is enabled. Do not open that port or put the pairing URL in Nix files:
it is a credential.

The service captures its startup/pairing JSON in the private runtime file
`/run/user/<uid>/orca-serve-ready.json`, rather than the journal. The launcher
fetches it over SSH during initial pairing; Orca stores the resulting client
grant in its private configuration.

Useful commands:

```sh
systemctl --user status orca.service       # on tocardstation
journalctl --user -u orca.service          # server diagnostics, not pairing data
orca status --environment station --json  # on tb-laptop, after launching Orca
```

The SSH control master stays alive independently of individual GUI launches.
It can be stopped explicitly on the laptop:

```sh
ssh -S "$XDG_RUNTIME_DIR/orca-client/ssh.sock" -O exit station
```

If the server's saved client grant is revoked, remove the laptop's saved
environment with `orca environment rm --environment station`. Explicitly
restart `orca.service` on the station to generate a fresh offer, then relaunch
the laptop client. The launcher never restarts the server to obtain credentials.

