# Aliases. Ported from the retired ~/.bashrc and ~/.bash_profile — see
# legacy/NOTES.md in the dotfiles repo for what was dropped and why.

# --- listing (from .bash_profile) --------------------------------------------
alias l='ls -G'
alias ll='ls -lahG'
alias la='ls -lAhG'
alias ..='cd ..'
alias ...='cd ../..'

# --- docker (from .bashrc; `docker-compose` v1 is EOL, v2 is a subcommand) ----
alias dc='docker compose'
alias dm='docker-machine'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# --- python / django (from .bashrc) ------------------------------------------
alias pym='python3 manage.py'
alias mkenv='python3 -m venv env'
alias startenv='source env/bin/activate && which python3'
alias stopenv='deactivate'

# --- git ----------------------------------------------------------------------
# oh-my-zsh's git plugin supplies the common ones (gst, gco, gp, …).
# These are the additions worth keeping.
alias gs='git status -sb'
alias gl='git graph'          # the alias defined in .gitconfig
alias gaa='git add -A'

# --- dotfiles ------------------------------------------------------------------
alias dotfiles='cd ~/dotfiles'
alias zshconfig='$EDITOR ~/.config/zsh'
alias reload='exec zsh'
