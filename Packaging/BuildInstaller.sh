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
# WHAT SHIPS, AND TO WHOM (owner, 2026-08-07)
# -------------------------------------------
# Two tiers, because the deciding question is whether the user has root:
#
#   .deb / .rpm     has root, own machine. Double-click install, applications
#                   menu entry, apt/dnf upgrades. Root installs a READ-ONLY
#                   payload to /opt; every user's own settings and projects
#                   still live in ~/ilwaco-ide (Packaging/BuildPackages.sh).
#   .tar.gz         NO root — a school or work managed machine. Wraps the
#                   AppImage, which runs from anywhere and touches nothing
#                   outside $HOME. Wrapped in tar rather than offered bare
#                   because tar restores the executable bit and a browser
#                   download does not (Documentation/Packaging.md).
#
# Usage:  Packaging/BuildInstaller.sh [--all|--appimage|--tar|--deb|--rpm|--run]
#         default: --all  (.tar.gz-wrapped AppImage, .deb and .rpm)
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

DO_APPIMAGE=0 DO_TAR=0 DO_DEB=0 DO_RPM=0 DO_RUN=0
case "${1:---all}" in
	--all)      DO_TAR=1; DO_DEB=1; DO_RPM=1 ;;
	--appimage) DO_APPIMAGE=1 ;;
	--tar)      DO_TAR=1 ;;
	--deb)      DO_DEB=1 ;;
	--rpm)      DO_RPM=1 ;;
	--run)      DO_RUN=1 ;;
	*)          die "unknown option '$1' (use --all, --appimage, --tar, --deb, --rpm or --run)" ;;
esac
# The .tar.gz wraps an AppImage, so asking for one asks for the other.
[ "$DO_TAR" = 1 ] && DO_APPIMAGE=1

VERSION="$(awk -F'"' '/#define VER_MAJOR/{a=$2} /#define VER_MINOR/{b=$2} /#define VER_PATCH/{c=$2} END{print a"."b"."c}' "$REPO/src/ilwaco.bas")"
[ -n "$VERSION" ] && [ "$VERSION" != ".." ] || die "could not read the version from src/ilwaco.bas"

echo "=== Step 1/2: staging release ==="
"$REPO/Packaging/StageRelease.sh" "$RELEASE"

echo ""
echo "=== Step 2/2: building installers ==="
# Cleared rather than added to — a stale installer beside a fresh one is how the
# wrong file gets distributed.
rm -rf "$INSTALLER_DIR"
mkdir -p "$INSTALLER_DIR"

APPIMAGE="$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.AppImage"

if [ "$DO_APPIMAGE" = 1 ]; then
	command -v appimagetool >/dev/null || die "appimagetool not found on PATH"
	APPDIR="$REPO/build/Ilwaco.AppDir"
	"$REPO/Packaging/build-appdir.sh" "$RELEASE" "$APPDIR" >/dev/null
	ARCH=x86_64 appimagetool "$APPDIR" "$APPIMAGE" || die "appimagetool failed"
fi

if [ "$DO_TAR" = 1 ]; then
	# The no-root download. tar carries the mode bits, so what comes out of the
	# archive is already executable — which a browser download never is, and
	# which no self-extracting format can fix either (the self-extractor would
	# need the executable bit itself).
	TARBALL="$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.tar.gz"
	chmod +x "$APPIMAGE"
	tar -czf "$TARBALL" -C "$INSTALLER_DIR" --owner=0 --group=0 \
		"$(basename "$APPIMAGE")" || die "tar failed"
	# The AppImage itself is not a separate download: shipping both invites a
	# beginner to pick the one that dead-ends on the executable bit.
	rm -f "$APPIMAGE"
fi

if [ "$DO_DEB" = 1 ] || [ "$DO_RPM" = 1 ]; then
	if   [ "$DO_DEB" = 1 ] && [ "$DO_RPM" = 1 ]; then PKGARG=--both
	elif [ "$DO_DEB" = 1 ]; then PKGARG=--deb
	else PKGARG=--rpm; fi
	"$REPO/Packaging/BuildPackages.sh" "$PKGARG" "$RELEASE"
fi

if [ "$DO_RUN" = 1 ]; then
	OUT="$INSTALLER_DIR/Ilwaco-IDE-$VERSION-x86_64.run"
	# Header first, then the payload appended verbatim. The header locates the
	# payload by searching for its own marker, so no line-count arithmetic has
	# to stay in sync with edits to the header.
	sed -e "s/@VERSION@/$VERSION/g" "$REPO/Packaging/installer-header.sh" > "$OUT"
	tar -czf - -C "$RELEASE" . >> "$OUT"
	chmod +x "$OUT"
fi

echo ""
echo "BuildInstaller.sh: artefacts in $INSTALLER_DIR"
ls -lh "$INSTALLER_DIR" | tail -n +2
