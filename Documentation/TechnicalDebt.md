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
- **🔴 Close Project SIGSEGVs — deterministic, and it takes the IDE down with it (2026-08-04).**
  Open any project, then Close Project (Ctrl+Shift+F4): the process dies with exit 139. **Not
  intermittent, and not the threading crash below** — it reproduces on every attempt, with no
  editor tab ever opened and no worker running. Present in the pushed binary, so it predates the
  menu work; `Rename Project` and `Delete Project` inherit it because both call `CloseProject`.
  This is the top-priority defect: a core command that destroys unsaved work in other tabs.

  **Measured** (see Testing.md): committed binary `087a720` → 139; open-and-don't-close → survives
  indefinitely, so it is the close itself, not the open path or startup.

  **Two Astoria fixes ported, neither of which cures it** — both are genuine bugs Ilwaco shared,
  so they stay:
  - MFF `Control` destructor now clears `FContextMenu->ParentWindow` when it still points at the
    dying control (Astoria `154fb8aa`/13.68 — a shared `mnuCode` outliving its editors). Cannot be
    this crash: the repro never opens an editor tab, so nothing ever bound the back-pointer.
  - `CloseProject` now nulls `tn->Tag` after each `_Delete` at all three sites (Astoria `d6fb59e8`
    bug 1 / `Nodes.Remove` → `tvExplorer_SelChange` deref). Ilwaco's `tvExplorer_SelChange` really
    does deref a freed `ProjectElement` via `ptn->Tag`, so this was a real dangling read — just not
    the fatal one.

  **Next lead, unproven:** after `tvExplorer.Nodes.Remove` frees the node, `ChangeMenuItemsEnabled`
  immediately calls `GetParentNode(tvExplorer.SelectedNode)` and derefs `->ImageKey`; if MFF's GTK
  `Nodes.Remove` does not clear `SelectedNode`, that is a second dangling read. **Do not patch this
  on the hunch — measure it.**

  **Tooling gap that blocked diagnosis:** no `gdb`, `eu-stack`, `catchsegv` or `coredumpctl` on this
  machine. A `signal(SIGSEGV)` + `backtrace_symbols_fd` handler installed in `ilwaco.bas` never
  fired, so something (likely GTK/glib at init) installs its own handler afterwards. Getting a
  backtrace needs either `gdb` installed, or `sigaction` installed *after* GTK init.
- **Intermittent startup/shutdown `SIGSEGV`.** A known Astoria-fixed threading issue — do *not*
  chase it as a new regression. It closed the IDE mid-test at least once this project. Distinct
  from the deterministic Close Project crash above.
- **Find-in-project worker vs project close (latent).** Astoria `8a90fec7` (13.66 site 2) measured
  6/6 dead IDEs when a `FindSubProj`/`ReplaceSubProj` walk was in flight during a close — the
  worker walks explorer `TreeNode`s while `CloseProject` frees them. Ilwaco has the same entry
  points in `frmFind.frm` and neither guard (`bClosingProject`, `gFindWorkers`). Not the crash
  above (no worker was running), and needs re-measuring on GTK rather than assuming: Ilwaco's
  `ThreadsEnter`/`ThreadsLeave` are real `gdk_threads_enter/leave`, where Astoria's were empty stubs.
- **AppImage packaging is unbuilt.** Read-only bundle + external writable Projects/Examples/Docs is
  the plan; still open.

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
