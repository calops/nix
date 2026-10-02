# The control master outlives individual GUI launches, including Electron's
# immediate exit when it hands a second launch to an existing window.
client_dir="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR must be set}/orca-client"
install -d -m 700 "$client_dir"
control_socket="$client_dir/ssh.sock"

# Serialize first launches so they cannot race for the forwarded port or
# create duplicate saved environments.
exec 9>"$client_dir/launch.lock"
flock 9

if ! ssh -S "$control_socket" -O check "$ORCA_SSH_HOST" >/dev/null 2>&1; then
  ssh -fNT \
    -M -S "$control_socket" \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -L "127.0.0.1:$ORCA_CLIENT_PORT:127.0.0.1:$ORCA_SERVER_PORT" \
    "$ORCA_SSH_HOST"
fi

# Only bootstrap a missing environment. Reuse its durable client grant on
# subsequent launches instead of issuing or importing new credentials.
environments="$("$ORCA_CLI" environment list --json)"
if ! jq -e --arg name "$ORCA_SSH_HOST" \
  '.result.environments | any(.name == $name)' \
  <<<"$environments" >/dev/null; then
  ready="$(ssh -S "$control_socket" "$ORCA_SSH_HOST" \
    "sh -c 'cat /run/user/\$(id -u)/orca-serve-ready.json'")"
  # SSH login-shell initialization may print text before the ready record.
  pairing_url="$(jq -Rer \
    'fromjson? | select(.type == "orca_server_ready" and .schemaVersion == 1 and .pairing.available == true) | .pairing.url' \
    <<<"$ready")"
  "$ORCA_CLI" environment add \
    --name "$ORCA_SSH_HOST" --pairing-code "$pairing_url" --json >/dev/null
  unset ready pairing_url
fi

# Authenticate before opening the GUI. A tunnel or stale grant failure must
# not silently launch an unrelated local workspace instead.
"$ORCA_CLI" status --environment "$ORCA_SSH_HOST" --json >/dev/null

flock -u 9
exec 9>&-

# Orca's ORCA_OPEN_COMMAND override inherits the CLI's Node-mode flag.
# Keep it for CLI calls, but never pass it into the desktop executable.
unset ELECTRON_RUN_AS_NODE
exec "$ORCA_GUI" "$@"
