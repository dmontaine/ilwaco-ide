#!/bin/sh
#
# Ilwaco IDE @VERSION@ — installer
#
# This file is a shell script with a compressed archive appended to it. Running
# it unpacks Ilwaco into a directory of your choosing and adds a menu entry.
# Nothing is installed system-wide and no root access is needed; uninstalling is
# deleting the directory.
#
# This header is a template: Packaging/BuildInstaller.sh substitutes the version
# and appends the payload. Keep it POSIX sh — it runs on whatever the user has.
#
set -eu

VERSION="@VERSION@"
DEST="$HOME/Ilwaco"
FORCE=0

usage() {
	cat <<EOF
Ilwaco IDE $VERSION installer

  --dir <path>   where to install            (default: $HOME/Ilwaco)
  --force        reinstall over an existing installation
  --help         show this message

Installing over an existing copy keeps your Settings, Projects, Examples,
Documentation, Templates and AddIns, and replaces everything else.
EOF
}

while [ $# -gt 0 ]; do
	case "$1" in
		--dir)   [ $# -ge 2 ] || { echo "installer: --dir needs a path" >&2; exit 1; }
		         DEST="$2"; shift 2 ;;
		--force) FORCE=1; shift ;;
		--help|-h) usage; exit 0 ;;
		*)       echo "installer: unknown option '$1' (try --help)" >&2; exit 1 ;;
	esac
done

for tool in tar gzip; do
	command -v "$tool" >/dev/null 2>&1 || { echo "installer: '$tool' is required but not installed" >&2; exit 1; }
done

UPGRADE=0
if [ -e "$DEST" ]; then
	[ -d "$DEST" ] || { echo "installer: $DEST exists and is not a directory" >&2; exit 1; }
	if [ -x "$DEST/ilwaco" ] || [ "$FORCE" = 1 ]; then
		UPGRADE=1
	elif [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
		echo "installer: $DEST already exists and is not an Ilwaco installation." >&2
		echo "installer: choose another --dir, or pass --force to install anyway." >&2
		exit 1
	fi
fi

mkdir -p "$DEST" || { echo "installer: cannot create $DEST" >&2; exit 1; }
[ -w "$DEST" ] || { echo "installer: $DEST is not writable" >&2; exit 1; }

# The payload starts on the line after the marker. Locating it by search rather
# than by a baked-in line number means edits to this header cannot corrupt it.
PAYLOAD_LINE=$(awk '/^__ILWACO_PAYLOAD__$/ { print NR + 1; exit }' "$0")
[ -n "$PAYLOAD_LINE" ] || { echo "installer: corrupt installer - no payload marker" >&2; exit 1; }

if [ "$UPGRADE" = 1 ]; then
	echo "Upgrading Ilwaco IDE $VERSION in $DEST (keeping your settings and work)..."
	# Everything the user owns is excluded, so an upgrade never overwrites work.
	tail -n +"$PAYLOAD_LINE" "$0" | tar -xzf - -C "$DEST" \
		--exclude='./Settings' --exclude='./Projects' --exclude='./Examples' \
		--exclude='./Documentation' --exclude='./Templates' --exclude='./AddIns'
else
	echo "Installing Ilwaco IDE $VERSION into $DEST..."
	tail -n +"$PAYLOAD_LINE" "$0" | tar -xzf - -C "$DEST"
fi

chmod +x "$DEST/ilwaco" "$DEST/ilwaco.sh" 2>/dev/null || true
[ -x "$DEST/ilwaco.sh" ] || { echo "installer: extraction failed - no launcher in $DEST" >&2; exit 1; }

# Menu entry. Per-user, so no root is needed; Exec points at the launcher rather
# than the binary because the launcher is what sets up the bundled compiler.
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
if mkdir -p "$APPS" 2>/dev/null; then
	cat > "$APPS/ilwaco.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Ilwaco IDE
Comment=FreeBASIC IDE
Exec=$DEST/ilwaco.sh
Icon=$DEST/Resources/Logo.png
Terminal=false
Categories=Development;IDE;
EOF
	command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
fi

echo ""
echo "Ilwaco IDE $VERSION is installed."
echo "  Start it from your applications menu, or run: $DEST/ilwaco.sh"
echo "  Your projects live in $DEST/Projects"
echo "  To uninstall, delete $DEST"
exit 0

__ILWACO_PAYLOAD__
