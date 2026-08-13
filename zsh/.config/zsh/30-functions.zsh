# Small shell functions. Anything longer than a screen belongs in ~/.local/bin
# as a real script instead.

# mkcd — make a directory and step into it.
mkcd() {
  [[ -z "$1" ]] && { print -u2 "usage: mkcd <dir>"; return 2; }
  mkdir -p -- "$1" && cd -- "$1"
}

# extract — unpack whatever archive you point it at.
extract() {
  [[ -f "$1" ]] || { print -u2 "extract: '$1' is not a file"; return 2; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf   "$1" ;;
    *.tar.gz|*.tgz)   tar xzf   "$1" ;;
    *.tar.xz)         tar xJf   "$1" ;;
    *.tar)            tar xf    "$1" ;;
    *.bz2)            bunzip2   "$1" ;;
    *.gz)             gunzip    "$1" ;;
    *.zip)            unzip     "$1" ;;
    *.7z)             7z x      "$1" ;;
    *)                print -u2 "extract: unknown archive type '$1'"; return 1 ;;
  esac
}

# serve — static HTTP server in the current directory.
serve() { python3 -m http.server "${1:-8000}"; }

# ports — what is listening, and who owns it.
ports() { lsof -nP -iTCP -sTCP:LISTEN; }

# dotfiles-sync — commit and push whatever changed in the dotfiles repo.
dotfiles-sync() {
  local repo="$HOME/dotfiles"
  [[ -d "$repo/.git" ]] || { print -u2 "no dotfiles repo at $repo"; return 1; }
  git -C "$repo" add -A
  git -C "$repo" diff --cached --quiet && { print "dotfiles: nothing to sync"; return 0; }
  git -C "$repo" commit -m "${1:-Sync dotfiles}" && git -C "$repo" push
}
