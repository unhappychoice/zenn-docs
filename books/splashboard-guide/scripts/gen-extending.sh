#!/usr/bin/env bash
set -euo pipefail
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
IMG=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide
TAPES="$ROOT/tapes/.generated"
NAME=demo-extending
mkdir -p "$TAPES" "$IMG"

SB=/tmp/sb-vhs/$NAME
rm -rf "$SB"; mkdir -p "$SB/store"
cp "$ROOT/tapes/demo-configs/$NAME.toml" "$SB/home.dashboard.toml"
cat > "$SB/settings.toml" <<TOML
[theme]
bg = "reset"
bg_subtle = "reset"
TOML

cat > "$SB/store/habit.json" <<'JSON'
{ "value": 0.7, "label": "habit · 7 / 10 日" }
JSON

cat > "$SB/store/signups.json" <<'JSON'
{ "values": [3, 5, 4, 7, 6, 8, 9, 12, 10, 11, 13, 15, 14, 18, 16, 19, 22, 20, 24, 27] }
JSON

cat > "$SB/store/reading.json" <<'JSON'
{
  "cells": [
    [0, 1, 0, 2, 3, 0, 0],
    [1, 1, 2, 0, 0, 4, 2],
    [0, 0, 1, 3, 2, 0, 1],
    [2, 1, 0, 0, 2, 3, 1]
  ],
  "col_labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
}
JSON

cat > "$TAPES/$NAME.tape" <<TAPE
Output "/tmp/sb-vhs-$NAME.gif"
Set Shell "bash"
Set FontSize 14
Set Width 1200
Set Height 600
Set TypingSpeed 0ms
Set Theme { "background": "#0e172a", "foreground": "#e1e4e8", "cursor": "#0e172a" }
Env SPLASHBOARD_HOME "$SB"
Env PS1 ""

Hide
Type 'cd /tmp'
Enter
Sleep 200ms
Show

Type "clear && splashboard --wait"
Enter
Sleep 4s
Screenshot "/tmp/sb-vhs-$NAME.png"
TAPE

vhs "$TAPES/$NAME.tape" 2>&1 | tail -1
if [[ -f "/tmp/sb-vhs-$NAME.png" ]]; then
  mv "/tmp/sb-vhs-$NAME.png" "$IMG/$NAME.png"
  echo "✓ $NAME"
else
  echo "✗ $NAME"
fi
