#!/usr/bin/env bash
#
# verify-toolchain.sh — prove that a toolchain built by make-toolchain.sh can
# compile FreeBASIC with NOTHING from the host but the kernel and the GTK/libc
# runtime a normal desktop already has.
#
# The test is the whole point: it compiles with `env -i` and a PATH containing
# only the bundled bin dir, so any accidental reach back into /usr/bin or a
# host -dev package shows up as a failure here instead of on a user's machine.
#
# Two cases, because they fail differently:
#   console — needs the crt objects, libgcc and ncurses/tinfo (the part that
#             silently breaks when gcc is absent)
#   GTK     — needs the unversioned .so link targets, which are generated
#             against the host's *runtime* GTK rather than bundled
#
# Usage:  Packaging/verify-toolchain.sh <toolchain-dir> [gtk-link-dir]
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TC="${1:-}"
[ -d "${TC:-}" ] || { echo "usage: ${0##*/} <toolchain-dir> [gtk-link-dir]" >&2; exit 1; }
TC="$(cd "$TC" && pwd)"
SYS="$TC/sysroot/lib/x86_64-linux-gnu"
GTKDIR="${2:-$SYS}"
FBC="$REPO/Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
fails=0

# fbc runs with a scrubbed environment: only the bundled toolchain on PATH.
# -v is not optional here: the assembler/linker command lines it prints are what
# the host-reach-back check below inspects.
run_fbc() {
	env -i PATH="$TC/bin" HOME="$WORK" LD_LIBRARY_PATH="$SYS" "$FBC" -v "$@"
}

check() {
	local name="$1" slug="$2"; shift 2
	if "$@" > "$WORK/$slug.log" 2>&1; then
		echo "  ok    $name"
	else
		echo "  FAIL  $name"; sed 's/^/        /' "$WORK/$slug.log"; fails=$((fails+1))
	fi
}

echo "verify-toolchain.sh: $TC"

# --- console ---------------------------------------------------------------
printf 'Print "ilwaco-console-ok"\n' > "$WORK/con.bas"
check "console: compile" con-build \
	run_fbc -gen gas64 "$WORK/con.bas" -x "$WORK/con" -p "$SYS" -l tinfo
if [ -x "$WORK/con" ]; then
	check "console: run" con-run env -i "$WORK/con"
	if grep -q ilwaco-console-ok "$WORK/con-run.log"; then
		echo "  ok    console: correct output"
	else
		echo "  FAIL  console: wrong output"; fails=$((fails+1))
	fi
else
	echo "  FAIL  console: no executable produced"; fails=$((fails+1))
fi

# --- GTK -------------------------------------------------------------------
cat > "$WORK/gui.bas" <<'EOF'
Extern "C"
	Declare Sub gtk_init(ByVal argc As Integer Ptr, ByVal argv As Any Ptr)
	Declare Function gtk_window_new(ByVal t As Integer) As Any Ptr
	Declare Function gtk_widget_get_name(ByVal w As Any Ptr) As ZString Ptr
End Extern
gtk_init(0, 0)
Print "ilwaco-gtk-ok "; *gtk_widget_get_name(gtk_window_new(0))
EOF
check "gtk: compile" gui-build \
	run_fbc -gen gas64 "$WORK/gui.bas" -x "$WORK/gui" -p "$SYS" -p "$GTKDIR" \
		-l tinfo -l gtk-3 -l gdk-3 -l gobject-2.0 -l glib-2.0

# --- no host reach-back ----------------------------------------------------
# Nothing the assembler/linker consumed may come from the host toolchain: a
# /usr/bin/{as,ld} or a -dev object appearing here means the image would still
# break on a machine without the build-time packages installed.
#
# Method: rewrite every path we legitimately own (the toolchain, the bundled
# fbc, the generated GTK link dir, this test's tmpdir) to a marker, then any
# absolute path that still starts a token is a reach-back. Markers matter: the
# toolchain's own paths contain "/bin/../sysroot/...", which a bare substring
# search would flag as if it were /bin on the host. Only two host paths are
# allowed through -- the dynamic loader, and the host GTK runtime that the
# generated link symlinks resolve to.
FBDIR="$REPO/Compilers/FreeBASIC-1.10.1-linux-x86_64"
leaked=$(cat "$WORK/gui-build.log" "$WORK/con-build.log" \
	| sed -e "s#$TC#@TC@#g" -e "s#$FBDIR#@FB@#g" -e "s#$GTKDIR#@GTK@#g" -e "s#$WORK#@TMP@#g" \
	| grep -oE '(^|[" ])/(usr/)?(bin|lib|lib64|sbin)/[^" ]*' \
	| sed -e 's/^[" ]//' \
	| grep -vE '^/lib64/ld-linux-x86-64\.so\.2$' \
	| grep -vE '^/(usr/)?lib/x86_64-linux-gnu/lib(gtk|gdk|gdk_pixbuf|glib|gobject|gio|gmodule|gthread|pango|pangocairo|pangoft2|cairo|atk|harfbuzz|fontconfig|freetype|X11)[-.0-9]*\.so\.[0-9]+$' \
	| sort -u || true)   # the clean case filters everything out: grep exits 1
if [ -n "$leaked" ]; then
	echo "  FAIL  link line still reaches into the host toolchain:"
	echo "$leaked" | sed 's/^/        /'
	fails=$((fails+1))
else
	echo "  ok    no host toolchain paths on the link line"
fi

echo "verify-toolchain.sh: $([ "$fails" -eq 0 ] && echo "all checks passed" || echo "$fails FAILED")"
exit "$fails"
