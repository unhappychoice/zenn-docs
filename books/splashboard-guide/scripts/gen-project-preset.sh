#!/usr/bin/env bash
set -euo pipefail
NAME=$1
HEIGHT=${2:-720}
SLEEP=${3:-5}
REPO=${4:-/home/owner/.ghq/github.com/unhappychoice/splashboard}
TEMPLATES=/home/owner/.ghq/github.com/unhappychoice/splashboard/src/templates
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
IMG=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" "$IMG"

SB_HOME=/tmp/sb-vhs/$NAME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME"
cp "$TEMPLATES/$NAME.toml" "$SB_HOME/project.dashboard.toml"
cat > "$SB_HOME/settings.toml" <<TOML
[theme]
bg = "reset"
bg_subtle = "reset"
TOML

cat > "$TAPES/$NAME.tape" <<TAPE
Output "/tmp/sb-vhs-$NAME.gif"
Set Shell "bash"
Set FontSize 14
Set Width 1500
Set Height $HEIGHT
Set TypingSpeed 0ms
Set Theme { "background": "#0e172a", "foreground": "#e1e4e8", "cursor": "#0e172a" }
Env SPLASHBOARD_HOME "$SB_HOME"
Env PS1 ""

Hide
Type 'cd $REPO'
Enter
Sleep 200ms
Show

Type "clear && splashboard"
Enter
Sleep ${SLEEP}s
Screenshot "/tmp/sb-vhs-$NAME.png"
TAPE

vhs "$TAPES/$NAME.tape" 2>&1 | tail -1
if [[ -f "/tmp/sb-vhs-$NAME.png" ]]; then
  mv "/tmp/sb-vhs-$NAME.png" "$IMG/$NAME.png"
  echo "✓ $NAME"
else
  echo "✗ $NAME (no png)"
fi
