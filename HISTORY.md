# Ilwaco IDE — Session History

**Extracted from [PROJECT_STATUS.md](PROJECT_STATUS.md) on 2026-08-03.** These are the session handoffs
that have scrolled off the top of PROJECT_STATUS — a faithful record kept for provenance, newest-first.
They are **snapshots of their own moment**: some describe state (e.g. the shim living only in scratchpad,
work "staged/uncommitted") that later sessions superseded. For the **current** state, next actions, and
the live build/run recipe, always read [PROJECT_STATUS.md](PROJECT_STATUS.md) — not this file.

For the mission, the port method, and the Linux/GTK build rules, see [CLAUDE.md](CLAUDE.md);
for the classified port backlog, [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md).

---

## ⏳ HANDOFF (2026-08-08) — framework license headers + deep-clean removals done; Stage A stash lost

Builds on the prior session's framework rename `Controls/MyFbFramework` → `Controls/Framework`
(committed `55745b8`). This session:

**1. DONE — LGPL modification header on every framework source file.** The original *"This file is part
of MyFBFramework"* attribution is **kept**; the *"Ilwaco IDE Modifications / copyright 2026 Donald
Montaine"* LGPL v3 block is **appended below it** on all **199** retained `Controls/Framework/mff/*.bi`
and `*.bas`, placed exactly per Astoria's own rules (after the `'###`/`'***` attribution box; after the
zlib `''` header; at the top for header-less files). Idempotent, verified against Astoria. Files were
also **converted to LF** (only `mff.bi`/`mff.bas`/`mff.rc` were CRLF).

**2. DONE — two dead MFF designer components removed** (no-dead-code policy, ahead of the scheduled
deep-clean): **`HTTPServer.{bi,bas}`** (matches Astoria `4a0798bf`; kept the HTTP client +
`HTTPConnection` — edited `mff.bi` include/registration, `mff.rc`, `Framework.vfp`, and
`src/TabWindow.bas:3592`) and **`NativeFontControl.{bi,bas}`** (already dead here — commented includes —
and dropped upstream + in Astoria; also removed its `Framework.vfp`/`mff.rc` refs). Recorded in
[IlwacoIDESignificantChanges.md](Documentation/IlwacoIDESignificantChanges.md) §2 + `REMOVED_FEATURES`.

**3. DECISION — framework BOMs KEPT deliberately.** No-BOM was requested, but a UTF-8 BOM is what makes
the framework's bare `""` literals wide (`WString`), so a blanket strip breaks the build (`SysUtils.bas
error 318`). Astoria's route was to strip **and** rewrite every literal to `WStr("")` — a large pass it
never finished (8 framework + 11 `src/` files still BOM'd there). **Measured that a framework BOM cannot
harm a user app:** a BOM is scoped to its own file and does *not* leak into an including file's literals
(compiled include-scoping test, FB 1.10.1). So Ilwaco keeps the framework BOMs; the discipline that
matters (never *write* a BOM; keep user-facing Example/Template source BOM-free) is unchanged. **DONE
(2026-08-08):** the 9 Example/Template `.vfp` BOMs were stripped, and `SaveProject` now removes the BOM
its `Encoding "utf-8"` write adds (new `StripUtf8Bom`, `Main.bas`), so saved projects stay BOM-less.

**4. Build-verified GREEN** — `./build-linux.sh lib` and `editor` both exit 0; `ilwaco` and
`Controls/Framework/libmff64_gtk3.so` are rebuilt and staged with the source.

**5. New record — [AstoriaFindings.md](Documentation/AstoriaFindings.md)** (owner, 2026-08-08): defects
found in **Astoria's own** Win64 code during the port, to feed back when Astoria unfreezes — the mirror
of [UpstreamFixes.md](Documentation/UpstreamFixes.md) (shared-upstream bugs). Wired into the TestPlan
rule table; `DocCheck` green.

**6. LOST — the Stage A (tcView bottom button row) `git stash` is GONE.** A stash is local to a working
copy and does **not** travel through `origin`; this is a fresh sandbox, so it is unrecoverable here.
Redo it from the design notes in the `Docs: stage the remaining UI work` commit and
[AstoriaParity.md](Documentation/AstoriaParity.md) "UI work — staged sequence": the tcView row (order
**Code · Code And Form · Form**, text labels via `FCaption` + `gtk_toolbar_set_style(...,
GTK_TOOLBAR_BOTH_HORIZ)`, reorder the three `Add` calls — handlers key off `Button.Name`, not index),
then re-test the view-switch crash on a *form* (`gtk_container_propagate_draw: GTK_IS_WIDGET(child)
failed`) against the now-present `Controls/Framework` library. Also still open: the benign
`CurrentView() = "Code"` → `CBool(...)` warning wrap in `src/TabWindow.bas`.

**Resume order:** (i) redo Stage A from the notes (piece 6); (ii) the parity tail. *(The 9 `.vfp` BOM
fix is DONE — see piece 3.)*

---

## ✅ DONE (2026-08-07) — Ilwaco ships three ways: `.deb`, `.rpm` and a no-root `.tar.gz`

Owner directive: ".deb and .rpm — between them they cover over 90% of the Linux market", then the
clarifying concern, "what about a user who wants to use Ilwaco but does not have root access". The
resolution is **two tiers chosen by one question — does the user have root**, documented for users in
the new [Installation.md](Documentation/Installation.md) and for maintainers in
[Packaging.md](Documentation/Packaging.md).

| user | artefact | root? |
| --- | --- | --- |
| own laptop | `.deb` (39 MB) / `.rpm` (47 MB) — double-click install, menu entry, `apt`/`dnf` upgrades | yes |
| managed school/work machine | `.tar.gz` (44 MB) wrapping the AppImage | **no** |

**The bare `.AppImage` is no longer offered.** It is shipped inside the `.tar.gz` because tar restores
mode 755 while a browser download is always 644 — so the no-root path needs **no `chmod`**, verified
by extracting and checking the bit. Offering both would invite a beginner to pick the dead-end one.

**One implementation of the writable-home problem.** A system package installs a *root-owned*
payload, and the IDE cannot run from a directory it cannot write to (`ExePath()` follows symlinks) —
the identical constraint the AppImage hit. So `Packaging/seed-app-home.sh` was factored out of
`AppRun` and is now shared by both routes; `/usr/bin/ilwaco` (`Packaging/ilwaco-launcher`) is a
12-line wrapper over it. `/opt/ilwaco-ide` holds only the immutable payload; every user still gets
their own `~/ilwaco-ide` with **no per-user configuration**.

**The two dependency traps, both real, both caught before shipping:**
- **RPM:** Fedora/RHEL call the GTK package `gtk3`, SUSE calls it `libgtk-3-0`, so a name-based
  `Requires:` reaches at most two of the three. rpmbuild's **SONAME** auto-requires
  (`libgtk-3.so.0()(64bit)`) satisfy all three — the auto-generated deps *are* the portability
  mechanism. But the generator had to be fenced off the bundled toolchain: `fbc` needs
  `libtinfo.so.5`, which we ship ourselves and Fedora does not install, so an unfenced scan would
  have baked in an unsatisfiable dependency and made the package refuse to install. Verified: the
  built RPM requires `libtinfo.so.6` (legitimate, the IDE's own) and no `.so.5`.
- **DEB:** `dpkg-shlibdeps` names packages as the *build host* has them, and Debian's 64-bit `time_t`
  transition renamed `libgtk-3-0` → `libgtk-3-0t64` (plus glib, atk) in Debian 13 / Ubuntu 24.04
  while **Debian 12, Ubuntu 22.04 and Mint 21 keep the old names**. Built here, the first `.deb` was
  uninstallable on half the targets. Each renamed dep is now rewritten to an alternative,
  `libgtk-3-0t64 (>= 3.16.2) | libgtk-3-0 (>= 3.16.2)`, modern name first.

**Reinstall safety — the owner's explicit requirement — proven, not asserted.** Planted a project and
a custom setting in a seeded home, then re-ran both the package launcher and the real AppImage over
it: `projects/` came back **byte-identical**, the custom setting survived, and a user-edited example
survived. It holds at three independent levels: neither package contains any path under a home
directory at all (checked), their scriptlets touch only desktop/icon caches, and the seed loop skips
anything that already exists. Uninstalling deliberately leaves `~/ilwaco-ide` behind.

**A display is now required, and said so politely (owner, 2026-08-07).** "Ilwaco should never be
installed on a headless system — I would prefer it fail gracefully with a message that a display is
required." Implemented at **launch**, not install: an install-time check would misfire on the
ordinary `sudo apt install` over SSH into one's own desktop, where `DISPLAY` is unset on a machine
that plainly has a GUI (owner agreed, install left alone). `Packaging/ilwaco.sh` now exits 1 with a
plain message when neither `DISPLAY` nor `WAYLAND_DISPLAY` is set, and every shipped route launches
through it. **The obvious in-binary guard does not work** — a check at the top of `src/ilwaco.bas`
never runs, because GTK initialises in a global constructor and FreeBASIC runs those before the main
module's statements; it was tried, measured as ineffective, and reverted rather than left looking
like protection. Detail in [TechnicalDebt.md](Documentation/TechnicalDebt.md).

**Verified by effect:** the `.deb` extracted to a scratch root, its launcher run from there → seeded a
correct home → **the IDE opened on `:0`** with IntelliSense loaded, and the `/opt` payload was
confirmed untouched afterwards. With no display the same launcher prints the message and exits 1. Glibc floor 2.34 gives Debian 12+, Ubuntu 22.04+, Mint 21+,
Fedora 35+, RHEL 9+, openSUSE Leap 15.5+. **Not yet verified: installing the `.rpm` on real Fedora**
— it is built and inspected only (see NEXT 1).

---

## ✅ DONE (2026-08-07) — user-data dir is lowercase `projects`; the seed-patch can no longer break launch

**The rename (owner directive: "keep 'projects' lower case").** Every producer and consumer moved
together, because Linux is case-sensitive and a half-rename means the IDE writes to one directory
while the packaging seeds another. Nine files: `Packaging/AppRun` (seed loop), `Packaging/ilwaco.sh`
(`mkdir`), `Packaging/StageRelease.sh`, `Packaging/installer-header.sh` (the upgrade `--exclude` — a
miss here would have made an upgrade **overwrite the user's work**), `Settings/ilwaco.ini`
(`ProjectsPath`, `CommandPromptFolder`), `src/Main.bas` (both INI-read defaults), `src/frmOptions.frm`
(two designer defaults), and the `ExePath & "Projects"` fallbacks in `src/TabWindow.bas` (×2) and
`src/frmImageManager.frm`. The dev tree's own `Projects/` was `git mv`'d. **`Templates/Projects/` was
deliberately left capitalised** — it is the shipped New-Project template store, not the user's work.

**Verified by effect at all three layers**, not just compiled: `AppRun` against a stub payload seeds
`projects/` and no capital `Projects/`; `ilwaco.sh` `mkdir`s `projects/`; and the **running IDE**,
asked over the MCP socket for a new project, answered
`/home/don/Projects/ilwaco-ide/projects/RenameProbe/RenameProbe.vfp` — so `ProjectsPath` resolves
lowercase through the real code path.

**One adjacent defect fixed while in there:** `src/ilwaco.bas:74` built its no-main-file fallback as
`*ProjectsPath & "\1"` — a **Windows** separator. `GetFolderName` never finds a `\` on Linux, so
Run ▸ command prompt opened in the exe directory instead of the projects directory. Now uses `Slash`.

**The seed-patch is insert-if-missing (was replace-only).** `ilwaco.sh`'s first-run patch rewrote only
*existing* keys and `die`d if one was absent — so any future rename or reorder of `Compiler64Arguments`
or the `[Compilers]` keys would have broken **launch**, not merely a build. The awk now appends a
missing key to its section, and a missing section to the file. Six fixtures pass (replace; insert into
an existing section; append an absent section; BOM on line 1 preserved byte-for-byte; our section last
in the file; and a same-named key in a *different* section left untouched).

**FUSE was measured and is not the problem people assume.** Our AppImage carries the modern static-pie
[type2-runtime](https://github.com/AppImage/type2-runtime) — `readelf -d` shows **no `NEEDED` entries
at all**, so the widely-repeated "AppImages need `libfuse2`" is about the *old* AppImageKit runtime, not
ours. It wants a `fusermount` **binary** (`fuse3`, present on desktop Debian 13), and
`APPIMAGE_EXTRACT_AND_RUN=1` works with `fusermount` deliberately broken. What remains is the
executable bit, which is a packaging-format decision — see NEXT 1.

---

## ✅ DONE (2026-08-07) — Examples: 53 ported, broken half deleted, 54 build-verified through the SHIPPED toolchain

Owner-requested, superseding the "defer Examples to the testing phase" note. Ported: the whole
`Learning` course except its DLL series — **`Console` 25 + `GUI` 25** (renamed from Astoria's
`WinGUI`, a misnomer on GTK) — plus **`Calculator`, `FiveInARow`, `Maze`**. Every one was compiled
with the bundled toolchain **and run**: console programs to completion (exit 0), GUI programs to a
confirmed window on screen. All converted to UTF-8-no-BOM + LF on the way in.

**Copying was not enough — four defects had to be fixed**, three of them the same class: a
case-insensitive filesystem had hidden `mff/Textbox.bi`, `mff/sys.bi` and `maze.bi`, all of which are
`error 23` here. The fourth was `crHand`, Win32-only (`LoadCursor(0, IDC_HAND)`), substituted with
GTK's `crHandPoint`. Separately, **every** GUI example needed the `#ifdef __FB_WIN32__` guard restored
around its `#cmdline "*.rc"` — an INVERT of Astoria's Win64-only stripping, without which fbc stops at
`Executable not found: "windres"`. Detail in [UpstreamFixes.md](Documentation/UpstreamFixes.md).

**Held back:** the `Learning/DLL` series, because **fbc 1.10.1 `-gen gas64 -dll` segfaults** on two of
its four lessons (minimal repro in [TechnicalDebt.md](Documentation/TechnicalDebt.md)) — shipping a
numbered course missing lessons 2 and 3 is worse than shipping none. **This is bigger than the
examples:** Ilwaco compiles everything with `-gen gas64`, so a user building a shared library can hit
a compiler crash with no diagnostic. Not yet reported upstream. Also not ported, as Windows by nature:
the DirectShow, COM, SAPI and WLan sets, plus `Sudoku` and `MultipleDisplay`.

**Then the broken half was deleted and every example put in its own directory** (owner). The 22 audited
pre-existing projects, 6 stale Windows-era duplicates under `Examples/Game/`, four empty placeholder
dirs and an orphaned `Examples/Manifest.xml` were `git rm`'d; the retained candidates were re-evaluated
against a "delete unless the port is trivial" bar and **test-compiled** — `try_catch_throw`, `Add-In`,
`Web Page`, `Graphics/CanvasDraw` deleted; `Class Form Example` compiled clean and was **kept and
finished into a real project** (BOM stripped, `.vfp` added). `Examples/` now holds **54 projects, one
per directory**. Detail and the per-candidate reasons in [ExamplesAudit.md](Documentation/ExamplesAudit.md).

**Verified against the SHIPPED build path, not just the dev shim.** The earlier "compiled with the
bundled toolchain" runs used the dev shim (`-p <shim> -l tinfo`); this session reproduced the *shipped*
path — `Packaging/make-toolchain.sh` sysroot on PATH, only `libtinfo.so.5` on `LD_LIBRARY_PATH`, the
seed-patch's `-p sysroot -p .link-shim` link args, the IDE-appended `-gen gas64`, and the main file via
`-b "<file>"` (how `.frm` reaches fbc) — and swept **all 54: 54/54 build, 0 fail**. The one sharp edge:
without `-gen gas64` the bundled `gcc` is a **stub** (crt-probe only) and fbc's default `-gen gcc`
backend dies `no C compiler in the image` — but the IDE appends `-gen gas64` for **every project**
build (`src/Main.bas:714`, `src/TabWindow.bas:11546`), and seeded examples are all `.vfp` projects, so
the shipped path is sound.

---

## ✅ DONE (2026-08-07) — MCP write safety, then agent permission levels

**Write safety first, because no permission tier makes an unversioned clobber safe.** Two live
data-loss paths, found by reading the write path during the permissions discussion rather than from a
failure report: `write_file` wrote to disk with no check for an open dirty tab (the very thing
CLAUDE.md tells humans never to do), and `set_active_file_content` replaced the whole buffer with no
version check. Now `dirty_buffer` and an opt-in `expected_version`/`version_mismatch`; `read_file` and
`get_active_file` hand out the token. Detail in [McpServer.md](Documentation/McpServer.md).

**Then five permission levels** — Off / Read-only / Edit / **Build & Run** / Trusted — replacing the
`AllowAgentControl` boolean (owner-directed, 2026-08-07). **The default stays Build & Run**: Ilwaco is
agent-first, and a default that let an agent edit but not build would break the edit-build-fix loop.
So it is two opt-in restrictions below the old capability and one opt-in expansion above it. One combo
in Tools ▸ Options ▸ General (the old checkbox became its `Off` value — an option removed, not added),
the level shown in the status bar, `AllowAgentControl=true/false` migrating to `Build & Run`/`Off`, and
**one gate at the dispatcher** so no handler can forget; unclassified commands fail **closed**.

Verified by effect at four levels over the socket, plus the Options combo and status bar by screenshot.
**Trusted gates nothing yet** — the designer tools and outside-the-project access it is meant to unlock
are still to build, which is the point of landing the mechanism once.

**Next on this thread, in order:** the activity log (agent actions into a pane — arguably the highest
value of the three, since it is what makes the Edit level trustworthy), then the Trusted-level path
relaxation, then the designer tools. Per-client pairing was considered and **rejected**: on a
same-user Unix socket any process running as the user can already read the source or the pairing
token, so it buys accountability the activity log gives more cheaply, at the cost of the "it just
works" default.

---

## ✅ DONE (2026-08-07) — Ilwaco installs: release staging, installer, toolchain, AppDir

**There is a single-file AppImage, and it works.** Following Astoria's two-step pattern:
`Packaging/StageRelease.sh` exports a clean end-user tree (from `git archive HEAD`, never the working
tree — Astoria's expensive lesson) to `../ilwaco-ide-release`; `Packaging/BuildInstaller.sh` stages
then packages it into `../ilwaco-ide-installer/Ilwaco-IDE-1.3.8-x86_64.AppImage`, 49 MB. Verified:
**run → seeds `~/ilwaco-ide` + a valid menu entry → IDE opens → GUI example compiles and runs →
second launch relinks the payload to the new mount and starts clean.**

`BuildInstaller.sh --run` builds a 52 MB self-extracting fallback for machines without
`appimagetool`/FUSE; it was verified the same way, plus **reinstall over the top leaving a user's
project file and hand-edited INI untouched**. A `.run` rather than a self-extracting zip because
`unzip` is not guaranteed on a minimal Linux install while `tar`/`gzip` effectively are.

**Build-machine requirement:** `appimagetool` is not vendored (as Astoria does not vendor Inno Setup) —
installed at `~/.local/bin/appimagetool` from the official AppImage project release, needs FUSE.
Both routes install to **`~/ilwaco-ide`** and write **`~/.local/share/applications/ilwaco.desktop`**
(owner, 2026-08-07).

The staged tree is laid out **exactly as an installed Ilwaco**, so both packaging routes fall out of
one staging step and ship identical content. `ilwaco.sh` is the shared launcher; `AppRun` only
materialises a writable copy and hands over to it.

**The AppDir runs.** `Packaging/build-appdir.sh` assembles a 136 MB AppDir; `Packaging/AppRun` seeds a
writable app home, patches the settings the shipped INI cannot carry, regenerates the GTK link targets,
and launches the IDE. Verified end to end: window opens, and a real MFF GUI example compiled under
AppRun's environment with the seeded arguments then **ran and opened its own window**.

The design turns on one measurement: **`ExePath()` resolves symlinks**, so the IDE — which writes to
`Settings/`, `Temp/` and `.bak` files next to its own binary — cannot run from the read-only image, and
cannot be symlinked out of it either. `AppRun` therefore keeps **real copies** of the binaries in
`~/Ilwaco` (refreshed when the image ships a different build) and relinks the bulk read-only payload
into the image on every start, because the mount point moves each run. Two traps worth remembering are
in [Packaging.md](Documentation/Packaging.md): the shipped `[Compilers]` block still points at the
original author's machine, and **`ilwaco.ini`'s UTF-8 BOM** makes a naive `[Parameters]` section match
fail silently (it did, first run — the patcher now verifies each key landed).

### The bundled link toolchain

The hardest part of packaging is settled: **Ilwaco can now compile FreeBASIC with nothing from the host
but the kernel and the GTK/libc runtime a normal desktop already has.** Three scripts in
[`Packaging/`](Packaging), designed and verified this session; the full write-up, including the two
decisions below, is [Documentation/Packaging.md](Documentation/Packaging.md).

- **`make-toolchain.sh`** assembles ~12 MB: wrapped `as`/`ld` (with their private `libbfd` etc. kept off
  the app's library path), a **stub `gcc`**, and a minimal C link sysroot. Run it on the release machine.
- **`gen-gtk-links.sh`** generates the unversioned GTK `.so` link targets against the *host's runtime*
  at startup. **GTK is deliberately not bundled** — the `ilwaco` binary already links host
  `libgtk-3.so.0`, so a host GTK3 runtime is a hard requirement regardless; bundling would add ~19 MB
  plus the pixbuf-loader/gio-module/theme tax and buy nothing.
- **`verify-toolchain.sh`** compiles under `env -i` with only the bundled `bin` on `PATH`, runs the
  result, and scans the link line for host reach-back. Green, and **confirmed falsifiable**: pointing the
  gcc stub at `/usr/bin/gcc` and deleting the bundled `crt1.o` each turn it red.

**The finding that changes the plan:** fbc's *default* backend shells out to a real **`gcc`**, not just
`as`/`ld` as previously recorded — and with no gcc present it fails **silently**, dropping every crt
object from the `ld` line and dying later on `cannot find -lgcc`. The escape is **`-gen gas64`**, which
needs no C compiler; **owner confirmed 2026-08-07, and the IDE already emits it** on every compile path
(`GetFirstCompileLine` in `src/TabWindow.bas`, plus a redundant second append in `Compile` in
`src/Main.bas`). Both are gated on there being a project, which is correct — **Ilwaco has no loose
single-file compiles, everything is a project.** So no code change was needed.

---

## ✅ DONE (2026-08-07) — the shutdown SIGSEGV is diagnosed and fixed

The "intermittent SIGSEGV" that hampered `:0` verification for weeks is **resolved**. It was never
intermittent, never a startup/large-files bug, and not the threading arc — all three were inherited
assumptions. **Measured:** 23/23 launches — startup 100% clean, window-close 100% SIGSEGV. The real
variable was **`UseDebugger` on/off**, the default being off. Two distinct close-path crashes, both fixed
and **verified 20/20 clean close (exit 0), IDE renders correctly**:

1. **`frmMain_Close` dereferenced a null `Parent`.** With the debugger off, `SetDebugTabsVisible(False)`
   detaches the 7 debug panes (`DetachTab` → `Parent = 0`); the close handler read `tpLocals->Parent->Name`
   for all 18 panes unguarded. Fixed with a guarded `SaveTabPagePlacement` helper in `src/Main.bas`
   (skips a detached pane), collapsing 36 duplicated lines to 18 calls.
2. **Global-destructor use-after-free over freed GTK widgets (framework).** FreeBASIC runs every
   module-level destructor at `_GLOBAL__D` *after* `main()`, but GTK freed the widget tree on window
   close; each `GTK_IS_WIDGET(widget)` guard then dereferenced freed memory (crash site
   build-nondeterministic: `~Control`/`~ToolButton`/`~MenuItem`/…). **Win32 is safe here for free via
   `IsWindow()`; GTK has no equivalent.** Fixed the Astoria way — the framework fast-exits on **main-form**
   close: `mff/Form.bas`'s two main-form paths call a `CloseOnMainForm` doing libc `_exit(0)`, skipping the
   destructor walk (the GTK port of Astoria's `End 0`-on-close; Astoria itself fast-exits via
   `ExitProcess(0)`, §13.29). The fix lives in **MFF**, so **every MFF app** — not just the IDE — gets a
   clean shutdown; a per-object null-on-`"destroy"` alternative was tried and rejected as large *and*
   unreliable (the signal doesn't fire uniformly). No data loss: `IniFile` writes through on every write,
   and all app state is saved in `frmMain_Close` before the exit. Non-main forms still hide. Detail in
   [UpstreamFixes.md](Documentation/UpstreamFixes.md); memory `project-known-segfault-threading` rewritten.

---

## ✅ DONE (2026-08-06) — Delete File shipped with deferred deletion; three GTK defects fixed

`93bbfa28` S5 **plus** `331b5705` (B1), scoped against Astoria's *final* state rather than the handoff's
note — that note described `93bbfa28`'s intermediate version, which Astoria reworked twice afterwards
(`331b5705` deferred deletion, `273df0f5` merged "Remove" into "Delete File"). Owner chose **full
parity**, superseding the earlier "keep both commands" product call.

**Shipped:** one **Delete File** command (File menu, Project menu, tree context menu, explorer toolbar),
confirmation defaulting to No, tree-selection based. A project member is queued — `(pending delete)`,
project flagged `*` — and only `Kill`ed by `SaveProject` after the `.vfp` is written; **Cancel Deletion**
undoes it; Close Project lists queued files as informational rows. **Removed:** the old unconfirmed
`RemoveFileFromProject` (it silently deleted files off disk), and `frmSave`'s **10-second auto-Yes
countdown**, which would have executed deletions with no user action.

**Three pre-existing GTK defects found while verifying**, all fixed: the explorer context menu's state
handler (`tvExplorer_MouseUp`) could never fire on GTK — MFF only raises `OnMouseUp` when the event
window is the widget window, never true for a `GtkTreeView` — so the menu had shown stale captions and
enablement since the port (logic moved to `UpdateExplorerMenuState`, driven from `tvExplorer_SelChange`
plus an explicit refresh after delete/undo, since re-clicking the selected row fires no change);
`node->Text &= "*"` never repainted, hiding the project dirty marker (five live sites, now explicit
assignment); and `CloseProject`/`SaveAllBeforeCompile` read the save dialog *after* it was torn down
(now `.SelectedItems`, with the window-X close treated as Cancel). Details in
[UpstreamFixes.md](Documentation/UpstreamFixes.md) and [AstoriaParity.md](Documentation/AstoriaParity.md).

**Owner direction (2026-08-06): Ilwaco is for project-based development only — files outside a project
are not supported.** Astoria's `0c08fe5f` standalone-node `ExplorerElement` Tag was therefore ported and
then **reverted**; it is recorded N/A. Two follow-ups this raises, neither actioned: **File ▸ Open still
creates a root-level node for a file outside any project**, where Delete File is a no-op — constraining
that entry point is a product question; and `DeleteEditorFile`'s non-project branch is consequently
unreachable in supported use (Astoria's own code, kept as a guard, but a no-dead-code candidate).

Verified by effect on `:0` throughout, using the MCP agent to open projects: confirm → pending → Close
Project **Yes** deletes and rewrites the `.vfp`; **No** leaves file and `.vfp` untouched; Cancel Deletion
reverts and the file then survives a real save.

**Also this session — the whole remaining backlog was classified, and `13.71` was ported.** All **396**
entries are now judged in [AstoriaParity.md](Documentation/AstoriaParity.md) "Full classification pass"
(cluster-level, with its own confidence caveats; the backlog file was deliberately not pruned).
**`13.71`** — the serial IntelliSense loader (`31a5e20`) — call the new `SpawnLoader` from all five loader
sites (three in `AddProject`, `TabWindow.SaveTab`, `TabWindow.FormDesign`) running one at a time, with
`ClearLoaderQueue()` from `CloseProject`/`CloseWorkspace`; Astoria's `ASTORIA_T70_SERIALLOAD` env gate was
deliberately not ported (dead code). It is a correctness improvement (the race is real, the serial load is
strictly safer), **not** a fix for the shutdown SIGSEGV — which was separately diagnosed and fixed on
2026-08-07 (see PROJECT_STATUS). `13.72` (idle slices) stays deferred: it only removes a stall `13.71`
introduces that nobody has felt on a real project.

**Also this session — the product direction was set, and documented for users.** The owner recorded the
project-only stance and the four divergences (the STANDING table in PROJECT_STATUS), and asked that the
Ilwaco/Astoria differences be written down "in case users assume they are exactly the same". New
**[IlwacoVsAstoria.md](Documentation/IlwacoVsAstoria.md)** does that, separating what **ships today** from
what is **planned** (Git and the AI templates are in neither product yet) and correcting the comparison
easiest to get wrong — there are **two** theme capabilities and Astoria removed neither. `README.md` now
leads with the comparison and indexes the user-facing docs. One stale claim fixed:
`IlwacoIDESignificantChanges.md` had the multi-assistant AI integration under "features removed", which the
divergence decision reverses.

**Method note worth keeping.** The handoff's scoping for S5 was written against `93bbfa28` alone and was
wrong in two ways only a whole-log scan caught: Astoria reworked the feature twice afterwards, and the
"keep both Remove and Delete File" call had been made without knowing Astoria later merged them. It also
asserted `bNestedInProject = (tn->ParentNode <> 0)` was memory-safe "matching Win32" — true, but backwards:
loose files are *root* nodes (`ParentNode = 0`), and it is `CloseTab` freeing exactly those that makes the
final version's post-`CloseTab` node access unsafe. **Read the current source, not the previous session's
summary of it.**

---

## ✅ DONE (2026-08-06) — MCP server finished; menu-taxonomy cluster closed; workspace replaces sessions

A long session. Six pieces of work, each built, verified **by effect** on `:0`, documented and
committed separately; the per-change narratives are in [HISTORY.md](HISTORY.md) and the per-item
classifications in [AstoriaParity.md](Documentation/AstoriaParity.md).

1. **Agent MCP server Tasks 6 + 7 — the server is COMPLETE.** Task 6 made the listener a
   user-controlled opt-out: `AllowAgentControl` (default ON), the Tools ▸ Options checkbox,
   `ReconcileAgentPipe` so the toggle needs no restart, the status bar reading **"MCP Agent: On/Off"**
   in the panel that used to be the always-"UTF-8" encoding readout, and
   [AgentMcpSetup.md](Documentation/AgentMcpSetup.md) for users. Task 7 drove the whole
   create → build → read-errors → fix → run loop from a real MCP client (20 checks, all pass;
   `Primes below 1000000 = 78498`) and **found a real bug**: `run` never returned, because
   `Compile("Run")` blocks in `RunPr`'s synchronous `Shell()` until the launched program's terminal
   closes — which, with a keep-open terminal, is never. The agent path now builds plainly and
   launches from the finalizer; `run` returns in 0.1 s.
2. **Recent Projects became a dialog** (`src/frmRecentProjects.{bi,frm}`) listing file + path and
   skipping entries whose `.vfp` is gone.
3. **The Options panels**: the "When Ilwaco IDE starts" radio group removed with everything only it
   fed, and the Code Editor page grouped **Display / Editing / Completion / IntelliSense / History**.
4. **`Show Holiday Frame` → `Show Indent Guides`, done as a feature.** Astoria only relabelled the
   caption while the checkbox still drove a seasonal decoration; Ilwaco deleted the decoration and
   implemented real indent guides in `EditControl.PaintControlPriv`. **The menu-taxonomy cluster
   `49ec5ccd`/`37ba31ea` is COMPLETE.**
5. **`b9735e8e` — the workspace replaces `.vfs` sessions.** `SaveWorkspace`/`LoadWorkspace` write
   `Settings/Workspace.ini` (BOM-less, paths relative to the exe, gitignored) on close and restore it
   on start; the whole Sessions UX is gone. `CloseSession` was never about `.vfs` files — it is the
   batched save-prompt run before the IDE will exit — so it was **renamed `CloseWorkspace` and kept**,
   and that prompt was re-verified against a modified tab.
6. **`cc9e7dd5` classified N/A**, with evidence rather than assumption: two GUI projects opened in one
   session both render their form in the designer and the Toolbox populates — closing **TestPlan T3**,
   which had stood unrecorded since the plan was written. The MFF library manifest was pruned to the
   one variant that ships.

**Everything is committed and pushed** (through `2ab9c4f`); the working tree is clean and
`python3 Tools/DocCheck.py` is green.

---

## ✅ DONE (2026-08-05) — terminal-launcher detection + the `.lng` startup error

Run used to shell out to `gnome-terminal` unconditionally, so on a box without it (this one has
`xfce4-terminal`) a compiled program "did nothing" — `sh: gnome-terminal: not found`, no window. Fixed
and verified end to end:

- **`LoadSettings` (`src/Main.bas`)** seeds the nine terminals Ilwaco knows about — gnome-terminal,
  konsole, xfce4-terminal, mate-terminal, lxterminal, terminator, terminology, qterminal, xterm — into
  the list if absent, then, when the configured default is not on `PATH`, auto-picks the first
  **installed** one. Any real terminal is preferred over `xterm` (xterm last). An installed default the
  user has chosen is always kept, so the override sticks.
- **`Settings/ilwaco.ini` `[Terminals]`** now ships all nine with correct keep-open args
  (`xfce4-terminal --hold -x`, `konsole --hold -e`, `xterm -hold -e`, …), replacing the old
  three-entry block whose `xterm` arg (`-bc`) was broken.
- **Tools > Options > Terminals** gained **Installed** and **Default** columns (installed via
  `g_find_program_in_path`; Default tracks the "Default Terminal" combo live through a new
  `cboTerminal_Change` handler in `frmOptions`), and the dialog was widened (`810×640`) so those
  columns show. The combo is the override control and lists all nine.

**Verified by effect:** the default auto-resolved to `xfce4-terminal`; the Options list showed all nine
with `xfce4-terminal` marked Installed + Default; selecting `xterm` moved the Default mark live (and its
blank Installed cell warned it is absent); and Run launched `"xfce4-terminal" --hold -x "…/Main"`, the
program's greeting rendering in the held-open terminal.

**The `.lng` startup error is also fixed.** Every GUI app built with Ilwaco used to print
`Open file failure! in function Application.CurLanguage` at startup, because the templates run
`App.CurLanguage = My.Sys.Language` (the OS locale, `C.UTF-8` here) and MFF's `CurLanguage` setter
tried to open a `Languages/<locale>.lng` that isn't there. English-only + `ML()` passthrough means a
missing translation file is normal, so the setter's `Else … Print` was dropped — a file that won't open
now silently keeps English. A/B-verified (pre-fix app printed `…/Languages/C.UTF-8.lng`; fixed app
prints nothing), then the lib **and** editor were rebuilt. Both fixes are detailed in
[TechnicalDebt.md](Documentation/TechnicalDebt.md) "Paid down 2026-08-05".

---

## ✅ DONE (2026-08-06) — the menu-taxonomy cluster `49ec5ccd`/`37ba31ea` COMPLETE

Owner directive was *"make the menu system as close to Astoria as possible; later changes will fill in
the blanks — same with the options panels."* Closed out over 2026-08-04 → 08-06:

- **2026-08-04:** the label pass (status bar "Press F1 for help", `Format`→`Designer`, "Not Set",
  "Clear Output"/"Clear Immediate", numbered `Untitled1/2/…`, Goto "Go to line:", the Find dialog's
  cryptic `Aa`/`W`/`.*`/`<`/`>` buttons); the **File-menu restructure** to Astoria's project-first
  taxonomy; **Open Project** exposed (Ilwaco had the handler with the menu item commented out);
  `Rename Project` + `Delete Project` added, the latter reimplemented for Linux (`rm -rf`,
  path-guarded) — both verified once the Close Project crash was fixed. The Rename dialog's
  `InputBox` title/prompt were swapped and its default carried `.vfp` into what becomes a folder
  name; both corrected, and MFF's `InputBox` gained a **Cancel** button.
- **Since:** `frmNewProject`, and the Console Application template rewrite that made every offered
  project type build (T14/T15).
- **2026-08-06:** **Recent Projects** became a dialog (`src/frmRecentProjects.{bi,frm}`) listing file +
  path and skipping entries whose `.vfp` is gone; `OpenProjectTemplate` classified **N/A** (dead code
  in Astoria). The **Options panels**: the "When Ilwaco IDE starts" radio group removed along with
  `WhenVisualFBEditorStarts`/`LastOpenedFileType`/`DefaultProjectFile` and the never-read
  `AutoReloadLastOpenFiles`; the Code Editor page grouped into **Display / Editing / Completion /
  IntelliSense / History** (Astoria's four, with its `History` catch-all split so each name describes
  its contents). Finally **`Show Holiday Frame` → `Show Indent Guides`**, done as a real feature:
  Astoria only relabelled the caption while the checkbox still drove the seasonal frame bitmap, so
  Ilwaco deleted the decoration and implemented actual indent guides in
  `EditControl.PaintControlPriv`.

Three GTK layout lessons came out of the Options work, all found by looking at the screen: a GroupBox
draws its caption inside the frame (needs `Margins.Top`); the VerticalBox/ScrollControl sums children's
`Constraints.Height` to size the scroll range (a group without one makes the page tail unreachable —
caught by A/B against the previous tracked binary); and panels inside a height-constrained group need
their own `Constraints.Height` or GTK compresses the rows into each other.

---

## ✅ DONE (2026-08-04, later) — Console template rewritten; T14/T15 now PASS; branding cleared

The Console Application template no longer breaks. It pulled in MFF's `mff/Console.bi`, which was
pure Win32 (84 console-API calls, a `windows.bi` include dragging in `-lkernel32/-lgdi32/-luser32/…`),
so a beginner picking "Console Application" got a project that would not link. Per the owner decision:

- **`Templates/Projects/Console Application/Main.bas` rewritten in plain FreeBASIC** — `Print` for
  output, `Color` for colour, both native on Linux; BOM-less, LF-only. It now prints a greeting
  instead of the old empty template.
- **`Controls/Framework/mff/Console.bi` deleted** as dead Windows code (nothing else in the repo
  included it), with a `REMOVED_FEATURES` guard for `ConsoleType` added to `Tools/DocCheck.py`.
- **Stale `VisualFBEditor` branding cleared:** the Console template's `Console.Title` went with the
  rewrite, and `Templates/Files/Form_3D.frm`'s caption `"VisualFBEditor-3D"` → `"Form1"` (matching the
  plain `Form.frm` template). The only `VisualFBEditor` strings left are in the *not-offered* Windows
  templates (Android/Addin), whose deletion is a separate open question.

**Verified by effect, end to end through the IDE (T14/T15 now PASS).** Created a Console project via
New Project → compiled + linked it from the IDE ("Layout succeeded, Elapsed 0.06s") → the built exe
prints single-byte ASCII (`Hello, world!` …), exit 0 — the BOM regression check. The New Project type
list showed exactly the six-item whitelist. All six offered types compile (Console needs
`-p <shim> -l tinfo` on the dev box until the AppImage ships `libncurses`). **No IDE rebuild was
needed** — only template/doc data and a header that was never on the IDE's build path changed.

Running that Console project also surfaced the terminal-launcher gap, now **fixed** — see the next
section.

---

## ✅ DONE (2026-08-04) — `frmNewProject` works end to end; the `FileCopy`/`UString` trap found

New Project (`src/frmNewProject.{bi,frm}`, registered in `ilwaco.vfp`, included from `Main.bas`) is
**verified creating projects on disk**: GUI Application → `Project1/` with `Main.frm` +
`Project1.vfp`, Console Application → `Project2/` with `Main.bas`; the manifest's template path
prefix is stripped (`*File=GUI Application/Main.frm` → `*File=Main.frm`), the offered name advances to
the first free `ProjectN`, and the project opens with a populated tree.

**What was wrong was not the dialog.** The previous session's *"Selected folder exists"* was the
second press of OK; the real failure was an empty project folder and *"Could not create the
project"*. Instrumenting the running IDE showed every path correct and both template files present —
`FileCopy` simply returned 1 and copied nothing. **FreeBASIC's `FileCopy` takes `ZString Ptr`, so a
`UString` argument binds through `UString.Cast() As Any Ptr` and the wide buffer is read as a narrow
path, ending at the first zero byte.** `&` with a `UString` operand propagates it. All copies now go
through a `FileCopy_(ByRef … As WString)` wrapper (`Main.bas`) and no raw `FileCopy` call remains, so
it cannot recur — see CLAUDE.md's trap list, [TechnicalDebt.md](Documentation/TechnicalDebt.md), and
[UpstreamFixes.md](Documentation/UpstreamFixes.md): `FolderCopy`'s GTK branch is upstream
VisualFBEditor code, so **folder copying has never worked on that build**.

**What the dialog does:** copies `Templates/Projects/<Type>/` into the chosen folder, copies
`<Type>.vfp` straight to `<FolderName>.vfp` (no rename step — FB's `Name` fails silently, see
Main.bi), then rewrites the manifest to strip the `<Type>/` path prefix, because the template's paths
are relative to `Templates/Projects` and the copied files land at the top of the new project folder.

**Design decisions already made (owner):**
- No icons; a pick-only combo, matching Astoria's current dialog.
- An explicit **whitelist**, not "everything in the folder": GUI Application (default), Console
  Application, GTK Application, Dynamic Library, Static Library, Control Library. **Windows
  Application, Android Project, Addin Project and Empty Project are deliberately not offered** —
  a Win32 GUI app cannot work on this build. Their template files are still on disk; deleting them
  is an open question.
- Not ported from Astoria's current dialog: the Author and License fields, and its "no
  auto-generated project name" rule. Ilwaco still pre-fills the first free `ProjectN`.

## ✅ DONE (2026-08-04) — project templates: BOM fix + default file renamed to `Main`

**Every shipped template source began with a UTF-8 BOM**, which makes FreeBASIC compile string
literals **wide**: the file builds clean and then prints UTF-32 bytes. Measured directly — the same
two-line program with and without a BOM printed `hello world` vs
`h^@^@^@e^@^@^@l^@^@^@...`. So every project created from a template, and every file added via
*Add Form* / *Add Module*, started out printing garbage. Stripped from all 9 sources under
`Templates/Projects` and all 7 under `Templates/Files`.

**Default module/form renamed to `Main`** (owner directive, matches Astoria): `Module1.bas`,
`Form1.bas` and `UserControl1.bas` → `Main.bas`; `Form1.frm` → `Main.frm`. The declared type went
with it (`Form1Type` → `MainType`), plus the `.rc` references and every `.vfp` manifest's `*File=`
line. `.vfp` manifests keep their BOMs — the IDE writes one back on save, so stripping them is churn.

**Still BOM'd and deliberately left:** `Examples/` — 93 of 111 sources. Owner: fold into the
deferred Examples work so that directory is touched once.

---

## ✅ DONE (2026-08-04) — `5fa5cf25` COMPLETE: debugger Pass 2C/2D + residual GDB cleanup + debuggee argv/env wiring

`5fa5cf25` is **finished**. The full narrative (what each pass removed, the traps hit, and the 2E divergence
from Astoria) is in [HISTORY.md](HISTORY.md); the classification is in
[AstoriaParity.md](Documentation/AstoriaParity.md). Headlines:

- **2C** — the `frmOptions` debugger-*choice* UI is gone (picker, paths list, Add/Change/Remove/Clear,
  handlers, LoadSettings/SaveSettings, `[Debuggers]` INI writer). **`pnlDebugger` was kept** (the plan said to
  delete it) because it still hosts the live `chkDisplayWarningsInDebug`. **Terminal is now a top-level
  options node.** `LimitDebug` removed — it never worked.
- **2D** — `DebuggerTypes`, `DefaultDebuggerType64`/`CurrentDebuggerType64`, `pDebuggers`/`Debuggers`, the
  `[Debuggers]` load/save/dealloc and the five `*Debugger64*` path globals are gone, along with the
  statically-dead `build_create_shellscript` (its only caller sat behind `If 0 Then`).
- **Residual cleanup** — the orphan `Declare`/`Extern "C"`/`pollfd`/global block at the foot of `Debug.bas`,
  the dead `tlockGDB` cluster, and the debug panel's no-op **"Update"** toggle.
- **2E (new capability)** — the debuggee now receives a real **argv** (`argv(0)` + Parameters
  `Debug64Arguments` + the project's `CommandLineArguments`) and a real **environment**. Astoria removed its
  env-vars option as non-functional; Ilwaco wired it instead. `frmParameters.cmdOK` now writes `txtDebug64`
  back — it never did.

**Verification:** four clean whole-program builds; Options tree/pages and Terminal page checked live on `:0`;
argv and environment confirmed at kernel level via `/proc/<pid>/environ` (injection, inheritance, same-name
override leaving exactly one entry, multi-var parsing, and no pollution of the IDE's own environment).

**The fork trap, worth remembering:** after `fork()` in a multithreaded process only async-signal-safe calls
are legal. A first attempt at env injection called `SetEnviron` (`putenv`, which allocates) in the child and
failed **silently** — argv worked because it is stack-only. Anything staged for the debuggee must now be built
in the parent (`build_debug_launch`); the child only copies pointers and calls `execve`.

**Pre-existing bug confirmed live (not a regression):** the Integrated debugger lowercases the source path
(`Main.bas:2885 AddTab(LCase(source(fntab)))`, a Win32-ism) → "File not found" for any project under a path
containing uppercase letters. Reproduced this session; worked around by testing from an all-lowercase path.

**Verification recipe (reusable):** a small console `.vfp` project (not a loose `.bas`) with `*File=` marking
the main file, `CreateDebugInfo=true`, and the dev shim on its lib path
(`CompilationArguments64Linux="-p <shim> -l tinfo"` — needed only in this dev env). Drive it on `:0` with
`xdotool`/`scrot`; read the debuggee's real argv with `pgrep -a` and its environment from `/proc/<pid>/environ`
rather than trusting the program's own output.

---

---

## ✅ DONE (2026-08-04) — `5fa5cf25`: alt-compiler-backend removal + debugger Passes 1/2 + debuggee argv/env wiring (COMMITTED)

Completed the port of Astoria's `5fa5cf25` with the **inverted debugger choice** — Ilwaco keeps the built-in
Integrated (stabs) debugger and removes GDB, because the Integrated engine reads FreeBASIC's `.dbgdat`/`.dbgstr`
sections that only the **gas64** backend emits with `-g`, and Ilwaco is gas64-only. Detail in
[AstoriaParity.md](Documentation/AstoriaParity.md); memory `project-debugger-keep-internal`.

**Compiler-backend half + debugger Pass 1** (earlier commit `1deb849`): removed the `ToGAS/ToLLVM/ToGCC/ToCLANG`
picker, the optimization radios and `frmAdvancedOptions` (`-gen gas64` hardcoded); deleted the whole GDB engine
from `Debug.bas` (−2130 lines) plus `TimerProcGDB`/`GDBCommand`/`miGDBCommand`.

**Pass 2C — `frmOptions` debugger page.** Deleted the debugger-*choice* UI: `grbDefaultDebuggers`,
`grbDebuggerPaths`, `cboDebugger64`, `cboGDBDebugger64`, `lvDebuggerPaths`, `hbxDebugger`, the four
`cmd*Debugger*` buttons and three `lblDebugger*` labels, their 5 handlers, the LoadSettings/SaveSettings blocks
and the `[Debuggers]` INI writer (`frmOptions.frm` −272 lines). **Kept `pnlDebugger`** — contrary to the
original plan — because it still hosts the live `chkDisplayWarningsInDebug` (`TabWindow.bas:481`); deleting the
panel would have silently dropped a working setting. **Terminal promoted to a top-level options node** (it
drives Run, not the debugger). Removed `LimitDebug` entirely (global + INI + checkbox): it never worked, its
only reference being a commented-out `#ifdef __FB_WIN32__` block in `Debug.bas`, which was deleted too (−274
comment-only lines, each verified blank-or-comment first).

**Pass 2D — the machinery.** Removed the `DebuggerTypes` enum, `DefaultDebuggerType64`/`CurrentDebuggerType64`,
the `pDebuggers`/`Debuggers` dictionary, the `[Debuggers]` settings load/save/dealloc, and
`Debugger64Path`/`GDBDebugger64Path`/`DefaultDebugger64`/`GDBDebugger64`/`CurrentDebugger64`. **Trap:** dropping
the `Debuggers` term from `LoadSettings`'s `Do Until` meant its `= -10` sentinel had to become `= -9`, or
settings loading would have stopped at index 0. Also found `build_create_shellscript`'s only caller sat behind
`If 0 Then` — statically dead — so the `If 0/Else` was collapsed to the live branch and the function, its
declare, the commented-out GTK-VTE experiment and an unused `Dim As GPid pid` all went.

**Residual GDB cleanup.** Removed the orphan block at the foot of `Debug.bas`: 12 dead `Declare`s, the
`Extern "C"` FFI block (`fdopen`/`poll`/`ioctl`/`_access`), `Type pollfd`, and the unreferenced globals
(`pIn`/`pOut`, `Running`, `ShowResult`, `szDataForPipe`, `iVersionGdb`, `CurrentFile`/`NewCommand`, the pipe and
flag counters). Kept `SIGKILL`, `WatchIndex`, `w9T`/`KillTimer`/`SetTimer`. Also removed the dead **`tlockGDB`**
cluster (created/destroyed/unlocked under `If iFlagStartDebug = 1`, a flag nothing sets) and the debug panel's
**"Update" toggle** — a clickable button whose only effect was writing `iStateMenu`, which nothing read.

**2E — debuggee argv + environment made real (divergence from Astoria).** Astoria removed its env-vars option as
non-functional and left its debug-parameters box inert; Ilwaco wires both instead, because on `fork`/`execv` it is
contained and because the project's own Command-line arguments field — on a tab literally named *Debugging* —
was honoured by Run and silently dropped by Debug. `RunWithDebug` now stages `debugargs` (Parameters
`Debug64Arguments` + the project's `CommandLineArguments`), and the debuggee gets a real NULL-terminated argv
with `argv(0)` set (previously `execv_(…, NULL)` — no `argv[0]` at all). `frmParameters.cmdOK` now writes
`txtDebug64` back; it never did, so typing there was silently discarded.
**The fork trap:** the first attempt called `SetEnviron` (i.e. `putenv`) in the forked child and *silently*
failed — after `fork()` in a multithreaded process only async-signal-safe calls are legal, and `putenv`
allocates. That is exactly why the argv half worked (stack-only) while the env half did not. The fix builds the
program path, argv tail and full environment block in the **parent** (`build_debug_launch`), leaving the child to
copy already-allocated pointers into stack arrays and call `execve`. Staged at all three `ThreadCreate(@start_pgm)`
sites: `restart_exe` reuses the same arguments/environment, `external_launch` clears the arguments.
Verified at kernel level via `/proc/<pid>/environ`: injection works, inheritance is preserved (83 entries),
a user `LANG` **overrides** the inherited one leaving exactly one entry (glibc `getenv` returns the first match,
so a duplicate would be ambiguous), multiple space-separated vars parse, and the IDE's own environment is
untouched. argv observed as `/tmp/argtest/argtest alpha beta gamma`.

**Confirmed live:** the pre-existing debugger **path-case bug** is real and reproducible — a project under a path
containing uppercase letters fails with "File not found" showing a lowercased path (`Main.bas:2885`
`AddTab(LCase(source(fntab)))`, a Win32-ism). Worked around by testing from an all-lowercase path.

---

## ✅ DONE (2026-08-04) — bottom-panel collapse: dedicated horizontal rail (COMMITTED)

Finished `e212819d`/`ef3b43e9` (bottom-panel collapse + persistence). The collapsed-panel affordance is a
horizontal activity rail mirroring the left/right rails: on collapse `pnlBottom` is hidden and a 25px
`pnlBottomRail` (`alBottom`) is shown — a pin at the right plus 14 tab buttons (`Output..Immediate` always;
`Locals..Profiler` only with the debugger on). Live-verified on `:0` by the owner. Full detail + the GTK/MFF
facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 — bottom-panel collapse via
a horizontal activity rail". Changed `src/Main.bas` + `src/ilwaco.bas`. Key fixes: pin repaint on reopen
(`ShowBottom` → `gtk_widget_show_all(pnlBottomPin.Handle)`); pin docked `alRight` (was `alLeft`, which jumped);
debug buttons re-asserted on the rail via `CloseBottom`/`SetDebugTabsVisible`; rail pin unclipped via a
`.ilwacorailpin` `GtkCssProvider`; and a **debugger-toggle desync fix** — `ilwaco.bas "UseDebugger"` reads
GTK's real `gtk_check_menu_item_get_active` instead of MFF's stale `Checked`. Persistence via the
`BottomClosed` INI key round-trips.

---

## ✅ DONE (2026-08-04) — left/right panel collapse: vertical-text rail + pin-repaint fix (UNCOMMITTED, verified)

Owner asked to make the **left/right tool panels collapse and reopen** with a **visual** affordance (not a
menu), and refined it to **look like Astoria's collapsed strip**: a thin **vertical-text** tab strip with a
**pin at the top**. Delivered as a **GTK REIMPLEMENT**. On collapse the panel is hidden entirely and a
separate 34px **rail** appears at the edge: a pin icon at top (re-expands to the last tab) above the tab
captions as **rotated vertical text**. **Both LEFT and RIGHT work, live-verified.** Full detail + the
hard-won GTK/MFF facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 —
left/right panel collapse via a vertical-text activity rail".

**State: COMPLETE, build-clean (`fbc` exit 0), UNCOMMITTED** on `bbd8ab0`. Changed files: `src/Main.bas`
+ `src/ilwaco.bas` (the `ilwaco` binary + `src/ilwaco.{asm,c}` are build byproducts — do not commit).
Verified live on `DISPLAY :0` by screenshot: each panel collapses to a vertical strip (pin icon above
rotated `Project`/`Toolbox` and `Properties`/`Events`); the pin re-expands to the last tab; each text
button re-expands and selects its tab; the **expanded-panel pin repaints after reopen** (the reported bug —
fixed); and both strips show **collapsed at startup** with `LeftClosed=true`/`RightClosed=true`. Additive
to MFF → no `.so` rebuild.

**Key implementation points (`src/Main.bas`):** the rail is text-only because MFF renders no icon on a
`CommandButton`/`Label` on GTK and rotates no toolbar text (owner chose vertical-text-only over a
custom-raw-GTK icon+text rail). Pin = one-button `ToolBar` with `gtk_toolbar_set_show_arrow(…,FALSE)`
(reuses the `PinLeft`/`PinRight` command). Tab buttons = `CommandButton`s with caption rotated via
`gtk_label_set_angle(gtk_bin_get_child(…),90/270)` (`RotateRailButton` helper), `.Designer=@frmMain` set,
`OnClick` handlers (`railLeftProjectClick` etc.). **Pin-repaint fix:** `Show{Left,Right}` now call
`gtk_widget_show_all(pnl…Pin.Handle)` + `gtk_widget_queue_resize(overlay…)` so the overlay pin remaps and
repaints. `Get…ClosedStyle → Not pnl….Visible`. `ilwaco.bas`: `Pin{Left,Right}` one-liners.

**Supersedes** the deferred `e212819d`/`ef3b43e9` left/right *persistence* item (save/load already works
via `Get…ClosedStyle` → `LeftClosed`/`RightClosed` INI keys + `frmMain_Create` re-apply). The **bottom**
panel keeps the old collapse-to-strip behaviour and its persistence is still deferred.

**NEXT:**
1. **Commit** `src/Main.bas` + `src/ilwaco.bas` + the two docs (message: vertical-text panel-collapse rail
   + pin repaint; not the binary, per precedent) — *only when the owner asks.*
2. **Optional hygiene:** `tab{Left,Right}_SelChange`/`_Click` and the focus-loss auto-collapse still carry
   dead `TabPosition = tp{Left,Right}` / `Width = 30` guards (can no longer be true); a `no-dead-code`
   pass can drop them. Rail button heights (84/96px) and rotation angles are tuneable if the text looks off.
3. **Resume the changelog walk** (see the session-handoff section below): bottom-panel *persistence*
   (`e212819d`/`ef3b43e9`), then `4bd02894`, then the `49ec5ccd` menu-taxonomy cluster.

**Test caution:** kill by PID (`pkill -x ilwaco`), `git checkout Settings/` after any launch, screenshots
via `scrot` on `DISPLAY=:0`, clicks via `xdotool`. **The Claude desktop app steals focus** — re-activate
the IDE with `xdotool windowactivate --sync $(xdotool search --name "Ilwaco IDE" | head -1)` before each
click, and verify `getactivewindow getwindowname` is the IDE. Display is 2560×1340 (screenshots come back
2000-wide → coords ×1.28). Collapsed rail buttons (real coords): left pin ≈(17,135), Project ≈(17,225),
Toolbox ≈(17,305); right pin ≈(2543,130), Properties ≈(2543,230), Events ≈(2543,305).

---

## ✅ DONE (2026-08-04) — documentation-maintenance apparatus + Astoria doc-set analogues (UNCOMMITTED)

Ported Astoria's document-maintenance discipline to Ilwaco, **adapted for Linux/GTK**, and gave every
file in Astoria's `Documentation/` folder an Ilwaco analogue. **The rule now has teeth:** a checker
catches doc drift, a skill says what to update when, and CLAUDE.md points at both.

- **`Tools/DocCheck.py`** — Astoria's checker, Linux-adapted and trimmed to 3 checks: (1) a doc names
  a *removed* feature as if it ships (`REMOVED_FEATURES` seeded with Ilwaco's removals), (2) a doc
  names a deleted file in inline code, (3) a maintained doc is missing from the rule table. Dropped
  the Windows-only bits (Chrome-PDF/`.txt` freshness, PowerShell changelog, `ROADMAP.md` §-check);
  file-suffix set is Linux (`.so`/`.sh`). Fixed a case-sensitivity bug in the FS fallback. **Green:**
  `python3 Tools/DocCheck.py` → "Documentation is current (10 documents checked)"; `--selftest` OK.
- **`Documentation/TestPlan.md`** — carries **the rule table** (which doc to update when) that
  `DocCheck` enforces, plus the current (thin) test scenarios and the Linux verify-by-effect method.
- **`.claude/skills/update-ilwaco-docs/SKILL.md`** — the trigger table as a skill (now registered).
- **`CLAUDE.md`** — Working practices now require `DocCheck` before commit and fold docs into "finish
  the whole job"; `update-ilwaco-docs` moved from pending to shipped.
- **Doc analogues** (all listed in the rule table): real content — `UpstreamFixes.md`,
  `TechnicalDebt.md`, `Testing.md`, `ControlTesting.md`, `IlwacoIDESignificantChanges.md`; honest
  scaffolds (purpose + Astoria source + "GTK review needed", per owner's choice) — `Controls.md`,
  `FrameworkGuide.md`, `FrameworkFeatures.md`, `IlwacoIDEManual.md`; plus root `CHANGELOG.md`.
  `AstoriaParity.md` + `AstoriaDetailedChangeLog.md` are excluded from `DocCheck` as historical
  records (like Astoria excludes its `DetailedChangelog`).

**NEXT:** commit when asked (all uncommitted). Fill the scaffolds as their subjects stabilise. Keep
`DocCheck` green — it runs on Documentation/*.md and is the pre-commit gate now.

---

## Session handoff (2026-08-03, earlier) — changelog walk + debug-tab visibility ported

**START HERE.** Continued the Astoria→Ilwaco changelog walk from the oldest entries in
[AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md). Resolved 5 entries (backlog
**401 → 396**) plus one sub-item pulled forward. Committed+pushed: first three (doc-only) `72a741b`,
`53d8e473` `c087255`, `4cf72752` `c8c9ce7`, doc-clarification `e09fa37`. The debug-tab-visibility work
(below) is source+docs, build+runtime-verified, **staged/uncommitted** at time of writing.

- **Debug-tab visibility** (`49ec5ccd` sub-item, pulled forward at owner's request) — **DONE,
  build+runtime-verified.** The 7 debug tabs (Locals…Profiler) now show only when `UseDebugger` is on
  (Immediate stays permanently visible). Required a new **MFF `DetachTab`** method (remove a tab without
  destroying its `TabPage`, with a GTK `g_object_ref` so the page widget survives re-add) + three subs +
  4 call sites in `Main.bas`. Verified both states by screenshot (off → tabs hidden; on → re-appear, no
  crash). Additive/non-virtual MFF change → no `.so` rebuild. This is **distinct** from `4cf72752`'s
  content-*clearing*. See AstoriaParity "Done — debug-tab visibility". `49ec5ccd` stays in the backlog
  (only this sub-item is done; the menu-taxonomy bulk remains deferred).

- **`4cf72752`** (WIN32_WINNT header bug + bottom-panel tab clearing) — **PORT (partial), DONE.** The
  `_WIN32_WINNT` `=`→`>=` header fix is N/A (Windows headers, not on the GTK build path); the AI-KnowledgeBase
  path fix is N/A (AI removed). Ported the **bottom-panel/debug tab clearing**: new `ClearAnalysisPanels`/
  `ClearDebugPanels` in `Main.bas`, wired into `CloseProject` + the debug-`End` case in `ilwaco.bas`, so
  stale project/debug results don't linger after a project closes. Forward-declared `ClearThreadsWindow` in
  `Main.bi`. Build clean (`fbc` exit 0); IDE launches, all 14 bottom tabs render. See AstoriaParity
  "Done — bottom-panel/debug tab clearing (`4cf72752`)".
- **`53d8e473`** (Fix all compile warnings) — **PORT (partial), DONE, committed `c087255`.** Ilwaco's
  production build was already warning-clean; most of Astoria's fixes targeted already-stripped code (Canvas
  Direct2D, Debug `SetConsoleTitle`) or don't reproduce. Ported the 2 `@literal→WString Ptr` hunks in
  `src/Debug.bas` (`brk_comp`, `list_all` → `WStr(...)`).

- **`bbfa3999`** (Initial Win64 fork import) — the fork anchor / base snapshot itself, not a port. Pruned.
- **`5a097399`** (Update INI window-state + rebuild exe) — NONCODE (Settings + binary only). Pruned.
- **`bef92671`** (Form Designer never activating) — **REVIEW → N/A, verified.** Astoria's designer was dead
  because *its own* `strip_gtk_preprocessor.ps1` deleted the `#ifdef __EXPORT_PROCS__` blocks from MFF,
  shipping `mff64.dll` with zero exports. Ilwaco never ran that tool; our `ppstrip.py` preserved every
  such block. **Proof:** `libmff64_gtk3.so` exports 469 symbols and *all 36* dispatchers that
  `src/Designer.bas` resolves via `DyLibSymbol()` are present (`nm -D` diff empty). Full narrative +
  re-runnable verify command in AstoriaParity "N/A — Form Designer export table intact".
- **Kept (partial):** `e212819d` + `ef3b43e9` — the bottom-panel **persistence** cluster (collapse half
  already DONE 2026-08-02; persistence still deferred — needs the panel-state save/restore infra).

---

## Session handoff (2026-08-03, earlier) — UTF-8/LF-only DONE + ALL AI REMOVED (both build+runtime-verified)

**START HERE.** This session landed, in order, all committed+pushed to `main`: (1) verified prior commit
`1dc1650`; (2) **UTF-8/LF-only** (`d99b23c`); (3) **AI removal slice 1/2** — Options AI page + `frmAIAgent.frm`
(`d7bf853`); (4) **AI removal slice 2/2** — the entire main-window AI subsystem (this commit, pending push at
time of writing). All build-verified (`fbc` exit 0) and runtime-verified (IDE launches to a stable window, full
editor, "IntelliSense fully loaded", status bar UTF-8/LF, no error dialog, no `DebugInfo.log`).

**TASK 2 (remove ALL AI elements) — COMPLETE.** Slice 2/2 removed (~−1360 lines): from `Main.bas` the AI
tab/panel/toolbar creation, the 13 AI subs (cboAIAgentModels_Change, EscapeJsonForPrompt/EscapeFromJson,
AIGetMaxChunkSize/AIPrintAnswer/AISplitText, HTTPAIAgent_Complete/_Receive, AIRequest, txtAIRequest_Activate,
AIChatPaste/AIRelease/AIResetContext, AddMRUAIChat), the knowledge-prompt block, the `mnuAIChat` menu, the
LoadToolBox wiki/markdown→AIContext generation (kept the toolbox build + DyLibFree cleanup), the `[AIAgents]`
INI load body (⚠ **kept the `AIAgents` KeyExists term in the fragile 10-section `Do Until` loop** per task-13
precedent — removing a term would force restructuring `= -10`), the AIChat MRU save + exit save, the tpAIAgent
INI write, the deallocs, and the AI toolbar `imgList.Add` icons; from `ilwaco.bas` the `mClickAIChat` sub +
all AI dispatch cases; from `Main.bi` the AI declares/globals + the `ModelInfo` type; from `TabWindow.bi` the
`MD2RTF.bi` include; deleted `src/MD2RTF.bi` + its `.vfp` entry. **Verified:** left panel is now Project|Toolbox
(no "AI Agent" tab); clean build+launch. Slice 2 built green on the first try.
**Follow-up (minor, deferred):** the `.rc` still registers now-unused AI toolbar icons (NewChat/AddComment/…);
harmless. The kept `[AIAgents]` INI loop term is the only remaining "AI" token in `src/` (functional, not dead).

**Changelog backlog seeded (2026-08-03).** Created [Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md)
— a **pruned** copy of Astoria's 888-commit `DetailedChangelog.md`. Deleted everything already resolved for
Ilwaco: the 6 AstoriaParity *done ports* (pass 1), then **481 non-actionable** commits (pass 2 — NONCODE 426,
INVERT 9, WIN32 20, AI 26), leaving **401 actionable** entries oldest-first. The file's header carries the
**maintenance rule** (delete DONE + the four non-actionable classes, matched on the commit *headline*). The
one-off classifier is in scratchpad (`prune_changelog.py`) — criteria are re-derivable from the rule.

**NEXT — resume the changelog walk from the 5 oldest remaining in that file:**
1. `bbfa3999` — the fork-import anchor (base; not a port — the walk's start marker).
2. `e212819d` — bottom-panel **persistence** (collapse half DONE; persistence still deferred — see the
   "panel collapse-on-pin" Done section below for the infrastructure it needs).
3. `ef3b43e9` — fix first-start collapsed bottom layout (same panel-persistence cluster).
4. `5a097399` — "update INI + rebuild exe" (near-noise; a rebuild/state-save — low value).
5. `bef92671` — Form Designer never activating (**REVIEW** — Astoria's root cause was a Win build tool;
   verify whether the underlying designer export-table issue reproduces in Ilwaco).
The 32-bit strip and the UTF-8/LF + AI strips are the standing owner directives, now all cleared.

---

### Detail from earlier in this session (kept for reference)

1. **Verified prior commit `1dc1650`** (removed dead `EditControl2.bi`; consolidated the two AI "Translate"
   buttons — "TranslateE" gone, kept "Translate" now targets `ML("English")`) which had been committed
   WITHOUT a build. Rebuilt the stale tracked `./ilwaco` binary in the process.
2. **UTF-8-only + LF-only — DONE (TASK 1 below, now complete).**

### TASK 1 — UTF-8-only + LF-only — DONE (build+runtime-verified; −295/+22 across 6 files)
Owner directives: UTF-8-only + LF-only; remove the encoding/newline *selection* and collapse the engine to
**UTF-8 + LF**. Decision kept: **new files = UTF-8 no-BOM**; **existing BOM preserved on load/save round-trip**.
The `FileEncodings`/`NewLineTypes` enums stay in MFF `Application.bi` (MFF untouched); `PlainText/Utf16BOM/
Utf32BOM` + `WindowsCRLF/MacOSCR` are now unused enum values. What was done:
- **Menu** (`Main.bas`): deleted the whole `File ▸ File format` submenu block (the 5 encoding items + 3 newline
  items + separators + the two `->Checked=True`), keeping one `miFile->Add("-")` so no doubled separator.
- **Dispatch** (`ilwaco.bas`): deleted both `Case "PlainText"…` and `Case "WindowsCRLF"…` blocks.
- **`ChangeFileEncoding`/`ChangeNewLineType`** (`Main.bas`): bodies collapsed to just set the status panel to
  `"UTF-8"` / `"LF"`. Signatures + both caller sites (`Main.bas` 9105-9106, `TabWindow.bas` 424-425) kept.
- **Status setup** (`Main.bas`): `"UTF-8 (BOM)"`→`"UTF-8"`, `"CR+LF"`→`"LF"`.
- **Globals** (`Main.bi`): deleted the now-unused `mi*` MenuItem-pointer line. Kept `DefaultFileFormat`/
  `DefaultNewLineFormat`.
- **Init** (`Main.bas`): the two `ReadInteger` lines are now hard-sets `DefaultFileFormat = FileEncodings.Utf8`,
  `DefaultNewLineFormat = NewLineTypes.LinuxLF`. `TabWindow.bas` still reads these for new tabs → UTF-8 no-BOM + LF.
- **`EditControl.bas` LoadFromFile:** BOM block collapsed to `If <UTF-8 BOM> Then Utf8BOM/"utf-8" Else Utf8/
  "ascii"`; newline forced to `LinuxLF`. Removed the now-dead write-only `NewLineStr` local. (`CheckUTF8NoBOM`
  is an MFF function — still used inside MFF — so not orphaned.)
- **`EditControl.bas` SaveToFile:** encoding block → `If Utf8BOM Then "utf-8" Else "ascii"`; newline → `Chr(10)`;
  removed the unused `FileEncodingSymbols`; folded the PlainText write branch into the Else.
- **`frmOptions`:** removed the **entire "Defaults" options page** — it existed *only* for these two combos
  (tree node `Defaults` → `pnlDefaults` → `grbDefaults` "Default Settings for New Files" → `vbxDefaults` → the
  two `hbx` → lbl+cbo, plus a duplicate `cboDefaultNewLineFormat` designer block). Removed the tree node, the
  panel-switch line, the populate/save/INI-write, and all `.bi` declarations. (Same pattern as the English-only
  session's removal of the Localization page.)
- **Verified by effect:** status bar reads "UTF-8" / "LF"; File menu has no "File format" submenu (no doubled
  separator); Options ▸ Code Editor has no "Defaults" node and opens cleanly. **Not** UI-verified: the on-disk
  save round-trip (deferred per owner — "as we walk the Astoria changelog it'll likely be covered"; the
  Load/Save code path is straightforward and compiles).
- **Deferred (low value):** the `Open … Encoding "utf-16"/"utf-32"` fallback chains in `Main.bas` (~15 places;
  some open utf-32/16 *first*, not as fallback — don't blind-sed). Optional secondary cleanup.

### TASK 2 (NEXT, IN PROGRESS) — remove ALL AI elements (large; own session)
Owner: remove the AI pane, model selection, and all AI support code. **Surveyed 2026-08-03 — full map below.**
The AI system is tightly interwoven; it is NOT cleanly separable into independently-building halves **except one
slice**: the Options "AI Agent" page + `frmAIAgent.frm` (that form is `#include`d *only* by `frmOptions.frm:9`).
MD2RTF and the main-window panel/backend must come out together (their symbols reference each other).

**Confirmed facts (survey):**
- `MD2RTF.bi` is **AI-only** — entry `MDtoRTF` is called only from AI paths (`Main.bas:8057`, `ilwaco.bas:130/181`),
  and it uses the AI global `AIRTF_HEADER`. Delete with Slice B. Included by `TabWindow.bi:24`; `.vfp` line 23.
- `frmAIAgent.frm` — whole form, referenced **only** by `frmOptions.frm:9` (`#include once`). `.vfp` line 29.

**SLICE A — Options "AI Agent" page + `frmAIAgent.frm` — DONE (build+runtime-verified, uncommitted).**
Removed from `frmOptions.frm`: the `#include once "frmAIAgent.frm"`, the `AI Agent` tree node (its `tnHelp` Var
dropped as now-unused), the `pnlAIAgent.Visible` panel-switch, the `pnlAIAgent` panel + all AI designer blocks
(`grbDefaultAIAgent`/`cboAIAgent`/`lvAIAgentTypes`/`hbxAIAgent`/`grbAIAgent` + 4 `cmd*AIAgent` buttons — interleaved
with Help blocks, removed per-block), the Form_Create `lvAIAgentTypes.Columns` setup, the LoadSettings populate, the
`cmdApply` rebuild + `[AIAgents]` INI write, and the 4 `cmd*AIAgent_Click` + `lvAIAgentTypes_ItemActivate` handlers.
`.bi`: the 6 handler `Declare`s + all AI control decls. Deleted `src/frmAIAgent.frm` + its `.vfp` entry.
⚠ **Trap hit & fixed:** the `cmdApply` `Dim i As Integer` sat *inside* the AI block but was shared by the MakeTools/
Debuggers/etc. bare-`i` loops below — removing it stranded `i` (error 42). Re-added a bare `Dim i As Integer` where
the block was. **Verified:** build exit 0; IDE launches; Options ▸ Help has no "AI Agent" child; dialog opens clean.
Kept the `AIAgent*` **globals** (Main.bi) + `pAIAgents` dict + INI *load* (Main.bas) — the backend still uses
  them; Slice A only removes the *editing UI*. Build-verify → intermediate state: AI still runs from INI, not
  editable in Options.

**SLICE B (the interdependent remainder) — main-window AI tab/panel/toolbar + backend + globals + MD2RTF:**
- `Main.bas` (~191 refs): globals `txtAIRequest`(88)/`HTTPAIAgent`(96)/`AIMessages`+`AIContext`(98)/`pHTTPAIAgent`(128);
  the AI tab/panel/toolbar creation (`tpAIAgent` 7183, `tbAIAgent` 7311-7331 buttons, `pnlAIAgent`, `txtAIAgent`
  7344, `txtAIRequest` 8125, `splAIAgent` 8135); `AIContext.Add` population (5128-5168, inside the component-scan
  sub); the knowledge-prompt block (~7514-7551); `EscapeJsonForPrompt`(7346)/`EscapeFromJson`(7429)/
  `AIGetMaxChunkSize`(7565)/`AIPrintAnswer`(7583)/`AISplitText`(7595)/`HTTPAIAgent_Complete`(7674)/
  `HTTPAIAgent_Receive`(7686)/`AIRequest`(7832)/`txtAIRequest_Activate`(7904); the `imgList.Add` AI images +
  `pimgListAIProviders32`/`pimgListAIModels32` image lists.
- `ilwaco.bas` (~16 refs): the AI dispatch cases (`AINewChat`/`AIAddComment`/`AIOptimizeCode`/`AIIntellicode`/
  `AITracepointError`/`AIWebBrowserItem`/`AIConvertCtoFB`/`AITranslate`/`AIRelease`) + AI-model handlers + the
  `MDtoRTF` renders (130/181).
- `Main.bi` (~9 refs): `pimgListAIProviders32`/`pimgListAIModels32`(82), `pHTTPAIAgent`(92), `bAIAgentFirstRun`(107),
  `AIAgentPort`/`AIAgentContentSize`(122), `AIAgentStream`(123), `AIAgentTop_P`/`AIAgentTemperature`(124),
  `AIAgentHost`/`Address`/`APIKey`/`ModelName`/`Provider`/`Name`/`AIRTF_HEADER`/`AIEditorFontName`(125),
  `DefaultAIAgent`/`CurrentAIAgent`(131), `pAIAgents`(196); plus the INI load/cleanup of these in `Main.bas`.
- `TabWindow.bi:24`: remove `#include once "MD2RTF.bi"` + its 1 AI ref. Delete `src/MD2RTF.bi`.
- `.vfp`: remove `File=src/MD2RTF.bi` (23) and `File=src/frmAIAgent.frm` (29).

## Session handoff (2026-08-03, earlier) — English-only (all other languages removed)

**START HERE.** Owner directive: **the app is English-only; remove other languages.** Build- and
runtime-verified (`fbc` exit 0; the IDE launches and renders fully in English — all menus, panels, and
the 14 bottom tabs; no garble, no `DebugInfo.log`; screenshot-confirmed).

- **How it works (no call-site churn):** MFF's `ML(V)` returns its argument `V` unchanged when
  `App.CurLanguage = App.Language`, and `English.lng`'s `[General]` values are empty (so English already
  resolves to the literal `ML("…")` argument). Forcing English makes all 1,829 `ML()` call sites pass
  through to their English text — **no call sites changed**. `LoadLanguageTexts` now hard-codes
  `App.CurLanguage = "english"` (dropped the `iniSettings.ReadString("Options","Language",…)`), and still
  loads the kept `Settings/Languages/English.lng`.
- **Removed the entire "Localization" Options page** (`frmOptions.frm`/`.bi`): the language picker
  (`cboLanguage`), the `grbLanguage`/`pnlLanguage`/`pnlLocalization` container tree, the "Localization"
  options-tree node + its panel-switch line, the `Language` INI save, the `newIndex`/`oldIndex`
  change-detect + "Localization changes… next run" message, the `Languages` `WStringList`, **and the whole
  ~665-line `cmdUpdateLng_Click` translator tool** ("Scan and Update … language files") with its
  `chkAllLNG` checkbox, `lblShowMsg` status label, and the unused `cmdUpdateLngHTMLFolds`/`cmdReplaceInFiles`
  vestigial declares. All six Localization-page child controls were accounted for (no orphans); tree-wide
  grep of every removed symbol is clean.
- **Deleted files:** all `Settings/Languages/*.lng` **except `English.lng`** (22 files incl. the `-AI`
  variants, `default.lng`, `tester`/`swabian`, `english.html`, translator `Readme.txt`) and the 4
  non-English per-language assets in `Settings/Others/` (`Compiler options.chinese(*)`, `KeywordsHelp.chinese(*)`;
  kept the base `KeywordsHelp.txt`/`AsmKeywordsHelp.txt`/`Compiler options.txt`).
- **Residual (harmless, deferred):** `English.lng` + the `LoadLanguageTexts` parser are kept as the active
  English path (not dead code). A few per-asset runtime guards (`If CurLanguage="english" … Else <lang>`) in
  Main.bas now always take the English branch — left as-is (runtime-guarded, low value). MFF's `ML`/
  `CurLanguage` i18n *mechanism* stays (framework capability, now inert for our app).

## Session handoff (2026-08-03, earlier) — rebrand VisualFBEditor → Ilwaco IDE

**START HERE.** Owner directive: rebrand the product. **User-facing name is "Ilwaco IDE"; files, the
executable, and build artifacts are "ilwaco" (lowercase).** Build- and runtime-verified.

- **User-facing strings → "Ilwaco IDE":** `APP_TITLE`, the main-window title (dropped the now-redundant
  `(x64)`), splash, About box, ~10 MsgBox captions, file-dialog filter labels (`Ilwaco IDE Project/Session/
  Project Group` — these are `ML()` keys, English fallback shows the new text), "When Ilwaco IDE starts",
  the `.rc` `ProductName`/`ApplicationTitle`/`FileDescription`, and the AI-prompt knowledge block prose.
- **Files/executable → `ilwaco`:** `git mv` of `src/VisualFBEditor.bas`→`src/ilwaco.bas`,
  `src/VisualFBEditor.rc`→`src/ilwaco.rc`, `VisualFBEditor.vfp`→`ilwaco.vfp`, `.vfs`, `.code-workspace`,
  `_Change.log`, `Resources/VisualFBEditor.ico`→`Resources/ilwaco.ico`, `VisualFBEditor64.desktop`→
  `ilwaco.desktop` (rewritten clean — the old one had the original author's `/mnt/media` paths),
  `Settings/VisualFBEditorX64_gtk3.ini`→`Settings/ilwaco.ini`. The whole-program `#cmdline` output is now
  `-x ../ilwaco`; `SettingsPath` is `Settings/ilwaco.ini`. Updated `build-linux.sh`, `makefile`, `.poseidon`,
  and every internal file reference (icon path, `.vfp` refs). Renamed `Help/AI prompt/KnowledgeBase/…
  VisualFBEditor IDE Environment.md`→`Ilwaco IDE Environment.md` + its two code refs.
- **Deleted** the 3 dead-platform settings INIs (`VisualFBEditor32.ini`, `…64.ini`, `…X64_gtk2.ini` — 32-bit
  and GTK2 are stripped platforms) and the old committed binary `VisualFBEditor64_gtk3` (rebuilt as `ilwaco`).
- **Left intact (functional/invisible):** the FB `Namespace VisualFBEditor` + `VisualFBEditorApp` type/global,
  the `WhenVisualFBEditorStarts` INI key + variable, `frmSplash`'s `This.Icon = "VisualFBEditor"` resource
  name, the AI-agent's upstream GitHub URL / `site_name` / `InStr(filename, "VisualFBEditor")` request-detection
  (these key off the original name deliberately), and historical/provenance mentions in docs. Also unchanged:
  a few commented-out `gtk_window_set_icon_name("VisualFBEditor…")` dead lines (no-comment sweep).
- **Caution (updated):** the old `pkill` note now applies to `ilwaco` — `pkill -f ilwaco` risks matching the
  caller; use `pkill -x ilwaco` or kill by PID. `git checkout Settings/` after any launch (writes `ilwaco.ini`).

## Session handoff (2026-08-03, earlier) — 64-bit-only strip COMPLETE (passes 1, 2a, 2b, 2c all DONE)

**START HERE.** Owner directive: **Ilwaco is 64-bit only — strip all 32-bit code** (memory
`project-64bit-only`). The whole 32-bit strip is now **done and build+runtime-verified**. Passes 1 and 2a
were committed in prior sessions (`a1b2722`, `12044a1`); **passes 2b and 2c are staged in the working tree,
uncommitted** (build-verified `fbc` exit 0 each; the IDE launches to the "Visual FB Editor (64-bit)" window
and idles clean — no error dialog, no `DebugInfo.log`, only the documented-harmless AppAddin/AppConsole
resource warnings). Grep of `Compiler32|LibX32|CompilationArguments32` (excluding the kept `…321` control)
is **empty**.

- **Pass 1 — DONE (committed `a1b2722`).** Removed the `tbt32Bit`/`tbt64Bit` 32/64 build-target toolbar
  toggle; collapsed every `Bit32`/`tbt32Bit->Checked` consumer to the 64 branch. Fixed a latent
  both-branches-32 bug. `Bit32`/`tbt32Bit`/`tbt64Bit` refs are zero.

- **Pass 2a — debugger-32 subsystem: DONE (committed `12044a1`).** Removed all `*Debugger32*`/
  `*DebuggerType32`/`Debug32Arguments` globals + the `cboDebug32`/`txtDebug32`/`lblDebug32` (frmParameters)
  + `cboDebugger32`/`cboGDBDebugger32`/`lblDebugger32` (frmOptions) controls with populate/apply/save +
  the shared Add/Change/Remove/Clear handlers repointed to `cboDebugger64`; fixed two latent 32/64 bugs.
  Kept `lblDebugger321` (different control).

- **Pass 2b — compiler-32: DONE, build-verified (staged).** Removed `Compiler32Path`/`Compiler32Arguments`
  (`Main.bi` globals + `Main.bas` assign/read/dealloc), `LibX32Folder` (`Main.bi` struct field + `Main.bas`
  library-load line); collapsed the `Main.bas` include-resolver and the `TabWindow.bas` lib-path pair to the
  64 attempt only; removed the frmParameters `txtfbc32`/`lblfbc32`/`lblAddCompilerOption32` designer blocks
  + populate/apply/save + the `lblAddCompilerOption32_Click` Sub + `.bi` declare/dims. Kept the `…64`
  equivalents (`txtfbc64`/`lblfbc64`/`lblAddCompilerOption64`).

- **Pass 2c — `CompilationArguments32` project property: DONE, build+runtime-verified (staged).** Removed the
  frmProjectProperties `lblCompilationArguments32`/`…32Linux` labels + `txtCompilationArguments32Windows`/
  `…32Linux` textboxes + their populate/apply/clear (`.frm`) and `.bi` dims; the `TabWindow.bi` struct fields
  `CompilationArguments32Windows`/`…32Linux` + `TabWindow.bas` deallocs; and the `Main.bas` `.vfp` parse
  (`ElseIf Parameter = "CompilationArguments32…"`) + save (`Print #Fn, "CompilationArguments32…`). Kept
  `lblCompilationArguments321` ("Command Line Arguments", a different control). Also collapsed the three live
  `#ifdef __FB_64BIT__` guards (frmSplash `lblSplash1.Text`, frmComponents `LibKey`, frmOptions `MFFDll`) to
  the 64 branch. **Deferred (not part of the 32-bit feature strip):** three commented-out `#ifdef __FB_64BIT__`
  lines inside large pre-existing dead-comment blocks in `Debug.bas` (~914/4568/9498) — sweep them with the
  standing "no commented-out code" cleanup of `Debug.bas`, not here.

**NEXT:** the 32-bit strip is complete. Resume the Astoria→Ilwaco changelog walk (AstoriaParity item 3:
`53d8e473` compile-warning fixes, then the menu-taxonomy feature ports). Optionally do the standing
"no commented-out code" sweep of `Debug.bas` (the three deferred `__FB_64BIT__` comment blocks live there).

## Session handoff (2026-08-02, earlier) — compiler stage 2 COMPLETE (tasks 11, 12, 13 all DONE)

**START HERE.** The whole-tree non-target strip (below) is done, committed, and pushed. Then **compiler
removal stage 2** (the "one compiler, no picker" completion) was finished. Stage 2 had three parts — 11
(Options picker UI), 12 (per-project `CompilerPath` override), 13 (`[Compilers]` INI machinery). **All three
are DONE and build+runtime-verified. Tasks 11 & 13 are staged (uncommitted); task 12 was committed `0fb1746`.**
The "one bundled compiler, no picker, no INI machinery" goal is fully realized — the only compiler path in the
system is the hard-coded `BundledCompilerPath`.

- **Task 13 — `[Compilers]` INI machinery: DONE — build-verified (`fbc` exit 0) AND runtime-verified with a
  real compile.** Retired the entire vestigial machinery: the `Compilers` `Dictionary` + `pCompilers` pointer,
  `Current/DefaultCompiler32/64` globals, the `[Compilers]` INI **read** (`Main.bas` load loop) and **write**
  (`frmOptions.frm`), the compiler lookup in the compile-command builder, and the cleanup/dealloc. **−441
  lines net** across `Main.bas`/`Main.bi`/`frmOptions.frm`. Key safety points honoured:
  - **Kept the fragile 10-section load loop's `Compilers` KeyExists term** (`Main.bas:5498`) so the shared
    `Do Until … = -10` loop still terminates correctly; only dropped the `Compilers.Add` body inside it.
  - **Kept `Compiler32Path`/`Compiler64Path`** (set from `BundledCompilerPath`; used by `FbcExe` and the
    include/lib path resolvers) — those are the bundled paths, not the retired picker machinery.
  - Compile-command builder (`Main.bas` ~604-613): dropped the `Else` branch that set `CompilerTool` from
    `pCompilers`; for a normal compile `CompilerTool` stays 0 and `CompileWith` is built entirely by the
    in-code `WAdd` flag chain (every `Command_N` template was empty anyway, so this is behaviour-preserving).
  - **Runtime-verified by real compile:** opened a trivial `.bas` in the IDE and hit Compile — fbc ran with
    the **bundled compiler** and compiled `.bas → .c → .asm → .o` cleanly. Only the final `ld` link failed
    with `cannot find -lncurses` — a **missing system lib in the dev shim** (fbc's default console link wants
    libncurses; task 13 never touched link flags), **not** a code regression. See "Known env gap" below.
  - **Known env gap (packaging/shim, not a code bug):** the dev shim provides `libtinfo.so.5` but no
    `libncurses.so`, so the IDE can't fully *link* a console app in this environment. Pre-existing; relevant to
    the AppImage/shim packaging task (add a `libncurses` dev symlink to `$SHIM`), tracked separately from the
    compiler work.

- **Task 11 — Options + Parameters picker UI: DONE — build-verified (`fbc` exit 0, zero warnings) AND
  runtime-verified.** Staged in the working tree (not yet committed). Removed the entire compiler-picker
  subsystem across 4 files, **−398 lines in `frmOptions.frm`** alone:

- **Task 11 — Options + Parameters picker UI: DONE — build-verified (`fbc` exit 0, zero warnings) AND
  runtime-verified.** Staged in the working tree (not yet committed). Removed the entire compiler-picker
  subsystem across 4 files, **−398 lines in `frmOptions.frm`** alone:
  - `frmOptions.frm`/`.bi` — the `grbDefaultCompilers`/`grbCompilerPaths` groupboxes, `lvCompilerPaths`,
    `cboCompiler32`/`cboCompiler64`, the `hbxCompilers` Add/Change/Remove/Clear button bar, the
    `cmdFindCompilers` button + `lblFindCompilersFromComputer`, the whole `FindCompilers`/
    `FindProcessStartStop`/`FindCompilersSub`/`FindedCompilersCount`/`FolderName` disk-scan subsystem, the
    4 handler bodies + their `Declare`s, the `lvCompilerPaths_ItemActivate` + `cmdFindCompilers_Click`
    handlers, and the LoadSettings populate + `cmdApply_Click` save blocks. **Kept** (shared): `bStop`
    (used by `HistoryCodeClean`), `Dim As UString tempStr` + `Dim As ToolType Ptr Tool` (used by the
    MakeTools/Debuggers/etc. save loops).
  - `frmParameters.frm`/`.bi` — the per-build `cboCompiler32`/`cboCompiler64` selector (designer, populate,
    apply). **Kept** `txtfbc32/64` (fbc-arguments), `lblfbc32/64`, `lblAddCompilerOption32/64`,
    `frmCompilerOptions` — the arg-string editor is a separate feature.
  - **Bonus fix:** both the Options Apply and the frmParameters OK used to `WLet(Compiler32/64Path,
    pCompilers->Get(...))`, **clobbering** the hard-coded bundled path on every OK/Apply. That clobber is
    now gone — the bundled `Compiler32/64Path` (set from `BundledCompilerPath` in LoadSettings) survives.
  - **Design decision:** kept `pnlCompiler` + the "Compiler" tree node — it is a *parent* category
    (children Build Configurations / Includes / Make Tool), so it now shows an **empty parent panel**
    (normal tree behaviour). Runtime-verified: Options opens, Compiler node shows empty panel, Apply works,
    no crash, no `DebugInfo.log`.
  - **Left intact for task 13:** `pCompilers`/`Compilers`, `Current/DefaultCompiler32/64`, and the
    `[Compilers]` INI read (`Main.bas` ~5506-5512) + write (`frmOptions.frm` save loop ~4353) — retiring
    that machinery is task 13, which touches the hot compile path and the fragile 10-section loop.

**Prior status (still current for task 12; task 11 now superseded above):**

- **Task 12 — per-project `CompilerPath` override: DONE — build-verified (`fbc` exit 0, zero warnings) and
  committed.** Runtime spot-check still advisable (open Project Properties ▸ Compile tab — the compiler row
  should be gone; leaves a harmless gap at y≈285). 5 files, −103 net lines:
  - `frmProjectProperties.frm` — removed the Compile-tab "Compiler" row (designer blocks for `lblCompiler`,
    `cboCompiler`, `txtCompilerPath`, `cmdCompiler`), their 3 dispatch stubs + 3 handler bodies, the
    `cboCompiler` population in `Form_Create`, and the load/save of `ppe->CompilerPath`. (Leaves a visual gap
    at y≈285 on `tpCompile` — controls use absolute bounds, so harmless; reflow later if desired.)
  - `frmProjectProperties.bi` — removed the 6 handler `Declare`s and `cmdCompiler`/`lblCompiler`/`cboCompiler`/
    `txtCompilerPath` from the `Dim As` lines.
  - `TabWindow.bi` / `TabWindow.bas` — removed the `CompilerPath As WString Ptr` project field + its `WDeAllocate`.
  - `Main.bas` — build branch now always `WLet(FbcExe, GetFullPath(IIf(Bit32, *Compiler32Path, *Compiler64Path)))`
    (dropped the `Project->CompilerPath` override); removed the `.vfp` `CompilerPath` parse (~1462) and save (~2078).
  - Verified by grep: zero remaining `CompilerPath`/`cboCompiler`/`txtCompilerPath`/`cmdCompiler` refs in `src/`.
    **Do NOT touch `Compiler32Path`/`Compiler64Path`** — those are the global bundled-compiler paths (keep).
  - Resume build: `./build-linux.sh editor` then runtime-check (open Project Properties ▸ Compile tab: the
    compiler row should be gone). Commit message ready in spirit: "Compiler stage 2: remove per-project
    CompilerPath override".

- **Task 11 — Options picker UI: DONE (see the DONE block at the top of this handoff for the full surface).**

- **Task 13 — `[Compilers]` INI machinery: DONE (see the DONE block at the top of this handoff).** Original
  survey notes retained below for reference. Key finding: every `Command_N` (the fbc
  argument template) is **empty** in the INIs, so `CompileWith` starts empty and all real flags are built in code
  (`Main.bas` ~622-677). So `pCompilers`/`Compilers` is used only by (a) the picker UI removed in task 11, (b) the
  arg-template lookup `Main.bas:616-617` (`CompilerTool = pCompilers->Item(Idx)->Object`; empty → contributes
  nothing), and (c) the `LoadSettings` read (~5513-5520 `Compilers.Add`) + cleanup (~10565). After task 11,
  replace 616-621 with `WLet(CompileWith, "")` for the non-Make branch, drop the `Compilers.Add` block **without
  touching the shared 10-section `Do Until…Loop` termination condition** (5509-5512 — leave the `Compilers` term
  in the KeyExists sum so the loop still ends correctly), then retire `Compilers`/`pCompilers`/`CurrentCompiler32/64`/
  `DefaultCompiler32/64` if nothing else references them. Build after each micro-step. **Exact surface after task 11
  (verified 2026-08-02):** the `[Compilers]` write lives in `frmOptions.frm` cmdApply save section, now
  **`4142-4151`** (`WriteString "Compilers", "DefaultCompiler32/64"` + the `Version_/Path_/Command_` loop + the
  `Do…KeyRemove` cleanup) — remove it in task 13. Main.bas anchors are unchanged by task 11: dict/pointer
  `84`/`122`/`199` (`Compilers`/`pCompilers = @Compilers`), lookup `612-613`, load `5502`/`5506-5512` +
  `5593-5596`, cleanup `10507-10510`/`10558-10559`. Note: after task 11 the `If CompilerTool <> 0` guard at
  `615-617` already yields empty `CompileWith` when `pCompilers` is empty, so real fbc flags are still built in
  code — retiring the machinery is safe.

**Build/run:** `./build-linux.sh` (committed `0b61d0c`) — `editor` | `lib` | `all`; run with
`LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`. `git checkout Settings/`
after any IDE launch (it writes session state on exit). *(Source is `src/ilwaco.bas`, binary `./ilwaco`,
settings `Settings/ilwaco.ini` since the 2026-08-03 rebrand.)*

---

## Session handoff (2026-08-02, earlier) — whole-tree non-target strip complete (MFF + src + Controls + Examples)

**START HERE.** Following the MFF strip below, the non-target strip was **extended across the whole tree**
per owner direction ("extend to all code in src, Controls and Examples"). Landed in these commits (on
`main`): `172aa23` MFF strip · `0b61d0c` build-linux.sh · `a0919c5` src/ strip · `422e931` non-MFF
Controls + cross-platform Examples strip · `d0b22a1` delete 16 Windows-only Examples demos · `b389866`
docs. **`src/` is build- + runtime-verified** (editor rebuilds clean, IDE launches + idles stably ~60 s,
no crash/`DebugInfo.log`). **`Controls/` (non-MFF) and `Examples/` are off the Ilwaco build path** so are
not IDE-build-verified — stripped conservatively (builtin `__FB_WIN32__` safe anywhere; `__USE_*` under
the GTK-target assumption) with every edit subsequence-checked. 16 Windows-only demos deleted (directshow,
directsound, WMI, SAPI, WLan, MediaFoundation, Midi, gdipClock/gdipGoldFish, IFileDialog, Com_VBA,
WellCOM, ChineseCalendar, MultipleDisplay, NTPClient, AndroidProject) — the Astoria mirror (Astoria, being
the Windows build, kept its whole Examples/ tree). Full detail: AstoriaParity "Done — whole-tree
non-target strip". **All committed; working tree clean.** Details of the MFF portion follow.

---

## Session handoff (2026-08-02, earlier) — MFF framework non-target strip (AstoriaParity task B) landed

The framework-wide non-target strip is done and **build- + runtime-verified**: both the
editor (`VisualFBEditor64_gtk3`, 4.99 MB) and the designer control lib (`libmff64_gtk3.so`, 1.69 MB)
rebuild **clean** (`fbc` exit 0, zero warnings), and the IDE **launches to a full editor window and idles
stably ~80 s** — no error dialog, no crash, no `DebugInfo.log` (only the documented-harmless
`AppAddin`/`AppConsole` resource warnings).

**Scale:** ~**134,600 lines removed across 274 files, 91 files deleted**. Two parts: (a) MFF control-code
strip — **198 files / ~41,250 lines** incl. 14 whole-file deletions; (b) `mff/gir_headers/` GTK4 binding
tree — **77 files / 93,349 lines** (included only under `#ifdef __USE_GTK4__`, so pure non-target). WINAPI
`#ifdef` occurrences in `mff/` went **954 → 0** outside the 3 excluded derivation files; the compiled
surface now has **zero** real non-target directives.

**How (durable tooling, reusable):** extended the task-A eliminator (`scratchpad/ppstrip.py`) into a full
recursive-descent `#if`/`#elseif` parser handling `defined()`/`AndAlso`/`OrElse`/`Not`/comparisons. It is
**conservative**: a chain collapses only if *every* branch condition is known (ground-truth symbol table
probed from the compiler — notably `__USE_CAIRO__` is **defined** on our build); any **opaque** symbol
(`pango_version`, `UNICODE`, `__USE_MAKE__`, `_WIN32_WINNT`, `GIFPlayOn`, …) leaves the chain intact but
still recurses inside. It only deletes whole lines — every edited file verified a strict line-subsequence
of the original. **Exclude list (they *define* the truth): `mff/mff.bi`, `mff/SysUtils.bi`, `inc/pipe.bi`.**
Two traps fixed mid-run: a **BOM** on line 1 hiding a leading `#ifdef`, and a **trailing `'comment`** on an
`#ifdef` line swallowed into the operand. Full method + symbol table + deleted-dir list in AstoriaParity
"Done — MFF non-target strip (staged task B)".

**Dark mode (REIMPLEMENT gap surfaced):** MFF already ships a real GTK3 `SetDarkMode`
(`gtk-application-prefer-dark-theme`), so `DarkMode/` was **kept** (not stubbed). But `g_darkModeSupported`
was only ever set by the deleted Win32 `InitDarkMode`, so on GTK it stays `False` and the
`If g_darkModeSupported AndAlso …` styling branches never fire — a REIMPLEMENT item (track with Astoria's
dark-mode commits). See AstoriaParity NEXT ACTION.

**Deferred strip sub-items (non-blocking, off the compiled path):** `mff/win/` (Windows headers, now inert),
`Controls/Framework/inc/` (not on the build path — incl. the WINAPI-forcing `pipe.bi`), a few
commented-out `'#ifdef` cruft lines, and `#define nullptr 0` in `DarkMode.bi`. Listed in AstoriaParity.

**Build note:** the shim (`$SHIM` GTK dev-symlink dir + vendored `Compilers/shim/libtinfo.so.5`) is
recreated per session in scratchpad; the durable `build-linux.sh` is still the open infra task. Nothing
committed yet this session — the strip is staged in the working tree for review.

---

## Session handoff (2026-08-02, earlier) — EditControl fully stripped; compiler hard-coded (no picker dialog)

**START HERE.** Two substantive landings, both **build-verified clean** (fbc exit 0, zero warnings) and
**runtime-verified** (the IDE launches to a fully-loaded editor — full menus/panels, "IntelliSense fully
loaded" — with **no error dialog**; no crash, no `DebugInfo.log`).

**1. Full `EditControl.bas`/`.bi` non-target strip (AstoriaParity staged task A — DONE).** The single
largest strip in `src/`: **`EditControl.bas` 9405 → 6582, `EditControl.bi` 845 → 764** (−2,904). Deleted
every non-target branch (Windows GDI + Direct2D, GTK2), collapsed the target-GTK guard wrappers, and
removed the commented `'#ifdef …` cruft. Also finished the Direct2D retirement: dropped the unused ungated
`UseDirect2D` global (`EditControl.bi`) and the two dead `#ifdef __USE_WINAPI__` D2D init blocks in
`Main.bas` — **zero D2D refs remain in `src/`**. Method was a *correct guard-evaluating* eliminator (every
conditional here is single-symbol `#ifdef`/`#ifndef`, no `#if`-exprs, no `#elseif`), run in two
build-checkpointed phases (A: delete non-target-guarded blocks; B: collapse `__USE_GTK__`/`__USE_GTK3__`
wrappers). Tools + full method in AstoriaParity's "Done — staged task A" section; scripts (`ppstrip.py`,
`ppmap.py`) in scratchpad. **Remaining strip = task B** (MFF), top of AstoriaParity.

**2. Compiler path hard-coded, first-run dialog gone (opinionated design, stage 1).** Owner: *"The
compiler path should be hard coded into the system, there is no choice anymore."* Added
`#define BundledCompilerPath "./Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"` (Main.bi; `./` resolves
to `ExePath` via `GetFullPath`, so it travels in the AppImage) and assigned `Compiler32/64Path` from it in
`LoadSettings` — **without touching the fragile 10-section `[Compilers]` INI parse loop** (kept
`CurrentCompiler64` so the argument template still resolves). Deleted `Function CheckCompilerPaths` and set
its call site `bSharedFind = True`. **The "Invalid defined compiler path / Find Compilers?" first-run
blocker (see Known issues below) is now gone.** **Stage 2 pending** (remove the picker UI + per-project
`CompilerPath` override + vestigial INI machinery — needs the fragile loop refactored, own session; see
AstoriaParity "Done — compiler path hard-coded" for the exact surface).

**Verification note / caution for next session:** driving the GTK build over `:0` with `xdotool type` is
**focus-fragile** — keystrokes leaked into the *host* window during this session. Prefer opening a file via
CLI args or verifying by effect (window loads, no error dialog) over synthetic typing. Also: **`pkill -f
VisualFBEditor64_gtk3` matches its own shell** (kills the caller, exit 144) — use `pkill -x` on the exact
name, or `pgrep`/`kill` by PID. The IDE **writes window/session state into the INI on exit** — `git
checkout` the `Settings/*.ini` afterward to keep it pristine.

**Follow-up pass (2026-08-02, this handoff):** removed the remaining commented-out Win32 lines in
`EditControl.bas` (`'txtCode.*`, the `'SendMessage`/`ComboBoxInfo`/`PostMessage` block, `'…SelectObject(bufDC…)`)
— build re-verified (fbc exit 0), IDE relaunched to a fully-loaded editor. **Caveat on the "no crash"
claim above:** on the first launch this session the process exited with **SIGSEGV (139) ~1 min in**; it did
**not** reproduce on relaunch (91 s idle, clean, no `DebugInfo.log`), so it is an *unconfirmed, possibly
interaction-triggered* crash, not a verified idle regression. Get a source-line backtrace next session by
rebuilding with `-g` (FreeBASIC's handler then reports error 12 with a line) and opening a file. A handful
(~4) of `'txtCode`-style dead comments still remain elsewhere in `EditControl.bas` for a later full sweep.

---

## Session handoff (2026-08-02, earlier) — GitHub menu + Direct2D option removed; build shim vendored; non-target strip scoped

**START HERE.** Continued the parity walk, removed the Direct2D user option, closed a standing infra
gap (vendored the fbc shim), and scoped the big non-target-platform strip for a fresh session.

**Landed this session (both build-verified clean, committed + pushed):**
- **Removed the Help ▸ GitHub submenu** (Astoria `d275dc93`) — `src/Main.bas` (the `miGitHub` block,
  8 items + 2 separators) and `src/VisualFBEditor.bas` (8 `Case` handlers incl. orphan `GitHubWebSite`).
  Kept `OpenUrl` (used by other Help commands) and the FreeBasic WiKi/Forums items. Commit `6f79c39`.
- **Removed the Direct2D user option** (Astoria `DIRECT2D_REMOVAL.md` §1, "Phase 1") — the
  "Use Direct2D (For Windows)" toolbar button + Options checkbox + INI key + dispatch. On GTK the whole
  Direct2D *render* path was already `#ifdef __USE_WINAPI__`-gated (never compiled); only the toggle was
  live-but-useless. `frmOptions.frm` done via **edit-form-safely**. Commit `5bc101d`.

**Re-scoping discovered (important):** the editor's remaining Direct2D can't be stripped on its own —
it's interleaved through **EditControl's entire Windows branch** (23 `#ifdef __USE_WINAPI__` blocks +
137 `#ifdef __USE_GTK*…#else…#endif` pairs, ~2,135 lines, GDI+D2D together). Retargeted as the **full
EditControl WINAPI strip**, staged in AstoriaParity (task A), with MFF Direct2D as task B. Owner steer:
prefer a **comprehensive global strip** of all non-GTK code (delete, never comment/no-op) — it makes
later work much easier (memory `project-strip-windows-code`). **GTK-guard trap:** `__USE_GTK2__` vs
`__USE_GTK3__` differ — the `#else` of a `__USE_GTK2__` block can be the live GTK3 branch; no blind
`#else` deletion.

**Infra fixed — the build shim no longer lives only in scratchpad:**
- `libtinfo.so.5` (the one piece `fbc` needs that Debian 13 dropped) is now **vendored in-repo at
  `Compilers/shim/libtinfo.so.5`** (183 KB, extracted from the Debian 11 `libtinfo5` .deb, owner-approved).
  Survives across sessions — no more re-downloading it.
- The GTK `-dev` `.so` symlinks are still recreated per session into a scratchpad shim dir
  (`$SHIM = <scratchpad>/fbclibs`) but now point `libtinfo.so.5` at the vendored copy. **Owner rule:
  retain the shim, do not delete it.** A `build-linux.sh` that farms the symlinks + references the
  vendored lib is the remaining infra step (memory `reference-linux-build`).
- **Delegation rule updated:** Sonnet workers do edits and **hand back to Opus for compilation** — a
  worker never rebuilds/loads the shim (memory `feedback-worker-returns-for-compilation`).

**Build recipe (this session, working):**
`cd src && LD_LIBRARY_PATH=$SHIM ../Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc VisualFBEditor.bas -i ../Controls/Framework -d __USE_GTK3__ -p $SHIM -l tinfo`

**NEXT (staged for a fresh session — see AstoriaParity "NEXT ACTION"):** strip **all non-target-platform
code** (target = x86_64 Linux/GTK3; strip Windows, Android/JNI, GTK4, GTK2, Darwin, WASM, 32-bit — delete,
never no-op). Two staged tasks: **A** = full `EditControl.bas`/`.bi` strip (~2,135 lines, its own
carefully-chunked, build-after-each session); **B** = MFF non-target strip (MFF holds the multi-platform
bulk — WINAPI 945, GTK4 125, WASM 129, JNI 88, GTK2 35 — rebuild `libmff64_gtk3.so`). Guard/keep lists
+ typo-guard landmines in memory `project-strip-windows-code`. Phase 1 is the parity win already banked.

---

## Session handoff (2026-08-02, earlier) — parity walk begun: 5 changes landed, all build-clean

**START HERE.** Build baseline was established earlier (section below). This session began the actual
**Astoria→Ilwaco parity walk**. Method and full backlog: [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md).
Key realization: **menus are the *surface* of feature-parity** — items appear/vanish because features
are ported/removed, so we drive menu edits from the feature walk (never pre-reorganize menus). And
**port to Astoria's *final* state, not replay commits** (the changelog has churn: things added then
removed).

**Landed this session (each `fbc`-verified, exit 0, no warnings — last clean binary 10:22):**
1. **Panel collapse-on-pin** — `VisualFBEditor.bas` `Pin{Left,Right,Bottom}` handlers now collapse in
   one click (Astoria `e212819d`/`c2672840`/`64daa66e`, behaviour half). Bottom-panel *persistence*
   half deferred (needs infra Ilwaco lacks — see AstoriaParity).
2. **Service→Tools menu rename** (`ae74b31c`), caption-only.
3. **Removed legacy Error Handling + Line Numbering** (`ec42ea83`) — ~500 lines across 5 files.
   Line-numbering *toggle* went because line numbering is now standard; the FB `Try/Catch` language
   construct and the editor's gutter line-number display are untouched.
4. **Removed "Close Folder"** (`ec42ea83`).
5. **Removed the "Use" target-selector dropdown** — WinAPI/GTK/JNI/WASM define picker (Astoria removed
   it wholesale; kept the `UseDefine` global + consumers, now always-empty — a follow-up cleanup).
   **First task delegated to a Sonnet worker** (owner asked: push mechanical work to Sonnet to save
   Opus credits — memory `feedback-delegate-mechanical-to-sonnet`).

**Infrastructure stood up this session:** `CLAUDE.md` (Linux/GTK rules), `Documentation/AstoriaParity.md`
(the classified backlog), 9 platform-neutral skills in `.claude/skills/`, and assistant memory
(project overview, port strategy, packaging=AppImage+external writable dirs, base provenance
[Newer≈Ilwaco≈upstream 1.3.8; Astoria = your DeepSeek/Cursor layer + the 888-commit changelog],
opinionated design, strip-windows mantra, feature-removal process, delegation).

**NEXT (fully scoped, ready to apply — see top of AstoriaParity.md):** remove the **Help ▸ GitHub**
menu (`d275dc93`) — `Main.bas` 7776–7785 + `VisualFBEditor.bas` 1171–1178, ~18 lines, no other files.
Delegate to Sonnet.

**Removal-process lessons (in memory `project-strip-windows-code`):** grep **all** src files for (a)
command strings, (b) function names, **and (c) `mi*/dmi*` menu-pointer variable names** — (c) was
missed twice and caught by the compiler in `TabWindow.bas`. Watch **shared `Var` declarations**
(`tbButton` had to be re-homed twice). The `fbc` build is the real safety net.

**Delegation gotcha:** the Sonnet worker's *edits* were correct but its *build* kept getting SIGTERM'd
and it never reported a final status — I ran the confirming build. Next time instruct the worker to run
the build as a **surviving background job** and report the log.

**Build/run env:** in-repo bundled `fbc` (`Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc`, tracked)
and the GTK-capable MFF source (`Controls/Framework/`, now vendored as real files — the old
submodule gitlink was dropped, commit `60015e4`), so the repo is self-contained **except** for a
userspace shim for `libtinfo.so.5` and the GTK `-dev` symlinks, **currently in the assistant's
scratchpad** (`/tmp/claude-.../scratchpad/fbclibs`) — NOT yet vendored into the repo (ephemeral;
recreate per memory `reference-linux-build`). A durable
`build-linux.sh` + vendored shim remains an open infra task (memory `reference-linux-build` has the
exact recipe). Build command:
`cd src && LD_LIBRARY_PATH=<shim> fbc VisualFBEditor.bas -i ../Controls/Framework -d __USE_GTK3__ -p <shim> -l tinfo`

---

## Session handoff (2026-08-02) — Linux build baseline established

**START HERE.** Ilwaco now **builds from source and runs** on this Debian 13 machine. That was not
possible at the start of the session: no compiler was on the box, the framework source was missing,
and the committed binary would not run. All three are resolved.

### What was done
- **Compiler:** found the bundled `Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc` inside the repo.
  It needs `libtinfo.so.5` (dropped by Debian 13) and the GTK `-dev` `.so` symlinks (no `-dev`
  packages installed). Both are handled by a **userspace shim** (no sudo): a real `libtinfo.so.5`
  extracted from the Debian 11 `libtinfo5` package on `LD_LIBRARY_PATH`, plus unversioned dev
  symlinks for the GTK stack passed via `fbc -p`, plus `-l tinfo` on the link line. Full recipe is
  in the assistant's project memory (`reference-linux-build`); **it still needs to be captured as a
  repo build script** — see Next.
- **Framework (MFF):** `Controls/Framework/` was empty. Vendored the **GTK-capable** MFF source
  from the original download (`~/pCloudDrive/VisualFBEditor - original/Controls/Framework`) —
  *not* Astoria's copy, which has GTK stripped. Skipped its `lib/` (48M, Windows-only import libs),
  `examples/`, `help/`.
- **Built, from `src/`:** `fbc VisualFBEditor.bas -i ../Controls/Framework -d __USE_GTK3__`
  (whole-program; output path is set by a `#cmdline` in the source) →
  `VisualFBEditor64_gtk3` (~5 MB, needs only **GLIBC_2.34**, far more portable than the committed
  binary's 2.42). Then the designer's control library:
  `cd Controls/Framework/mff && fbc -b mff.bi -dll -x ../libmff64_gtk3.so -d __USE_GTK3__`
  → `Controls/Framework/libmff64_gtk3.so` (~1.7 MB). Each whole-program compile is ~3–4 min.
- **Verified by effect:** the IDE launches (splash "Visual FB Editor 1.3.8 64-bit", main window,
  live GTK event loop), and with the `.so` present the control-toolbox "libmff64_gtk3.so not found"
  error is gone.

### Known issues surfaced (not blockers for the restructuring work)
- **First-run "Invalid defined compiler path" dialog — RESOLVED 2026-08-02** (see the latest handoff,
  stage 1). The shipped `[Compilers]` pointed at the original author's dead `/mnt/media/...` paths. Rather
  than restructure the fragile parse loop (it crashes if the `[Compilers]` block is restructured — a
  null-deref), the compiler path is now **hard-coded** from `BundledCompilerPath` after the loop and the
  `CheckCompilerPaths` validator/dialog was removed. The INI block is left intact (ignored for path). The
  full "one compiler, no picker" UI removal is **stage 2** (AstoriaParity).
- **Runtime needs the fbc shim on `LD_LIBRARY_PATH`** when the IDE spawns fbc to build a user
  project. Launching the IDE with the shim env makes the child fbc inherit it; a shipped build needs
  a launcher/wrapper that sets this (packaging concern).
- Harmless startup warnings: resources `AppAddin`, `AppConsole` "do not exist".
- `gdb` is not installed (debugger default won't resolve); `UseDebugger=false` by default.
- `UseDirect2D=true` in settings — Direct2D is Windows-only; Astoria has a `DIRECT2D_REMOVAL.md`.
  A clear early parity item on the GTK side.

### Next
1. **Capture the build as a repo script** (`build-linux.sh` + vendor the shim `libtinfo.so.5` under
   `Compilers/`) so the toolchain isn't trapped in the assistant's scratchpad.
2. **Stand up the doc infrastructure** listed at the top (parity backlog is the keystone).
3. **Begin the changelog walk** from `astoria-ide/Documentation/AstoriaIDESignificantChanges.md`
   (§1 added features → port; §2 removed features → decide keep/drop; §3 inherited-defect fixes →
   port + upstream), classifying each item in `AstoriaParity.md`.

### Environment note
No FreeBASIC on PATH, no sudo, `/opt` not writable. Everything builds via the in-repo bundled fbc +
the userspace shim. Rebuilt binary and vendored MFF are untracked/modified in git; nothing committed
this session.
