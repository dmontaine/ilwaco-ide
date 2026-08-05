#!/usr/bin/env bash
#
# build-linux.sh — build Ilwaco (the Linux/GTK3 FreeBASIC IDE) from source.
#
# Ilwaco builds with the in-repo bundled FreeBASIC compiler
# (Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc). On a stock modern Debian/
# Ubuntu that compiler needs a small userspace "shim" — no root, nothing installed
# system-wide:
#
#   1. libtinfo.so.5  — fbc itself links it, but Debian 13 ships only .so.6 (which
#      lacks the NCURSES_TINFO_5.0 symbol version). A real .so.5 is vendored in-repo
#      at Compilers/shim/libtinfo.so.5; this script just links to it.
#   2. Unversioned GTK "-dev" .so names (libgtk-3.so, libgdk-3.so, …) — the link
#      step needs these, but they only exist when the distro's -dev packages are
#      installed. This script generates them as symlinks to whatever versioned
#      system libs (.so.N) are present.
#
# The symlinks point at absolute host paths, so they are host-specific and are NOT
# committed — this script regenerates them into Compilers/shim/gtk-dev/ (gitignored).
# Re-run it whenever the toolchain dir is missing or your system libs change.
#
# Usage:
#   ./build-linux.sh              # generate shim, then build the control lib + editor
#   ./build-linux.sh shim         # (re)generate the shim dir only
#   ./build-linux.sh lib          # build the MFF designer control lib only (libmff64_gtk3.so)
#   ./build-linux.sh editor       # build the editor only (ilwaco)
#   ./build-linux.sh --print-shim # print the shim dir path (for LD_LIBRARY_PATH) and exit
#   ./build-linux.sh -h|--help
#
# To RUN the built IDE, put the shim on LD_LIBRARY_PATH so the fbc it spawns to
# compile your projects can find libtinfo.so.5:
#   LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FBC="$REPO/Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"
VENDORED_TINFO5="$REPO/Compilers/shim/libtinfo.so.5"
SHIM="$REPO/Compilers/shim/gtk-dev"

# Unversioned dev names the GTK/ncurses link step needs.
LIBS=(
	libtinfo libncurses
	libgtk-3 libgdk-3 libgdk_pixbuf-2.0
	libpango-1.0 libpangocairo-1.0 libpangoft2-1.0
	libcairo libcairo-gobject
	libatk-1.0 libharfbuzz libfontconfig libfreetype libX11
	libgobject-2.0 libglib-2.0 libgio-2.0 libgmodule-2.0 libgthread-2.0
)
# Missing any of these is fatal (the build cannot link without them).
CORE=(libtinfo libgtk-3 libgdk-3 libglib-2.0 libgobject-2.0 libpango-1.0 libcairo)
# Where to look for versioned system libs (.so.N).
LIBDIRS=(/usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu /usr/lib64 /usr/lib /lib)

die() { echo "build-linux.sh: error: $*" >&2; exit 1; }

# Highest-versioned real .so.N for a base name, across LIBDIRS ("" if none).
find_lib() {
	local base="$1" d hit
	for d in "${LIBDIRS[@]}"; do
		hit=$(ls "$d/$base".so.* 2>/dev/null | grep -E "\.so\.[0-9]+$" | sort -V | tail -1 || true)
		[ -n "$hit" ] && { echo "$hit"; return 0; }
	done
	return 1
}

is_core() { local x; for x in "${CORE[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

build_shim() {
	[ -x "$FBC" ] || die "bundled fbc not found or not executable: $FBC"
	[ -f "$VENDORED_TINFO5" ] || die "vendored libtinfo.so.5 missing: $VENDORED_TINFO5"
	mkdir -p "$SHIM"
	# The compiler's own libtinfo.so.5 -> the vendored copy.
	ln -sf "$VENDORED_TINFO5" "$SHIM/libtinfo.so.5"
	local base real missing=()
	for base in "${LIBS[@]}"; do
		if real=$(find_lib "$base"); then
			ln -sf "$real" "$SHIM/$base.so"
		else
			ln -sf /dev/null "$SHIM/$base.so" 2>/dev/null || true
			rm -f "$SHIM/$base.so"
			missing+=("$base")
			if is_core "$base"; then
				die "required system library '$base.so.N' not found in: ${LIBDIRS[*]} (install the GTK3 runtime)"
			fi
		fi
	done
	if [ "${#missing[@]}" -gt 0 ]; then
		echo "build-linux.sh: warning: optional libs not found (skipped): ${missing[*]}" >&2
	fi
	echo "build-linux.sh: shim ready -> $SHIM"
}

need_shim() { [ -e "$SHIM/libtinfo.so.5" ] && [ -e "$SHIM/libgtk-3.so" ] || build_shim; }

build_lib() {
	need_shim
	echo "build-linux.sh: building libmff64_gtk3.so (MFF designer control lib)…"
	( cd "$REPO/Controls/MyFbFramework/mff" \
		&& LD_LIBRARY_PATH="$SHIM" "$FBC" -b mff.bi -dll -x ../libmff64_gtk3.so \
			-d __USE_GTK3__ -p "$SHIM" -l tinfo )
	echo "build-linux.sh: -> $REPO/Controls/MyFbFramework/libmff64_gtk3.so"
}

build_editor() {
	need_shim
	echo "build-linux.sh: building ilwaco (editor, whole-program ~3-4 min)…"
	( cd "$REPO/src" \
		&& LD_LIBRARY_PATH="$SHIM" "$FBC" ilwaco.bas -i ../Controls/MyFbFramework \
			-d __USE_GTK3__ -p "$SHIM" -l tinfo )
	echo "build-linux.sh: -> $REPO/ilwaco"
}

build_sidecar() {
	need_shim
	echo "build-linux.sh: building ilwaco-mcp (Agent MCP sidecar, console app)…"
	( cd "$REPO/src" \
		&& LD_LIBRARY_PATH="$SHIM" "$FBC" AgentMcp.bas -x ../ilwaco-mcp \
			-p "$SHIM" -l tinfo )
	echo "build-linux.sh: -> $REPO/ilwaco-mcp"
}

case "${1:-all}" in
	-h|--help)      sed -n '2,40p' "$0"; exit 0 ;;
	--print-shim)   echo "$SHIM"; exit 0 ;;
	shim)           build_shim ;;
	lib)            build_lib ;;
	editor)         build_editor ;;
	sidecar|mcp)    build_sidecar ;;
	all)            build_shim; build_lib; build_editor; build_sidecar
	                echo "build-linux.sh: done. Run with:"
	                echo "  LD_LIBRARY_PATH=\"$SHIM\" DISPLAY=:0 \"$REPO/ilwaco\"" ;;
	*)              die "unknown argument '$1' (try --help)" ;;
esac
