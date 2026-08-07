# Changelog

Milestones for Ilwaco IDE, newest first. Hand-kept — append a line at each shipped milestone (Ilwaco
has no PowerShell changelog generator; the per-change port backlog lives in
[Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md), and the
handoff/state in [PROJECT_STATUS.md](PROJECT_STATUS.md)).

The format is loosely [Keep a Changelog](https://keepachangelog.com/). Dates are ISO-8601.

## [Unreleased]

### Added
- **Delete File** — one command on the File menu, the Project menu, the tree context menu and the
  explorer toolbar, with a confirmation prompt that defaults to *No*. A file belonging to a project is
  queued rather than deleted: it shows as `(pending delete)` and only leaves the disk when the project
  is saved, so closing without saving abandons the deletion. Right-click a queued file for
  **Cancel Deletion** to undo it (2026-08-06).
- **Open Project** is now on the File menu — the command existed but its menu item was commented
  out, so there was no way to reach it (2026-08-04).
- **Rename Project** and **Delete Project** commands (2026-08-04). ⚠️ Both currently inherit a
  pre-existing crash in Close Project — see `Documentation/TechnicalDebt.md`.
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
- The project explorer's right-click menu showed fixed, stale entries: the handler that prepares it
  could never run on GTK, so captions and enabled/disabled state never reflected what was selected
  (2026-08-06).
- A modified project showed no `*` against its name in the tree — the marker was being recorded but
  never repainted (2026-08-06).
- Answering the Close Project save prompt saved nothing, because the file list was read after the
  dialog had already been torn down; closing that prompt with the window's X now counts as Cancel
  rather than silently continuing without saving (2026-08-06).
- Project templates shipped with a UTF-8 BOM, which makes FreeBASIC compile string literals as wide
  characters — every new project built cleanly and then printed garbled text (2026-08-04).
- Debugging a project stored under a path containing uppercase letters failed with "File not found":
  the debugger lowercased the source path, a Win32 habit that is wrong on Linux (2026-08-04).
- Two files whose names differ only in case (`Foo.bas` / `foo.bas`) collapsed onto a single editor
  tab — path comparison was case-insensitive, a Win32 assumption. Paths now compare exactly, and the
  backslash-normalisation and drive-letter handling that went with it are gone (2026-08-04).
- The Parameters dialog silently discarded whatever was typed in the Debug arguments box — `cmdOK`
  never wrote it back (2026-08-04).
- Panel pin vanishing after a collapse/reopen cycle (overlay remap + relayout) (2026-08-04).
- Bottom/debug panels cleared on project close and debug end (2026-08-03).

### Changed / Removed (opinionated by design)
- The **Remove** command is gone, merged into **Delete File**. Remove deleted a file from disk with no
  confirmation of any kind; there is now one command, and it asks first (2026-08-06).
- The save-changes prompt no longer counts down and answers **Yes** for you after ten seconds — it
  guards a destructive action and now waits (2026-08-06).
- The default module/form in a new project is now `Main.bas` / `Main.frm`, and New Project offers
  only project types that work on a Linux/GTK build (2026-08-04).
- Menus follow Astoria's taxonomy: the File menu leads with project commands, `Format` is now
  `Designer`, and several labels are plainer — the status bar reads "Press F1 for help", the output
  toolbar says "Clear Output"/"Clear Immediate", Goto asks "Go to line:", and the Find dialog's
  `Aa` / `W` / `.*` / `<` / `>` buttons are now Match Case / Whole Word / Regex / Find Previous /
  Find Next. New documents are numbered `Untitled1`, `Untitled2`, … (2026-08-04).
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
