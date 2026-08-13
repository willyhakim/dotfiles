# PATH construction. Loaded first (00-) so the de-duplication flag below is in
# effect before any later file touches PATH.
#
# Every entry is guarded, so a missing directory is a no-op rather than a stale
# PATH component that slows down every lookup.
#
# Deliberately NOT carried over from the old ~/.bash_profile:
#   ~/bin                                        — does not exist
#   ~/.nvm/versions/node/v8.0.0/bin              — nvm now manages this (v24)
#   /Applications/Postgres.app/.../9.6/bin       — superseded; Postgres.app is
#                                                  already on PATH via
#                                                  /etc/paths.d/postgresapp
#   anaconda3/bin                                — was commented out for years
#   a full literal PATH= reset, twice            — clobbered the system PATH

# `typeset -U` marks $path as a unique array — a persistent property, so every
# later addition (here or in 10-env.zsh) is de-duplicated automatically.
typeset -U path PATH

path_prepend() { [[ -d "$1" ]] && PATH="$1:${PATH}"; }
path_append()  { [[ -d "$1" ]] && PATH="${PATH}:$1"; }

path_prepend "/usr/local/sbin"
path_prepend "/usr/local/opt/openssl/bin"
path_prepend "/usr/local/opt/icu4c/bin"

# Language toolchains
path_append  "$HOME/go/bin"                    # GOPATH/bin
path_append  "$HOME/Library/Python/3.9/bin"    # pipx shims

# User binaries win over everything above.
path_prepend "$HOME/.local/bin"

export PATH
