#!/usr/bin/env bash
#
# bootstrap.sh — set up this machine from the dotfiles repo.
#
# Idempotent: safe to run repeatedly. Any real file that a stow package would
# claim is moved to ~/.dotfiles-backup/<timestamp>/ first, never deleted.
#
#   ./bootstrap.sh                 # everything
#   ./bootstrap.sh --no-brew       # skip `brew bundle` (slow)
#   ./bootstrap.sh --dry-run       # show what would happen, change nothing
#   ./bootstrap.sh zsh git         # only these packages

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Packages stowed by default. Order is irrelevant; each is independent.
DEFAULT_PACKAGES=(zsh git vim psql mycli conda claude vscode cursor)

DO_BREW=1
DRY_RUN=0
PACKAGES=()

BOLD=$'\033[1m'; GREEN=$'\033[0;32m'; YEL=$'\033[0;33m'; RED=$'\033[0;31m'; NC=$'\033[0m'
info()  { printf '%s==>%s %s\n' "$GREEN" "$NC" "$*"; }
warn()  { printf '%s==>%s %s\n' "$YEL" "$NC" "$*"; }
err()   { printf '%s==>%s %s\n' "$RED" "$NC" "$*" >&2; }
step()  { printf '\n%s%s%s\n' "$BOLD" "$*" "$NC"; }

while (( $# )); do
  case "$1" in
    --no-brew) DO_BREW=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) err "unknown flag: $1"; exit 2 ;;
    *)  PACKAGES+=("$1") ;;
  esac
  shift
done
(( ${#PACKAGES[@]} )) || PACKAGES=("${DEFAULT_PACKAGES[@]}")

run() {
  if (( DRY_RUN )); then
    printf '  [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# ---------------------------------------------------------------------------
step "1. Prerequisites"
# ---------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found."
  if (( DRY_RUN )); then
    printf '  [dry-run] install Homebrew\n'
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/brew/HEAD/install.sh)"
    # Pick up brew on this shell for the rest of the run.
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [[ -x "$p" ]] && eval "$("$p" shellenv)" && break
    done
  fi
fi

for tool in stow gh; do
  if command -v "$tool" >/dev/null 2>&1; then
    info "$tool already installed"
  else
    info "installing $tool"
    run brew install "$tool"
  fi
done

# ---------------------------------------------------------------------------
step "2. Homebrew bundle"
# ---------------------------------------------------------------------------
if (( DO_BREW )); then
  info "brew bundle (this takes a while — rerun with --no-brew to skip)"
  run brew bundle --file="${DOTFILES}/Brewfile"
else
  warn "skipped (--no-brew)"
fi

# ---------------------------------------------------------------------------
step "3. Back up conflicting files"
# ---------------------------------------------------------------------------
# `stow` refuses to overwrite a real file. Find everything a package would
# claim that already exists as a non-symlink, and move it aside.
conflicts=0
for pkg in "${PACKAGES[@]}"; do
  pkgdir="${DOTFILES}/${pkg}"
  [[ -d "$pkgdir" ]] || { warn "no such package: $pkg — skipping"; continue; }

  while IFS= read -r -d '' src; do
    rel="${src#"$pkgdir"/}"
    dst="${TARGET}/${rel}"
    # A symlink already pointing into the repo is fine; a real file is not.
    if [[ -e "$dst" && ! -L "$dst" ]]; then
      info "backing up ${dst/#$HOME/\~}"
      run mkdir -p "${BACKUP_DIR}/$(dirname "$rel")"
      run mv "$dst" "${BACKUP_DIR}/${rel}"
      conflicts=$((conflicts + 1))
    fi
  done < <(find "$pkgdir" -type f -print0)
done
(( conflicts )) && info "backed up ${conflicts} file(s) to ${BACKUP_DIR/#$HOME/\~}" \
                || info "no conflicting files"

# ---------------------------------------------------------------------------
step "4. Stow packages"
# ---------------------------------------------------------------------------
if (( DRY_RUN && conflicts )); then
  warn "In --dry-run the backups above did not actually happen, so stow will"
  warn "report conflicts for those ${conflicts} file(s). That is expected — a real"
  warn "run moves them aside first and the conflicts disappear."
fi
for pkg in "${PACKAGES[@]}"; do
  [[ -d "${DOTFILES}/${pkg}" ]] || continue
  info "stow ${pkg}"
  if (( DRY_RUN )); then
    stow --no --verbose=1 --dir="$DOTFILES" --target="$TARGET" "$pkg" 2>&1 | sed 's/^/  /'
  else
    stow --restow --dir="$DOTFILES" --target="$TARGET" "$pkg"
  fi
done

# ---------------------------------------------------------------------------
step "5. Seed local override files"
# ---------------------------------------------------------------------------
# These hold secrets and machine-specific settings, and are never tracked.
seed() {
  local template="${DOTFILES}/templates/$1" dest="${TARGET}/$2"
  if [[ -e "$dest" ]]; then
    info "${dest/#$HOME/\~} already exists — left alone"
  else
    info "creating ${dest/#$HOME/\~} from template"
    run cp "$template" "$dest"
  fi
}
seed zshrc.local.example    .zshrc.local
seed gitconfig.local.example .gitconfig.local

# ---------------------------------------------------------------------------
step "6. Install git hooks"
# ---------------------------------------------------------------------------
if [[ -d "${DOTFILES}/.git" ]]; then
  info "installing pre-commit secret scanner"
  run cp "${DOTFILES}/hooks/pre-commit" "${DOTFILES}/.git/hooks/pre-commit"
  run chmod +x "${DOTFILES}/.git/hooks/pre-commit"
else
  warn "not a git checkout — skipping hook install"
fi

# ---------------------------------------------------------------------------
step "Done"
# ---------------------------------------------------------------------------
cat <<EOF

${GREEN}Bootstrap complete.${NC}

Next steps:

  1. ${BOLD}Put your tokens in ~/.zshrc.local${NC} — never in a tracked file.
     The old ~/.npmrc and ~/.bash_profile both held plaintext npm tokens;
     if this is the same machine, rotate them at npmjs.com first.

  2. Restore Cursor extensions (VS Code's came from brew bundle):
       xargs -n1 cursor --install-extension < ${DOTFILES}/editors/cursor-extensions.txt

  3. Install oh-my-zsh if this is a fresh machine:
       sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
     (it will offer to replace ~/.zshrc — decline, or restore the symlink after)

  4. Open a new shell:  exec zsh

EOF
