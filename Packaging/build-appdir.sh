#!/usr/bin/env bash
#
# build-appdir.sh — assemble the Ilwaco AppDir: everything that goes inside the
# AppImage, laid out the way AppRun expects.
#
#   <outdir>/
#     AppRun                    launcher (see Packaging/AppRun for the design)
#     ilwaco.desktop            top-level, as the AppImage spec requires
#     ilwaco.png                ditto, matching the desktop file's Icon=
#     usr/bin/                  ilwaco, ilwaco-mcp
#     usr/toolchain/            bundled as/ld/gcc-stub + C link sysroot
#     usr/share/ilwaco/         the payload AppRun seeds or links into ~/Ilwaco
#
# Build the binaries first (./build-linux.sh all) — this script packages what is
# already there rather than compiling, so that packaging stays a fast, repeatable
# step and a 3-4 minute whole-program compile is not hidden inside it.
#
# Usage:  Packaging/build-appdir.sh [outdir]        (default: build/Ilwaco.AppDir)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$REPO/build/Ilwaco.AppDir}"
SHARE="$OUT/usr/share/ilwaco"

die() { echo "build-appdir.sh: error: $*" >&2; exit 1; }

[ -x "$REPO/ilwaco" ] || die "no ./ilwaco binary — run ./build-linux.sh editor first"
[ -f "$REPO/Controls/MyFbFramework/libmff64_gtk3.so" ] \
	|| die "no libmff64_gtk3.so — run ./build-linux.sh lib first (the toolbox needs it)"

rm -rf "$OUT"
mkdir -p "$OUT/usr/bin" "$SHARE"

# --- binaries ----------------------------------------------------------------
cp "$REPO/ilwaco" "$OUT/usr/bin/ilwaco"
[ -x "$REPO/ilwaco-mcp" ] && cp "$REPO/ilwaco-mcp" "$OUT/usr/bin/ilwaco-mcp"
chmod +x "$OUT/usr/bin/"*

# --- link toolchain ----------------------------------------------------------
"$REPO/Packaging/make-toolchain.sh" "$OUT/usr/toolchain" >/dev/null \
	|| die "make-toolchain.sh failed"

# --- payload -----------------------------------------------------------------
# Read-only at runtime (AppRun symlinks these into the app home each launch).
for d in Compilers Controls Resources Help CHMVIEW; do
	[ -e "$REPO/$d" ] || continue
	cp -a "$REPO/$d" "$SHARE/$d"
done
# The compiler tarball is a build-time artefact, not something to ship.
rm -f "$SHARE/Compilers"/*.tar.xz
# The shim is a from-source dev-build aid; the AppImage has usr/toolchain instead.
rm -rf "$SHARE/Compilers/shim"

# Seeded once into the app home, then owned by the user.
for d in Settings Templates AddIns Examples Documentation; do
	[ -e "$REPO/$d" ] || continue
	cp -a "$REPO/$d" "$SHARE/$d"
done
mkdir -p "$SHARE/Projects"
# Workspace.ini is per-session state; shipping one would restore a stranger's tabs.
rm -f "$SHARE/Settings/Workspace.ini"

# AppRun regenerates the GTK link targets on every start.
mkdir -p "$SHARE/Packaging"
cp "$REPO/Packaging/gen-gtk-links.sh" "$SHARE/Packaging/gen-gtk-links.sh"
chmod +x "$SHARE/Packaging/gen-gtk-links.sh"

# --- settings the shipped INI cannot carry -----------------------------------
# Two things in the tracked Settings/ilwaco.ini are wrong for a packaged build:
# the [Compilers] block still points at the original author's machine
# (/mnt/media/FreeBasic/...), and nothing tells fbc where the bundled link
# sysroot is. AppRun patches both when it first seeds the app home, because the
# paths depend on where the user's app home ends up. Only *values* change --
# never the shape of [Compilers], whose parser is fragile about restructuring.
cat > "$SHARE/Settings/.seed-patch" <<'EOF'
# Applied by AppRun the first time it seeds the app home. "@APPHOME@" is
# replaced with the real path. key=value, one per line, [section] scoped.
[Parameters]
Compiler64Arguments=-b {S} -exx -p "@APPHOME@/.toolchain/sysroot/lib/x86_64-linux-gnu" -p "@APPHOME@/.link-shim"
[Compilers]
DefaultCompiler64=fbc
Version_0=fbc
Path_0=@APPHOME@/Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc
EOF

# --- AppImage top-level ------------------------------------------------------
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
