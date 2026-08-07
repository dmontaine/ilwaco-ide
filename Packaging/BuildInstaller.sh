#!/usr/bin/env bash
#
# BuildInstaller.sh — one-command build of the Ilwaco installer.
#
# The Linux counterpart of Astoria's BuildInstaller.ps1, and it works the same
# way: stage a clean release tree, then package that tree into a single file.
# The two steps travel together — repackaging alone would just rewrap whatever
# was already staged, not the IDE you just built.
#
#   ../ilwaco-ide-release/     the staged tree     (StageRelease.sh)
#   ../ilwaco-ide-installer/   one file, nothing else
#
# WHY A .run AND NOT A SELF-EXTRACTING ZIP
# ----------------------------------------
# A self-extracting zip is the Windows idiom; unzip is not guaranteed present on
# a minimal Linux install, whereas tar and gzip effectively are. So the default
# output is a self-extracting shell archive — a shell script with a tar.gz
# appended, the makeself pattern. It needs nothing installed to build or to run,
# which is why it is what this script produces today.
#
# The better single-file answer on Linux, and the format already chosen for the
# primary download, is an AppImage: one file, chmod +x, run, with no extraction
# step at all. This script emits that instead when `appimagetool` is available,
# since the AppDir is already built (Packaging/AppRun, build-appdir.sh). It is
# not yet on this machine, and fetching it is a download the owner has to
# approve — see Documentation/Packaging.md.
#
# Usage:  Packaging/BuildInstaller.sh [--appimage|--run]
#         default: appimage if appimagetool is on PATH, otherwise run
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE="${ILWACO_RELEASE_DIR:-$(dirname "$REPO")/ilwaco-ide-release}"
INSTALLER_DIR="${ILWACO_INSTALLER_DIR:-$(dirname "$REPO")/ilwaco-ide-installer}"

die() { echo "BuildInstaller.sh: error: $*" >&2; exit 1; }

case "${INSTALLER_DIR##*/}" in
	ilwaco-ide-installer) ;;
	*) die "refusing to continue: '$INSTALLER_DIR' does not end with 'ilwaco-ide-installer'" ;;
esac

FORMAT="${1:-auto}"
case "$FORMAT" in
	--appimage) FORMAT=appimage ;;
	--run)      FORMAT=run ;;
	auto)       command -v appimagetool >/dev/null && FORMAT=appimage || FORMAT=run ;;
	*)          die "unknown option '$FORMAT' (use --appimage or --run)" ;;
esac

VERSION="$(awk -F'"' '/#define VER_MAJOR/{a=$2} /#define VER_MINOR/{b=$2} /#define VER_PATCH/{c=$2} END{print a"."b"."c}' "$REPO/src/ilwaco.bas")"
[ -n "$VERSION" ] && [ "$VERSION" != ".." ] || die "could not read the version from src/ilwaco.bas"

echo "=== Step 1/2: staging release ==="
"$REPO/Packaging/StageRelease.sh" "$RELEASE"

echo ""
echo "=== Step 2/2: building installer ($FORMAT) ==="
# Only ever holds the one artefact, so it is cleared rather than added to —
# a stale installer beside a fresh one is how the wrong file gets distributed.
rm -rf "$INSTALLER_DIR"
mkdir -p "$INSTALLER_DIR"

if [ "$FORMAT" = appimage ]; then
	command -v appimagetool >/dev/null || die "appimagetool not found on PATH"
	APPDIR="$REPO/build/Ilwaco.AppDir"
	"$REPO/Packaging/build-appdir.sh" "$RELEASE" "$APPDIR" >/dev/null
	ARCH=x86_64 appimagetool "$APPDIR" "$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.AppImage" \
		|| die "appimagetool failed"
	OUT="$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.AppImage"
else
	OUT="$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.run"
	# Header first, then the payload appended verbatim. The header locates the
	# payload by searching for its own marker, so no line-count arithmetic has
	# to stay in sync with edits to the header.
	sed -e "s/@VERSION@/$VERSION/g" "$REPO/Packaging/installer-header.sh" > "$OUT"
	tar -czf - -C "$RELEASE" . >> "$OUT"
	chmod +x "$OUT"
fi

echo ""
echo "BuildInstaller.sh: $OUT"
echo "BuildInstaller.sh: $(du -h "$OUT" | cut -f1)"
