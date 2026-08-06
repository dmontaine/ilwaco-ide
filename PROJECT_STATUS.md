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

## ✅ DONE (2026-08-06) — MCP Tasks 6 + 7: the agent server is finished, opt-in, and proven end to end

### Task 6 — the listener is opt-out, visible, and documented

The Agent MCP server stopped being a thing only we knew how to switch on. Five pieces, all live-verified:

- **`AllowAgentControl`** — a `[Options]` key in `Settings/ilwaco.ini`, **default True** (Ilwaco is
  agent-first), read in `LoadSettings`. `frmMain_Show` now starts the socket only `If AllowAgentControl`,
  so the sidecar's `--mcp-agent` auto-launch no longer grants access by itself.
- **Tools ▸ Options ▸ General ▸ "Allow AI agent control (MCP)"** — the checkbox, wired through the same
  five points every General checkbox uses.
- **`ReconcileAgentPipe()`** (`src/Main.bas`), called at the end of `cmdApply_Click`, starts/stops the
  listener to match the setting — **the toggle takes effect without a restart**.
- **Status-bar panel 3 now reads "MCP Agent: On/Off"** (`UpdateMcpAgentStatusBar`). It was the
  file-encoding readout, which under the UTF-8-only directive could only ever say "UTF-8"; the agent
  state varies and matters. `ChangeFileEncoding` and its two call sites are **deleted**, not left as an
  empty hook.
- **[Documentation/AgentMcpSetup.md](Documentation/AgentMcpSetup.md)** — the user-facing "connect Claude
  to this" page: registering `ilwaco-mcp` with Claude Code/Desktop, the shim's `LD_LIBRARY_PATH` for a
  source build, the 15 tools, security notes, troubleshooting. Added to TestPlan's rule table; DocCheck
  green. Packaging needed nothing new — `./build-linux.sh sidecar` already builds `ilwaco-mcp` and both
  binaries are tracked.

**Verified by effect** on `:0`, driving the real dialog with `xdotool` and reading state from the socket
and screenshots: default-ON launch binds the socket and shows **"MCP Agent: On"**; untick + OK removes
the socket file, flips the panel to **"MCP Agent: Off"** and fails `ping`, with no restart; the setting
persists and the reopened dialog reflects it; the sidecar then reports *"…make sure Tools > Options >
Allow AI agent control is ticked"* and does **not** launch a second IDE; re-tick + OK re-binds live and a
full `initialize` → `tools/list` (**15 tools**) → `tools/call get_status` round-trip succeeds; and a
restart with the key false binds nothing at startup. Both closes exited 139 — the known intermittent
shutdown SIGSEGV, which also fired on the run where the listener was never started.

### Task 7 — the whole loop, driven by a real MCP client

`create_project` → `write_file` (broken) → `build` → `get_errors` → `write_file` (fixed) → `build` →
`run`, driven from one long-lived `ilwaco-mcp` process over its stdio **with no IDE running beforehand**.
20 checks, all pass: the sidecar auto-launched exactly one IDE; a sieve of Eratosthenes with a deliberate
typo built to `success=false, error_count=1` with `Variable not declared, composit in 'composit(j) = 1'`
at **line 10**; `get_errors` matched byte for byte; the one-character fix rebuilt clean; the executable
printed **`Primes below 1000000 = 78498`**, exit 0.

**A real bug fell out: `run` never returned.** `Compile("Run")` calls `RunPr`, whose `Shell()` is
synchronous — and every terminal Ilwaco ships stays open (`--hold`), so it blocked forever and the agent's
request hung (the first attempt burned a 10-minute timeout). The agent path now builds plainly and
`AgentBuildFinalize` launches the program with `ThreadCreate_(@RunProgram)` — the same call the Run menu
makes — when the build is clean, then completes the slot. `run` returns in **0.1 s**. Details in
TechnicalDebt "Paid down 2026-08-06".

**Found, not ours, but it matters:** the terminal Run opens shows **no program output** on this box —
`xfce4-terminal --hold -x /bin/echo TEST` reproduces it with no IDE involved (so does `-e`/`--command`),
while a plain `xfce4-terminal` renders fine. The program runs and exits 0; the user just sees an empty
window. This supersedes the 2026-08-05 "greeting rendered in the held-open terminal" observation. Tracked
in TechnicalDebt "Known gaps"; settle it before the testing phase.

### Start here next session

**The Agent MCP server is COMPLETE** — Tasks 0–7 all done and verified; only the `designer_*` tools stay
deferred (owner). So the active thread returns to the **Astoria→Ilwaco changelog walk**: the
menu-taxonomy / Options-panel cluster below (`OpenProjectTemplate`/`Recent Project`, the Options-panel
restructure, `Show Holiday Frame` → `Show Indent Guides`), plus the deferred Examples BOM sweep.

Two things worth doing before the testing phase, both in TechnicalDebt "Known gaps": the **blank-terminal
finding** above (a beginner pressing Run would see an empty window), and the **project `.vfp` BOMs** written
by `SaveProjectFile` and carried by the template `.vfp` data, which violate the no-BOM directive.

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

## COMPLETE — Agent MCP server (Tasks 0–7)

Astoria's Agent MCP server is ported to Linux/GTK and finished: a real MCP client → `ilwaco-mcp` sidecar →
Unix socket → the live IDE, auto-launching it, with the read-only, project (`open_project`/`create_project`),
mutation and build/run/errors tools all verified against a real project, the project-root path guard blocking
`..` escapes, the listener gated by the Tools ▸ Options opt-in (default ON) with its state in the status bar,
and the whole create → build → fix → run loop driven end to end. Design, the three Win32→Linux substitutions,
the owner decisions, the per-task narratives and the v1 limits are in
[Documentation/McpServer.md](Documentation/McpServer.md); the user-facing setup is
[Documentation/AgentMcpSetup.md](Documentation/AgentMcpSetup.md). Only the `designer_*` tools remain deferred
(owner) — revisit as Ilwaco's designer matures.

---

## NEXT — finish the menu-taxonomy cluster

**The Close Project crash is FIXED (2026-08-04)** — it was an MFF bug (`TabControl.DeleteTab` left a
surviving `TabPage`'s `_Label` pointing at a finalised GTK widget), not the close path. `Rename
Project` and `Delete Project` were blocked by it and are now verified working. Diagnosis, including
how the fault address was recovered from a core dump with no debugger installed, is in
[Controls.md](Documentation/Controls.md) and [TechnicalDebt.md](Documentation/TechnicalDebt.md).


- **The path-case cluster is closed (2026-08-04)** — all three findings fixed and live-verified; see
  TechnicalDebt "Paid down". The cosmetic breakpoint-line report turned out to be a *symptom* of the
  path-case bug (an empty tab conjured from the bad path), not a separate defect, proven by an A/B
  against the pre-fix binary. `EqualPaths` is now a direct comparison with its Win32-isms removed.
- **Menu-taxonomy cluster `49ec5ccd`/`37ba31ea` — partly done (2026-08-04).** Owner directive: *"make
  the menu system as close to Astoria as possible; later changes will fill in the blanks — same with
  the options panels, except cases like the debug flag entry we've already decided to keep."*
  **Done + verified:** the label pass (status bar "Press F1 for help", `Format`→`Designer`,
  "Not Set", "Clear Output"/"Clear Immediate", `tbDebug.Name`, numbered `Untitled1/2/…`, Goto
  "Go to line:", and the Find dialog's cryptic `Aa`/`W`/`.*`/`<`/`>` buttons relabelled); the
  **File-menu restructure** to Astoria's project-first taxonomy; **Open Project** exposed (Ilwaco had
  the handler with the menu item commented out); `Rename Project` + `Delete Project` added, the latter
  reimplemented for Linux (`rm -rf`, path-guarded) — both **verified working** once the Close Project
  crash was fixed. The Rename dialog's `InputBox` title/prompt were swapped and its default carried
  the `.vfp` extension into what becomes a folder name; both corrected, and MFF's `InputBox` gained a
  **Cancel** button (it offered only OK).
  **Done + verified since:** `frmNewProject` (New Project dialog — see [HISTORY.md](HISTORY.md)),
  the Console Application template rewrite that made every offered project type build (T14/T15 PASS),
  and **Recent Projects as a dialog (2026-08-06)** — `src/frmRecentProjects.{bi,frm}`, a File/Path list
  replacing the MRU submenu, skipping entries whose `.vfp` is gone. `OpenProjectTemplate` needs no port:
  it is dead code in Astoria (defined, called from nowhere) and Ilwaco's `frmTemplates` has no
  `DialogMode` counterpart. **The Options panels are done (2026-08-06)** — the "When Ilwaco IDE
  starts" radio group is gone (with `WhenVisualFBEditorStarts`, `LastOpenedFileType`,
  `DefaultProjectFile` and the dead `AutoReloadLastOpenFiles` key), and the Code Editor page is
  grouped into **Display / Editing / Completion / IntelliSense / History**
  (Astoria's four groups, with its `History` catch-all split so each name describes its contents —
  owner call 2026-08-06). **Still to port:**
  `Show Holiday Frame` → `Show Indent Guides`, which is a *feature* port
  needing real indent-guide rendering in `EditControl`, not a relabel.
  Skip the pure 32-bit/GTK-strip entries (`e139c2cc` etc.). All owner directives (32-bit, UTF-8/LF,
  AI, English-only) remain cleared.
- **Examples work — deferred to just before the testing phase (owner).** The two Astoria Examples
  items (`4bd02894`, `51441d7a`), **plus a BOM sweep**: 93 of 111 sources under `Examples/` start
  with a UTF-8 BOM, which makes FreeBASIC compile their string literals wide, so they build clean and
  then print UTF-32 bytes. Measured 2026-08-04; the same defect was fixed in `Templates/` at the
  time. Do all three together so `Examples/` is touched once.
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
