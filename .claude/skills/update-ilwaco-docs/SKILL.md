---
name: update-ilwaco-docs
description: Keep Ilwaco's own documentation matching the software. Use after ANY change that could make a document wrong - a fix, a test, a new feature, and above all a removal. Run python3 Tools/DocCheck.py before committing.
---

# Update the documents, then prove it

[Documentation/TestPlan.md](../../../Documentation/TestPlan.md) opens with a table of which
document to touch when. **That table is the rule; this skill is how to satisfy it without relying
on memory.**

```bash
python3 Tools/DocCheck.py        # fails on stale documents, with file and line
python3 Tools/DocCheck.py --list # show what is checked and where the rules live
```

## The trigger is any change, not just a test

The rule is deliberately not "update the docs after every test" — **a removal produces no test.**
Deleting a feature leaves no failing check and no test to run, so a document can go on describing
it for days (Astoria's Git menu survived four days in five documents this way). Treat all of these
as triggers:

| You did this | Then |
| --- | --- |
| Ran a test | `TestPlan.md` scenario row; `Testing.md` if what is proven changed |
| Fixed a defect | `PROJECT_STATUS.md`; whichever document described the broken behaviour |
| **Removed a feature** | `IlwacoIDESignificantChanges.md`, **and** add a line to `REMOVED_FEATURES` in `Tools/DocCheck.py`; mark obsolete rows in `TestPlan.md` rather than deleting them |
| Changed a control | `Controls.md` — the one most often missed — and `ControlTesting.md` |
| Changed a non-toolbox framework capability | `FrameworkFeatures.md` |
| Fixed a bug in vendored upstream code (VisualFBEditor / MFF) | `UpstreamFixes.md` |
| Ported / classified an Astoria change | `AstoriaParity.md` (and tick the backlog) |
| Deleted a file the docs name | grep for it; `DocCheck` catches inline-code paths |
| Shipped a milestone | append a line to `CHANGELOG.md` (root) — hand-kept |

## Mark obsolete, do not delete

A scenario or note for a removed feature becomes **OBSOLETE** with the date and the reason, kept in
place. Deleting it makes coverage that once existed read as coverage that lapsed, and throws away
the reasoning — expensive to reconstruct, impossible to recover once gone. `DocCheck`'s HISTORICAL
lookback is what lets a removal *notice* sit in the docs without being flagged as live drift, so
keep the notice near the words that mark it (`removed`, `OBSOLETE`, `no longer`, …).

## Linux/GTK — what Ilwaco does NOT carry from Astoria's version

Astoria's doc apparatus is partly Windows-shaped; Ilwaco drops those pieces on purpose:

- **No rendered `.pdf`/`.txt` companions.** Astoria renders `AstoriaIDESignificantChanges.md` to a
  Chrome-PDF and a wrapped `.txt` for forums; Ilwaco keeps only the Markdown. There is nothing to
  regenerate and no "all three move together" rule.
- **No PowerShell changelog generator.** Astoria's `DetailedChangelog.md` is built from commit
  messages by `GenerateChangelog.ps1`. Ilwaco has no PowerShell; `CHANGELOG.md` is hand-kept and
  `AstoriaDetailedChangeLog.md` is the hand-pruned port backlog.
- **No `ROADMAP.md` §-status check.** Ilwaco's forward record is `AstoriaParity.md` +
  `PROJECT_STATUS.md` (prose), so `DocCheck` has no section-number check — just removed-features,
  missing-files, and the rule-table completeness check.

## Say what is not known

[Documentation/Testing.md](../../../Documentation/Testing.md) lists what has been verified **and
what has not**, written for outside testers. If something is unproven, write that it is unproven.
An honest gap is worth more than a confident sentence that turns out to be false — and Ilwaco's
verification is *by effect* on the live GTK display, so the gaps are real and worth naming.
