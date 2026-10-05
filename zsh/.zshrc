# .zshrc — the versioned zsh setup this repo ships, on Prezto. This directory is the
# ZDOTDIR; Prezto itself lives in $ZPREZTODIR and reads .zpreztorc from here.
QODE_ZSH_VERSION="$(<${${(%):-%x}:A:h:h}/VERSION)"

source "${ZPREZTODIR:-$HOME/.zprezto}/init.zsh"

# --- user configuration -----------------------------------------------------------
export EDITOR="${EDITOR:-vi}"
