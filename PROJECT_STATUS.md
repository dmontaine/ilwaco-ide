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

## Session handoff (2026-08-02, latest) — GitHub menu + Direct2D option removed; build shim vendored; non-target strip scoped

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
- **First-run "Invalid defined compiler path" dialog.** The shipped `Settings/VisualFBEditorX64_gtk3.ini`
  `[Compilers]` points at the original author's dead `/mnt/media/...` paths. Pointing it at the
  bundled fbc is trivial, **but the settings parser crashes on startup if the `[Compilers]` block is
  *restructured*** (removing `Version_N`/`Path_N` entries or renaming the default) — a null-deref of
  the class Astoria documents. So the eventual "one compiler, no picker" change must edit the parser,
  not just the ini. The ini was reverted to pristine for now; this is a **parity/restructuring item**,
  not something to hot-patch.
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
