#!/usr/bin/env bash
#
# BuildPackages.sh — build the .deb and/or .rpm from a staged release tree.
#
# These exist because they are the fewest clicks for a beginner: a distro package
# is double-click-installable, lands in the applications menu, and — unlike a
# downloaded AppImage — never depends on the user knowing about the executable
# bit (Documentation/Packaging.md, "What the AppImage needs on the USER's
# machine"). Between them .deb and .rpm cover most of the desktop Linux market.
#
#   .deb   Debian, Ubuntu, Mint
#   .rpm   Fedora, RHEL, openSUSE
#
# THE LAYOUT, IDENTICAL IN BOTH
# -----------------------------
#   /opt/ilwaco-ide/                    the staged release tree, read-only
#   /usr/bin/ilwaco                     launcher; seeds ~/ilwaco-ide, then execs
#   /usr/share/applications/ilwaco.desktop
#   /usr/share/icons/hicolor/256x256/apps/ilwaco.png
#
# /opt rather than /usr/lib because this is a self-contained vendor application
# that carries its own compiler toolchain — precisely what the FHS reserves /opt
# for, and both dpkg and rpm are content there.
#
# ONE RPM FOR FEDORA, RHEL *AND* SUSE
# -----------------------------------
# The three disagree on what the GTK package is called (`gtk3` vs `libgtk-3-0`),
# so a Requires: on a package NAME would pick at most two of them. rpmbuild's
# automatic dependency generator emits SONAME requires instead —
# `libgtk-3.so.0()(64bit)` — which every one of them satisfies from its own
# provides. So the auto-generated deps are not a convenience here, they are the
# portability mechanism, and the same is true of dpkg-shlibdeps on the .deb side.
#
# BUT the generator must only look at OUR binaries. The payload also carries the
# bundled FreeBASIC toolchain, and `fbc` needs libtinfo.so.5 — which we ship
# ourselves in Toolchain/runtime and which Fedora does NOT install by default.
# Letting the scanner see it would bake an unsatisfiable dependency into the
# package and make it refuse to install. Hence the exclusions below, on both
# sides. This is the single most important detail in this script.
#
# Usage:  Packaging/BuildPackages.sh [--deb|--rpm|--both] [release-tree]
#         default: --both
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DEFAULT="${ILWACO_RELEASE_DIR:-$(dirname "$REPO")/ilwaco-ide-release}"
OUTDIR="${ILWACO_INSTALLER_DIR:-$(dirname "$REPO")/ilwaco-ide-installer}"

die() { echo "BuildPackages.sh: error: $*" >&2; exit 1; }

WHAT=both
case "${1:---both}" in
	--deb)  WHAT=deb;  shift ;;
	--rpm)  WHAT=rpm;  shift ;;
	--both) WHAT=both; shift ;;
	-*)     die "unknown option '$1' (use --deb, --rpm or --both)" ;;
esac
RELEASE="${1:-$RELEASE_DEFAULT}"

[ -d "$RELEASE" ]     || die "no release tree at $RELEASE — run Packaging/StageRelease.sh first"
[ -x "$RELEASE/ilwaco" ] || die "$RELEASE has no ilwaco binary — is it a staged release tree?"

VERSION="$(awk -F'"' '/#define VER_MAJOR/{a=$2} /#define VER_MINOR/{b=$2} /#define VER_PATCH/{c=$2} END{print a"."b"."c}' "$REPO/src/ilwaco.bas")"
[ -n "$VERSION" ] && [ "$VERSION" != ".." ] || die "could not read the version from src/ilwaco.bas"

BUILD="$REPO/build/packages"
ROOT="$BUILD/root"
mkdir -p "$OUTDIR"

# --- the common install root -------------------------------------------------
echo "BuildPackages.sh: laying out the install root (version $VERSION)"
rm -rf "$BUILD"
mkdir -p "$ROOT/opt" "$ROOT/usr/bin" "$ROOT/usr/share/applications" \
         "$ROOT/usr/share/icons/hicolor/256x256/apps"

cp -a "$RELEASE" "$ROOT/opt/ilwaco-ide"
cp "$REPO/Packaging/seed-app-home.sh" "$ROOT/opt/ilwaco-ide/seed-app-home.sh"
chmod +x "$ROOT/opt/ilwaco-ide/seed-app-home.sh"

# The payload is read-only for the user, so Temp/ and projects/ inside it are
# pure noise — the launcher makes the real ones in ~/ilwaco-ide.
rm -rf "$ROOT/opt/ilwaco-ide/Temp"

cp "$REPO/Packaging/ilwaco-launcher" "$ROOT/usr/bin/ilwaco"
chmod +x "$ROOT/usr/bin/ilwaco"
cp "$REPO/ilwaco.desktop" "$ROOT/usr/share/applications/ilwaco.desktop"
cp "$REPO/Resources/Logo.png" "$ROOT/usr/share/icons/hicolor/256x256/apps/ilwaco.png"

INSTALLED_KB="$(du -sk "$ROOT" | cut -f1)"

# --- .deb --------------------------------------------------------------------
build_deb() {
	command -v dpkg-deb >/dev/null || die "dpkg-deb not found (install dpkg-dev)"
	echo ""
	echo "BuildPackages.sh: building .deb"

	local D="$BUILD/deb"
	rm -rf "$D"; mkdir -p "$D"
	cp -a "$ROOT/." "$D/"
	mkdir -p "$D/DEBIAN" "$D/usr/share/doc/ilwaco-ide"
	cp "$RELEASE/license.txt" "$D/usr/share/doc/ilwaco-ide/copyright"

	# Only our own two binaries are scanned; see the header for why the bundled
	# toolchain must not be. dpkg-shlibdeps wants a debian/control to exist and
	# runs relative to the package root.
	local DEPS
	mkdir -p "$D/debian"
	printf 'Source: ilwaco-ide\n\nPackage: ilwaco-ide\nArchitecture: amd64\n' > "$D/debian/control"
	DEPS="$(cd "$D" && dpkg-shlibdeps -O --ignore-missing-info \
	          opt/ilwaco-ide/ilwaco opt/ilwaco-ide/ilwaco-mcp 2>/dev/null \
	        | sed 's/^shlibs:Depends=//')"
	rm -rf "$D/debian"
	[ -n "$DEPS" ] || die "dpkg-shlibdeps produced no dependencies — refusing to ship a package that declares none"

	# dpkg-shlibdeps names packages as THIS machine has them, and Debian's 64-bit
	# time_t transition renamed a lot of them: libgtk-3-0 became libgtk-3-0t64 in
	# Debian 13 and Ubuntu 24.04, while Debian 12, Ubuntu 22.04 and Mint 21 still
	# ship the old name. Depending on only the name this build host happens to use
	# would make the package uninstallable on half the distros we target, so every
	# renamed package gets an alternative on its pre-transition name. Which way
	# round matters: dpkg takes the FIRST satisfiable alternative, so the modern
	# name leads and the old one is the fallback.
	local FIXED="" item base
	local OLDIFS="$IFS"
	IFS=','
	for item in $DEPS; do
		IFS="$OLDIFS"
		item="${item#"${item%%[![:space:]]*}"}"   # strip leading blanks
		[ -n "$item" ] || continue
		case "$item" in
			*t64\ *|*t64)
				base="${item/t64/}"
				item="$item | $base" ;;
		esac
		FIXED="${FIXED:+$FIXED, }$item"
		IFS=','
	done
	IFS="$OLDIFS"
	DEPS="$FIXED"
	echo "BuildPackages.sh: deb depends: $DEPS"

	cat > "$D/DEBIAN/control" <<EOF
Package: ilwaco-ide
Version: $VERSION
Section: devel
Priority: optional
Architecture: amd64
Depends: $DEPS
Installed-Size: $INSTALLED_KB
Maintainer: Ilwaco IDE <dmontaine@gmail.com>
Homepage: https://github.com/dmontaine/ilwaco-ide
Description: FreeBASIC IDE for Linux
 Ilwaco is a GTK3 integrated development environment for the FreeBASIC
 language, with a form designer, an integrated debugger and a bundled
 FreeBASIC compiler and link toolchain, so no development packages have
 to be installed to build a program.
 .
 On first launch it seeds a writable ~/ilwaco-ide with your settings,
 projects and the bundled examples; upgrading the package leaves those
 untouched.
EOF

	# The desktop database and icon cache are refreshed on install/removal.
	# Both are best-effort: a headless box has neither tool and must not fail.
	cat > "$D/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache   >/dev/null 2>&1 && gtk-update-icon-cache -qtf /usr/share/icons/hicolor || true
exit 0
EOF
	cat > "$D/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache   >/dev/null 2>&1 && gtk-update-icon-cache -qtf /usr/share/icons/hicolor || true
exit 0
EOF
	chmod 0755 "$D/DEBIAN/postinst" "$D/DEBIAN/postrm"

	local OUT="$OUTDIR/ilwaco-ide_${VERSION}_amd64.deb"
	rm -f "$OUT"
	# Ownership: everything root:root, as a system package requires. fakeroot is
	# not needed because dpkg-deb --root-owner-group does exactly this.
	dpkg-deb --root-owner-group -Zxz --build "$D" "$OUT" >/dev/null || die "dpkg-deb failed"
	echo "BuildPackages.sh: $OUT ($(du -h "$OUT" | cut -f1))"
}

# --- .rpm --------------------------------------------------------------------
build_rpm() {
	command -v rpmbuild >/dev/null || die "rpmbuild not found (install the 'rpm' package)"
	echo ""
	echo "BuildPackages.sh: building .rpm"

	local R="$BUILD/rpm"
	mkdir -p "$R/BUILD" "$R/RPMS" "$R/SPECS" "$R/BUILDROOT"

	cat > "$R/SPECS/ilwaco-ide.spec" <<EOF
# Built from an already-staged tree, so there is no %prep/%build — the payload is
# copied into the buildroot in %install. This is a binary repack, not a source RPM.
%global _build_id_links none
%global __brp_mangle_shebangs %{nil}
%global __brp_strip %{nil}
%global __brp_strip_static_archive %{nil}
%global __brp_strip_comment_note %{nil}
%global __brp_check_rpaths %{nil}

# The dependency generator must see ONLY our own binaries. The bundled FreeBASIC
# toolchain needs libtinfo.so.5, which we ship in Toolchain/runtime and which
# Fedora does not install by default — scanning it would bake in a dependency
# nothing can satisfy. We also provide none of these libraries to the system.
%global __requires_exclude_from ^/opt/ilwaco-ide/(Compilers|Toolchain|Controls|Examples)/.*\$
%global __provides_exclude_from ^/opt/ilwaco-ide/.*\$

Name:           ilwaco-ide
Version:        $VERSION
Release:        1%{?dist}
Summary:        FreeBASIC IDE for Linux
License:        GPL-2.0-or-later
URL:            https://github.com/dmontaine/ilwaco-ide
BuildArch:      x86_64

%description
Ilwaco is a GTK3 integrated development environment for the FreeBASIC language,
with a form designer, an integrated debugger and a bundled FreeBASIC compiler
and link toolchain, so no development packages have to be installed to build a
program.

On first launch it seeds a writable ~/ilwaco-ide with your settings, projects
and the bundled examples; upgrading the package leaves those untouched.

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cp -a $ROOT/. %{buildroot}/

%files
/opt/ilwaco-ide
/usr/bin/ilwaco
/usr/share/applications/ilwaco.desktop
/usr/share/icons/hicolor/256x256/apps/ilwaco.png

%post
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || :
command -v gtk-update-icon-cache   >/dev/null 2>&1 && gtk-update-icon-cache -qtf /usr/share/icons/hicolor || :
exit 0

%postun
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database -q /usr/share/applications || :
command -v gtk-update-icon-cache   >/dev/null 2>&1 && gtk-update-icon-cache -qtf /usr/share/icons/hicolor || :
exit 0

%changelog
* $(LC_ALL=C date '+%a %b %d %Y') Ilwaco IDE <dmontaine@gmail.com> - $VERSION-1
- Packaged from the staged release tree.
EOF

	rpmbuild --define "_topdir $R" --define "_tmppath $R/tmp" \
	         -bb "$R/SPECS/ilwaco-ide.spec" > "$BUILD/rpmbuild.log" 2>&1 \
		|| { tail -25 "$BUILD/rpmbuild.log"; die "rpmbuild failed (full log: $BUILD/rpmbuild.log)"; }

	local BUILT
	BUILT="$(find "$R/RPMS" -name '*.rpm' -type f | head -1)"
	[ -n "$BUILT" ] || die "rpmbuild reported success but produced no .rpm"
	local OUT="$OUTDIR/$(basename "$BUILT")"
	rm -f "$OUT"; cp "$BUILT" "$OUT"
	echo "BuildPackages.sh: $OUT ($(du -h "$OUT" | cut -f1))"
}

case "$WHAT" in
	deb)  build_deb ;;
	rpm)  build_rpm ;;
	both) build_deb; build_rpm ;;
esac

echo ""
echo "BuildPackages.sh: done — artefacts in $OUTDIR"
