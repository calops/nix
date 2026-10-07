# nix

Personal flake for home-manager and nixos configuration.

## Ghostty

`modules/programs/ghostty.nix` installs the
[pixel-scroll fork](https://github.com/parkers0405/ghostty-pixel-scroll) through
Home Manager, enabled only on `tb-laptop`. It follows the host's nixpkgs so
Ghostty and the graphics drivers use compatible runtime libraries. The aspect
restores Zig's configure phase to initialize its build cache and declares the
fork's binary cache. Stylix supplies the shared terminal font and theme.

Launch `ghostty` or select Ghostty in the application menu after rebuilding.
Kitty remains installed and the existing terminal keybindings are unchanged.

## Shell prompt

Oh My Posh shows the user and hostname in SSH sessions; non-root local sessions
omit that segment. The session template uses the case-sensitive `.HostName` field.
After applying prompt changes through Home Manager, start a new shell to discard
cached prompt templates.

## Neovim clipboard

Neovim uses OSC 52 for clipboard access. `,y` copies through the attached
terminal rather than the host's `wl-copy`/`xclip`; a local Kitty terminal handles
the system clipboard, and Herdr forwards clipboard writes over SSH.

Yanky's `system_clipboard.sync_with_ring` is disabled: its focus-loss/focus-gain
callbacks read the clipboard, and Herdr does not answer OSC 52 read queries.
This prevents the "Waiting for OSC 52 response" freeze when returning to Neovim.
Normal yank history remains enabled, but external clipboard changes are no
longer automatically imported into the yank ring.

Use Kitty's `Ctrl+Shift+V` to paste into Neovim through Herdr instead of `"+p`,
which still requests an unsupported clipboard read. Restart Neovim to apply the
focus-sync change; no Nix rebuild is needed.

## Neovim picker input

Snacks picker input windows use `virtualedit = "onemore"` so the insertion
point stays valid when `modes.nvim` redraws during preview Normal-mode commands.
Without it, preview updates can move the prompt cursor left and reorder typed
characters. Other editor windows retain `virtualedit = "block"`.

Restart Neovim after changing the picker configuration; no Nix rebuild is needed.

## Herdr theme

`modules/programs/herdr/default.nix` uses the global palette from `modules/colors.nix`.
Sidebar and UI chrome use `mantle`, sidebar separators use `crust`, and focused/selected
sidebar rows use `surface0`. Terminal contents retain Kitty's default `base`
background. UI accents use `blue`; sidebar agent names use `mauve` without bold.
Split panes share single dividers, with no outer frame or gaps. Pane divider
colors retain Herdr's upstream focus-dependent styling.

After applying the Home Manager configuration, reload Herdr with
`Ctrl+B`, then `Shift+R`. For remote sessions, detach and relaunch the remote
client to pick up theme changes.

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

## Herdr

Herdr comes from [calops/herdr](https://github.com/calops/herdr/tree/calops/sidebar-workspaces),
locked through the `herdr` flake input. The checkout is in `~/projects/herdr`.
Both the Herdr aspect and the OMP integration use this package; OMP itself
still comes from `llm-agents`. The phone bridge and Tailscale integration are
not installed. SSH aliases `station` and `tocardstation` connect directly to
`station.tocards.net`; its public IPv6 address does not require Tailscale.

The expanded desktop sidebar is one workspace-first tree. Workspace names occupy
one line. Agents appear as indented children, with agent names on the first line
and the gray tab/pane description on the second. One empty line separates
workspace groups.

The fork supports a `projects` metadata row, but this configuration leaves it
disabled for compatibility with older running servers. Those servers reject the
token when parsing the UI section, preventing updated border settings from loading.

Tree guides drop directly from each workspace's status dot, with no leftover
arrow padding. They connect agents using `├──` and a rounded `╰──` for the last
child, continue through metadata/description lines, and stop below the last child.

Workspace groups have no disclosure arrow or reserved arrow padding. Double-click
anywhere in a group (its header, projects, or either agent line) to fold or unfold
it. Workspace names are bold and use the normal `text` color in both states.
Folded groups occupy one line: the colored status dot and workspace name followed
by muted middle dots filling the
remaining width, with metadata hidden. Long names truncate to keep a visible fold
marker.

Single-click a workspace label to focus it, or either line of an agent to focus
that pane. Rapid clicks on different rows do not fold the group. Hover and focus
backgrounds cover both lines and the indentation; hover uses `surface1` and never
overrides focus. The tree has one scrollbar, and wheel input over agents scrolls
that same tree.

Collapse state lasts for the client session. Agent shortcuts reveal their target
automatically. Sorting and plugin views affect agents within the workspace
hierarchy. Compact and mobile layouts retain their compact presentation.

After applying the Nix configuration, detach and relaunch the Herdr client.
Client-only sidebar changes do not require stopping the server or pane processes.
Enabling the optional `projects` token requires the updated server as well as the
updated client; an older server cannot parse that sidebar configuration.

### Fork development

Edit and commit changes in `~/projects/herdr` on `calops/sidebar-workspaces`.
To test local edits without changing the lock:

```sh
nix build path:.#nixosConfigurations.tocardstation.config.home-manager.users.calops.programs.herdr.package \
  --override-input herdr "path:$HOME/projects/herdr" --no-write-lock-file --no-link
```

After pushing the fork, update and build the pinned package:

```sh
nix flake update herdr
nix build path:.#nixosConfigurations.tocardstation.config.home-manager.users.calops.programs.herdr.package --no-link
```

Package builds do not run tests. Validate UI changes by launching the built
binary and exercising the actual sidebar. Home Manager installs the same package
derivation, so activation reuses the built output. `path:.` includes untracked
working-tree files during development.

### Neovim sidebar

The Herdr aspect builds [herdr-nvim](https://github.com/ChmaraX/herdr-nvim)
from a manually pinned `fetchFromGitHub` source in `modules/programs/herdr/default.nix`,
not a flake input, and registers it on each Home Manager switch. Lazy.nvim
loads its annotations plugin from the same Nix store package; Herdr's upstream
download/build hooks are removed because Nix supplies the binary.

A small local patch makes the file picker and its `fff-search`/`crossterm`
dependencies optional. The package uses `--no-default-features`, so it does not
compile them or expose their commands, plugin entries, or keybinding. The upstream
source and Cargo lockfile remain intact to keep the patch small; optional crates
remain vendored but are not compiled. Only necessary feature gates are patched;
lightweight unused helpers and upstream tests are left unchanged.

Full release LTO and build-time tests are disabled. A plain Neovim supplies
build-time tools; the sidebar still launches the Home Manager Neovim package.
To update manually, change the source revision/hash, rebase
`modules/programs/herdr/disable-file-picker.patch` if needed, and update
`cargoHash` only when the upstream Cargo lockfile changes.

- `Ctrl+B`, then `Shift+E`: toggle the persistent Neovim sidebar for the tab.
- Existing `Ctrl+B`, then `e` (scrollback) and `o` (notification target) stay unchanged.
- In Neovim: `,ac` comments on a line/selection, `,al` lists comments,
  `,as` pastes comments to the agent, `,aS` submits them, and `,ai` inserts a reference.
  These are also available through `:Herdr`; see `:help herdr-nvim` for details.

The sidebar uses the Home Manager Neovim package and normal editor configuration.
Closing its tab discards unsaved sidebar buffers; `herdr-nvim daemons` lists
running sidebar daemons.
