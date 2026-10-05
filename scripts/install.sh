#!/bin/sh
# Install Prezto the way its README teaches — `git clone --recursive` — pinned to one
# commit, into $ZPREZTODIR (default ~/.zprezto). Prezto's own runcoms are NOT linked in:
# this repo's zsh/ directory is the ZDOTDIR, with its own .zshrc and .zpreztorc.
# Used by the Dockerfile and by fleet.conf's INSTALL_CMD.
set -eu
PREZTO_REF="${PREZTO_REF:-cff2d01871425b1b80710f8ec6a475c5a53145b4}"
ZPREZTODIR="${ZPREZTODIR:-$HOME/.zprezto}"

if [ ! -d "$ZPREZTODIR/.git" ]; then
  git clone -q https://github.com/sorin-ionescu/prezto.git "$ZPREZTODIR"
fi
git -C "$ZPREZTODIR" -c advice.detachedHead=false checkout -q "$PREZTO_REF"
git -C "$ZPREZTODIR" submodule update -q --init --recursive --depth 1
echo "prezto at $(git -C "$ZPREZTODIR" rev-parse --short HEAD) in $ZPREZTODIR"
