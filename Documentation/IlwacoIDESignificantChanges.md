# Ilwaco IDE — significant changes from VisualFBEditor

How Ilwaco differs from its base, [VisualFBEditor](https://github.com/XusinboyBekchanov/VisualFBEditor),
for readers outside the repo. Ilwaco is a Linux/GTK3 fork being brought toward parity with its
Windows sibling **Astoria** by walking Astoria's changelog and translating each change to GTK, while
following the same "opinionated by design" stance: where there is a clearly better answer, make the
choice once and remove the option.

The authoritative, per-change record is [AstoriaParity.md](AstoriaParity.md); this page is the
curated summary. (Unlike Astoria's equivalent, there is no rendered PDF or `.txt` companion — Ilwaco
keeps only this Markdown.)

---

## 1. Platform & identity

- **Linux / GTK3, x86_64 only.** Ilwaco is the GTK build of the shared codebase. Windows-only source
  (`#ifdef __FB_WIN32__` / `__USE_WINAPI__` branches) is treated as dead code and physically deleted
  as files are touched — the mirror image of Astoria, which deleted the GTK branches. 32-bit builds
  are no longer supported; all 32-bit code and options were removed.
- **Rebranded to Ilwaco IDE.** VisualFBEditor → **Ilwaco IDE** in the UI, `ilwaco` for files and the
  executable. The internal source namespace is kept to minimise churn against the base.
- **UTF-8 + LF only.** New files are written UTF-8 without a BOM, newlines are LF; the encoding and
  newline **selection** UI was removed, and with it the status bar's encoding readout — a panel that
  could only ever say "UTF-8". That panel now shows the MCP agent state (§4).
- **English only.** The other interface languages were removed; `ML()` is a passthrough.

## 2. Features removed (opinionated by design)

Each of these was a *choice* in VisualFBEditor and is now made once, with the option gone:

- **The compiler picker is gone** — one bundled compiler, hard-coded, no selection dialog. (The INI
  `[Compilers]` block cannot simply be restructured — the settings parser is edited so the picker no
  longer exists rather than just hiding it.)
- **AI-assistant features were removed** — the multi-assistant integration (a choice of several) is
  no longer present.
- **The Direct2D user option was removed** — it was a Win32-only rendering path with no GTK meaning.
- **Legacy editor options removed** — Error Handling and Line Numbering menu items, the "Close
  Folder" command, the "Use" target-selector dropdown, and the Help ▸ GitHub submenu are no longer
  present (Astoria parity).
- **The alt compiler-backend picker is gone** — no GAS/LLVM/GCC/CLANG choice, no optimization radios
  and no Advanced Options dialog; `-gen gas64` is hard-coded (2026-08-04).
- **The debugger picker is gone (2026-08-04).** Ilwaco ships **one** debugger, the built-in
  Integrated (stabs) engine, and the GDB engine is removed — the *inverse* of Astoria's choice, made
  because the Integrated engine reads FreeBASIC's `.dbgdat`/`.dbgstr` sections that only the gas64
  backend emits. With it went the Default Debuggers / Debugger Paths options page, the debugger
  combo in Parameters, and the `[Debuggers]` settings block.
- **Two never-functional options removed (2026-08-04)** — "Limit debug to the directory of the main
  file" (its only reference was commented-out Win32 code) and the debug panel's "Update" toggle (it
  wrote a flag nothing read). A broken option costs a beginner more than a missing one.

## 3. Behaviour reimplemented for GTK

- **Collapsible tool panels (2026-08-04).** The left and right tool panels collapse to a thin
  vertical-text strip at the edge — a pin icon on top (re-expands to the last tab) above the tab
  captions rendered as rotated vertical text — mimicking Astoria's collapsed look. This is a GTK
  reimplement: Astoria's Win32 collapse-to-vertical-tab-strip cannot reuse the GTK notebook, so the
  panel is hidden and a separate rail is shown. State persists across sessions.
- **Debug-tab visibility.** The debugger's seven analysis tabs appear only when the debugger is
  enabled; the Immediate tab stays visible.
- **New projects are written to disk with a name you choose (2026-08-04).** New Project used to open
  an unsaved `Project1` from the chosen template that you had to Save As later — easy to lose. It now
  asks for a project type and name up front and creates the project on disk. The dialog offers only
  project types that work on this build, so there is no Win32 GUI option.
- **Project templates no longer start with a UTF-8 BOM (2026-08-04).** Every shipped template source
  carried one, which makes FreeBASIC treat string literals as wide — so a brand-new project compiled
  cleanly and then printed garbage. The default module/form in a new project is now `Main.bas` /
  `Main.frm` (was `Module1`/`Form1`/`UserControl1`), matching Astoria.
- **The debuggee's arguments and environment now work (2026-08-04).** VisualFBEditor exposed Debug
  arguments and an "Environment variables" option that were never applied — and Astoria, hitting the
  same thing on Win32, removed the env option as non-functional. Ilwaco wires both up instead: the
  debuggee is launched with a real `argv` (program name, the Parameters *Debug* arguments, then the
  project's *Command-line arguments*, matching what Run already did) and a real environment, with a
  user variable overriding the inherited one of the same name. Implemented for `fork`/`execve`: the
  block is built in the parent, because after `fork()` in a multithreaded process the child must not
  allocate.
- **The "When the IDE starts" option is gone (2026-08-06).** VisualFBEditor let you pick between
  prompting for a project, creating one from a default template, reopening the last file, or doing
  nothing. Ilwaco always does the last of those: it starts empty unless you passed a file on the
  command line. The settings only that group fed were removed with it (`WhenVisualFBEditorStarts`,
  `LastOpenedFileType`, `DefaultProjectFile`), as did `AutoReloadLastOpenFiles`, which nothing had
  ever read. (Astoria reopens its saved workspace instead; Ilwaco has no workspace loader yet, so
  adopting that behaviour waits for one.)
- **The Code Editor options page is grouped (2026-08-06)** into **Display**, **Editing**,
  **Completion**, **IntelliSense** and **History** — a flat list of twenty-five checkboxes gave a
  beginner no way to guess where a setting lived. Astoria uses four groups; Ilwaco splits its
  "History" one, because there a group named History also held Tab Size, Treat Tab as Spaces, the
  IntelliSense limit and the tooltip hover time. Tab settings moved to **Editing**, the two
  IntelliSense settings to **IntelliSense**, and History keeps only the history/autosave limits, so
  every group name now describes what is inside it.
- **Indent guides, and no more holiday frame (2026-08-06).** VisualFBEditor shipped a "Show Holiday
  Frame" option that blitted a decorative PNG over the editor during December and January. It is
  removed — decoration is not what an IDE for a classroom needs — and the option is replaced by a
  real feature: **Show Indent Guides** draws a faint vertical rule at each enclosing indent level, so
  the nesting of FreeBASIC blocks is visible at a glance. Tabs and spaces count identically, so a
  file indented either way guides the same. (Astoria renamed the same checkbox to "Show Indent
  Guides" but left it driving the holiday frame; Ilwaco implements what the label says.)
- **Recent Projects is a dialog, not a menu of paths (2026-08-06).** File ▸ Recent Projects… opens a
  list showing each recent project's file name and full path with its icon, and quietly drops entries
  whose `.vfp` is no longer on disk — a menu could show neither the path nor whether the project still
  exists. Recent Files, Folders and Sessions remain submenus for now.

## 4. Added: an AI agent can drive the IDE (MCP, 2026-08-06)

Ilwaco ships an **Agent MCP server** — nothing in VisualFBEditor corresponds to it. A small native
sidecar, `ilwaco-mcp`, sits beside the `ilwaco` binary and speaks MCP/JSON-RPC over stdio to a client
such as Claude Code or Claude Desktop, forwarding each tool call to the running IDE over a per-user
Unix socket. The agent gets 15 tools — open/create a project, list/read/write files, open editor
tabs, build, syntax-check, run, and read structured compile errors — and each one runs the *same*
code the corresponding menu item runs, so the IDE the agent drives is the IDE you see. If Ilwaco is
not running when the first tool call arrives, the sidecar starts it.

It is **opt-out, not opt-in**: the listener is up by default (Ilwaco is meant to be driven this way),
controlled by **Tools ▸ Options ▸ General ▸ "Allow AI agent control (MCP)"**, which starts and stops
it without a restart. The status bar reads **"MCP Agent: On"** or **"MCP Agent: Off"** so the state
is never a guess. File tools are confined to the open project's folder. Setting a client up is
[AgentMcpSetup.md](AgentMcpSetup.md); the architecture and the task-by-task record are in
[McpServer.md](McpServer.md).

---

## Maintenance

Adding or removing a feature updates this page — and a *removal* also adds a line to
`REMOVED_FEATURES` in `Tools/DocCheck.py`, so the checker catches any other document that goes on
describing the gone feature. See the rule table in [TestPlan.md](TestPlan.md).
