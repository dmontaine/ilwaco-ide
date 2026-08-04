# Ilwaco IDE — Test Plan & the document-maintenance rule

Two jobs live in this file:

1. **The document-maintenance rule** — the table below of *which document to update when*. It is
   the rule; the [update-ilwaco-docs](../.claude/skills/update-ilwaco-docs/SKILL.md) skill is how
   to satisfy it without relying on memory, and `Tools/DocCheck.py` is what catches it being
   skipped. Run the check before committing:

   ```bash
   python3 Tools/DocCheck.py
   ```

2. **The forward-looking test plan** — the companion to [Testing.md](Testing.md). Testing.md
   records what **has** been verified; this lists what **should** be, as named scenarios with a
   result against each. Fill in a row in the same commit as any fix it produced.

---

## The rule: which document to update when

The trigger is **any change that could make a document wrong — not just a test.** A removal is the
dangerous case, because it produces no test to force a visit (this is exactly how Astoria's docs
came to describe a deleted Git menu for four days). Treat every row below as a trigger.

| Document | Update when |
| --- | --- |
| `IlwacoIDEManual.md` | user-facing behaviour, a menu, or a workflow changes |
| `IlwacoIDESignificantChanges.md` | a feature is **added or removed** — how Ilwaco differs from VisualFBEditor. On a *removal*, also add a line to `REMOVED_FEATURES` in `Tools/DocCheck.py` |
| `Controls.md` | an MFF control's API, properties, events, or behaviour changes |
| `ControlTesting.md` | a control is tested — record the per-control result |
| `FrameworkFeatures.md` | a non-toolbox framework capability changes |
| `MyFbFrameworkGuide.md` | an MFF usage pattern, constructor idiom, or gotcha changes |
| `TechnicalDebt.md` | debt is found, paid down, or a known-suspect area changes |
| `Testing.md` | what is **proven or unproven** changes (typically a test run) |
| `TestPlan.md` | a test scenario is added, run, or made obsolete |
| `UpstreamFixes.md` | a bug in vendored upstream code (VisualFBEditor or MyFbFramework) is fixed |
| `AstoriaParity.md` | a changelog-walk item is ported, deferred, or reclassified, or its current-status / next-action changes — the port backlog's classification + "Done" record |

These are **not** rows in the table above:

- `AstoriaParity.md` **is** now a synchronized doc (row above, per owner 2026-08-04). It stays exempt
  from `DocCheck`'s removed-feature / deleted-file *content* scans — as a port history it names removed
  features and deleted files by design — but it **is** required to appear in the rule table.
- `PROJECT_STATUS.md` (root) — updated after **any** change, per CLAUDE.md; the session handoff. It
  lives at the repo root, outside `Documentation/`, so `DocCheck` does not scan it.
- `AstoriaDetailedChangeLog.md` — the pruned port backlog (the diff to walk); fully excluded from `DocCheck`.
- `CHANGELOG.md` (root) — append a line at each shipped milestone; hand-kept (Ilwaco has no
  PowerShell changelog generator, and `AstoriaDetailedChangeLog.md` already tracks the port work).

### Mark obsolete, do not delete

A test scenario for a removed feature becomes **OBSOLETE** with the date and reason, kept in place.
Deleting it makes coverage that once existed read as coverage that lapsed, and throws away the
reasoning for why it was rewritten.

### Say what is not known

[Testing.md](Testing.md) lists what has been verified **and what has not**, for outside testers. If
something is unproven, write that it is unproven. An honest gap is worth more than a confident
sentence that turns out to be false.

---

## How Ilwaco is verified (Linux/GTK)

Ilwaco has **no headless test harness yet**; verification is *by effect* on the live display, which
shapes what the scenarios below can claim:

- Build: `./build-linux.sh` (`editor` | `lib` | `all`); a clean `fbc` exit is necessary, not
  sufficient — "it compiled" is not "it works".
- Run: `LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`.
- Observe: `scrot` on `DISPLAY=:0` for screenshots, `xdotool`/`wmctrl` to drive and to raise the
  window (the Claude desktop app steals focus — re-activate the IDE and confirm with
  `xdotool getactivewindow getwindowname` before each click).
- Reset: `git checkout Settings/` after any launch (the IDE writes window state on exit).

---

## Scenarios

Coverage today is thin and mostly manual. This section is the backlog of what to prove; add named
rows (T1, T2, …) as scenarios are defined and run. See [Testing.md](Testing.md) for results.

| # | Scenario | Result |
| --- | --- | --- |
| T1 | Editor builds from source and the window opens on `:0` with no error dialog | **PASS** (standing; see PROJECT_STATUS) |
| T2 | Left/right panels collapse to the vertical rail and re-expand to each tab; pin repaints | **PASS** 2026-08-04 (screenshots) |
| T3 | Designer control library loads (toolbox populates without a runtime error) | not formally recorded |
| T4 | A user `.vfp` project builds through the IDE (end-to-end, not `fbc`-direct) | **PASS** 2026-08-04 — console `.vfp` compiled, linked and launched from the IDE (exe deleted beforehand). Needs `CompilationArguments64Linux="-p <shim> -l tinfo"` in *this* dev env only |
| T5 | A project debugs under the Integrated engine: tracing stop, current-line marker, Locals | **PASS** 2026-08-04 |
| T6 | The debuggee receives its arguments and environment (override + inheritance; IDE env untouched) | **PASS** 2026-08-04 (`pgrep -a`, `/proc/<pid>/environ`) |
| T7 | A project under a path containing uppercase letters debugs (path-case regression) | **PASS** 2026-08-04 (`/tmp/ArgTest_MixedCase/`) |
| T8 | Two files differing only in case open as two tabs with their own content | **PASS** 2026-08-04 (`Foo.bas` / `foo.bas`) |
| T9 | Close Project closes the project and leaves the IDE running | **PASS** 2026-08-04 — was a deterministic SIGSEGV; fixed in MFF `TabControl.DeleteTab` |
| T10 | Delete Project removes the project folder from disk | **PASS** 2026-08-04 |
| T11 | Rename Project prompts with the project name and renames the folder | **PASS** 2026-08-04 — dialog has OK + Cancel; folder renamed and project re-opened. Note: the `.vfp` inside keeps its old name (TechnicalDebt) |
| T12 | Debug tabs keep their captions after Use Debugger is toggled off and on | **PASS** 2026-08-04 (regression check for the MFF `_Label` fix) |
