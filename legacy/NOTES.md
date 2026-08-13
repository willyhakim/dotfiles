# Legacy bash setup — what happened to it

The shell has been zsh (via oh-my-zsh) for years, but `~/.bash_profile` and
`~/.bashrc` were still on disk carrying about eight years of accumulated
configuration. They are archived here **for reference only** — nothing in this
directory is stowed, and nothing links to it.

`bash_profile.old` and `bashrc.old` are verbatim copies with one edit: the
plaintext `NPM_TOKEN` on line 41 is redacted.

---

## Ported forward

| From | To | Note |
|---|---|---|
| `alias l`, `alias ll` | `zsh/.config/zsh/20-aliases.zsh` | unchanged |
| `alias dc` | same | `docker-compose` → `docker compose` (v1 is EOL) |
| `alias dm` | same | unchanged |
| `alias pym`, `mkenv`, `startenv`, `stopenv` | same | unchanged |
| `NVM_DIR` + nvm sourcing | `zsh/.config/zsh/10-env.zsh` | now lazy-loaded |
| OpenSSL `LDFLAGS`/`CPPFLAGS`/`PKG_CONFIG_PATH` | same | now guarded by a `-d` test |
| `GOPATH` | same | `~/go-workspace` → `~/go` (see below) |
| `/usr/local/sbin`, `icu4c`, `openssl`, `~/.local/bin` on PATH | `zsh/.config/zsh/00-path.zsh` | each guarded |
| opam init | `zsh/.config/zsh/10-env.zsh` | `init.sh` → `init.zsh` |

## Dropped, and why

- **`export PATH=~/bin:...:/sbin`, twice.** Two full literal PATH assignments
  that discarded whatever the system had set up. `~/bin` does not exist.
- **`~/.nvm/versions/node/v8.0.0/bin`.** Hardcoded a node version from 2017.
  The installed versions are now v16 through v24; nvm handles this.
- **`/Applications/Postgres.app/Contents/Versions/9.6/bin`.** Postgres.app is
  already on PATH system-wide via `/etc/paths.d/postgresapp`, which points at
  `Versions/latest` (currently 13.3). Note this means `psql` resolves to
  Postgres.app, *not* to the Homebrew `postgresql@18` that is also installed —
  pre-existing behaviour, left as-is.
- **`anaconda3/bin`, twice.** Both lines were already commented out.
- **`GOROOT=/usr/local/opt/go/libexec`.** Modern Go resolves its own GOROOT;
  hardcoding it breaks on every toolchain upgrade.
- **`GOPATH=~/go-workspace`.** Both `~/go` and `~/go-workspace` exist.
  `~/go-workspace/bin` holds a dozen abandoned Go tools from the pre-`gopls`
  era (`gocode`, `godef`, `golint`, `go-outline`…); `~/go` is the modern
  default and is what recent installs have been writing to. Switched to `~/go`.
  **`~/go-workspace` is untouched on disk** — delete it by hand if you agree
  it is dead.
- **`export NPM_TOKEN=...`.** A plaintext credential. Belongs in
  `~/.zshrc.local`, which is untracked.
- **`export PATH="$PATH:/Applications/Visual Studio Code.app/..."`.** No longer
  needed; `code` is already at `/usr/local/bin/code`.
- **virtualenvwrapper block.** Entirely commented out.
- **`__docker_machine_ps1` in `PS1`.** bash-specific prompt; oh-my-zsh's
  `robbyrussell` theme covers the git half, and docker-machine is deprecated.
- **oh-my-bash (`~/.oh-my-bash`, `OSH_THEME="font"`).** Superseded by
  oh-my-zsh. The directory is still on disk.

## Stale files still sitting in `$HOME`

Not copied here, not tracked, not deleted — listed so you can clear them out
when you feel like it:

```
~/.bash_profile~                    ~/.bashrc~
~/.bash_profile-anaconda.bak        ~/.bashrc.pre-oh-my-zsh
~/.bash_profile-anaconda3.bak       ~/.shell.pre-oh-my-zsh
~/.bash_sessions/                   ~/.oh-my-bash/
```

Once you are happy the zsh config covers everything, the live `~/.bash_profile`
and `~/.bashrc` can go too — these archived copies are the record.

---

## Open items elsewhere in the repo

- **`vim/.vimrc`** is pure Vundle scaffolding with an *empty* plugin list — it
  bootstraps a plugin manager to manage zero plugins. Tracked as-is because it
  is what actually runs, but it wants either real plugins or deletion.
- **`pyenv`** is installed via Homebrew but has no versions beyond `system`, so
  `pyenv init` is commented out in `10-env.zsh` rather than paying its startup
  cost and inserting shims in front of `python3` for no benefit.
