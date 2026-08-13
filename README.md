# dotfiles

macOS configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

```bash
git clone https://github.com/willyhakim/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

That installs Homebrew + `stow` + `gh` if missing, runs `brew bundle`, backs up
any file it is about to replace, symlinks every package into `$HOME`, and seeds
the two untracked local-override files.

Preview without touching anything:

```bash
./bootstrap.sh --dry-run
```

---

## Layout

One directory per tool. Each mirrors `$HOME` internally, so
`stow -t ~ zsh` creates `~/.zshrc -> ~/dotfiles/zsh/.zshrc`.

| Package  | Contents |
|----------|----------|
| `zsh`    | `.zshrc` (slim loader) + `.config/zsh/NN-*.zsh` |
| `git`    | `.gitconfig`, `.config/git/ignore` |
| `vim`    | `.vimrc` |
| `psql`   | `.psqlrc` |
| `mycli`  | `.myclirc` |
| `conda`  | `.condarc` |
| `claude` | `.claude/settings.json` |
| `vscode` | `Library/Application Support/Code/User/settings.json` |
| `cursor` | `Library/Application Support/Cursor/User/{settings,keybindings}.json` |

Not packages: `Brewfile`, `bootstrap.sh`, `hooks/`, `templates/`,
`editors/` (extension lists + notes), `legacy/` (archived bash setup — never
stowed).

### Adding a package

```bash
mkdir -p ~/dotfiles/tmux
mv ~/.tmux.conf ~/dotfiles/tmux/.tmux.conf
stow -d ~/dotfiles -t ~ tmux
```

Then add it to `DEFAULT_PACKAGES` in `bootstrap.sh`.

---

## Shell config

`~/.zshrc` stays deliberately small. Everything real is in `~/.config/zsh/`,
sourced in numeric order:

| File | Purpose |
|---|---|
| `00-path.zsh` | PATH, built from guarded entries. Runs first because it sets `typeset -U path`, which makes every later addition de-duplicate automatically. |
| `10-env.zsh` | `EDITOR`, `LANG`, `GOPATH`, OpenSSL build flags, lazy nvm |
| `20-aliases.zsh` | aliases |
| `30-functions.zsh` | `mkcd`, `extract`, `serve`, `ports`, `dotfiles-sync` |

`nvm` is lazy-loaded: the newest installed node goes straight on PATH, and
`nvm.sh` is sourced only when you actually call `nvm`. This keeps roughly a
second off every shell start.

---

## Secrets

**This repo is public. Nothing secret goes in it, ever.**

Two untracked files hold anything sensitive or machine-specific. `bootstrap.sh`
creates them from `templates/` on first run and never overwrites them after:

| File | For |
|---|---|
| `~/.zshrc.local` | tokens, `AWS_PROFILE`, per-machine PATH, config overrides |
| `~/.gitconfig.local` | credential helpers, work identity |

Three layers of defence:

1. **`.gitignore`** — `.npmrc`, `.netrc`, `.aws/`, `.ssh/`, `*.local`,
   `**/auth.json`, `**/mcp.json`, history files, `*.pem`, keys.
2. **`hooks/pre-commit`** — greps staged content for credential shapes (npm
   `_authToken`, `ghp_`, `xox…`, `sk-…`, bare UUIDs, PEM headers) and blocks the
   commit. Installed by `bootstrap.sh`. Bypass with `--no-verify` only when you
   are certain it is a false positive.
3. **Manual scan before pushing anything new**:
   ```bash
   gitleaks detect --source . --no-git
   ```

### If you are setting this up on the original machine

The pre-existing `~/.npmrc` and `~/.bash_profile` both contained plaintext npm
tokens. Rotate them at npmjs.com, then put the new value in `~/.zshrc.local`
only. `~/.npmrc` is gitignored and stays where it is — it is not managed here.

---

## Homebrew

```bash
brew bundle --file=~/dotfiles/Brewfile          # restore
brew bundle dump --file=~/dotfiles/Brewfile --force   # refresh after installing
```

The Brewfile also carries `vscode "..."` lines, so VS Code extensions are
restored by the same command. Cursor extensions are separate — see
[`editors/README.md`](editors/README.md).

---

## Everyday use

```bash
dotfiles                    # cd ~/dotfiles           (alias)
dotfiles-sync "message"     # add + commit + push     (function)
reload                      # exec zsh                (alias)
./bootstrap.sh --dry-run    # preview a re-stow
stow -D -t ~ vscode         # unlink one package
```

Editing a config is just editing the file in this repo — the symlink means the
change is live immediately.

---

## History

`legacy/` holds the retired bash setup (`.bash_profile`, `.bashrc`, oh-my-bash)
with the token redacted, plus [`NOTES.md`](legacy/NOTES.md) recording exactly
what was ported forward, what was dropped, and why. Worth reading before
resurrecting anything from it.
