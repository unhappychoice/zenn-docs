#!/usr/bin/env bash
set -euo pipefail
THEME=$1
HEIGHT=${2:-720}
SLEEP=${3:-5}
PRESET=${4:-home_daily}
TEMPLATES=/home/owner/.ghq/github.com/unhappychoice/splashboard/src/templates
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" /home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide

SB_HOME=/tmp/sb-vhs/theme-$THEME
rm -rf "$SB_HOME"
mkdir -p "$SB_HOME"
cp "$TEMPLATES/$PRESET.toml" "$SB_HOME/home.dashboard.toml"
cat > "$SB_HOME/settings.toml" <<TOML
[theme]
preset = "$THEME"
TOML

cat > "$TAPES/theme-$THEME.tape" <<TAPE
Output "/tmp/sb-vhs-theme-$THEME.gif"
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

Type "clear && splashboard"
Enter
Sleep ${SLEEP}s
Screenshot "/tmp/sb-vhs-theme-$THEME.png"
TAPE

vhs "$TAPES/theme-$THEME.tape" 2>&1 | tail -1
if [[ -f "/tmp/sb-vhs-theme-$THEME.png" ]]; then
  mv "/tmp/sb-vhs-theme-$THEME.png" "/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide/theme-$THEME.png"
  echo "✓ theme-$THEME"
else
  echo "✗ theme-$THEME"
fi
