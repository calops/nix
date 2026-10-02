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
