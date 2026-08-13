# Environment variables and toolchain initialisation.

export LANG="en_US.UTF-8"
export EDITOR="vim"
export VISUAL="$EDITOR"
export CLICOLOR=1

# less: case-insensitive search, no clear on exit, honour colour
export LESS="-iMFXR"
export PAGER="less"

# --- Go ----------------------------------------------------------------------
# GOROOT is intentionally unset: modern Go and Homebrew both resolve it
# themselves, and hardcoding it (as the old .bash_profile did) breaks on every
# toolchain upgrade.
export GOPATH="$HOME/go"

# --- OpenSSL build flags -----------------------------------------------------
# Kept from the old .bash_profile; still needed by some Python/Ruby native
# extensions on Intel macOS.
if [[ -d /usr/local/opt/openssl ]]; then
  export LDFLAGS="-L/usr/local/opt/openssl/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
fi

# --- nvm ---------------------------------------------------------------------
# Lazy-loaded: sourcing nvm.sh eagerly costs ~1s on every shell start, and it is
# needed only when actually switching versions. The newest installed node is put
# on PATH directly so node/npm/npx work instantly without loading nvm at all.
export NVM_DIR="$HOME/.nvm"

if [[ -d "$NVM_DIR/versions/node" ]]; then
  _nvm_newest=("$NVM_DIR"/versions/node/*(/N))
  if (( ${#_nvm_newest} )); then
    # Sort by version number, take the highest.
    _nvm_pick=${${(On)_nvm_newest}[1]}
    [[ -d "$_nvm_pick/bin" ]] && PATH="$_nvm_pick/bin:$PATH"
  fi
  unset _nvm_newest _nvm_pick
fi

# `nvm` itself still needs the real script — load it on first invocation.
nvm() {
  unset -f nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# --- pyenv -------------------------------------------------------------------
# Installed via Homebrew but currently has no versions beyond `system`, so its
# shims would only add startup cost and an extra layer in front of python3.
# Uncomment once you actually install a pyenv-managed version.
#
# if command -v pyenv >/dev/null 2>&1; then
#   export PYENV_ROOT="$(pyenv root)"
#   eval "$(pyenv init - zsh)"
# fi

# --- opam (OCaml) ------------------------------------------------------------
[[ -r "$HOME/.opam/opam-init/init.zsh" ]] && \
  source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>&1

export PATH
