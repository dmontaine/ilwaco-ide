# ilwaco.ide

**Ilwaco IDE** — a FreeBASIC IDE for **Linux** (GTK3, x86_64), forked from
[VisualFBEditor](https://github.com/XusinboyBekchanov/VisualFBEditor) and built on MyFbFramework.

It has a Windows sibling, **Astoria IDE**, forked from the same base. The two look alike and mostly
behave alike, but they are **separate programs and they do differ** — different platforms, a different
intended audience, and some features deliberately kept in one and not the other.

👉 **If you use one and are picking up the other, read
[Documentation/IlwacoVsAstoria.md](Documentation/IlwacoVsAstoria.md) first.**

Ilwaco is project-based: you work inside a project, not on loose files.

## Documentation

| Document | What it is |
| --- | --- |
| [IlwacoVsAstoria.md](Documentation/IlwacoVsAstoria.md) | **How Ilwaco and Astoria differ** — read this if you know one of them |
| [IlwacoIDEManual.md](Documentation/IlwacoIDEManual.md) | The user manual |
| [IlwacoIDESignificantChanges.md](Documentation/IlwacoIDESignificantChanges.md) | How Ilwaco differs from VisualFBEditor, its base |
| [AgentMcpSetup.md](Documentation/AgentMcpSetup.md) | Letting an AI agent drive the IDE (opt-in) |
| [CHANGELOG.md](CHANGELOG.md) | Milestones |

Contributor-facing: [CLAUDE.md](CLAUDE.md) (orientation), [PROJECT_STATUS.md](PROJECT_STATUS.md)
(current state and next actions), [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md)
(the port backlog).

## Status

Under active development, and **not yet packaged** — it builds and runs from source on Linux
(`./build-linux.sh editor`; see PROJECT_STATUS for the full recipe). Parity with Astoria is a work in
progress; the current gaps are listed in the comparison document above.
