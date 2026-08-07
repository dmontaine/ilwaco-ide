# Ilwaco IDE and Astoria IDE — how they differ

**They are siblings, not the same program.** Both are forks of
[VisualFBEditor](https://github.com/XusinboyBekchanov/VisualFBEditor), both are FreeBASIC IDEs built on
MyFbFramework, and Ilwaco is deliberately being brought *toward* Astoria by walking Astoria's change
history and translating each change. So they look alike and mostly behave alike — which is exactly why
the places they diverge are worth stating plainly.

If you use one and are picking up the other, read this page first.

> **Status note.** This page describes what **ships today**. Ilwaco is mid-way through the parity walk,
> so some rows say "planned" — those are decisions taken and recorded, not features you can use yet.
> The per-change engineering record is [AstoriaParity.md](AstoriaParity.md); how Ilwaco differs from
> the shared *base* is [IlwacoIDESignificantChanges.md](IlwacoIDESignificantChanges.md).

---

## 1. The one difference that governs the rest: platform

| | Ilwaco | Astoria |
| --- | --- | --- |
| Operating system | **Linux**, GTK3 | **Windows** |
| Architecture | x86_64 only | 64-bit |

Each fork physically deletes the other's platform code, so this is not a build flag you can flip — they
are separate programs with a shared ancestor. Anything in Astoria implemented with Win32 calls has to be
*re-implemented* for GTK rather than copied, which is why parity is a walk rather than a merge, and why a
handful of Astoria features are not in Ilwaco yet.

## 2. Intended audience

Astoria targets **returning Basic programmers, hobbyists and students**, and removes advanced features
that would confuse that audience. Ilwaco targets a **somewhat more advanced** user, so several
capabilities Astoria dropped for simplicity are kept — or planned — here. That single decision explains
every row in §3.

## 3. What Ilwaco keeps that Astoria does not

### Available now

- **Multiple IDE windows at once.** Ilwaco lets you run several instances side by side. In Astoria a
  second launch hands your command line to the window already running and brings it to the front, so
  there is only ever one Astoria.
- **A much larger set of editor themes.** Ilwaco ships **96** editor colour themes; Astoria curated its
  shipped set down to **12**. Both IDEs let you choose and define themes — see §5, this is a difference
  in what is *bundled*, not in capability.

### Planned, not yet present

These are recorded decisions. **Neither is in Ilwaco today**; both exist in Astoria's history and were
removed there.

- **Git integration** — a top-level Git menu (Pull, Push, Commit, Set Up SSH Key, Create Remote
  Repository), Git identity settings, and Git-aware project creation. Astoria built this and then removed
  it as "an advanced feature that doesn't fit Astoria's target audience". Ilwaco intends to have it.
- **A choice of AI assistant templates** — **Claude Code, ChatGPT, Kun and Kimi Code**, each with its own
  Skills and Rules. Astoria supported six agents, then consolidated onto Claude Code alone so that its
  audience would not face a choice of help systems. Ilwaco intends to offer the four above. (Cursor and
  OpenCode, also in Astoria's original set, are not planned.)

## 4. Where Ilwaco is behind Astoria

Parity is a work in progress, and Astoria is the more evolved fork. At the time of writing the notable
gaps are:

- **Dark mode does not apply on GTK.** The framework has a real GTK dark-mode path, but the flag that
  switches it on was only ever set by Windows-specific startup code, so Ilwaco's dark styling does not
  currently take effect. Editor colour themes are unaffected and work normally.
- **No packaged release yet.** Ilwaco builds and runs from source; the AppImage is not done.
- **The form designer is less mature**, and the agent interface deliberately exposes no designer tools.
- Assorted changelog items are still unported — the current backlog is in
  [AstoriaParity.md](AstoriaParity.md).

## 5. Things that are easy to assume are different, and are not

- **Both are project-based only.** Neither is a general-purpose text editor: you work inside a project.
- **Both let you choose and define themes, in two independent places** — the **IDE interface** theme
  (Tools ▸ Options ▸ General ▸ Themes) and the **editor** syntax colours and fonts (Tools ▸ Options ▸
  Code Editor ▸ Colors and Fonts). Astoria never removed either; it only trimmed the bundled editor-theme
  collection (§3).
- **Both ship a single bundled FreeBASIC compiler** with no compiler picker.
- **Both can be driven by an AI agent** over an MCP server, and in both it is a user-controlled opt-in.
- **Both are English-only** and write **UTF-8 without a BOM, with LF newlines** — Ilwaco removed the
  encoding and newline selection UI entirely.

One genuine reversal worth knowing: **the debugger choice is inverted.** Both IDEs ship exactly one
debugger, but not the same one — Ilwaco keeps the built-in *Integrated* engine and removed GDB, because
the Integrated engine reads the debug sections the bundled compiler actually emits.

---

## Maintenance

Update this page whenever a difference between the two IDEs appears or disappears — in particular when a
"planned" item in §3 ships (move it to *Available now*) or a §4 gap is closed. `Tools/DocCheck.py` will
not catch a stale comparison here, because half the facts live in the *other* repository; this one needs
a human to notice. When in doubt, cross-check against Astoria's own significant-changes document in the
sibling checkout.
