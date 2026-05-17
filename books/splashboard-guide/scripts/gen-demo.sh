#!/usr/bin/env bash
set -euo pipefail
NAME=$1
HEIGHT=${2:-400}
SLEEP=${3:-3}
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
CONF="$ROOT/tapes/demo-configs/$NAME.toml"
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES"

SB_HOME=/tmp/sb-vhs/$NAME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME"
cp "$CONF" "$SB_HOME/home.dashboard.toml"

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
Type 'cd /tmp'
Enter
Sleep 200ms
Show

Type "clear && splashboard --wait"
Enter
Sleep ${SLEEP}s
Screenshot "/tmp/sb-vhs-$NAME.png"
TAPE

vhs "$TAPES/$NAME.tape" 2>&1 | tail -1
if [[ -f "/tmp/sb-vhs-$NAME.png" ]]; then
  mv "/tmp/sb-vhs-$NAME.png" "/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide/$NAME.png"
  echo "✓ $NAME"
else
  echo "✗ $NAME"
fi
