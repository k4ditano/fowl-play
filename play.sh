#!/bin/sh
# Fowl Play in a window of its own.
#
#   ./play.sh            in a window (make it as big as you like: the picture
#                        grows a whole number of times, and stays sharp)
#   ./play.sh stop       closes it
#
# It needs a pleamar that knows `font file` and `delay` in its tones (0.4.14 or
# newer, https://github.com/k4ditano/pleamar), and any Wayland compositor.
# PLEAMAR=/path/to/pleamar uses that one instead of the one on the PATH.
here=$(dirname "$(readlink -f "$0")")
PATH="$PATH:$HOME/.local/bin"
pleamar=${PLEAMAR:-pleamar}
if ! command -v "$pleamar" > /dev/null 2>&1; then
    echo "pleamar is not installed: see https://github.com/k4ditano/pleamar" >&2
    exit 1
fi
case "$1" in
    stop) exec "$pleamar" --say fowl quit ;;
esac
cd "$here" || exit 1
# An older pleamar does not know what the scene asks for: it is said plainly.
if ! "$pleamar" --check fowl.plm > /dev/null 2>&1; then
    echo "this pleamar is too old for Fowl Play: update it (pleamar-update, or nix flake update)" >&2
    "$pleamar" --check fowl.plm 2>&1 | head -3 >&2
    exit 1
fi
exec "$pleamar" --no-hud --scene fowl.plm
