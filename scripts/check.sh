#!/bin/sh
# The job: start an INTERACTIVE zsh with this repo's setup (zsh/ as ZDOTDIR) and check
# that it loaded — Prezto itself, a bundled module, the custom module, and the custom
# prompt theme. Exits 0 when every check passes.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
export ZDOTDIR="$here/zsh"     # always this repo's setup
export TERM="${TERM:-xterm-256color}"

errfile=$(mktemp)
zsh -i -c '
  fail=0
  ok()   { print -r -- "ok   $1" }
  bad()  { print -r -- "FAIL $1"; fail=1 }
  print -r -- "qode zsh setup $QODE_ZSH_VERSION on prezto, zsh $ZSH_VERSION"
  (( $+functions[pmodload] ))           && ok "prezto loaded from $ZPREZTODIR" || bad "prezto not loaded"
  zstyle -t ":prezto:module:git" loaded && ok "bundled module: git"            || bad "git module not loaded"
  zstyle -t ":prezto:module:qode" loaded && ok "custom module: qode"           || bad "qode module not loaded"
  [[ "$(qode_hello)" == "hello from qode" ]] && ok "qode_hello works"         || bad "qode_hello output"
  zstyle -s ":prezto:module:prompt" theme theme
  [[ $theme == qode ]]                  && ok "prompt theme: $theme"           || bad "prompt theme is ${theme:-unset}"
  rendered=$(print -P -- "$PROMPT")
  [[ $rendered == *qode* ]]             && ok "prompt renders: $rendered"      || bad "prompt does not render: $rendered"
  exit $fail
' 2>"$errfile"
rc=$?
if [ -s "$errfile" ]; then
  echo "FAIL zsh wrote to stderr while loading:"; sed 's/^/  | /' "$errfile"; rc=1
fi
rm -f "$errfile"
[ $rc -eq 0 ] && echo "PASS" || echo "FAILED"
exit $rc
