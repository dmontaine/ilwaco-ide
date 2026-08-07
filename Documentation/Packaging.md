# Packaging Ilwaco — the AppImage and its bundled toolchain

The target is the audience: a teacher, student or hobbyist downloads **one file**, makes it
executable, and both *runs* Ilwaco and *compiles FreeBASIC* with it — nothing installed, no
`apt install`, no `-dev` packages. This document records what that costs, what is built so far,
and the decisions taken along the way.

Scripts live in [`Packaging/`](../Packaging). User-editable data (Projects, Examples,
Documentation) lives **outside** the read-only image and is seeded on first run.

---

## Status

| Piece | State |
| --- | --- |
| Bundled link toolchain (`as`, `ld`, gcc stub, C sysroot) | **Done** — `Packaging/make-toolchain.sh`, proven by `Packaging/verify-toolchain.sh` |
| GTK link targets generated against the host runtime | **Done** — `Packaging/gen-gtk-links.sh` |
| `-gen gas64` for user compiles | **Done** — already emitted by the IDE; see "The gcc question" below |
| Staged release tree | **Done** — `Packaging/StageRelease.sh` → `../ilwaco-ide-release` |
| Single-file installer | **Done** — `Packaging/BuildInstaller.sh` → `../ilwaco-ide-installer/Ilwaco-IDE-<ver>-x86_64.run` (52 MB); install, launch, compile and upgrade all verified |
| AppDir layout + `AppRun` | **Done** — `Packaging/build-appdir.sh` + `Packaging/AppRun`; launched and verified |
| Writable user-data dirs, seeded on first run | **Done** — no IDE source changes needed |
| Wrapping the AppDir into a `.AppImage` | Wired up in `BuildInstaller.sh`, but untested — needs `appimagetool` |
| Building on an old-glibc host | Not set up |

## How a release is built

Two commands, following the same shape as Astoria's `StageRelease.ps1` + `BuildInstaller.ps1`:

```bash
Packaging/StageRelease.sh      # -> ../ilwaco-ide-release
Packaging/BuildInstaller.sh    # stages, then -> ../ilwaco-ide-installer (one file)
```

Both output directories are **siblings of the repo**, so they are never tracked by git regardless
of `.gitignore` — only the scripts are. Override with `ILWACO_RELEASE_DIR` / `ILWACO_INSTALLER_DIR`.
Each clears its target on every run and refuses to proceed if the path does not end with the
expected name, so a future edit cannot point the delete somewhere unintended.

**The staged tree is exported with `git archive HEAD`, not copied from the working tree.** This is
Astoria's rule and it was learned expensively there: a working-tree copy shipped 187 MB of test-build
output, a complete nested `.git` repository, a stale untracked folder, and the developer's own
per-session workspace file. No exclusion list would have caught the next one. The consequence to keep
in mind is that `./ilwaco` and `./ilwaco-mcp` are **tracked binaries**, so a release ships whatever
was last *committed* — build and commit before staging. `StageRelease.sh` warns when the working tree
and `HEAD` disagree.

What ships is the runtime: the binaries, the bundled compiler and link toolchain, `Controls/`,
`Templates/`, `Resources/`, `Help/`, `AddIns/`, `Examples/`, `Settings/`, `CHMVIEW/`, and the
user-facing half of `Documentation/`. What does not: `src/`, `Packaging/`, `Tools/`, the build
scripts, the IDE's own project file, and the maintainer documents (the port backlog and parity
record, the test plan, the per-control matrix, the upstream-defect write-up, this file, and the
debt register). `Testing.md` is deliberately kept — it is addressed to outside testers and its
whole value is saying where the thin ice is. `Controls/` ships **with** its `.bas` sources on
purpose: every `Form.frm` does `#include once "mff/Form.bi"`, and that header text-includes its own
implementation, so a prebuilt `.so` plus headers is not enough for a user's project to compile. GPL
source access for the IDE's own `src/` is satisfied by the GitHub repository, not by this tree.

The staged tree is laid out **exactly as an installed Ilwaco** — binaries at the root, the
directories the IDE expects beside them, and `ilwaco.sh` to launch it. That is what lets both
packaging routes fall out of one staging step, shipping byte-identical content.

### Why a `.run` and not a self-extracting zip

A self-extracting zip is the Windows idiom, and `unzip` is not guaranteed on a minimal Linux
install, whereas `tar` and `gzip` effectively are. So the default output is a self-extracting shell
archive — a shell script with a `tar.gz` appended, the makeself pattern — which needs nothing
installed either to build or to run. It takes `--dir` and `--force`, adds a per-user menu entry (no
root anywhere), and on reinstall **keeps `Settings`, `Projects`, `Examples`, `Documentation`,
`Templates` and `AddIns`** while replacing everything else, so an upgrade never eats a user's work.

The better single-file answer on Linux, and the format already chosen for the primary download, is
an **AppImage**: one file, `chmod +x`, run, with no extraction step at all. `BuildInstaller.sh`
emits that instead when `appimagetool` is on `PATH`. It is not on this machine, and fetching it is a
download that needs the owner's approval — so that branch is written but has never run.

---

## Why a bundled toolchain is needed at all

The bundled FreeBASIC compiler directory ships **only `fbc`**. Turning a `.bas` into an executable
also needs, all from the host, all of them `-dev` packages a fresh desktop does not have:

- an assembler and linker — `as`, `ld` (`binutils`);
- the C startup objects — `crt1.o`, `crti.o`, `crtn.o` (`libc6-dev`);
- gcc's link objects — `crtbegin.o`, `crtend.o`, `libgcc.a`, `libgcc_eh.a`;
- unversioned `.so` link targets for libc/libm/ncurses/GTK (every relevant `-dev` package);
- **`gcc` itself** — fbc runs `gcc -print-file-name=<obj>` to locate the crt objects above.

**The failure is silent, which is why it was under-scoped for so long.** Measured 2026-08-07: with
no `gcc` on `PATH`, fbc does not report a missing compiler. It quietly drops *every crt object*
from the `ld` command line and the link dies further along on `cannot find -lgcc`. Nothing in that
message points at the real cause.

## What ships, and how the pieces fit

`Packaging/make-toolchain.sh <outdir>` assembles roughly **12 MB**:

- `bin/as`, `bin/ld` — tiny `/bin/sh` wrappers around `libexec/*.real`, setting `LD_LIBRARY_PATH`
  to the toolchain's own `libexec/lib` (libbfd, libctf, …). Wrapping keeps the bundled binutils
  libraries off the *application's* library path, where they could shadow the host's. The wrappers
  use `${0%/*}` rather than `dirname`, because fbc may spawn them with a `PATH` that contains
  nothing but the bundled `bin`.
- `bin/gcc` — a **stub**. Under `-gen gas64` fbc never compiles C; it only *probes* gcc for crt
  paths. The stub answers those probes from the bundled sysroot and refuses anything else with a
  clear message. It must reproduce all three of real gcc's `-print-file-name` behaviours — resolve
  against gcc's libdir, then the target libdir, then echo the bare name — because fbc's link line
  is only correct if it does.
- `sysroot/` — the crt objects, `libgcc`, and the libc/libm/ncurses link targets, laid out so
  fbc's own `<gcclibdir>/../../../x86_64-linux-gnu/` path arithmetic lands *inside* the sysroot.

Two host artefacts had to be rewritten rather than copied: `libc.so` and `libm.so` are **ld scripts
naming absolute host paths**, which would send the linker straight back out to the host. They are
regenerated with bare library names, which `ld` resolves through its `-L` search path — i.e. inside
the sysroot.

## Why GTK is *not* bundled

Linking `-lgtk-3` needs a file literally named `libgtk-3.so`, which only the `-dev` package ships,
while every desktop has `libgtk-3.so.0`. Bundling GTK would solve that but buys nothing: **the
Ilwaco binary is itself dynamically linked against the host's `libgtk-3.so.0`**, so a host GTK3
runtime is already a hard requirement for the IDE to start at all. Bundling would add ~19 MB of
directly-linked libraries (far more with the transitive closure) plus the usual AppImage GTK tax —
gdk-pixbuf loader caches, gio modules, immodules and theme engines that must be regenerated per
host or the app renders unthemed.

So `Packaging/gen-gtk-links.sh` creates the unversioned symlinks against whatever runtime GTK the
machine has, at startup, into a writable cache directory (the image is read-only and the host's
versions are not knowable before then). If a *core* GTK library is genuinely absent it fails with a
message naming it — better than letting the user hit `cannot find -lgtk-3` from inside the IDE.

## Verifying it — the check that matters

`Packaging/verify-toolchain.sh <toolchain-dir> [gtk-link-dir]` compiles with `env -i` and a `PATH`
containing **only** the bundled `bin`, so any accidental reach back into `/usr/bin` or a host `-dev`
package fails *here* rather than on a user's machine. It covers a console program (crt objects,
libgcc, ncurses — the part that breaks silently without gcc), builds and *runs* it, a GTK program
(the generated `.so` link targets), and then scans the `-v` link line for host paths.

That last check is easy to write so that it cannot fail. Two things it must get right, both learned
by getting them wrong: the compile has to run with `-v` or the log is empty and the scan is
vacuous; and the toolchain's own paths contain `/bin/../sysroot/…`, which a naive substring search
flags as if it were host `/bin`, so owned prefixes are rewritten to markers first. **Confirm a
green result by sabotage** — pointing the gcc stub at the host `/usr/bin/gcc`, or removing the
bundled `crt1.o`, must both turn it red. Both were checked on 2026-08-07.

## The gcc question — settled: gas64

Everything above depends on compiling user projects with **`-gen gas64`**, which needs no C
compiler. FreeBASIC's default on x86_64 is `-gen gcc`, which shells out to a real `gcc` — bundling
one would add well over 100 MB and a second sysroot. Confirmed by the owner on 2026-08-07: Ilwaco
goes with gas64. It is also what the Integrated debugger was verified viable on.

**This needs no change — the IDE already emits it**, in the two places that assemble an fbc command
line, both gated on there being a project:

- `GetFirstCompileLine` in [`src/TabWindow.bas`](../src/TabWindow.bas) — the shared builder;
- `Compile` in [`src/Main.bas`](../src/Main.bas), which appends it again on top of the line the
  builder already returned. Harmless (fbc takes the last `-gen`), but redundant.

The project gating is correct and must stay: **Ilwaco has no loose single-file compiles — everything
is a project**, so "no project" is not a case that needs covering. Ilwaco is therefore gas64-only,
with no backend picker, which is why the GCC/CLANG-only optimization and `-Wc` warning options were
removed from the UI.

## The AppDir, and why the IDE cannot run from inside the image

Ilwaco resolves everything relative to FreeBASIC's `ExePath()` — Settings, Templates, Compilers,
Resources, Temp — and it **writes** to several of them: `Settings/ilwaco.ini` and
the per-session workspace file on exit, `Temp/Compile.log` on every build, `.bak` files on save. An
AppImage is a read-only squashfs, so the IDE cannot simply run from inside it.

The obvious fix — symlink the binary into a writable directory — does not work. **`ExePath()`
resolves symlinks** (measured 2026-08-07: it reads `/proc/self/exe`, so a symlink into the image
reports the *image's* path). Only a real file in a writable directory yields a writable `ExePath`.

So `AppRun` maintains a writable **app home**, `~/Ilwaco` by default (`ILWACO_HOME` overrides):

| In `~/Ilwaco` | What it is |
| --- | --- |
| `ilwaco`, `ilwaco-mcp` | **real copies** — `ExePath()` must be writable. Refreshed when the image ships a different build, so upgrading the AppImage upgrades the IDE |
| `Settings/`, `Temp/` | real and writable; the IDE writes these |
| `Projects/`, `Examples/`, `Documentation/`, `Templates/`, `AddIns/` | the user's work — seeded once, then **never touched again**, so edits survive an upgrade |
| `Compilers/`, `Controls/`, `Resources/`, `Help/`, `CHMVIEW/` | symlinks into the mounted image |
| `.toolchain/`, `.link-shim/` | the bundled toolchain, and the generated GTK link targets |

The image mounts at a different path every run (`/tmp/.mount_XXXXXX`), so **every symlink into it is
stale by the next launch**. `AppRun` recreates them on each start, which is cheap and also picks up
an upgraded image. The two paths baked into the IDE's settings — `.toolchain` and `.link-shim` —
are stable precisely because they live in the app home rather than in the image.

### Settings the shipped INI cannot carry

Two things in the tracked `Settings/ilwaco.ini` are wrong for a packaged build: the `[Compilers]`
block still points at the original author's machine (`/mnt/media/FreeBasic/…`), and nothing tells
fbc where the bundled link sysroot is. `AppRun` patches both when it first seeds the app home,
because the values depend on where the app home lands. It changes **values only** — never the shape
of `[Compilers]`, whose parser is fragile about being restructured — and only on first seed, so a
user's later edits are never overwritten.

That patcher has one trap worth remembering: **`ilwaco.ini` starts with a UTF-8 BOM**, so its first
line is not literally `[Parameters]`. A naive section compare silently skips that whole section
while later sections patch correctly — which is exactly what happened on the first run here. The
patcher now compares against a BOM-stripped copy, and *verifies each key landed*, because a miss is
otherwise invisible until the user's first build fails deep inside fbc.

`AppRun` does only the materialisation; everything machine-specific — the GTK link targets, the
first-run settings, `PATH` and `LD_LIBRARY_PATH` — is `ilwaco.sh`'s job, shared with installed
copies, so there is one launch path rather than two that can drift.

### What has been verified

All on 2026-08-07, on this machine.

**Installer route:** `BuildInstaller.sh --run` produced a 52 MB single file. Installing it into a
clean directory laid out the tree, patched all three settings to the install path, and wrote a
per-user menu entry; `ilwaco.sh` launched the IDE (window opens, only the known-harmless
`AppAddin`/`AppConsole` resource warnings). A real MFF GUI example
(`Examples/Class Form Example.bas`) compiled from the installed tree and **the resulting program ran
and opened its window**. Re-running the installer over that installation upgraded the binary while
**leaving a user file in `Projects/` and a hand-edited `Settings/ilwaco.ini` untouched**.

**AppImage route:** `build-appdir.sh` produced a 121 MB AppDir from the same staged tree; `AppRun`
seeded a clean app home, relinked the payload, and reached the same running IDE.

Still unverified: driving a build *from inside the IDE's own UI* rather than reproducing its command
line, and the `appimagetool` branch of `BuildInstaller.sh`.

## Glibc floor

`make-toolchain.sh` must run on the **oldest glibc we intend to support**: the crt objects and the
libc link target it captures set the floor for every program a user compiles with Ilwaco. glibc is
backward- but not forward-compatible. The same rule already applies to building the `ilwaco` binary
itself — a previously committed prebuilt needed `GLIBC_2.42` and would not start on Debian 13;
the from-source build needs only `GLIBC_2.34`.

Note the distinction: a user's *compiled program* runs fine against any host `libc.so.6` at or above
the floor. The pieces the AppImage supplies are strictly **link-time**.
