# GUI examples — learning MyFbFramework

Twenty-five small windowed programs, each a complete Ilwaco project. They follow the same
introductory path as [../Console](../Console/) — input, decisions, loops, arrays, procedures,
files — but with a window instead of a console, so you can see the same ideas in the form you
will actually ship them in.

Start with [`01_HelloWindow`](01_HelloWindow/). Its comments explain the three parts every
program here shares, and everything after it assumes you have read them.

## How to use them

Open the `.vfp` in a folder — **File → Open Project** — then build and run. The form opens in
Ilwaco's designer as well, so you can select a control and see the properties the code sets.

## Tested

**All 25 compile and open their window on Linux/GTK3** (Debian 13, x86_64, verified 2026-08-07
with Ilwaco's bundled FreeBASIC toolchain). Each was launched and confirmed to put a window on
screen, because compiling proves none of that: a form whose constructor fails half way still
builds, and opens empty.

What that does *not* prove is that a handler does the right thing — nothing clicks anything. Read
the code, then try it.

These need no hardware, no network and no control libraries — only Ilwaco and FreeBASIC.

They came from Astoria, Ilwaco's Windows sibling, where they were tested on 64-bit Windows 11. Two
changes were needed to make them build here: the `#cmdline "*.rc"` line each one carries is a
Windows resource step, and had to be put back behind `#ifdef __FB_WIN32__` — without the guard,
fbc stops with `Executable not found: "windres"`.

## The programs

| # | Project | What it shows | Files |
| --- | --- | --- | --- |
| 1 | [`01_HelloWindow`](01_HelloWindow/) | A window with a label and a button | `Main.frm` |
| 2 | [`02_LabelsAndText`](02_LabelsAndText/) | Changing what a label says and how it looks | `Main.frm` |
| 3 | [`03_TextBoxInput`](03_TextBoxInput/) | Reading a TextBox when a button is clicked | `Main.frm` |
| 4 | [`04_NumbersAndValidation`](04_NumbersAndValidation/) | Turning typed text into numbers, and checking it first | `Main.frm` |
| 5 | [`05_CheckBoxes`](05_CheckBoxes/) | A CheckBox is a Boolean the user can see | `Main.frm` |
| 6 | [`06_RadioGroup`](06_RadioGroup/) | A group of RadioButtons where choosing one clears the rest | `Main.frm` |
| 7 | [`07_ComboBox`](07_ComboBox/) | Filling a ComboBox and reading the choice | `Main.frm` |
| 8 | [`08_ListOfItems`](08_ListOfItems/) | Adding and removing rows in a ListView | `Main.frm` |
| 9 | [`09_DecisionsInAHandler`](09_DecisionsInAHandler/) | IF and SELECT CASE deciding what the window shows | `Main.frm` |
| 10 | [`10_LoopsFillAList`](10_LoopsFillAList/) | A FOR loop putting many rows into a ListView | `Main.frm` |
| 11 | [`11_ArraysBehindTheList`](11_ArraysBehindTheList/) | Keeping data in an array and the display separate | `Main.frm` |
| 12 | [`12_ProceduresInAModule`](12_ProceduresInAModule/) | Moving shared Subs and Functions into a module of their own | `Main.frm`, `Money.bas`, `Money.bi` |
| 13 | [`13_FunctionsAndReturn`](13_FunctionsAndReturn/) | Functions returning values into the window | `Main.frm` |
| 14 | [`14_Calculator`](14_Calculator/) | Buttons, state, and division by zero | `Main.frm` |
| 15 | [`15_TrackBarValue`](15_TrackBarValue/) | An event that carries a value with it | `Main.frm` |
| 16 | [`16_ProgressAndTimer`](16_ProgressAndTimer/) | Work that takes time, without freezing the window | `Main.frm` |
| 17 | [`17_ClockTimer`](17_ClockTimer/) | A timer updating the window once a second | `Main.frm` |
| 18 | [`18_SharedModule`](18_SharedModule/) | Why a module exists: code two windows both need | `Convert.bas`, `Convert.bi`, `Details.frm`, `Main.frm` |
| 19 | [`19_GroupsAndPanels`](19_GroupsAndPanels/) | GroupBox and Panel as containers | `Main.frm` |
| 20 | [`20_MenuAndStatusBar`](20_MenuAndStatusBar/) | The standard furniture of a real application | `Main.frm` |
| 21 | [`21_MessageBoxes`](21_MessageBoxes/) | MsgBox for information, warnings and questions | `Main.frm` |
| 22 | [`22_SecondForm`](22_SecondForm/) | Opening a dialog and getting an answer back | `Editor.frm`, `Main.frm` |
| 23 | [`23_OpenAndSaveFiles`](23_OpenAndSaveFiles/) | The standard file dialogs, and reading what they return | `Main.frm` |
| 24 | [`24_DrawingOnAForm`](24_DrawingOnAForm/) | Painting with a Canvas, and why you never keep what you drew | `Main.frm` |
| 25 | [`25_GuessTheNumber`](25_GuessTheNumber/) | A small game with its rules in a module | `Game.bas`, `Game.bi`, `Main.frm` |

## The ones with more than one file

Four projects are deliberately larger than one form, because a real program never is:

- **12_ProceduresInAModule** — a `.bi`/`.bas` pair holding code that has nothing to do with
  windows. This is where the mechanics are explained.
- **18_SharedModule** — *why* you would bother: two windows needing the same conversion, and
  one copy of it.
- **22_SecondForm** — a modal dialog, and reading its result before believing its value.
- **25_GuessTheNumber** — a game whose rules live in a module that could not care less whether
  there is a window at all.

A trap worth knowing before you write your own: **listing a `.bas` in the project is not what
compiles it.** The `.bi` ends by including its own `.bas` (guarded with `__USE_MAKE__`), which
is the convention every example in this repository uses. Without it the code compiles and then
fails at link time with *undefined reference* — the names are spelled correctly, the code
simply is not there.

## If something does not work

Two mistakes account for most GUI crashes, and both build cleanly:

- **`.Designer` must be set before `.OnClick`.** A control hands its Designer to the handler,
  so wiring an event without one crashes on the first click.
- **Match the handler signature to the control.** A `CheckBox` hands its handler a `CheckBox`,
  a `MenuItem` hands it a `MenuItem`. The wrong one compiles silently.
