#!/usr/bin/env bash
set -euo pipefail
NAME=$1
HEIGHT=${2:-200}
SLEEP=${3:-3}
WIDTH=${4:-800}
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
IMG=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide
CONF="$ROOT/tapes/demo-configs/$NAME.toml"
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" "$IMG"

SB_HOME=/tmp/sb-vhs/$NAME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME/store"
cp "$CONF" "$SB_HOME/home.dashboard.toml"
# Pre-populate store file
cat > "$SB_HOME/store/habit.json" <<'JSON'
{ "value": 0.6, "label": "habit · 6 / 10 日" }
JSON

cat > "$TAPES/$NAME.tape" <<TAPE
Output "/tmp/sb-vhs-$NAME.gif"
Set Shell "bash"
Set FontSize 14
Set Width $WIDTH
Set Height $HEIGHT
Set TypingSpeed 0ms
Set Theme { "background": "#0e172a", "foreground": "#e1e4e8" }
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
  mv "/tmp/sb-vhs-$NAME.png" "$IMG/$NAME.png"
  echo "✓ $NAME"
else
  echo "✗ $NAME"
fi
