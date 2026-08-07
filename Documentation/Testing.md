# Testing — what is proven, and what is not

Written for outside testers and for future-me. The forward-looking companion is
[TestPlan.md](TestPlan.md) (named scenarios to run); this file records **results** — and, just as
important, **the gaps**. If something is unproven, it says so. An honest gap is worth more than a
confident sentence that turns out to be false.

**How Ilwaco is verified.** There is **no automated/headless harness yet.** Everything below is
verified *by effect*: build with `./build-linux.sh`, run on the live X display
(`DISPLAY=:0 ./ilwaco`), and observe with `scrot` / `xdotool` / `wmctrl`. A clean `fbc` exit is
necessary but not sufficient — "it compiled" is not "it works".

---

## Proven

- **MCP agent permission levels (2026-08-07).** Probed over the agent socket at four levels, one
  command per band. Read-only: `get_status` allowed, `write_file`/`open_in_editor`/`syntax_check` all
  `permission_denied`. Edit: writes allowed, `syntax_check` denied. Build & Run (the migrated
  default): every current tool allowed, an unclassified command denied. Trusted: the unclassified
  command passes the gate and the dispatcher reports `unknown_cmd`, which is what proves the gate
  lets things through rather than blanket-denying. Migration verified: an INI carrying only the old
  `AllowAgentControl=true` starts at Build & Run.

- **MCP write safety (2026-08-07).** Driven against a live IDE over the agent socket, six behaviours:
  `read_file`/`get_active_file` return a `version`; `write_file` with a stale `expected_version` is
  refused (`version_mismatch`) with the file unchanged **on disk**; with the correct version it
  succeeds; a `write_file` onto a deliberately dirtied editor tab is refused (`dirty_buffer`) with the
  file unchanged on disk; `set_active_file_content` with a stale version is refused with the **buffer**
  unchanged; with the current version it succeeds. Separately checked rather than assumed: the editor
  buffer reports CRLF even when handed LF, but a build-triggered save writes **LF** to disk, so that is
  Scintilla's internal representation and not a line-ending corruption path.

- **The 53 examples ported from Astoria all build and run; 25 of the 28 GUI ones also look right
  (2026-08-07).** Built with Ilwaco's bundled Linux toolchain on Debian 13 x86_64: **25/25**
  `Learning/Console` programs compiled and ran to completion (exit 0), and all 28 GUI programs
  compiled and opened a window.

  **"A window opened" was not enough, and the first version of this entry claimed too much.** Every
  GUI example was subsequently screenshotted and inspected, which found seven layout defects —
  **all now fixed and re-verified by screenshot**: three wrapped labels (`04_NumbersAndValidation`,
  `12_ProceduresInAModule`, `13_FunctionsAndReturn`), `20_MenuAndStatusBar`'s status bar rendering
  at the top (fixed in MFF, see [UpstreamFixes.md](UpstreamFixes.md)), and the `Calculator`,
  `FiveInARow` and `Maze` layouts. The catalogue is in [ExamplesAudit.md](ExamplesAudit.md).

  What is still *not* proven for any of them is that a handler does the right thing — nothing was
  clicked, and console output was spot-checked rather than diffed.
- **Editor builds from source and runs.** `./build-linux.sh editor` produces `ilwaco`; the window
  opens on `:0` with no error dialog (harmless `AppAddin`/`AppConsole` "does not exist" warnings
  aside). Standing result — see [PROJECT_STATUS.md](../PROJECT_STATUS.md).
- **Left/right panel collapse (2026-08-04).** Each tool panel collapses to a thin vertical-text
  rail (pin icon + rotated `Project`/`Toolbox`, `Properties`/`Events`); the pin re-expands to the
  last tab; each text button re-expands and selects its tab; the expanded-panel pin repaints after
  reopen; both rails show collapsed at startup when the INI says so. Verified by screenshot.
- **Debug-tab visibility.** The seven debug tabs (Locals…Profiler) show only when the debugger is
  enabled; Immediate stays visible. Verified both states by screenshot.
- **Bottom/debug panel clearing.** Stale project/debug results are cleared on project close and on
  debug end; all bottom tabs render. Build + launch verified.
- **End-to-end user-project build *and debug* through the IDE (2026-08-04).** A console `.vfp`
  compiles, links and launches under the Integrated debugger from the IDE itself — the exe was
  deleted before each run, so the IDE genuinely produced it. Confirmed: tracing stop with the
  current-line marker, Locals populated, and the debuggee's real `argv` and environment read from
  `pgrep -a` / `/proc/<pid>/environ`. Caveat: in *this* dev environment the project needs
  `CompilationArguments64Linux="-p <shim> -l tinfo"`; that is a dev-shim artefact, not an IDE
  limitation (see [TechnicalDebt.md](TechnicalDebt.md)).
- **Debuggee arguments and environment (2026-08-04).** Arguments arrive in order (program name, the
  Parameters *Debug* arguments, then the project's *Command-line arguments*); environment variables
  are injected, the inherited environment is preserved, a user variable overrides the inherited one
  of the same name leaving exactly one entry, and the IDE's own environment is untouched.
- **Debugging from a mixed-case path (2026-08-04).** A project under `/tmp/ArgTest_MixedCase/` loads
  its source and debugs without the old "File not found" — the path-case regression test.
- **Close Project / Delete Project / Rename Project (2026-08-04).** Close Project closes the project
  and leaves the IDE running; Delete Project removes the folder from disk; Rename Project prompts
  with the project name (no extension), its dialog has both OK and Cancel, the folder is renamed on
  disk and the project re-opens. Close Project had segfaulted deterministically, and Rename failed
  silently through FreeBASIC's `Name` statement — both fixed; see TechnicalDebt "Paid down".
- **Debug tabs survive remove/re-add (2026-08-04).** Toggling Use Debugger removes and re-adds the
  seven analysis tabs; their captions still render, confirming the MFF `_Label` fix did not break
  `AddTab`.
- **Case-distinct filenames (2026-08-04).** `Foo.bas` and `foo.bas` in one directory open as two
  separate tabs, each showing its own content, and both appear in the explorer. Previously the
  case-insensitive path compare collapsed them onto one tab.
- **A created GUI project compiles and runs (2026-08-04).** The GUI Application template, created
  through New Project, compiles clean with the bundled `fbc` and its window opens with a
  correctly-rendered caption — the BOM fix confirmed by effect, since a BOM would have made the
  literal wide. GTK Application, Dynamic/Static/Control Library also compile. TestPlan T14/T15.
- **A created Console project compiles and prints correct text (2026-08-04).** The Console Application
  template, now plain FreeBASIC (the Win32-only `mff/Console.bi` deleted), was created through New
  Project and compiled + linked from the IDE ("Layout succeeded"); the built exe prints single-byte
  ASCII (`Hello, world!` …), exit 0 — the BOM regression check. On the dev box it needs
  `-p <shim> -l tinfo` to link (no `libncurses` in the shim). TestPlan T14/T15.
- **New Project creates a project on disk (2026-08-04).** Both a GUI Application and a Console
  Application were created from the dialog: the template's files land in the new folder, the manifest
  is copied to `<FolderName>.vfp` with the template's path prefix stripped, the offered name advances
  to the first free `ProjectN`, and the project opens with a populated explorer tree. Until the
  `FileCopy`/`UString` fix this produced an empty folder and an error (TechnicalDebt "Paid down").
- **Run launches an installed terminal, output visible (2026-08-05).** On this box (no `gnome-terminal`,
  only `xfce4-terminal`) Ilwaco auto-selected `xfce4-terminal` as the default terminal, and Run launched
  `"xfce4-terminal" --hold -x "…/Main"` — the Console program's greeting rendered in the terminal, held
  open. Tools > Options > Terminals listed all nine known terminals with an **Installed** column marking
  `xfce4-terminal`, a **Default** column that moved live when a different terminal was picked in the
  "Default Terminal" combo, and the combo as the override. Previously Run died `sh: gnome-terminal: not
  found` with no window. TechnicalDebt "Paid down 2026-08-05".
- **No `.lng` startup error in built GUI apps (2026-08-05).** A/B on the GUI Application template: built
  against the pre-fix `mff/Application.bas` the app printed `Open file failure! … Application.CurLanguage.
  File Name: …/Languages/C.UTF-8.lng`; built against the fix it prints nothing. `ML()` still returns the
  untranslated (English) key. TechnicalDebt "Paid down 2026-08-05".
- **The agent listener obeys its opt-in, live (2026-08-06).** With "Allow AI agent control (MCP)"
  ticked the Unix socket is bound, `ping` answers, and the status bar reads "MCP Agent: On";
  unticking it in Tools ▸ Options and pressing OK removes the socket file, fails the next connect and
  flips the panel to "MCP Agent: Off" **without a restart**; the choice persists to
  `Settings/ilwaco.ini` and the reopened dialog shows it; re-ticking re-binds live; and a restart with
  the key false binds nothing at startup. TestPlan T16.
- **An MCP client reaches the IDE, and is told what to do when it can't (2026-08-06).** Through
  `ilwaco-mcp`'s stdio: `initialize` → `tools/list` (15 tools) → `tools/call get_status` all succeed
  with the toggle on. With it off the tool call returns `isError` and names the checkbox to tick, and
  no second IDE is launched. TestPlan T17.
- **An agent drives the whole loop (2026-08-06).** From one long-lived `ilwaco-mcp` process with no IDE
  running beforehand: `create_project` auto-launched exactly one IDE; a sieve of Eratosthenes with a
  deliberate typo built to `success=false, error_count=1` with the diagnostic `Variable not declared,
  composit in 'composit(j) = 1'` at **line 10**; `get_errors` returned the same rows; the one-character
  fix rebuilt clean; the produced executable printed **`Primes below 1000000 = 78498`**, exit 0; and
  `run` returned in **0.1 s** with the program launched in its own terminal. 20 checks, all passed.
  `run` used to hang forever (TechnicalDebt "Paid down 2026-08-06"). TestPlan T18.
- **The Options dialog matches Astoria's shape (2026-08-06).** General no longer carries the "When
  Ilwaco IDE starts" radio group, and the Code Editor page is grouped into Display / Editing /
  Completion / IntelliSense / History with every control inside its frame, no overlaps, and the page
  scrolling to its last row at the dialog's default size. TestPlan T20.
- **The form designer and toolbox work (2026-08-06).** A GUI Application project's `Main.frm` opens
  in the design pane showing the live form — caption "Main", alignment grid — and a second project
  opened in the same session renders too. The Toolbox lists the MFF controls with their icons. This
  is what Astoria's `cc9e7dd5` had to fix on Win32 (`Designer.CreateControl("Form")` returning 0, an
  empty grey panel, and every project after the first broken); neither symptom occurs here.
  TestPlan T3, T24.
- **Sessions removed without losing the exit prompt (2026-08-06).** The File menu carries no
  Open/Save/Close Session and no Recent Sessions. `CloseSession` — the batched save-prompt run before
  the IDE exits, which was never about `.vfs` files — is renamed `CloseWorkspace` and still fires:
  closing with a modified tab listed it with Yes/No/Cancel. Add From Templates ▸ Recent now lists
  Folders/Projects/Files and selecting Projects lists the recent `.vfp` entries, so the category
  renumbering is correct. TestPlan T23.
- **The workspace round-trips (2026-08-06).** A project with two open tabs, closed and reopened:
  `Settings/Workspace.ini` holds the project and both tabs with `*` on the selected one, paths
  relative to the executable, no BOM; the relaunched IDE shows the same project tree and tabs. A
  workspace pointing at a deleted project opens empty without an error, and an empty session deletes
  the file rather than leaving it stale. TestPlan T22.
- **Indent guides render and toggle (2026-08-06).** A four-level nested source shows a continuous
  vertical rule at each enclosing indent level — one at an 8-space indent, two at 12, three at 16,
  four at 20 — visually distinct from the ShowSpaces dots. Unticking Code Editor ▸ Display ▸ Show
  Indent Guides removes them live and persists `ShowIndentGuides=false`. TestPlan T21.
- **Recent Projects opens from a dialog (2026-08-06).** File ▸ Recent Projects… is now a flat item, not
  an MRU submenu; the dialog lists each recent project's file name and full path with its icon, shows
  **only** entries whose `.vfp` still exists (the stale `VisualFBEditor.vfp` was filtered out), and OK
  opened the selected project — confirmed by `get_status` reporting `Framework.vfp` as the open
  project. TestPlan T19.

## Not proven (known gaps)
- **None of the 22 PRE-EXISTING examples builds on Linux (2026-08-07).** Measured, all 17 with a
  usable project file failing and 5 skipped for a manifest with no main file — they are Windows
  programs (`InvalidateRect`, `QueryPerformanceCounter`, `win/wininet.bi`, `ITaskbarList3`, Win32
  `Point`/`Rect`). They are **seeded into `~/ilwaco-ide/Examples` on first run**, so a beginner who
  opens one and presses Build gets a wall of compiler errors. Audit-only by owner direction; the full catalogue, grouped by root
  cause, is in [ExamplesAudit.md](ExamplesAudit.md). The 53 ported from Astoria are currently the
  only examples that work.
- **`Calculator`, `FiveInARow` and `Maze` had broken layouts on GTK (2026-08-07, owner-reported;
  now FIXED — kept here as the record of what "it opened a window" missed).**
  They compile and open, but: `FiveInARow`'s settings panel has genuinely overlapping labels
  ("Chess Board Size" collides with "Background:") with clipped radio captions, and it opens at
  2560×1293; `Maze`'s "Maze Size:"/"Wall Size:" labels wrap into their text boxes and the Refresh
  button overlaps a progress bar; `Calculator` leaves a large dead area below its controls.
  **Cause:** absolute pixel layouts tuned to Win32 font metrics. GTK's default font is wider, the
  fixed-width labels wrap to a second line, and that second line lands on whatever is beneath —
  which is the overlap. Not a framework wrap-flag divergence: both forks default `WordWraps = True`.
  These three predate Astoria's own examples and came from the shared VisualFBEditor base, so the
  **pre-existing `Examples/` in this repo are likely affected the same way and have not been swept.**
- **Six of the eight `FileCopy_` call sites are build-verified only.** New Project exercised the two
  that were actually broken (`FolderCopy` and the manifest copy). The other conversions — backup on
  save, `Resource.rc`/`Manifest.xml` creation, Find-and-Replace-in-project backups, Remove File From
  Project, and the `DebugInfo.log` rotation — were already working shapes and are unchanged in
  behaviour, but none was re-exercised at runtime.
- **Control behaviour beyond load-and-render.** The designer renders a form and the toolbox lists the
  controls (proven above), but placing, configuring and wiring each control is still unswept — see
  [ControlTesting.md](ControlTesting.md).
- **Control behaviour at large.** No systematic control sweep has been run on the GTK build — see
  [ControlTesting.md](ControlTesting.md). Compiles-and-opens is not properties-events-and-docked.
- **GTK dark mode.** Never exercised — the styling branch does not fire on GTK yet (TechnicalDebt).
- **A program's output in the terminal Run launches.** As of 2026-08-06 the launched terminal on this
  box shows a blank content area, though the program runs and exits 0 — reproducible with
  `xfce4-terminal --hold -x /bin/echo TEST`, i.e. without Ilwaco. So "Run shows the user their output"
  is currently **unproven on this machine** and supersedes the 2026-08-05 observation above
  (TechnicalDebt "Known gaps").

---

## Maintenance

A test run updates the matching scenario row in [TestPlan.md](TestPlan.md) and, if what is proven or
unproven changed, this file — in the same commit as any fix it produced. `python3 Tools/DocCheck.py`
before committing.
