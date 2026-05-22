#!/usr/bin/env bash
set -euo pipefail
THEME=$1
HEIGHT=${2:-720}
SLEEP=${3:-5}
PRESET=${4:-home_daily}
TEMPLATES="${SPLASHBOARD_REPO:-$HOME/.ghq/github.com/unhappychoice/splashboard}/src/templates"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG="$ROOT/../../images/splashboard-guide"
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" "$IMG"

# Source bg from src/theme/presets.rs by default. For 3 themes (dracula,
# nord, monokai) the rendered splash inside is 1-2 RGB units off from
# what vhs paints for that same hex outside the splash (vhs handles
# "explicit Rgb bg" cells slightly differently from Color::Reset cells).
# Pre-compensate by giving vhs the actual rendered inside value so the
# outside matches the inside.
case "$THEME" in
  tokyo_night) BG="#1a1b26" ;;
  catppuccin_mocha) BG="#1e1e2e" ;;
  dracula) BG="#272a35" ;;  # source #282a36, rendered #272a35
  nord) BG="#2c333f" ;;     # source #2e3440, rendered #2c333f
  gruvbox_dark) BG="#282828" ;;
  monokai) BG="#27281D" ;;  # source #272822, rendered #27281d
  *) echo "unknown theme: $THEME"; exit 1 ;;
esac

SB_HOME=/tmp/sb-vhs/theme-$THEME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME"
cp "$TEMPLATES/$PRESET.toml" "$SB_HOME/home.dashboard.toml"
cat > "$SB_HOME/settings.toml" <<TOML
[theme]
preset = "$THEME"
bg = "reset"
bg_subtle = "reset"
TOML

cat > "$TAPES/theme-$THEME.tape" <<TAPE
Output "/tmp/sb-vhs-theme-$THEME.gif"
Set Shell "bash"
Set FontSize 14
Set Width 1500
Set Height $HEIGHT
Set TypingSpeed 0ms
Set Theme { "background": "$BG", "foreground": "#e1e4e8", "cursor": "$BG" }
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
  mv "/tmp/sb-vhs-theme-$THEME.png" "$IMG/theme-$THEME.png"
  echo "✓ theme-$THEME"
else
  echo "✗ theme-$THEME"
fi
