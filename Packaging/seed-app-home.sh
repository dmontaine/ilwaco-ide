#!/usr/bin/env bash
#
# seed-app-home.sh — materialise a writable Ilwaco app home from a read-only payload.
#
# Shared by every delivery route that puts the payload somewhere the user cannot
# write to:
#
#   * the AppImage    — payload is the mounted image      (Packaging/AppRun)
#   * the .deb/.rpm   — payload is /opt/ilwaco-ide        (Packaging/ilwaco-launcher)
#
# WHY THIS EXISTS AT ALL
# ----------------------
# The IDE resolves *and writes* everything relative to FreeBASIC's ExePath() —
# Settings/, Temp/, .bak files — and ExePath() follows symlinks, so it reports
# the real payload location, not the path used to launch. A read-only payload
# therefore cannot host a running IDE, and symlinking the binary out of one does
# not help either: only a REAL COPY of the binary in a writable directory gives a
# writable ExePath. So both routes keep the bulk payload read-only and
# materialise the writable parts here.
#
# The split, and why each part is on the side it is on:
#
#   seeded once   Settings/ Templates/ AddIns/ projects/ Examples/ Documentation/
#                 The user's work. Never refreshed, so an upgrade cannot eat it.
#   symlinked     Compilers/ Controls/ Resources/ Help/ CHMVIEW/ Toolchain/
#                 Bulk read-only payload. Recreated every launch: an AppImage
#                 mounts at a new path each run, so yesterday's links are stale.
#   real copies   ilwaco ilwaco-mcp ilwaco.sh license.txt
#                 Must be real for the ExePath reason above. Refreshed when the
#                 payload carries a different build, so upgrading the package
#                 upgrades the IDE.
#
# Usage:  seed-app-home.sh <payload-dir> <app-home>
#
set -euo pipefail

PAYLOAD="${1:?seed-app-home.sh: no payload directory given}"
APPHOME="${2:?seed-app-home.sh: no app home given}"

die() { echo "Ilwaco: $*" >&2; exit 1; }

[ -d "$PAYLOAD" ] || die "broken package: $PAYLOAD is missing"

mkdir -p "$APPHOME" || die "cannot create $APPHOME"
[ -w "$APPHOME" ]   || die "$APPHOME is not writable"

# --- seeded once, then owned by the user -------------------------------------
for d in Settings Templates AddIns projects Examples Documentation; do
	[ -e "$APPHOME/$d" ] && continue
	if [ -d "$PAYLOAD/$d" ]; then cp -a "$PAYLOAD/$d" "$APPHOME/$d"; else mkdir -p "$APPHOME/$d"; fi
done
mkdir -p "$APPHOME/Temp"

# --- bulk read-only payload: relinked every launch ---------------------------
for d in Compilers Controls Resources Help CHMVIEW Toolchain; do
	[ -e "$PAYLOAD/$d" ] || continue
	rm -rf "$APPHOME/$d"          # may be a stale symlink from a previous mount
	ln -s "$PAYLOAD/$d" "$APPHOME/$d"
done

# --- real copies -------------------------------------------------------------
for f in ilwaco ilwaco-mcp ilwaco.sh license.txt; do
	src="$PAYLOAD/$f"
	[ -f "$src" ] || continue
	if [ ! -f "$APPHOME/$f" ] || [ "$src" -nt "$APPHOME/$f" ] \
	   || [ "$(stat -c %s "$src")" != "$(stat -c %s "$APPHOME/$f")" ]; then
		cp -f "$src" "$APPHOME/$f.tmp$$" && mv -f "$APPHOME/$f.tmp$$" "$APPHOME/$f"
	fi
done
chmod +x "$APPHOME/ilwaco" "$APPHOME/ilwaco.sh" 2>/dev/null || true
[ -x "$APPHOME/ilwaco.sh" ] || die "broken package: no launcher in $PAYLOAD"
