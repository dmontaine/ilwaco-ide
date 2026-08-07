#!/usr/bin/env bash
#
# StageRelease.sh — assemble a clean, end-user-facing release tree for Ilwaco.
#
# The Linux counterpart of Astoria's StageRelease.ps1, and it keeps that script's
# two hard-won rules:
#
#   1. SOURCE OF TRUTH IS THE COMMIT, NOT THE WORKING TREE. Content is exported
#      with `git archive HEAD`, so a file that is not committed cannot ship.
#      Astoria learned this the expensive way: a working-tree copy shipped 187 MB
#      of test-build output, a complete nested .git repository, a stale folder
#      with no tracked files, and the developer's Settings/Workspace.ini. No
#      exclusion list would have caught the next one.
#
#   2. The release tree lives OUTSIDE the repo, so it is never tracked by git
#      regardless of .gitignore — only this script is.
#
# The consequence to keep in mind: ./ilwaco and ./ilwaco-mcp are tracked binaries
# (owner directive — the repo moves between machines), so a release ships
# whatever was last COMMITTED, not what you last built. Build with
# ./build-linux.sh and commit before staging. This script warns when the working
# tree and HEAD disagree.
#
# WHAT THE TREE IS
# ----------------
# Unlike Astoria's, this tree is not just "files to hand out" — it is laid out
# exactly as an installed Ilwaco: the binaries at the root, the directories the
# IDE expects beside them, and `ilwaco.sh` to launch it. That is what makes both
# packaging routes fall out of one staging step. See Documentation/Packaging.md.
#
# Usage:  Packaging/StageRelease.sh [outdir]
#         default outdir: ../ilwaco-ide-release (sibling of the repo)
#         override with ILWACO_RELEASE_DIR
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE="${1:-${ILWACO_RELEASE_DIR:-$(dirname "$REPO")/ilwaco-ide-release}}"

die() { echo "StageRelease.sh: error: $*" >&2; exit 1; }

# This script clears its target on every run. Guard against a future edit
# pointing it somewhere unintended — the same sanity check Astoria's has.
case "${RELEASE##*/}" in
	ilwaco-ide-release) ;;
	*) die "refusing to continue: release path '$RELEASE' does not end with 'ilwaco-ide-release'" ;;
esac
[ "$RELEASE" != "$REPO" ] || die "refusing to stage on top of the repo"

command -v git >/dev/null || die "git is required"
git -C "$REPO" rev-parse HEAD >/dev/null 2>&1 || die "not a git repository — cannot stage"
HEAD_SHORT="$(git -C "$REPO" rev-parse --short HEAD)"

echo "Repo:    $REPO"
echo "Release: $RELEASE"
echo "Commit:  $HEAD_SHORT"

# The release ships the COMMITTED binaries. Say so loudly if they differ.
if [ -n "$(git -C "$REPO" status --porcelain -- ilwaco ilwaco-mcp)" ]; then
	echo "StageRelease.sh: WARNING: ./ilwaco or ./ilwaco-mcp differ from HEAD." >&2
	echo "StageRelease.sh: the release ships the COMMITTED build, not the one on disk." >&2
	echo "StageRelease.sh: run ./build-linux.sh and commit first if that is not what you want." >&2
fi

EXPORT="$(mktemp -d)"
trap 'rm -rf "$EXPORT"' EXIT
git -C "$REPO" archive --format=tar HEAD | tar -x -C "$EXPORT" \
	|| die "git archive failed — release not staged"

rm -rf "$RELEASE"
mkdir -p "$RELEASE"

copy() {   # copy <path> [label]
	if [ -e "$EXPORT/$1" ]; then
		cp -a "$EXPORT/$1" "$RELEASE/$1"
	else
		echo "StageRelease.sh: warning: expected '$1' not found in the commit, skipped" >&2
	fi
}
prune() {  # prune <path-inside-release>
	[ -e "$RELEASE/$1" ] && rm -rf "$RELEASE/$1" && echo "  pruned  $1"
	return 0
}

# --- runtime artefacts, not source -------------------------------------------
for f in ilwaco ilwaco-mcp license.txt ilwaco.desktop; do copy "$f"; done
chmod +x "$RELEASE/ilwaco" "$RELEASE/ilwaco-mcp" 2>/dev/null || true

# --- directories the installed IDE needs beside its binary -------------------
#  Compilers  bundled fbc — users compile their own programs with it
#  Controls   MFF: ships WITH its .bas sources on purpose. Every Form.frm does
#             #include once "mff/Form.bi", and that header text-includes its own
#             .bas implementation — FreeBASIC's Type system needs the full
#             definition, so a prebuilt .so plus headers is not enough for a
#             user's project to compile. GPL source access for the IDE's own
#             src/ is satisfied by the GitHub repository, not by this tree.
#  Templates  New Project / New File skeletons, used at runtime
#  Resources  icons/images the IDE loads at runtime
#  Help       in-IDE help content
#  AddIns     compiled IDE add-ins
#  Examples   kept WITH source deliberately — they teach the framework
#  Settings   default configuration
#  CHMVIEW    the help viewer the IDE shells out to
for d in Compilers Controls Templates Resources Help AddIns Examples Settings CHMVIEW Documentation; do
	copy "$d"
done
mkdir -p "$RELEASE/projects" "$RELEASE/Temp"

# --- prunes ------------------------------------------------------------------
# The compiler's own manual and samples duplicate our Help/ and Examples/.
prune "Compilers/FreeBASIC-1.10.1-linux-x86_64/doc"
prune "Compilers/FreeBASIC-1.10.1-linux-x86_64/examples"
# Build-time artefacts: the compiler tarball, and the from-source dev shim that
# the bundled Toolchain/ below replaces.
find "$RELEASE/Compilers" -maxdepth 1 -name '*.tar.xz' -delete
prune "Compilers/shim"

# Vendored, uncurated example folders inside third-party controls.
find "$RELEASE/Controls" -depth -type d -iname examples -exec rm -rf {} + 2>/dev/null || true

# Per-session state: shipping one would restore a stranger's open tabs.
prune "Settings/Workspace.ini"

# Documentation/: ship what a USER needs. What does not ship is this project's
# own working material — the port backlog and parity record, the test plan and
# per-control matrix, the write-up of defects in upstream code, the packaging
# and MCP design notes, and the debt register. Testing.md is deliberately KEPT:
# it is addressed to outside testers and its whole value is saying where the
# thin ice is. AgentMcpSetup.md is the user-facing half of the MCP story, so it
# stays while McpServer.md (the design) goes.
for doc in AstoriaDetailedChangeLog.md AstoriaParity.md TestPlan.md ControlTesting.md \
           UpstreamFixes.md Packaging.md McpServer.md TechnicalDebt.md; do
	prune "Documentation/$doc"
done

# --- the bundled link toolchain ----------------------------------------------
# Ilwaco-specific, with no Astoria equivalent: on Windows the bundled compiler
# directory already carries a complete MinGW, whereas the Linux fbc ships only
# fbc itself and leans on host -dev packages that a fresh desktop lacks.
# Captured from THIS machine, so stage releases on the oldest glibc you intend
# to support (Documentation/Packaging.md, "Glibc floor").
"$REPO/Packaging/make-toolchain.sh" "$RELEASE/Toolchain" >/dev/null \
	|| die "make-toolchain.sh failed — release not staged"

# --- launcher ----------------------------------------------------------------
cp "$REPO/Packaging/ilwaco.sh" "$RELEASE/ilwaco.sh"
chmod +x "$RELEASE/ilwaco.sh"
cp "$REPO/Packaging/gen-gtk-links.sh" "$RELEASE/Toolchain/gen-gtk-links.sh"
chmod +x "$RELEASE/Toolchain/gen-gtk-links.sh"

# Settings whose values are only knowable once Ilwaco is installed somewhere:
# ilwaco.sh applies these on first run, substituting the install path for
# @APPHOME@. Values only — never the shape of [Compilers], whose parser is
# fragile about the block being restructured.
cat > "$RELEASE/Settings/.seed-patch" <<'EOF'
# Applied by ilwaco.sh on first run; "@APPHOME@" becomes the install directory.
[Parameters]
Compiler64Arguments=-b {S} -exx -p "@APPHOME@/Toolchain/sysroot/lib/x86_64-linux-gnu" -p "@APPHOME@/.link-shim"
[Compilers]
DefaultCompiler64=fbc
Version_0=fbc
Path_0=@APPHOME@/Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc
EOF

# --- everything else is intentionally NOT copied -----------------------------
#   src/                      the IDE's own source (GitHub satisfies GPL access)
#   Packaging/                these scripts — build plumbing, not a user feature
#   Tools/                    Windows-native utilities (COMWrapperBuilder,
#                             ControlSpy, SPY, depends), the removed translation
#                             system's LNGCreator, and DocCheck.py, which acts on
#                             this repo's own doc tree
#   build-linux.sh            builds the IDE itself
#   ilwaco.vfp / .vfs         the IDE's own project file
#   PROJECT_STATUS, HISTORY, CLAUDE, CHANGELOG, README, *_Change.log,
#   changes_en.txt            maintainer-facing
#   .claude .vscode *.code-workspace   dev tooling
#   projects/ Temp/           local scratch — recreated empty above

echo ""
echo "StageRelease.sh: staged $RELEASE from commit $HEAD_SHORT"
echo "StageRelease.sh: $(find "$RELEASE" -type f | wc -l) files, $(du -sh "$RELEASE" | cut -f1)"
