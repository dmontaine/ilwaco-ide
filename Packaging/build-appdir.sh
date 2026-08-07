#!/usr/bin/env bash
#
# build-appdir.sh — wrap a staged release tree into an AppDir, ready for
# appimagetool.
#
# It packages a tree produced by StageRelease.sh rather than reading the repo
# directly, so the AppImage and the self-extracting installer ship byte-identical
# content and only one script decides what a release contains.
#
#   <outdir>/
#     AppRun                    materialises the payload into ~/Ilwaco
#     ilwaco.desktop            top-level, as the AppImage spec requires
#     ilwaco.png                ditto, matching the desktop file's Icon=
#     usr/share/ilwaco/         the staged release tree, verbatim
#
# Usage:  Packaging/build-appdir.sh [release-tree] [outdir]
#         defaults: ../ilwaco-ide-release, build/Ilwaco.AppDir
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE="${1:-${ILWACO_RELEASE_DIR:-$(dirname "$REPO")/ilwaco-ide-release}}"
OUT="${2:-$REPO/build/Ilwaco.AppDir}"

die() { echo "build-appdir.sh: error: $*" >&2; exit 1; }

[ -d "$RELEASE" ] || die "no release tree at $RELEASE — run Packaging/StageRelease.sh first"
[ -x "$RELEASE/ilwaco" ] || die "$RELEASE has no ilwaco binary — is it a staged release tree?"

rm -rf "$OUT"
mkdir -p "$OUT/usr/share"
cp -a "$RELEASE" "$OUT/usr/share/ilwaco"

cp "$REPO/Packaging/AppRun" "$OUT/AppRun"
chmod +x "$OUT/AppRun"
cp "$REPO/ilwaco.desktop" "$OUT/ilwaco.desktop"
cp "$REPO/Resources/Logo.png" "$OUT/ilwaco.png"
# appimagetool also expects the desktop file and icon in the usual share paths.
mkdir -p "$OUT/usr/share/applications" "$OUT/usr/share/icons/hicolor/256x256/apps"
cp "$OUT/ilwaco.desktop" "$OUT/usr/share/applications/ilwaco.desktop"
cp "$OUT/ilwaco.png"     "$OUT/usr/share/icons/hicolor/256x256/apps/ilwaco.png"

echo "build-appdir.sh: AppDir ready -> $OUT ($(du -sh "$OUT" | cut -f1))"
echo "build-appdir.sh: try it with:  ILWACO_HOME=/tmp/ilwaco-home DISPLAY=:0 $OUT/AppRun"
