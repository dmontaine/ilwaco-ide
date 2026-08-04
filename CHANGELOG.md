# Changelog

Milestones for Ilwaco IDE, newest first. Hand-kept — append a line at each shipped milestone (Ilwaco
has no PowerShell changelog generator; the per-change port backlog lives in
[Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md), and the
handoff/state in [PROJECT_STATUS.md](PROJECT_STATUS.md)).

The format is loosely [Keep a Changelog](https://keepachangelog.com/). Dates are ISO-8601.

## [Unreleased]

### Added
- The debugged program now receives its **command-line arguments and environment variables**. Both
  were settable in the UI but never applied; the project's Command-line arguments field (on the
  *Debugging* tab) was honoured by Run and silently dropped by Debug (2026-08-04).
- Documentation-maintenance apparatus: `Tools/DocCheck.py`, the rule table in
  `Documentation/TestPlan.md`, the `update-ilwaco-docs` skill, and Ilwaco analogues of Astoria's
  Documentation set (2026-08-04).
- Collapsible left/right tool panels — a thin vertical-text rail (pin + rotated tab captions) that
  re-expands to the last or a chosen tab; state persists across sessions (2026-08-04).
- Debug-tab visibility: the seven analysis tabs show only when the debugger is enabled; new MFF
  `DetachTab` (2026-08-03).

### Fixed
- The Parameters dialog silently discarded whatever was typed in the Debug arguments box — `cmdOK`
  never wrote it back (2026-08-04).
- Panel pin vanishing after a collapse/reopen cycle (overlay remap + relayout) (2026-08-04).
- Bottom/debug panels cleared on project close and debug end (2026-08-03).

### Changed / Removed (opinionated by design)
- Rebranded VisualFBEditor → Ilwaco IDE; x86_64/GTK3/Linux only.
- Removed the compiler picker (one bundled compiler), the AI-assistant features, non-English UI
  languages, encoding/newline selection, the Direct2D option, and assorted legacy menus.
- Removed the alt compiler-backend picker, optimization radios and Advanced Options dialog;
  `-gen gas64` is hard-coded (2026-08-04).
- Removed the debugger picker and the GDB engine — Ilwaco ships one debugger, the built-in
  Integrated (stabs) engine; Terminal is now a top-level options page (2026-08-04).
- Removed two options that never did anything: "Limit debug to the directory of the main file" and
  the debug panel's "Update" toggle (2026-08-04).
- Stripped Windows-only source as files are touched (the GTK build is the target).

See [Documentation/IlwacoIDESignificantChanges.md](Documentation/IlwacoIDESignificantChanges.md) for
the curated summary and [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md) for the
per-change record.
