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
  `libtinfo.so.5` but no `libncurses.so`, so `fbc`'s default console link fails when the IDE tries
  to *link* a console user-project in this environment. Add a `libncurses` dev symlink when building
  the AppImage. (Blocks TestPlan T4 — end-to-end project build.)
- **GTK dark mode never fires (REIMPLEMENT).** MFF ships a real GTK3 `SetDarkMode`, but
  `g_darkModeSupported` was only ever set by the deleted Win32 `InitDarkMode`, so the dark-styling
  branches never run on GTK. Track with Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/
  `a7c7839d`); drive `g_darkModeSupported` + per-control theming from the GTK theme.
- **`gdb` not installed here.** The debugger default won't resolve; `UseDebugger=false` by default.
- **Intermittent startup/shutdown `SIGSEGV`.** A known Astoria-fixed threading issue — do *not*
  chase it as a new regression. It closed the IDE mid-test at least once this project.
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

- **The tracked `ilwaco` binary drifts from source.** Source commits generally omit the ~4.6 MB
  artifact, so the committed blob is usually stale. Consider `.gitignore`-ing it (it rebuilds via
  `./build-linux.sh editor`) rather than tracking a perpetually-stale binary.

---

## How this list is maintained

A change that discovers, pays down, or alters a suspect area updates this file — see the rule table
in [TestPlan.md](TestPlan.md). When an item is *resolved*, mark it resolved with the date and the
commit rather than deleting it silently, so the register reads as history, not amnesia.
