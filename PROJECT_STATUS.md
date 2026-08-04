# Ilwaco IDE — Project Status & Handoff

Ilwaco is a Linux (GTK3) IDE for FreeBASIC — the **VisualFBEditor** codebase — being brought toward
parity with its Windows sibling **Astoria** (`../astoria-ide`). The plan is to walk Astoria's change
history and translate each change into Ilwaco, adapting Win32 → GTK, and — following Astoria's
"opinionated by design" stance — *removing* options and dialogs rather than accumulating them
(e.g. one bundled compiler, no compiler picker). Hobby project, no deadline: prefer durable
scaffolding over speed.

See also: [HISTORY.md](HISTORY.md) (past session narratives, extracted from this file),
[Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md) (the pruned port
backlog), [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md) (what we ported and what we
couldn't, and why), and [CLAUDE.md](CLAUDE.md) (orientation for the Linux/GTK build). Still to be created
as work proceeds: `CHANGELOG.md` (milestones) and `Documentation/UpstreamFixes.md` (our GTK fixes useful
to VisualFBEditor upstream, where Astoria's Win64-only ones cannot apply).

**Keep this file pruned.** It holds only the **most-recent session handoff**, the **NEXT** actions, and
the **standing facts** below — not an archive. When a session's work is done and committed, move its dated
narrative section to [HISTORY.md](HISTORY.md) (newest-first) instead of letting handoffs pile up here.
`python3 Tools/DocCheck.py` flags this file once more than two dated session sections accumulate; see
CLAUDE.md "Working practices".

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

## NEXT — two found bugs, then the menu-taxonomy cluster

- ~~The debugger source path-case `LCase`~~ — **fixed 2026-08-04** (`Main.bas TimerProc`; verified by
  debugging a project from `/tmp/ArgTest_MixedCase/`). The remaining found bug is the cosmetic
  breakpoint-line path render (the source path is drawn after the code text).
- **New, deferred:** `EqualPaths` (`Main.bas`) compares `LCase(a) = LCase(b)`, so Ilwaco treats `Foo.bas`
  and `foo.bas` as one file. Wrong on Linux, but it is on every tab-lookup / tree-match / project-file
  comparison path, so it wants its own build-verified pass. See TechnicalDebt.
- Then the **menu-taxonomy cluster** `49ec5ccd`/`37ba31ea`; skip the pure 32-bit/GTK-strip entries
  (`e139c2cc` etc.). The two **Examples items** (`4bd02894`, `51441d7a`) stay deferred to just before the
  testing phase (owner). All owner directives (32-bit, UTF-8/LF, AI, English-only) remain cleared.
- Unverified, low priority: **Ctrl+F5 did not resume** a stopped debuggee during this session's driving. May
  be an artefact of synthetic input rather than a defect — check by hand before treating it as a bug.

**Repo-hygiene note:** the `./ilwaco` binary is tracked **by owner directive (2026-08-04) — do not
`.gitignore` it** (the repo moves between two machines and the built editor must travel with each push).
Instead, **rebuild it (`./build-linux.sh editor`) and commit it alongside source changes** so the tracked
blob stays current rather than drifting.

---

## Current state (standing facts — not a session narrative)

**Where things stand.** Ilwaco builds from source and runs on this Debian 13 machine. All owner
directives are cleared: 64-bit-only, one bundled compiler (no picker), UTF-8/LF-only, English-only,
rebrand to Ilwaco IDE, and the whole-tree non-target (Windows/GTK4/GTK2/32-bit) strip. The active work
is the **Astoria→Ilwaco changelog walk** (backlog: [AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md),
classified in [AstoriaParity.md](Documentation/AstoriaParity.md)). Past session narratives now live in
[HISTORY.md](HISTORY.md).

**Build / run (self-contained — shim is vendored).**
- Build: `./build-linux.sh` — `editor` | `lib` | `all`.
- Run: `LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`.
- Source `src/ilwaco.bas` → binary `./ilwaco`; designer lib `Controls/MyFbFramework/libmff64_gtk3.so`
  (rebuild with `lib` or the toolbox errors); settings `Settings/ilwaco.ini`.
- The shim is now **fully in-repo**: `Compilers/shim/libtinfo.so.5` + the GTK `-dev` symlinks under
  `Compilers/shim/gtk-dev/` — no per-session scratchpad shim needed. `build-linux.sh` wires them up.
- A whole-program editor compile is ~3–4 min — run it in the background (a 2-min foreground limit kills it).

**Operational cautions.**
- **`git checkout Settings/` after any IDE launch** — it writes window/session state into `ilwaco.ini` on exit.
- **`pkill -f ilwaco` matches its own caller** — use `pkill -x ilwaco` or kill by PID.
- **Intermittent startup/shutdown SIGSEGV** is a known Astoria-fixed threading issue — don't chase it as a
  new regression (memory `project-known-segfault-threading`).
- Harmless startup warnings: resources `AppAddin`/`AppConsole` "do not exist".

**Known gaps (tracked, not blockers).**
- **Packaging/shim:** the dev shim has `libtinfo.so.5` but no `libncurses.so`, so fbc's *default* console
  link fails here. Work around it per-project with `CompilationArguments64Linux="-p <shim> -l tinfo"` — the
  IDE then compiles, links and debugs a console project end-to-end (verified 2026-08-04). Add a
  `libncurses` dev symlink when building the AppImage. AppImage packaging itself is still open (memory
  `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- `UseDebugger=false` by default. GDB is gone — the Integrated engine needs no external debugger.
