# Ilwaco IDE — Project Status & Handoff

Ilwaco is a Linux (GTK3) IDE for FreeBASIC — the **VisualFBEditor** codebase — being brought toward
parity with its Windows sibling **Astoria** (`../astoria-ide`). The plan is to walk Astoria's change
history and translate each change into Ilwaco, adapting Win32 → GTK, and — following Astoria's
"opinionated by design" stance — *removing* options and dialogs rather than accumulating them
(e.g. one bundled compiler, no compiler picker). Hobby project, no deadline: prefer durable
scaffolding over speed.

See also (to be created as work proceeds): `HISTORY.md` (session narratives), `CHANGELOG.md`
(milestones), `Documentation/DetailedChangelog.md`, `Documentation/AstoriaParity.md` (what we ported
and what we couldn't, and why), `Documentation/UpstreamFixes.md` (fixes useful to VisualFBEditor —
Ilwaco keeps GTK, so our GTK fixes apply upstream where Astoria's Win64-only ones cannot), and
`CLAUDE.md` (orientation for the Linux/GTK build).

---

## Session handoff (2026-08-02, latest) — whole-tree non-target strip complete (MFF + src + Controls + Examples)

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
`Controls/MyFbFramework/inc/` (not on the build path — incl. the WINAPI-forcing `pipe.bi`), a few
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
`cd src && LD_LIBRARY_PATH=$SHIM ../Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__ -p $SHIM -l tinfo`

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
and the GTK-capable MFF source (`Controls/MyFbFramework/`, now vendored as real files — the old
submodule gitlink was dropped, commit `60015e4`), so the repo is self-contained **except** for a
userspace shim for `libtinfo.so.5` and the GTK `-dev` symlinks, **currently in the assistant's
scratchpad** (`/tmp/claude-.../scratchpad/fbclibs`) — NOT yet vendored into the repo (ephemeral;
recreate per memory `reference-linux-build`). A durable
`build-linux.sh` + vendored shim remains an open infra task (memory `reference-linux-build` has the
exact recipe). Build command:
`cd src && LD_LIBRARY_PATH=<shim> fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__ -p <shim> -l tinfo`

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
- **Framework (MFF):** `Controls/MyFbFramework/` was empty. Vendored the **GTK-capable** MFF source
  from the original download (`~/pCloudDrive/VisualFBEditor - original/Controls/MyFbFramework`) —
  *not* Astoria's copy, which has GTK stripped. Skipped its `lib/` (48M, Windows-only import libs),
  `examples/`, `help/`.
- **Built, from `src/`:** `fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__`
  (whole-program; output path is set by a `#cmdline` in the source) →
  `VisualFBEditor64_gtk3` (~5 MB, needs only **GLIBC_2.34**, far more portable than the committed
  binary's 2.42). Then the designer's control library:
  `cd Controls/MyFbFramework/mff && fbc -b mff.bi -dll -x ../libmff64_gtk3.so -d __USE_GTK3__`
  → `Controls/MyFbFramework/libmff64_gtk3.so` (~1.7 MB). Each whole-program compile is ~3–4 min.
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
