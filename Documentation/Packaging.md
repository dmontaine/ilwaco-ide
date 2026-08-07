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
| `-gen gas64` for user compiles | **Open decision** — see "The gcc question" below |
| AppDir layout + `AppRun` | Not built |
| Writable user-data dirs, seeded on first run | Not built (needs IDE source changes) |
| Wrapping the AppDir into a `.AppImage` | Not built (needs `appimagetool`) |
| Building on an old-glibc host | Not set up |

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

## The gcc question — an open decision

Everything above depends on compiling user projects with **`-gen gas64`**, which needs no C
compiler. FreeBASIC's default on x86_64 is `-gen gcc`, which shells out to a real `gcc` — bundling
one would add well over 100 MB and a second sysroot.

The IDE therefore has to pass `-gen gas64` when it compiles user projects, which is a settings /
source change that has not been made yet. The trade-off to weigh before making it: gas64 is the
less battle-tested of the two backends, so codegen differences would land on users. In its favour,
Ilwaco's Integrated debugger was already verified viable on gas64/Linux.

## Glibc floor

`make-toolchain.sh` must run on the **oldest glibc we intend to support**: the crt objects and the
libc link target it captures set the floor for every program a user compiles with Ilwaco. glibc is
backward- but not forward-compatible. The same rule already applies to building the `ilwaco` binary
itself — a previously committed prebuilt needed `GLIBC_2.42` and would not start on Debian 13;
the from-source build needs only `GLIBC_2.34`.

Note the distinction: a user's *compiled program* runs fine against any host `libc.so.6` at or above
the floor. The pieces the AppImage supplies are strictly **link-time**.
