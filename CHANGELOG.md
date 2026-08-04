# Changelog

Milestones for Ilwaco IDE, newest first. Hand-kept — append a line at each shipped milestone (Ilwaco
has no PowerShell changelog generator; the per-change port backlog lives in
[Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md), and the
handoff/state in [PROJECT_STATUS.md](PROJECT_STATUS.md)).

The format is loosely [Keep a Changelog](https://keepachangelog.com/). Dates are ISO-8601.

## [Unreleased]

### Added
- Documentation-maintenance apparatus: `Tools/DocCheck.py`, the rule table in
  `Documentation/TestPlan.md`, the `update-ilwaco-docs` skill, and Ilwaco analogues of Astoria's
  Documentation set (2026-08-04).
- Collapsible left/right tool panels — a thin vertical-text rail (pin + rotated tab captions) that
  re-expands to the last or a chosen tab; state persists across sessions (2026-08-04).
- Debug-tab visibility: the seven analysis tabs show only when the debugger is enabled; new MFF
  `DetachTab` (2026-08-03).

### Fixed
- Panel pin vanishing after a collapse/reopen cycle (overlay remap + relayout) (2026-08-04).
- Bottom/debug panels cleared on project close and debug end (2026-08-03).

### Changed / Removed (opinionated by design)
- Rebranded VisualFBEditor → Ilwaco IDE; x86_64/GTK3/Linux only.
- Removed the compiler picker (one bundled compiler), the AI-assistant features, non-English UI
  languages, encoding/newline selection, the Direct2D option, and assorted legacy menus.
- Stripped Windows-only source as files are touched (the GTK build is the target).

See [Documentation/IlwacoIDESignificantChanges.md](Documentation/IlwacoIDESignificantChanges.md) for
the curated summary and [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md) for the
per-change record.
