# Learning Ilwaco and FreeBASIC

Small, complete programs for someone starting out. Every one is an Ilwaco project: open the
`.vfp`, build it, run it, then change something and see what happens.

| Folder | What it is |
| --- | --- |
| [Console](Console/) | 25 console programs covering an introductory programming course — output, variables, input, decisions, loops, arrays, procedures, files, sorting and searching. |
| [GUI](GUI/) | The same ground again, as windowed programs built with MyFbFramework — controls, events, timers, dialogs, menus, drawing, and splitting a program across several files. |

## Which to read first

**Console, then GUI.** A console program runs top to bottom, so you can follow it
with your finger. A window does not: it sits waiting, and your code runs in fragments when the
user does something. Meeting loops and arrays for the first time *and* that change of shape at the
same time is harder than it needs to be.

If you already program in another language, start at [GUI](GUI/) — the Console set will
mostly be syntax you can skim.

## What these are, and are not

They are written to be **read**. Where there is a choice between the clear way and the clever way,
they take the clear one — `24_BubbleSort` uses the slowest sort in common use because it is the
one you can follow by hand.

They are **not** a reference. For that see [the manual](../../Documentation/IlwacoIDEManual.md) for
the IDE and [the framework guide](../../Documentation/MyFbFrameworkGuide.md) for the controls.

The other folders under `Examples/` are real programs rather than teaching material — larger, and
several need particular hardware. They are worth reading once these make sense; each carries a
`REQUIREMENTS.md` saying what it needs.

## Tested

**Every project here was built and run on Linux/GTK3 (Debian 13, x86_64) on 2026-08-07**, using
Ilwaco's bundled FreeBASIC toolchain: all 25 console programs compiled and ran to completion, and
all 25 GUI programs compiled and were confirmed to open their window.

Nothing here needs hardware, a network, or any of the optional control libraries.

These examples came from Ilwaco's Windows sibling, Astoria, where they were tested on 64-bit
Windows 11. Three portability defects that a case-insensitive filesystem had hidden were fixed on
the way across, so **these are the Linux-verified copies** — see
[Documentation/UpstreamFixes.md](../../Documentation/UpstreamFixes.md).
