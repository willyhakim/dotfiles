# Editor configuration

## What is stowed

| Package  | Links into |
|----------|------------|
| `vscode` | `~/Library/Application Support/Code/User/settings.json` |
| `cursor` | `~/Library/Application Support/Cursor/User/{settings.json,keybindings.json}` |

These target paths contain spaces. `bootstrap.sh` quotes them correctly; if you
stow by hand, quote the target:

```bash
stow -t "$HOME" vscode cursor
```

## Extensions

VS Code extensions are tracked in the **Brewfile** as `vscode "..."` entries, so
`brew bundle` restores them along with everything else. There is no separate
list — one source of truth.

Cursor is not covered by `brew bundle`, so its extensions live here:

```bash
# save
cursor --list-extensions > editors/cursor-extensions.txt

# restore
xargs -n1 cursor --install-extension < editors/cursor-extensions.txt
```

## Note on VS Code Settings Sync

If you ever turn on VS Code's built-in Settings Sync, it will fight these
symlinks — it rewrites `settings.json` in place. Pick one mechanism, not both.
