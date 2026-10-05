# qode — the template's own Prezto module (zsh/modules/qode). Prezto adds ./functions to
# fpath and autoloads it, then sources this file.

# mkcd DIR — make a directory and cd into it
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

alias ll='ls -lah'
