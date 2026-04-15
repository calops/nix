# Quickshell Development Instructions

Whenever editing QML files, the configuration is automatically reloaded by Quickshell.

To see the errors, warnings, and debug statements, run:
```bash
journalctl --user -u quickshell -n 20
```

Important: remember to look at the latest logs at the end of ta task to check
that your work doesn't produce errors or warnings.
