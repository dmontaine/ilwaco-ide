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

## ✅ DONE (2026-08-04, later) — Console template rewritten; T14/T15 now PASS; branding cleared

The Console Application template no longer breaks. It pulled in MFF's `mff/Console.bi`, which was
pure Win32 (84 console-API calls, a `windows.bi` include dragging in `-lkernel32/-lgdi32/-luser32/…`),
so a beginner picking "Console Application" got a project that would not link. Per the owner decision:

- **`Templates/Projects/Console Application/Main.bas` rewritten in plain FreeBASIC** — `Print` for
  output, `Color` for colour, both native on Linux; BOM-less, LF-only. It now prints a greeting
  instead of the old empty template.
- **`Controls/MyFbFramework/mff/Console.bi` deleted** as dead Windows code (nothing else in the repo
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

### Start here next session

**In flight: the Agent MCP server** (owner asked 2026-08-05 for Astoria's MCP sidecar in Ilwaco). This
is a phased Linux/GTK port tracked in [Documentation/McpServer.md](Documentation/McpServer.md) — **Task 0
(socket + `g_idle_add` marshal skeleton + `ping`) is DONE and verified**; resume at **Task 1 (read-only
tools)**. New files: [src/AgentPipe.bas](src/AgentPipe.bas)/`.bi` (the IDE-side Unix-socket command
server) and [src/JsonLite.bas](src/JsonLite.bas)/`.bi` (portable UTF-8 JSON). Not yet committed.

Secondary (only if the MCP thread stalls): the **Astoria→Ilwaco changelog walk** — the menu-taxonomy /
Options-panel cluster below, plus the deferred Examples BOM sweep.

---

## IN FLIGHT — Agent MCP server

Port Astoria's Agent MCP server to Linux/GTK so an MCP client can drive the live IDE. Design, the three
Win32→Linux substitutions, the owner decisions, and the Task 0–7 progress table live in
[Documentation/McpServer.md](Documentation/McpServer.md). Task 0 verified end-to-end (ping round-trips
over `/run/user/1000/ilwaco-agent.sock` while the GUI stays live; clean shutdown removes the socket).
**Next: Task 1** — the read-only tools (`get_status`, `list_files`, `read_file`, `get_active_file`,
`get_build_output`), which need Ilwaco's open-project accessor and active-tab/message-pane reads.

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
  **Done + verified since:** `frmNewProject` (New Project dialog — see [HISTORY.md](HISTORY.md)) and
  the Console Application template rewrite that made every offered project type build (T14/T15 PASS —
  see the DONE section above). **Still to port:**
  `OpenProjectTemplate`/`Recent Project`; the Options panels
  (remove the "When the IDE starts" radio group, Code Editor grouping into Display/Completion/
  IntelliSense/History); and `Show Holiday Frame` → `Show Indent Guides`, which is a *feature* port
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
