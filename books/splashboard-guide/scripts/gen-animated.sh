#!/usr/bin/env bash
set -euo pipefail
NAME=$1
HEIGHT=${2:-400}
DURATION=${3:-3}
REPO="${4:-${SPLASHBOARD_REPO:-$HOME/.ghq/github.com/unhappychoice/splashboard}}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" /home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide

SB_HOME=/tmp/sb-vhs/$NAME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME"
cp "$ROOT/tapes/demo-configs/$NAME.toml" "$SB_HOME/project.dashboard.toml"

cat > "$TAPES/$NAME.tape" <<TAPE
Output "/tmp/sb-vhs-$NAME.gif"
Set Shell "bash"
Set FontSize 14
Set Width 1500
Set Height $HEIGHT
Set TypingSpeed 0ms
Env SPLASHBOARD_HOME "$SB_HOME"
Env PS1 ""

Hide
Type 'cd $REPO'
Enter
Sleep 200ms
Show

Type "clear && splashboard watch"
Enter
Sleep ${DURATION}s
Type "q"
TAPE

vhs "$TAPES/$NAME.tape" 2>&1 | tail -1
if [[ -f "/tmp/sb-vhs-$NAME.gif" ]]; then
  mv "/tmp/sb-vhs-$NAME.gif" "/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide/$NAME.gif"
  echo "✓ $NAME (gif)"
else
  echo "✗ $NAME"
fi
