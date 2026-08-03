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

---

## Session handoff (2026-08-03, latest) — changelog walk + debug-tab visibility ported

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

**NEXT — continue the walk. The two persistence entries are the oldest remaining; after them:**
1. `e212819d` / `ef3b43e9` — bottom-panel **persistence** (deferred infra: save/restore collapsed panel
   state across sessions; see AstoriaParity "Deferred, split out: bottom-panel persistence").
2. `4bd02894` — add missing example `.vfp` files + "no unnecessary options" principle + Examples audit
   (REVIEW — the `.vfp` additions may be Windows-example-specific; the guiding principle is already ours).
Then the menu-taxonomy feature ports (`49ec5ccd` cluster). All owner directives (32-bit, UTF-8/LF, AI,
English-only) remain cleared.

**Repo-hygiene note:** the tracked `./ilwaco` binary drifts from source — `c087255` committed source
without rebuilding it, and source commits generally omit the 4.6 MB artifact. Consider `.gitignore`-ing the
built binary (it rebuilds via `./build-linux.sh editor`) rather than tracking a perpetually-stale blob.

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
- **Packaging/shim:** the dev shim has `libtinfo.so.5` but no `libncurses.so`, so the IDE can't fully *link*
  a console user-project in this environment (fbc's default console link wants libncurses). Add a
  `libncurses` dev symlink when building the AppImage. AppImage packaging itself is still open (memory
  `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- **`gdb` not installed** here (debugger default won't resolve); `UseDebugger=false` by default.
