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
  newline **selection** UI was removed.
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

## 3. Behaviour reimplemented for GTK

- **Collapsible tool panels (2026-08-04).** The left and right tool panels collapse to a thin
  vertical-text strip at the edge — a pin icon on top (re-expands to the last tab) above the tab
  captions rendered as rotated vertical text — mimicking Astoria's collapsed look. This is a GTK
  reimplement: Astoria's Win32 collapse-to-vertical-tab-strip cannot reuse the GTK notebook, so the
  panel is hidden and a separate rail is shown. State persists across sessions.
- **Debug-tab visibility.** The debugger's seven analysis tabs appear only when the debugger is
  enabled; the Immediate tab stays visible.

---

## Maintenance

Adding or removing a feature updates this page — and a *removal* also adds a line to
`REMOVED_FEATURES` in `Tools/DocCheck.py`, so the checker catches any other document that goes on
describing the gone feature. See the rule table in [TestPlan.md](TestPlan.md).
