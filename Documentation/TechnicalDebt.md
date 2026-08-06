# Technical debt — the register

**Purpose.** Ilwaco is being brought toward parity with Astoria by walking its changelog and
translating each change to GTK, while stripping Windows-only code. This file is the register of what
is known to be wrong, or known to be *suspect*.

**A hit here means "go and read this", never "this is broken".** Confirm by measurement before
changing anything — a grep is a triage tool, not a verdict. Prefer a build + an observed effect over
an argument.

---

## Known gaps (tracked, not blockers)

These are the standing items from [PROJECT_STATUS.md](../PROJECT_STATUS.md) "Known gaps", kept here
as the durable register:

- **Packaging / dev shim — no `libncurses`.** The in-repo shim under `Compilers/shim/` provides
  `libtinfo.so.5` but no `libncurses.so`, so `fbc`'s *default* console link fails in this dev
  environment. Not a blocker: a console project links and runs once it carries
  `CompilationArguments64Linux="-p <shim> -l tinfo"` (TestPlan T4 passes that way, 2026-08-04). Add a
  `libncurses` dev symlink when building the AppImage so users need no per-project arguments.
- **GTK dark mode never fires (REIMPLEMENT).** MFF ships a real GTK3 `SetDarkMode`, but
  `g_darkModeSupported` was only ever set by the deleted Win32 `InitDarkMode`, so the dark-styling
  branches never run on GTK. Track with Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/
  `a7c7839d`); drive `g_darkModeSupported` + per-control theming from the GTK theme.
- **`UseDebugger=false` by default.** (The old note here — "`gdb` not installed, the debugger default
  won't resolve" — is obsolete: GDB was removed 2026-08-04 and the built-in Integrated engine, which
  needs no external debugger, is the only one.)
- **Intermittent startup/shutdown `SIGSEGV`.** A known Astoria-fixed threading issue — do *not*
  chase it as a new regression. It closed the IDE mid-test at least once this project. Distinct
  from the deterministic Close Project crash above.
- **Find-in-project worker vs project close (latent).** Astoria `8a90fec7` (13.66 site 2) measured
  6/6 dead IDEs when a `FindSubProj`/`ReplaceSubProj` walk was in flight during a close — the
  worker walks explorer `TreeNode`s while `CloseProject` frees them. Ilwaco has the same entry
  points in `frmFind.frm` and neither guard (`bClosingProject`, `gFindWorkers`). Not the crash
  above (no worker was running), and needs re-measuring on GTK rather than assuming: Ilwaco's
  `ThreadsEnter`/`ThreadsLeave` are real `gdk_threads_enter/leave`, where Astoria's were empty stubs.
- **Rename Project renames the folder, not the project manifest inside it.** After renaming a
  project folder, the `.vfp` keeps its original basename and the explorer still shows the old
  project name — confusing for a beginner.
  Ilwaco re-opens the correct file (Astoria's version silently re-opened nothing), but making the
  rename coherent means moving the `.vfp` and updating `ProjectName` inside it. Found 2026-08-04.
- **AppImage packaging is unbuilt.** Read-only bundle + external writable Projects/Examples/Docs is
  the plan; still open.
- **The launched terminal shows no program output on this box (found 2026-08-06).** Run opens the
  terminal and the program runs to completion — the window's own banner says "The child process exited
  normally with status 0" — but its content area is blank, so a user sees an empty window instead of
  their output. **It is not Ilwaco:** `xfce4-terminal --hold -x /bin/echo TEST` reproduces it with no
  IDE involved, as do `-e` and `--command`, and the child's output does not reach the parent's stdout
  either; meanwhile a plain `xfce4-terminal` *and* `xfce4-terminal --hold` render text normally. So it
  is this xfce4-terminal (1.1.4, Xfce 4.20) spawning a command, not the argument Ilwaco passes. This
  **supersedes the 2026-08-05 observation below** that the greeting rendered in the held-open terminal
  — that no longer reproduces here. Settle it before the testing phase (try another installed terminal,
  and check whether a newer/older xfce4-terminal behaves differently) — an empty window is exactly the
  "beginner cannot tell a broken tool from their own mistake" case.

**Paid down 2026-08-06 — the agent's `run` tool never returned.** `AgentStartBuild` mapped `run` to
`Compile("Run")`, whose Run branch calls `RunPr`, whose `Result = Shell(CommandLine)` is **synchronous**:
it blocks until the launched program's terminal closes. Every terminal Ilwaco ships is configured to stay
open (`--hold` and friends), so that is never — the build thread never returned, the finalizer never ran,
and an agent's `run` request hung forever (it burned a 10-minute timeout the first time Task 7 was driven).
The shape is right for a *human*: Run has its own thread and the Output panel reports the exit code when
the program ends. For the agent, `run` must complete when the program *starts*. Fixed in
[src/AgentPipe.bas](../src/AgentPipe.bas): the agent path builds plainly and `AgentBuildFinalize` launches
the program with `ThreadCreate_(@RunProgram)` — the same call the Run menu item makes — when the build came
back clean, then completes the command slot. New `gAgentRunAfterBuild` flag replaces the `"Run"` compile
parameter, and the sidecar's tool description now says `run` waits for the build, not for the program.
Verified: `run` returns in **0.1 s** after the build, with the program live in its own terminal.

**Paid down 2026-08-05 — every GUI app built with Ilwaco printed `Open file failure! in function
Application.CurLanguage` at startup.** The templates' form bootstrap runs `App.CurLanguage =
My.Sys.Language`, and `My.Sys.Language` is the OS locale (`setlocale(LC_CTYPE, "")` — e.g. `C.UTF-8`),
so the `CurLanguage` setter in `mff/Application.bas` tried to open a `Languages/<locale>.lng` that does
not exist beside a built exe and **printed the failure to stdout** in every student's program. Ilwaco
is English-only and `ML()` already falls back to the untranslated key, so a missing translation file is
the normal case, not an error. Fixed by dropping the setter's `Else … Print` branch: a file that cannot
be opened now silently leaves the current (English) language in place. Verified by A/B — the same GUI
template app, built against the pre-fix source, printed `…Languages/C.UTF-8.lng`; built against the fix
it prints nothing. The fix reaches user apps as soon as they recompile against the mff source; the lib
and editor were rebuilt so the shipped binaries match.

**Paid down 2026-08-05 — Run's terminal launcher defaulted to `gnome-terminal`, absent on many Linux
boxes.** The shipped `[Terminals]` list held only gnome-terminal/mate-terminal/xterm (xterm with a
broken `-bc`), and `DefaultTerminal=gnome-terminal`, so on a box without gnome-terminal (this one has
`xfce4-terminal`) Run compiled and linked, then died `sh: gnome-terminal: not found` with no window —
a beginner saw their program "do nothing". Fixed in `LoadSettings` (`src/Main.bas`): the nine terminals
Ilwaco knows about (gnome-terminal, konsole, xfce4-terminal, mate-terminal, lxterminal, terminator,
terminology, qterminal, xterm) are seeded into the list if missing, and when the configured default is
not on `PATH` a new default is auto-picked from the first **installed** one — any real terminal
preferred over `xterm` (xterm last). The shipped `Settings/ilwaco.ini` `[Terminals]` block now carries
all nine with correct keep-open args (e.g. `xfce4-terminal --hold -x`). Tools > Options > Terminals
gained **Installed** and **Default** columns (installed detected via `g_find_program_in_path`; the
Default column tracks the "Default Terminal" combo live via a new `cboTerminal_Change` handler), and
the dialog was widened to show them. Verified end to end: on this box the default auto-resolved to
`xfce4-terminal`, Run launched `"xfce4-terminal" --hold -x "…/Main"`, and the program's output showed
in the terminal held open. The user can override the default in that combo, including to a not-installed
terminal (the Installed column then warns it is absent).

**Paid down 2026-08-04 — the Console Application template could not build (Windows-only `Console.bi`).**
The template pulled in MFF's `mff/Console.bi`, which was pure Win32 (84 console-API calls, no Linux
branch, and a `windows.bi` include dragging in `-lkernel32/-lgdi32/-luser32/…`), so a beginner picking
"Console Application" got a project that would not link. Nothing else in the repo included that header.
Per the owner decision, the template was **rewritten in plain FreeBASIC** — `Print` for output and
`Color` for colour, both native on Linux — and `mff/Console.bi` was **deleted** as dead Windows code
(a `REMOVED_FEATURES` guard for `ConsoleType` was added to `Tools/DocCheck.py`). Verified by effect:
the new `Templates/Projects/Console Application/Main.bas` compiles clean with the bundled `fbc` + shim
and prints single-byte ASCII (the BOM regression check), no wide-literal garble.

**Paid down 2026-08-04 — stale `VisualFBEditor` branding in shipped templates.** The Console template's
`Console.Title = "VisualFBEditor - Console"` went away with the rewrite above, and
`Templates/Files/Form_3D.frm`'s form caption was changed from `"VisualFBEditor-3D"` to `"Form1"`,
matching the plain `Form.frm` template. (The remaining `VisualFBEditor` strings live only in the
not-offered Windows templates — Android/Addin — whose deletion is a separate open question.)

**Paid down 2026-08-04 — `FileCopy` silently copied nothing when handed a `UString`.** New Project
created an empty folder and then reported *"Could not create the project"*. Every path involved was
correct — instrumenting the running IDE showed the right template folder and `.vfp`, both existing,
and the right branch taken — but `FileCopy` returned 1 and copied nothing. FreeBASIC's `FileCopy`
takes `ZString Ptr`, so a `UString` argument binds through `UString.Cast() As Any Ptr`: the raw wide
buffer is read as a narrow path, ending at the first zero byte (a bare `"/"`). A `&` concatenation
with a `UString` operand fails the same way, because `&` resolves to MFF's `UString` operator.
Measured shape by shape at a `ZString Ptr` parameter: `UString` and `UString & …` truncate to `"/"`;
`WString`, `Str(u)`, `*u.vptr` and a narrow `+` concatenation are fine. Two call sites were live
defects — `Main.bas FolderCopy` (upstream VisualFBEditor's GTK branch, so folder copying has **never**
worked on that build; the Windows branch staged into `WString` buffers and used `CopyFileW`) and
`frmNewProject`'s manifest copy. Fixed by routing all copies through a `FileCopy_` wrapper taking
`ByRef … As WString`, which makes the narrowing the compiler's job; no raw `FileCopy` call remains
outside the wrapper, so the trap cannot recur. The two pre-existing workarounds it explains —
`Str(GetBakFileName(…))` and `*x.vptr` at other call sites — are now unnecessary and gone. Offered
upstream in [UpstreamFixes.md](UpstreamFixes.md).

**Paid down 2026-08-04 — the path-case cluster.** Three findings turned out to be one root cause plus
one shared assumption, all now fixed and verified:

1. The debugger lowercased the source path (`AddTab(LCase(source(fntab)))` in `Main.bas TimerProc`), so
   debugging any project under a path containing uppercase letters failed with "File not found".
2. The "breakpoint line renders the source path after the code text" report was **a symptom of (1)**,
   not a separate bug. With the lowercased path not found, `AddTab` fell past its `bFind` check and
   built a *new empty tab named after that path*; the debugger then painted into it. Confirmed by
   running the pre-fix binary (`git show f54867d:ilwaco`) side by side with the fixed one.
3. `EqualPaths` compared `LCase(a) = LCase(b)`, so `Foo.bas` and `foo.bas` collapsed onto one tab. It
   is now a direct comparison. Its other two Win32-isms went at the same time (owner directive: no
   project file will be authored on Windows) — `\`→`/` normalisation, which *corrupted* paths since a
   backslash is a legal Linux filename character, and a drive-letter trailing-colon strip, which
   mangled a file legitimately named `foo:`. `AddTab`'s matching colon strip went with it.

**Paid down 2026-08-04 — the Close Project crash.** Close Project killed the IDE (exit 139)
  deterministically, and had shipped that way. Root cause was in MFF, not the close path:
  `TabControl.DeleteTab` never cleared a surviving `TabPage`'s `_Label`, so
  `CloseProject → ClearAnalysisPanels → tpProblems->Caption = …` reached `TabPage.Text`, whose
  `GTK_IS_LABEL(_Label)` dereferenced a finalised widget. Full diagnosis, including how the fault
  address was recovered from a core dump without a debugger, is in [Controls.md](Controls.md).
  `Rename Project` and `Delete Project` were blocked by it and now work.

  **Two fixes were ported from Astoria first and did *not* cure it** — both real bugs Ilwaco shared,
  so they stay, but the record matters: the MFF shared-`ContextMenu` back-pointer (`154fb8aa`;
  couldn't be it — the repro never opens an editor tab) and `CloseProject` not nulling freed `Tag`s
  (`d6fb59e8` bug 1; a genuine dangling read, just not the fatal one). A third guess — a dangling
  `SelectedNode` in `ChangeMenuItemsEnabled` — was recorded as unproven and turned out **wrong**.
  The lesson is the one Astoria's own history teaches: measure before patching.

  **Tooling note for the next crash:** there is no `gdb`, `eu-stack`, `catchsegv` or `coredumpctl`
  here, and a `signal(SIGSEGV)` + `backtrace_symbols_fd` handler in `ilwaco.bas` never fired
  (something, likely GTK/glib, installs its own afterwards). What *did* work, and needs no root:
  `ulimit -c unlimited`, then parse the core's `NT_PRSTATUS` note for `RIP`/`RAX` and resolve with
  `nm` + `objdump`.

## Left-over dead code (low-priority cleanup)

- **Panel-collapse dead guards.** After the vertical-rail reimplement, `tabLeft_SelChange` /
  `tabLeft_Click` / `tabRight_SelChange` and the focus-loss auto-collapse in `src/Main.bas` still
  guard on `TabPosition = tp{Left,Right}` / `Width = 30`, which can no longer be true. Harmless but
  dead; a `no-dead-code` pass can drop them. Recorded in `AstoriaParity.md`.
- **Windows tool binaries in `Tools/`.** `Tools/` carries `SPY`, `depends`, `COMWrapperBuilder` and
  friends — Windows debugging utilities that are dead weight on Linux and candidates for the strip
  (the mirror of the Astoria mission: delete non-target code when a change touches the area).

## Bottom-panel collapsed pin — GTK layout findings (2026-08-04)

Making the collapsed bottom panel show a working **pin** (re-open affordance) fought GTK across many
builds. Persistence itself already works; this is only the visible affordance. Findings, so a future
attempt need not re-derive them:

- A **checked `tbsCheck`** on the bottom's *vertical* toolbar draws its active-state background but **no
  icon** (plain `tbsButton`s beside it — the erasers — draw fine). So the pin must be a `tbsButton`; the
  pinned/unpinned look comes from the ImageKey.
- A single `ToolBar` button in a narrow strip needs `gtk_toolbar_set_show_arrow(FALSE)` to draw at all.
- **A child control inside a panel that is *squeezed* to the collapsed height gets no usable allocation**,
  so an in-strip pin toolbar draws nothing there — even as a lone `tbsButton`. This is the core wall.
- A **floating GTK overlay** gives the pin an explicit rectangle (bypassing the squeeze) and it renders —
  **but** reparenting an MFF `ToolBar` handle into the overlay silently fails (MFF event-box-wraps
  toolbars); you must wrap the pin in a **Panel** and reparent that (as the left/right pins do). Even then,
  the overlay **does not track the panel collapsing** — the pin stayed at the expanded position, floating
  in the editor area (a regression).
- **Resolution (DONE 2026-08-04, live-verified):** the owner chose a **separate rail** (`pnlBottomRail`,
  not a child of `pnlBottom`) — mirroring the left/right rails — which sidesteps all of the above. It costs
  extra code because the rail must **replicate the tab buttons and sync the 7 debug tabs** with
  `SetDebugTabsVisible` (re-asserted + re-aligned on show, since MFF `show_all` un-hides all children and
  never sized hidden buttons). The reflow concern **did not materialise** — the editor reclaims the freed
  vertical space on collapse. Two extra GTK facts learned finishing it: a 25px strip clips GtkToolbar's
  min-height (fix: a `.ilwacorailpin`-scoped `GtkCssProvider` trimming padding/min-height, **not**
  `gtk_widget_set_valign`, which pushes the icon *down*); and a native check-menu click flips GTK's active
  state without updating MFF's cached `MenuItem.Checked`, so debugger-toggle logic must read
  `gtk_check_menu_item_get_active`, not `->Checked`. Full detail in AstoriaParity "Done 2026-08-04 —
  bottom-panel collapse via a horizontal activity rail".

## Repo hygiene

- **The tracked `ilwaco` binary is committed on purpose — do not `.gitignore` it.** Owner directive
  (2026-08-04): the repo moves between two machines and the built editor must travel with each push
  (rebuilt via `./build-linux.sh editor` only when necessary). So **rebuild + commit the binary when
  committing source changes** to it, rather than letting the committed blob go stale.

---

## How this list is maintained

A change that discovers, pays down, or alters a suspect area updates this file — see the rule table
in [TestPlan.md](TestPlan.md). When an item is *resolved*, mark it resolved with the date and the
commit rather than deleting it silently, so the register reads as history, not amnesia.
