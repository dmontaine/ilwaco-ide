#!/usr/bin/env bash
#
# gen-gtk-links.sh — create the unversioned GTK/X11 ".so" link targets that
# fbc needs to link a GUI program, pointing at whatever versioned runtime
# libraries this machine actually has.
#
# WHY NOT BUNDLE GTK
# ------------------
# Linking `-lgtk-3` needs a file literally named libgtk-3.so; only the -dev
# package ships one, while every desktop has libgtk-3.so.0. Bundling GTK inside
# the AppImage would fix that, but buys nothing: the Ilwaco binary is itself
# dynamically linked against the host's libgtk-3.so.0, so a host GTK3 runtime is
# already a hard requirement for the IDE to start. Bundling would add ~19 MB of
# directly-linked libraries (far more with the transitive closure) plus the
# usual AppImage GTK tax — gdk-pixbuf loader caches, gio modules, immodules and
# theme engines that must be regenerated per host or the app renders unthemed.
#
# So: point at the host's runtime libraries instead. This runs at startup (from
# AppRun) into a writable cache dir, because the AppImage itself is read-only
# and the host's library versions are not known until then.
#
# Usage:  gen-gtk-links.sh <outdir>
# Exits non-zero, with a message naming the missing library, if a core GTK
# runtime library is absent — that is a genuinely unusable host, and saying so
# beats letting the user hit "cannot find -lgtk-3" from inside the IDE.
#
set -euo pipefail

OUT="${1:-}"
[ -n "$OUT" ] || { echo "usage: ${0##*/} <outdir>" >&2; exit 1; }

# Unversioned names a GTK/MFF program's link step asks for.
LIBS=(
	libgtk-3 libgdk-3 libgdk_pixbuf-2.0
	libpango-1.0 libpangocairo-1.0 libpangoft2-1.0
	libcairo libcairo-gobject
	libatk-1.0 libharfbuzz libfontconfig libfreetype libX11
	libgobject-2.0 libglib-2.0 libgio-2.0 libgmodule-2.0 libgthread-2.0
)
# Without these there is no GUI build at all; the rest are best-effort.
CORE=(libgtk-3 libgdk-3 libglib-2.0 libgobject-2.0 libpango-1.0 libcairo)
LIBDIRS=(/usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu /usr/lib64 /usr/lib /lib)

is_core() { local x; for x in "${CORE[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

find_lib() {
	local base="$1" d hit
	for d in "${LIBDIRS[@]}"; do
		hit=$(ls "$d/$base".so.* 2>/dev/null | grep -E "\.so\.[0-9]+$" | sort -V | tail -1 || true)
		[ -n "$hit" ] && { echo "$hit"; return 0; }
	done
	return 1
}

mkdir -p "$OUT"
missing=()
for base in "${LIBS[@]}"; do
	if real=$(find_lib "$base"); then
		ln -sf "$real" "$OUT/$base.so"
	else
		rm -f "$OUT/$base.so"
		missing+=("$base")
		is_core "$base" && {
			echo "gen-gtk-links.sh: error: this system has no $base.so.N." >&2
			echo "gen-gtk-links.sh: Ilwaco needs the GTK 3 runtime installed." >&2
			exit 1
		}
	fi
done
[ "${#missing[@]}" -eq 0 ] || echo "gen-gtk-links.sh: note: optional libs absent: ${missing[*]}" >&2
