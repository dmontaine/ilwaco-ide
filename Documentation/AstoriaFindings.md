# Findings to share back with Astoria

Ilwaco is the Linux/GTK fork of the shared [VisualFBEditor](https://github.com/XusinboyBekchanov/VisualFBEditor)
base; [Astoria](../../astoria-ide) is the Win64 sibling fork, and the two share most of their history.
While walking Astoria's changelog to port each change into Ilwaco (see
[AstoriaParity.md](AstoriaParity.md)), we occasionally find a genuine defect or notable flaw in
**Astoria's own code**. This file is where we record those, so they can be fed back to Astoria when it
resumes development after Ilwaco reaches release.

**Offered, not claimed — and the same owner maintains both projects.** Astoria is *frozen* (owner,
2026-08-06), so nothing here can be acted on yet; this is a durable holding pen, not a bug tracker.
Entries are written from Ilwaco's vantage point and may need adapting to Astoria's Win64 tree.

## What goes here vs. UpstreamFixes.md

Two different audiences — put each finding in the right file:

| Finding is a defect in… | Goes in | Because |
| --- | --- | --- |
| the **shared VisualFBEditor / MyFbFramework upstream** base (present in the common ancestor) | [UpstreamFixes.md](UpstreamFixes.md) | offered to the upstream maintainer; likely affects every fork |
| **Astoria's own code** — Win64-specific, or something Astoria introduced/reworked | **this file** | only Astoria needs it; upstream and Ilwaco do not have that code |

A Win32-shaped bug that is **N/A for Ilwaco but real for Astoria** belongs **here**, not dismissed:
Ilwaco not being able to reach the bug does not mean Astoria is not still living with it.

## How to add an entry

One entry per finding. Give enough that an Astoria maintainer can act without this repository:

- **Symptom** — what goes wrong, observably.
- **Location** — Astoria file(s), and the Astoria commit hash if the flaw was introduced or last
  touched by a known one (`git -C ../astoria-ide show <hash>`).
- **How we noticed** — the Ilwaco port step or investigation that surfaced it.
- **Severity** — crash / wrong-result / cosmetic / housekeeping.
- **Confidence** — confirmed (measured) vs. suspected (read from code).

Keep the honesty bar of [UpstreamFixes.md](UpstreamFixes.md): if it is unverified against Astoria's
current tree, say so.

---

## Findings

*(No confirmed Astoria-specific defects logged yet. The port direction means we mostly encounter
Astoria's deliberate **decisions**, not bugs, and the shared-base bugs we do find go to
[UpstreamFixes.md](UpstreamFixes.md). Real Astoria-side defects get appended below as the walk
surfaces them.)*

### Housekeeping — BOM-less-UTF-8 policy has stragglers (cosmetic, confirmed)

- **Symptom:** Astoria documents that *"all files Astoria writes are BOM-less UTF-8"*
  ([AstoriaIDESignificantChanges.md](../../astoria-ide/Documentation/AstoriaIDESignificantChanges.md)),
  but a number of source files still carry a UTF-8 BOM — 8 framework files under
  `Controls/Framework/mff/`, 11 files under `src/`, and `mff/mff.rc` — presumably because those files
  were never re-saved through the IDE and so the save-time normalisation never touched them.
- **Severity / impact:** **Cosmetic only.** We verified on FB 1.10.1 that a BOM is scoped to the file
  it is in — it does *not* leak into an including file's string literals — so these stragglers are
  harmless at runtime; the framework's wide literals are what a Unicode library wants anyway. This is
  a policy-vs-reality mismatch, not a functional bug.
- **How we noticed:** Ilwaco's own framework BOM/line-ending review (2026-08-08), which measured the
  include-scoping behaviour directly before deciding to leave Ilwaco's framework BOMs in place.
- **Confidence:** confirmed (byte-level file inspection + a compiled include-scoping test).
