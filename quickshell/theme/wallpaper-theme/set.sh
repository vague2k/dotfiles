#!/usr/bin/env sh
# Generate a theme from a wallpaper image with matugen, then write every
# downstream config the shell owns. No Python: all file output is either a
# matugen template or a jq/printf step below.
#
# Usage: set.sh <image> [scheme]
#   scheme defaults to m3-content and maps to matugen's scheme-* types.
set -eu

img=${1:-}
scheme=${2:-m3-content}

[ -n "$img" ] || { echo "set.sh: usage: set.sh <image> [scheme]" >&2; exit 1; }
[ -f "$img" ] || { echo "set.sh: no such image: $img" >&2; exit 1; }

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
state="$HOME/.local/state/quickshell"
palette="$state/wallpaper-theme.json"

command -v matugen >/dev/null 2>&1 || { echo "set.sh: matugen is not installed" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "set.sh: jq is not installed" >&2; exit 1; }

case "$scheme" in
  m3-*) type="scheme-${scheme#m3-}" ;;
  *) type="scheme-content" ;;
esac

mkdir -p "$state" \
  "$HOME/.config/ghostty/themes" \
  "$HOME/.config/tmux/themes" \
  "$HOME/.config/hypr" \
  "$HOME/.config/gtk-3.0" \
  "$HOME/.config/gtk-4.0" \
  "$HOME/.config/qt5ct/colors" \
  "$HOME/.config/qt6ct/colors"

# Clean up artifacts from the old "noctalia" naming.
rm -f "$HOME/.config/hypr/noctalia.lua" \
      "$HOME/.config/ghostty/themes/noctalia" \
      "$HOME/.config/tmux/themes/noctalia.conf" \
      "$HOME/.config/gtk-3.0/noctalia.css" \
      "$HOME/.config/gtk-4.0/noctalia.css" \
      "$HOME/.config/qt5ct/colors/noctalia.conf" \
      "$HOME/.config/qt6ct/colors/noctalia.conf"

matugen image "$img" -c "$dir/matugen/config.toml" \
  --mode dark --type "$type" --prefer saturation -q

[ -f "$palette" ] || { echo "set.sh: matugen did not produce a palette" >&2; exit 1; }
[ -n "$(jq -r '.accentPrimary // empty' "$palette")" ] || { echo "set.sh: incomplete palette" >&2; exit 1; }

# GTK: import the generated stylesheet (idempotent, migrates the old name).
for version in gtk-3.0 gtk-4.0; do
  gtk_css="$HOME/.config/$version/gtk.css"
  touch "$gtk_css"
  sed -i '/@import url("noctalia.css");/d' "$gtk_css"
  grep -qs 'theme.css' "$gtk_css" || printf '@import url("theme.css");\n' >> "$gtk_css"
done

# Hyprland borders: a require-able drop-in (loaded by hyprland.lua at startup)
# plus a live update for the running instance.
primary=$(jq -r '.accentPrimary' "$palette"); primary=${primary#\#}
cyan=$(jq -r '.accentCyan' "$palette"); cyan=${cyan#\#}
inactive=$(jq -r '.bgBorder' "$palette"); inactive=${inactive#\#}
printf 'hl.config({ general = { col = {\n  active_border = { colors = { "rgba(%see)", "rgba(%see)" }, angle = 45 },\n  inactive_border = "rgba(%see)",\n} } })\n' \
  "$primary" "$cyan" "$inactive" > "$HOME/.config/hypr/theme.lua"
if command -v hyprctl >/dev/null 2>&1; then
  # The lua (non-legacy) parser ignores `hyprctl keyword`; eval applies it live.
  hyprctl eval "$(cat "$HOME/.config/hypr/theme.lua")" >/dev/null 2>&1 || true
fi

# System color scheme.
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true
fi

# Reload tmux if it is running.
if command -v tmux >/dev/null 2>&1; then
  tmux source-file "$HOME/.config/tmux/themes/theme.conf" >/dev/null 2>&1 || true
fi

# Persist which wallpaper/scheme produced the palette.
jq -n --arg wallpaper "$img" --arg scheme "$scheme" \
  '{wallpaper:$wallpaper, scheme:$scheme}' > "$state/wallpaper.json"
