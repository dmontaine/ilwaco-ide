#!/usr/bin/env bash
#
# ilwaco.sh — launch an installed Ilwaco.
#
# This is the launcher that ships INSIDE the release tree, next to the ilwaco
# binary. It does the handful of things that can only be done on the machine
# Ilwaco ends up on:
#
#   * point fbc at the bundled assembler/linker instead of the host's;
#   * regenerate the GTK link targets against whatever runtime GTK is installed;
#   * on first run, write the settings whose values depend on the install path.
#
# It assumes it lives in a WRITABLE directory — the IDE resolves everything from
# FreeBASIC's ExePath() and writes Settings/, Temp/ and .bak files there. The
# AppImage's AppRun is the wrapper that arranges for that to be true when the
# payload itself is a read-only mount; it then hands over to this script, so
# both packaging routes share one launch path.
#
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
TOOLCHAIN="$HERE/Toolchain"

die() { echo "Ilwaco: $*" >&2; exit 1; }

[ -x "$HERE/ilwaco" ]  || die "no ilwaco binary beside this script ($HERE)"
[ -d "$TOOLCHAIN" ]    || die "the bundled compiler toolchain is missing from $HERE"
[ -w "$HERE" ]         || die "$HERE is not writable — Ilwaco stores its settings beside itself"

mkdir -p "$HERE/Temp" "$HERE/projects"

# --- first-run settings ------------------------------------------------------
# Two things the shipped Settings/ilwaco.ini cannot carry, because both depend
# on where Ilwaco was installed: the bundled compiler's path (the tracked INI
# still names the original author's machine), and the -p search paths for the
# bundled link sysroot and the generated GTK link targets. Applied once, so a
# user's later edits are never overwritten.
patch_file="$HERE/Settings/.seed-patch"
ini="$HERE/Settings/ilwaco.ini"
if [ -f "$patch_file" ] && [ -f "$ini" ]; then
	section=""
	while IFS= read -r line; do
		case "$line" in
			''|'#'*)  continue ;;
			'['*']')  section="$line"; continue ;;
		esac
		key="${line%%=*}"
		val="${line#*=}"
		val="${val//@APPHOME@/$HERE}"
		# ilwaco.ini starts with a UTF-8 BOM, so its first line is not literally
		# "[Parameters]". Comparing raw makes that whole section silently fail to
		# patch while later sections succeed — compare BOM-stripped, but print
		# the original so nothing else about the file changes.
		#
		# Insert-if-missing, not replace-only: a replace-only patch turns any
		# future rename or reorder of these keys into a failure to LAUNCH (the
		# check below dies), not merely a failed build. Missing key → appended to
		# its section; missing section → appended to the file.
		awk -v sec="$section" -v key="$key" -v val="$val" '
			function emit() { print key "=" val; done = 1 }
			{ line = $0 }
			NR == 1 && substr(line, 1, 3) == "\357\273\277" { line = substr(line, 4) }
			line ~ /^\[/ {
				if (insec && !done) emit()	# our section ended without the key
				insec = (line == sec)
				if (insec) seen = 1
				print; next
			}
			insec && !done && index(line, key "=") == 1 { emit(); next }
			{ print }
			END {
				if (insec && !done) emit()		# our section ran to end of file
				else if (!seen) { print sec; emit() }	# no such section at all
			}
		' "$ini" > "$ini.tmp" && mv -f "$ini.tmp" "$ini"

		# A miss here stays invisible until the user's first build fails deep
		# inside fbc, so check rather than hope.
		grep -qF -- "$key=$val" "$ini" || die "could not apply first-run setting '$key' to $ini"
	done < "$patch_file"
	rm -f "$patch_file"
fi

# --- GTK link targets --------------------------------------------------------
# Regenerated every launch: they point at the host's runtime libraries, which a
# system update can renumber underneath us.
"$TOOLCHAIN/gen-gtk-links.sh" "$HERE/.link-shim" \
	|| die "Ilwaco needs the GTK 3 runtime installed to build GUI programs"

# --- environment -------------------------------------------------------------
# The bundled assembler, linker and gcc stub must win over anything on the host,
# so they go on the FRONT of PATH. fbc inherits this when the IDE spawns it.
export PATH="$TOOLCHAIN/bin:$PATH"

# Only fbc's own libtinfo.so.5 belongs here. Deliberately NOT Toolchain/sysroot:
# that holds libc.so.6 and the loader as *link* targets, and putting it on the
# library path would make the IDE — and every program it launches — resolve
# glibc against our bundled copy instead of the host's.
export LD_LIBRARY_PATH="$TOOLCHAIN/runtime${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$HERE"
exec "$HERE/ilwaco" "$@"
