#!/usr/bin/env bash
set -euo pipefail
THEME=$1
HEIGHT=${2:-720}
SLEEP=${3:-5}
PRESET=${4:-home_daily}
TEMPLATES=/home/owner/.ghq/github.com/unhappychoice/splashboard/src/templates
ROOT=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/books/splashboard-guide
IMG=/home/owner/.ghq/github.com/unhappychoice/docs/Flow/Articles/zenn-docs/images/splashboard-guide
TAPES="$ROOT/tapes/.generated"
mkdir -p "$TAPES" "$IMG"

# Theme bg color map (matches src/theme/presets.rs)
case "$THEME" in
  ayu_mirage) BG="#1f2430" ;;
  catppuccin_frappe) BG="#303446" ;;
  catppuccin_latte) BG="#eff1f5" ;;
  catppuccin_macchiato) BG="#24273a" ;;
  catppuccin_mocha) BG="#1e1e2e" ;;
  default) BG="#0e172a" ;;
  dracula) BG="#282a36" ;;
  everforest_dark) BG="#2d353b" ;;
  github_dark) BG="#0d1117" ;;
  github_light) BG="#ffffff" ;;
  gruvbox_dark) BG="#282828" ;;
  gruvbox_light) BG="#fbf1c7" ;;
  kanagawa) BG="#1f1f28" ;;
  material_palenight) BG="#292d3e" ;;
  monokai) BG="#272822" ;;
  night_owl) BG="#011627" ;;
  nord) BG="#2e3440" ;;
  one_dark) BG="#282c34" ;;
  rose_pine) BG="#191724" ;;
  rose_pine_dawn) BG="#faf4ed" ;;
  rose_pine_moon) BG="#232136" ;;
  solarized_dark) BG="#002b36" ;;
  solarized_light) BG="#fdf6e3" ;;
  synthwave_84) BG="#2a2139" ;;
  tokyo_night) BG="#1a1b26" ;;
  tokyo_night_storm) BG="#24283b" ;;
  *) echo "unknown theme: $THEME"; exit 1 ;;
esac

SB_HOME=/tmp/sb-vhs/theme-$THEME
rm -rf "$SB_HOME"; mkdir -p "$SB_HOME"
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
Set Theme { "background": "$BG", "foreground": "#e1e4e8" }
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
