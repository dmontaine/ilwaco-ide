#!/usr/bin/env bash
#
# make-toolchain.sh — assemble the self-contained link toolchain that ships
# inside the Ilwaco AppImage.
#
# WHY THIS EXISTS
# ---------------
# The bundled FreeBASIC compiler (Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/)
# ships *only* fbc. To turn a .bas into an executable fbc also needs, from the
# host:
#
#   * an assembler and a linker  — /usr/bin/as, /usr/bin/ld  (binutils)
#   * the C startup/link objects — crt1.o crti.o crtn.o      (libc6-dev)
#   * gcc's own link objects     — crtbegin.o crtend.o libgcc.a libgcc_eh.a
#   * the unversioned .so link targets for libc/libm/ncurses/GTK  (-dev packages)
#   * gcc itself, which fbc runs as `gcc -print-file-name=<obj>` to locate the
#     crt objects above
#
# None of that exists on a fresh desktop install — those are all -dev packages.
# A beginner who downloads the AppImage has the GTK *runtime*, and nothing else.
# Measured 2026-08-07: with no gcc on PATH, fbc does not fail loudly — it
# silently drops every crt object from the ld command line and the link dies on
# `cannot find -lgcc`. So all of the above must come from inside the image.
#
# WHAT IT BUILDS
#
#   <outdir>/bin/as, bin/ld     wrappers -> libexec/*.real with their private
#                               LD_LIBRARY_PATH (libbfd etc.), so the bundled
#                               binutils never leak onto the app's library path
#   <outdir>/bin/gcc            a STUB. Under -gen gas64 fbc never compiles C —
#                               it only probes gcc for crt paths. The stub
#                               answers those probes from the bundled sysroot
#                               and refuses anything else.
#   <outdir>/sysroot/…          crt objects, libgcc, and the libc/libm/ncurses
#                               link targets, laid out so that fbc's own
#                               <gcclibdir>/../../../x86_64-linux-gnu/ path
#                               arithmetic lands inside the sysroot.
#
# GTK is deliberately NOT bundled: Ilwaco itself is dynamically linked against
# the host's libgtk-3.so.0, so a host GTK3 runtime is already a hard requirement
# for the IDE to start at all. The unversioned GTK link symlinks are generated
# against the host's runtime libraries at first run instead — see AppRun.
#
# Run this on the RELEASE BUILD MACHINE, which should have the OLDEST glibc we
# intend to support: the crt objects and libc link target captured here set the
# floor for every program a user compiles with Ilwaco.
#
# Usage:  Packaging/make-toolchain.sh <outdir>
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TC="${1:-}"
[ -n "$TC" ] || { echo "usage: ${0##*/} <outdir>" >&2; exit 1; }

die() { echo "make-toolchain.sh: error: $*" >&2; exit 1; }

# The host toolchain we are copying out of. All of these are build-machine-only
# requirements; nothing here is required on a user's machine.
command -v gcc >/dev/null || die "need gcc on the build machine (to locate crt objects)"
[ -x /usr/bin/as ] || die "need binutils 'as' on the build machine"
GCCV=$(basename "$(dirname "$(gcc -print-file-name=crtbegin.o)")")
HOST_GCCDIR="/usr/lib/gcc/x86_64-linux-gnu/$GCCV"
[ -d "$HOST_GCCDIR" ] || die "gcc lib dir not found: $HOST_GCCDIR"

rm -rf "$TC"
mkdir -p "$TC"/{bin,libexec/lib}
SYS="$TC/sysroot/lib/x86_64-linux-gnu"
GCCDIR="$TC/sysroot/lib/gcc/x86_64-linux-gnu/$GCCV"
mkdir -p "$SYS" "$GCCDIR"

# ---------------------------------------------------------------- binutils ---
cp -L /usr/bin/as     "$TC/libexec/as.real"
cp -L /usr/bin/ld.bfd "$TC/libexec/ld.real"
# Copy whatever the two binaries actually pull in, rather than a hardcoded list
# (libbfd carries a version in its SONAME and changes with the build distro).
for lib in $(ldd /usr/bin/as /usr/bin/ld.bfd | awk '$3 ~ /^\// {print $3}' | sort -u); do
	case "${lib##*/}" in
		libc.so.6|ld-linux-x86-64.so.2) continue ;;   # always present on the host
	esac
	cp -Ln "$lib" "$TC/libexec/lib/${lib##*/}" 2>/dev/null || true
done

for tool in as ld; do
	# No external commands in these wrappers: fbc may spawn them with a PATH
	# that contains nothing but the bundled bin dir.
	cat > "$TC/bin/$tool" <<EOF
#!/bin/sh
d=\${0%/*}/..
LD_LIBRARY_PATH="\$d/libexec/lib" exec "\$d/libexec/$tool.real" "\$@"
EOF
	chmod +x "$TC/bin/$tool"
done

# --------------------------------------------------------------- gcc stub ---
# fbc asks `gcc -print-file-name=X` once per crt object and uses the answer
# verbatim. Real gcc resolves X against its own libdir first, then the target
# libdir, and echoes the bare name when it finds neither — fbc's link line is
# correct only if all three behaviours are reproduced.
cat > "$TC/bin/gcc" <<EOF
#!/bin/sh
d=\${0%/*}/..
g=\$d/sysroot/lib/gcc/x86_64-linux-gnu/$GCCV
t=\$d/sysroot/lib/x86_64-linux-gnu
for a in "\$@"; do
	case "\$a" in
		-print-file-name=*)
			f=\${a#-print-file-name=}
			if   [ -e "\$g/\$f" ]; then echo "\$g/\$f"
			elif [ -e "\$t/\$f" ]; then echo "\$t/\$f"
			else echo "\$f"; fi
			exit 0 ;;
	esac
done
echo "gcc: this is Ilwaco's bundled stub - there is no C compiler in the image" >&2
echo "gcc: (FreeBASIC is compiled with -gen gas64, which needs no C compiler)" >&2
exit 1
EOF
chmod +x "$TC/bin/gcc"

# --------------------------------------------------------- link objects -----
for f in crtbegin.o crtend.o libgcc.a libgcc_eh.a; do
	cp -L "$HOST_GCCDIR/$f" "$GCCDIR/$f" || die "missing $HOST_GCCDIR/$f"
done
for f in crt1.o crti.o crtn.o libc_nonshared.a; do
	cp -L "/usr/lib/x86_64-linux-gnu/$f" "$SYS/$f" || die "missing $f (install libc6-dev)"
done
for f in libc.so.6 libm.so.6 libdl.so.2 libpthread.so.0 ld-linux-x86-64.so.2; do
	cp -L "/lib/x86_64-linux-gnu/$f" "$SYS/$f" || die "missing runtime $f"
done

# The host's libc.so/libm.so are ld scripts naming ABSOLUTE host paths, which
# would send the linker straight back out to the host. Rewrite with bare names:
# ld resolves those through its -L search path, i.e. inside this sysroot.
cat > "$SYS/libc.so" <<'EOF'
/* Ilwaco bundled sysroot. Bare names on purpose - resolved via ld's -L path. */
OUTPUT_FORMAT(elf64-x86-64)
GROUP ( libc.so.6 libc_nonshared.a AS_NEEDED ( ld-linux-x86-64.so.2 ) )
EOF
ln -sf libm.so.6      "$SYS/libm.so"
ln -sf libdl.so.2     "$SYS/libdl.so"
ln -sf libpthread.so.0 "$SYS/libpthread.so"

# ncurses/tinfo: every FB console program links them, so they ship bundled.
# libtinfo.so.5 is what fbc itself needs (modern distros carry only .so.6).
cp -L "$REPO/Compilers/shim/libtinfo.so.5" "$SYS/libtinfo.so.5" \
	|| die "vendored libtinfo.so.5 missing from Compilers/shim/"
for base in libtinfo libncurses; do
	real=$(ls /lib/x86_64-linux-gnu/$base.so.[0-9] 2>/dev/null | sort -V | tail -1) \
		|| die "no $base.so.N on the build machine"
	cp -L "$real" "$SYS/${real##*/}"
	ln -sf "${real##*/}" "$SYS/$base.so"
done

echo "make-toolchain.sh: gcc $GCCV link objects; $("$TC/bin/ld" --version | head -1)"
echo "make-toolchain.sh: toolchain ready -> $TC ($(du -sh "$TC" | cut -f1))"
