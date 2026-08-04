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

## ✅ DONE (2026-08-04) — `5fa5cf25`: alt-compiler-backend removal + debugger Pass 1 (GDB engine deleted, Integrated kept & re-verified) + Pass 2 steps 2A/2B — COMMITTED (partial; Pass 2 2C/2D pending — see NEXT)

Porting Astoria's `5fa5cf25` ("remove Integrated (stabs) debugger and alt-compiler-backend/debugger-choice
code"), **adapted with the inverse debugger choice**: Ilwaco **keeps its built-in Integrated (stabs)
debugger and removes GDB** (Astoria kept GDB, dropped Integrated). Rationale: keep Astoria's opinionated
"one debugger, no picker" philosophy but make the best choice for Linux — the Integrated engine reads
FreeBASIC's own `.dbgdat`/`.dbgstr` ELF sections, emitted **only** by the **gas64** backend with `-g`
(Ilwaco is gas64-only), whereas gdb isn't installed here and Astoria's bundled-gdb path doesn't transfer.
See memory `project-debugger-keep-internal` and [AstoriaParity.md](Documentation/AstoriaParity.md).

**Compiler-backend half (done, built):** removed the `ToGAS/ToLLVM/ToGCC/ToCLANG` backend picker, the
optimization radios, and the whole `frmAdvancedOptions` dialog (GCC-only warning flags); `-gen gas64` is now
hardcoded in the project compile path (`Main.bas Compile()` + `TabWindow.bas GetFirstCompileLine`). Changed
`ilwaco.vfp`, `src/.poseidon`, `src/Main.bas`, `src/TabWindow.{bas,bi}`, `src/frmProjectProperties.{bi,frm}`,
`src/makefile`; deleted `src/frmAdvancedOptions.{bi,frm}`. (Correct that `-gen gas64` lives under `If Project
Then` — Ilwaco is **project-only**, not a loose-file editor.)

**Debugger Pass 1 (done, built, re-verified live):** removed the entire GDB engine — **2130 lines** from
`src/Debug.bas` (`CreatePipeD`→`deinit`: the `tlockGDB` pipe cluster, `run_debug`/`continue_debug`/
`step_debug`/`command_debug`/`kill_debug`, `load_file`/`get_read_data`/`set_bp`, `fill_*`/`info_*_debug`,
`get_version_gdb`, `GetPartPath`) plus `RunWithDebug`'s `IntegratedGDBDebugger` branch; collapsed the 10
`ilwaco.bas` `If CurrentDebugger = IntegratedGDBDebugger … Else …` dispatch blocks to their Integrated branch;
removed `Main.bas` `TimerProcGDB`, the `GDBCommand` sub + `miGDBCommand` menu, and the GDB watch
`command_debug`. `Debug.bas` 10,362 → 8,232. **Integrated debugger re-verified on `:0` after the refactor:**
gas64 project compiles → debuggee enters `t (tracing stop)` → Locals thread view + current-line marker work.

**Verification method (reusable):** a small **console `.vfp` project** (not a loose `.bas`) with the dev shim
on its lib path (`CompilationArguments64Linux="-p <shim> -l tinfo"`, needed only in this dev env — see Known
gaps), Integrated IDE debugger in `Settings/ilwaco.ini`, driven over `:0` with `xdotool`/`scrot`; `readelf -S`
confirms `-gen gas64 -g` emits `.dbgdat`/`.dbgstr`.

**Two pre-existing Linux bugs found (NOT Pass-1 regressions):** (1) the Integrated debugger lowercases the
source path (`Main.bas:2885 AddTab(LCase(source(fntab)))`, a Win32-ism) → "File not found" on case-sensitive
paths with uppercase letters (tracked as a spawned task); (2) cosmetic — the breakpoint line renders the
source file path appended after the code text.

---

## NEXT — `5fa5cf25` debugger Pass 2, then residual cleanup, then continue the walk

`5fa5cf25` is **partly done** (compiler-backend half + debugger Pass 1 + Pass 2 steps 2A/2B above;
committed, build-clean). Remaining:

- **Debugger Pass 2 — remove the debugger-choice machinery** now that only the Integrated engine survives.
  **Done (committed, each built green):** **2A** — `RunWithDebug` rewritten to Integrated-only
  (`check_bitness`→`start_pgm`; dropped the `pDebuggers`/`DebuggerPath`/`CmdL`/`GDBCommands.txt` writer +
  terminal machinery; `Debug.bas` → 8074). **2B** — `frmParameters`'s `cboDebug64` combo removed (control +
  `.bi` decl + LoadSettings/cmdOK logic). **Remaining:**
  - **2C — remove the `frmOptions` debugger options page** (`src/frmOptions.frm` ~55 refs + `frmOptions.bi`).
    Controls to delete: `pnlDebugger`, `grbDefaultDebuggers`, `grbDebuggerPaths`, `cboDebugger64`,
    `cboGDBDebugger64`, `lvDebuggerPaths`, `hbxDebugger`, `cmdAddDebugger`/`cmdRemoveDebugger`/
    `cmdChangeDebugger`/`cmdClearDebuggers`, `lblDebugger64`/`lblDebugger321`/`lblDebugger641` — their
    constructor blocks, the `.bi` `Dim As …`/`Declare` lines, the 5 handlers (`cmd*Debugger*_Click`,
    `lvDebuggerPaths_ItemActivate`(`_`)), the LoadSettings block (~3032-3045), the SaveSettings block
    (~3427-3447), the `[Debuggers]` `WriteString`/`KeyRemove` block (~3617-3628), and `.pnlDebugger.Visible`
    (~4060). **Tree reparent:** the options tree parents **Terminal under Debugger** (`tnDebugger->Nodes.Add(…
    "Terminal")` at ~3264); make Terminal a top-level node and drop `tnDebugger` (~3255).
  - **2D — remove the underlying machinery** (now unreferenced by UI): the **`DebuggerTypes` enum** +
    `DefaultDebuggerType64`/`CurrentDebuggerType64` (`Debug.bas:292-298`); `pDebuggers`/`Debuggers` dict
    (`Main.bas:91,122`); the `[Debuggers]` settings load (`Main.bas:5311-5371`) + `WDeAllocate`s
    (`9430-9434`) + save loop (`9479-9480`); `Debugger64Path`/`GDBDebugger64Path`/`DefaultDebugger64`/
    `GDBDebugger64`/`CurrentDebugger64` (`Main.bi:123-124,173`); and `build_create_shellscript`'s dead
    `DebuggerPath`/`bDebug` prefix (`TabWindow.bas:10759` — only ever called `bDebug=False`). Build-gated.
- **Residual `Debug.bas` GDB cleanup** (deferred from Pass 1 to avoid touching shared symbols mid-removal):
  the orphan GDB forward `Declare`s (~`Debug.bas:7958-7982`) and now-unused GDB globals (`Running`,
  `iStateMenu`, `szDataForPipe`, `iVersionGdb`, `CurrentFile`, `iGlPid`, the Extern-C `poll`/`ioctl`/`pollfd`
  block). **Keep** the shared helpers `KillTimer`/`SetTimer` (+ `w9T`), `DeleteDebugCursor`, `check_bitness`,
  `hard_closing`, and verify `SIGKILL` (`#define`, used by the Integrated engine at ~1772/2077/2487) is still
  sourced before removing its block.
- Two **found bugs to fix**: the debugger source path-case `LCase` (`Main.bas:2885`, spawned task) and the
  cosmetic breakpoint-line path render.
- Then the **menu-taxonomy cluster** `49ec5ccd`/`37ba31ea`; skip the pure 32-bit/GTK-strip entries
  (`e139c2cc` etc.). The two **Examples items** (`4bd02894`, `51441d7a`) stay deferred to just before the
  testing phase (owner). All owner directives (32-bit, UTF-8/LF, AI, English-only) remain cleared.

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
- **Packaging/shim:** the dev shim has `libtinfo.so.5` but no `libncurses.so`, so the IDE can't fully *link*
  a console user-project in this environment (fbc's default console link wants libncurses). Add a
  `libncurses` dev symlink when building the AppImage. AppImage packaging itself is still open (memory
  `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- **`gdb` not installed** here (debugger default won't resolve); `UseDebugger=false` by default.
