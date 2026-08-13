# ~/.zshrc — managed by github.com/willyhakim/dotfiles (stow package: zsh)
#
# Keep this file small. Real configuration lives in ~/.config/zsh/NN-*.zsh,
# sourced in numeric order at the bottom (00-path must run first — it sets the
# PATH de-duplication flag). Anything machine-specific or secret goes in
# ~/.zshrc.local, which is never tracked.

# --- oh-my-zsh ---------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Add wisely — each plugin costs shell startup time.
plugins=(
  git
  brew
  docker
  z
)

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# --- modular config ----------------------------------------------------------
for _zf in "$HOME"/.config/zsh/*.zsh(N); do
  source "$_zf"
done
unset _zf

# --- machine-local overrides (untracked: tokens, work-only config) -----------
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
