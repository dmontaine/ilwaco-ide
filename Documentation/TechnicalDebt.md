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

## Repo hygiene

- **The tracked `ilwaco` binary drifts from source.** Source commits generally omit the ~4.6 MB
  artifact, so the committed blob is usually stale. Consider `.gitignore`-ing it (it rebuilds via
  `./build-linux.sh editor`) rather than tracking a perpetually-stale binary.

---

## How this list is maintained

A change that discovers, pays down, or alters a suspect area updates this file — see the rule table
in [TestPlan.md](TestPlan.md). When an item is *resolved*, mark it resolved with the date and the
commit rather than deleting it silently, so the register reads as history, not amnesia.
