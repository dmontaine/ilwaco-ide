# Ilwaco IDE — user manual

**Status: scaffold.** A tracked placeholder, not yet written for Ilwaco. It exists so the document
has an analogue, is listed in the rule table, and is caught by `DocCheck` when it goes stale — see
[TestPlan.md](TestPlan.md).

**Purpose.** The user-facing manual: what Ilwaco is, how to install and launch it on Linux, and how
to use each part of the IDE (projects, the editor, the form designer, building and running, the
debugger). Audience: teachers, students, hobbyists — so plain language, and a feature either works
or is not documented as working.

**Source to adapt.** Astoria maintains a full `AstoriaIDEManual.md` (~930 lines) for Windows. The
*structure* is a good starting point, but the platform specifics are all different and must be
rewritten, not adapted line-by-line:

- **Install/launch is Linux.** No installer or `.exe`; Ilwaco ships as an AppImage (planned) with an
  external writable Projects/Examples/Docs area — see the packaging notes in
  [PROJECT_STATUS.md](../PROJECT_STATUS.md). Building from source uses `./build-linux.sh`.
- **Opinionated surface.** Sections describing removed features (compiler picker, multiple UI
  languages, the AI assistants, encoding/newline pickers, `.vfs` sessions, the "when the IDE starts"
  choice, the holiday frame) must **not** be carried over — see
  [IlwacoIDESignificantChanges.md](IlwacoIDESignificantChanges.md) for what is gone.
- **Two behaviours to describe that Astoria's manual does not have.** Ilwaco reopens the project and
  tabs it had when it was last closed (no session file to manage), and its Code Editor options are
  grouped Display / Editing / Completion / IntelliSense / History rather than one flat list.
- **GTK behaviour.** The collapsible vertical-text tool-panel rails, dark mode (once it fires), and
  keyboard/menu specifics need to be documented from the GTK build, not from Astoria's Win32 one.
- **The AI-agent chapter already exists** as [AgentMcpSetup.md](AgentMcpSetup.md) — connecting a
  client to `ilwaco-mcp`, the "Allow AI agent control (MCP)" opt-in, and the status-bar readout. Fold
  it in (or link it) rather than rewriting it.

Write this once the feature set stabilises. Until then, [PROJECT_STATUS.md](../PROJECT_STATUS.md) is
the authoritative description of current behaviour.
