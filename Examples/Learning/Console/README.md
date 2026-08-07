# Console examples — learning FreeBASIC

Twenty-five short console programs, each a complete Ilwaco project. They cover the ground an
introductory programming course covers, in roughly the order such a course covers it, and every
one is under 100 lines so you can read the whole thing before running it.

## How to use them

Open the `.vfp` in a folder — **File → Open Project** — then build and run it. Each project is
self-contained: one `Main.bas`, no dependencies, console subsystem. The source is commented for
someone meeting the idea for the first time, so read it before you run it; the comments explain
*why*, and the output shows *what*.

Every program ends by waiting for a key, so a window launched from the IDE stays open long
enough to read.

## Tested

**All 25 compile and run on Linux/GTK3** (Debian 13, x86_64, verified 2026-08-07 with Ilwaco's
bundled FreeBASIC toolchain) — every one built, then executed to completion with exit code 0. This
is a stronger claim than the other examples carry, and it is only possible because these need no
hardware: nothing here has a device to be missing.

What was *not* checked is every line of output against what it ought to be. A sample was read by
hand and is correct; the rest is verified to have run, not to be right.

They need no hardware, no network and no control libraries — only Ilwaco and FreeBASIC.

They came from Astoria, Ilwaco's Windows sibling, where they were tested on 64-bit Windows 11.

## The programs

| # | Project | What it shows | Lines |
| --- | --- | --- | --- |
| 1 | [`01_HelloWorld`](01_HelloWorld/) | Your first program: printing text | 21 |
| 2 | [`02_Variables`](02_Variables/) | Storing values: DIM, types and assignment | 27 |
| 3 | [`03_UserInput`](03_UserInput/) | Reading what the user types with INPUT | 21 |
| 4 | [`04_Arithmetic`](04_Arithmetic/) | Operators, and the difference between `/` and `\` | 30 |
| 5 | [`05_Strings`](05_Strings/) | Joining, measuring and slicing text | 29 |
| 6 | [`06_IfElse`](06_IfElse/) | Making decisions with IF, ELSEIF and ELSE | 37 |
| 7 | [`07_SelectCase`](07_SelectCase/) | Choosing between many options cleanly | 35 |
| 8 | [`08_ForLoop`](08_ForLoop/) | Repeating a fixed number of times | 37 |
| 9 | [`09_WhileLoop`](09_WhileLoop/) | Repeating until something changes | 34 |
| 10 | [`10_NestedLoops`](10_NestedLoops/) | A loop inside a loop | 29 |
| 11 | [`11_Arrays`](11_Arrays/) | Many values under one name | 41 |
| 12 | [`12_Array2D`](12_Array2D/) | Grids: arrays with rows and columns | 49 |
| 13 | [`13_Procedures`](13_Procedures/) | SUBs: naming a block of work | 34 |
| 14 | [`14_Functions`](14_Functions/) | FUNCTIONs: work that gives an answer back | 36 |
| 15 | [`15_ByRefByVal`](15_ByRefByVal/) | How arguments are passed, and why it matters | 39 |
| 16 | [`16_Recursion`](16_Recursion/) | A procedure that calls itself | 32 |
| 17 | [`17_Fibonacci`](17_Fibonacci/) | The same problem two ways: loop vs recursion | 41 |
| 18 | [`18_Constants`](18_Constants/) | CONST and ENUM: names for fixed values | 38 |
| 19 | [`19_UserTypes`](19_UserTypes/) | TYPE: grouping related values together | 43 |
| 20 | [`20_FileWrite`](20_FileWrite/) | Saving text to a file | 36 |
| 21 | [`21_FileRead`](21_FileRead/) | Reading a file back, line by line | 33 |
| 22 | [`22_RandomNumbers`](22_RandomNumbers/) | Chance: RND and RANDOMIZE | 40 |
| 23 | [`23_DateTime`](23_DateTime/) | Working with dates and times | 43 |
| 24 | [`24_BubbleSort`](24_BubbleSort/) | Putting an array in order | 42 |
| 25 | [`25_BinarySearch`](25_BinarySearch/) | Finding a value fast, and checking input | 47 |

## Suggested order

They are numbered in a deliberate order and later ones assume earlier ones. If you are starting
from nothing, work straight through 01 to 25. If you already program in another language, 01–10
will mostly be syntax you can skim; the FreeBASIC-specific parts worth slowing down for are
**15 (ByRef vs ByVal)**, **19 (user-defined types)** and **23 (dates, which need `vbcompat.bi`)**.

## A note on style

These are written to be *read*, not to be efficient. `24_BubbleSort` uses the slowest sort in
common use because it is the one you can follow by hand; `17_Fibonacci` computes the sequence
both recursively and with a loop precisely so you can compare them.
