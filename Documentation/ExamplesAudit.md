# Examples audit — what actually builds and runs on Linux

Ilwaco's `Examples/` tree has two halves with opposite results, and the difference matters more
than anything else in this document:

| Half | Projects | Build | Run |
| --- | --- | --- | --- |
| **Ported from Astoria (2026-08-07)** — `Learning/Console`, `Learning/GUI`, `Calculator`, `FiveInARow`, `Maze` | 53 | **53 / 53** | **53 / 53** |
| **Pre-existing** — inherited with the VisualFBEditor base | 22 | **0 / 17** (5 have no project file) | not reached |

**Every pre-existing example fails to compile on Linux.** This was measured on 2026-08-07 by
building each `.vfp` with Ilwaco's bundled toolchain, and it is not a marginal failure: they are
Windows programs. Per the owner's direction this document is the **audit only** — nothing here has
been fixed.

Why it matters: these examples **are installed for the user**. They travel in the AppImage only as a
seed, and `AppRun` copies them out to `~/ilwaco-ide/Examples` on first run — a writable copy the user
owns, per the packaging decision that nothing user-facing runs from the read-only image. The effect is
the same either way: a beginner — the audience Ilwaco is built for — opens one, presses Build, gets a
wall of compiler errors, and cannot tell a Windows-only example from a mistake of their own. That is precisely the failure the product
standard in [CLAUDE.md](../CLAUDE.md) exists to prevent.

## How the pre-existing examples fail

Four groups, by root cause. None is a near miss.

**1. Direct Win32 API use.** The example calls Windows functions that do not exist on Linux.
- `MDIForm` — `InvalidateRect`, `UpdateWindow`
- `MDINotepad/FileSearch`, `MDINotepad/TimeMeter` — `QueryPerformanceFrequency`,
  `QueryPerformanceCounter`
- `MDINotepad/Text`, and everything that includes it (`AiAgent` ×2, `MDIScintilla`,
  `MDIScintillaControl`, `MDINotepad`) — `LCMAP_LOWERCASE`, `TextConvert`

**2. Windows headers pulled in directly.** These fail *inside* FreeBASIC's own `win/*.bi`, because
those headers assume a Windows target.
- `Download` — `win/wininet.bi` (`DWORD`, `DWORD_PTR`)
- `DeviceExplorer`, `MDINotepad/Hash` — `win/windef.bi`, `win/wingdi.bi`
- `PipeProcess` — `DWORD` in its own `.bi`

**3. COM / Windows-only interfaces.**
- `MDINotepad/FileSync` — `ITaskbarList3`, `HWND`

**4. Win32 types the GTK framework does not define.**
- `Game/Sudoku` — `Point`, `Rect`

**Five projects were skipped**, not failed — `Bass/netradio`, `DynamicControl`, `FileBrowser`,
`MediaPlayer` and `Radar`. Their `.vfp` names no main file, so there is nothing to build. They need
a manifest audit before anything can be said about them (see the `audit-project-manifest` skill);
this may be the cheapest group to recover.

## What this does not tell you

- **Nothing here was run**, because nothing built. The layout defects catalogued below were found
  in the *ported* half only.
- **`Bass`, `MediaPlayer`, `SerialPort`, `USBView`, `Radar` and friends may also need hardware or
  third-party libraries** even once ported. The build failure comes first, so that question is
  untested.
- Whether each example is *worth* porting is a separate judgement. Several teach Windows-specific
  material (taskbar progress, COM automation) with no GTK counterpart.

## Layout defects in the ported half

Found by screenshotting every GUI example rather than by checking that a window appeared — the
distinction that produced them. Cause in every case: absolute pixel layouts tuned to **Win32 font
metrics**. GTK's default font is wider, so a label given a fixed width wraps to a second line, and
that second line lands on whatever sits beneath it.

| Example | Defect | State |
| --- | --- | --- |
| `Learning/GUI/04_NumbersAndValidation` | label wrapped, misaligned with its text box | **fixed** — label widened |
| `Learning/GUI/12_ProceduresInAModule` | same | **fixed** |
| `Learning/GUI/13_FunctionsAndReturn` | same | **fixed** |
| `Learning/GUI/20_MenuAndStatusBar` | status bar rendered at the top | **fixed in MFF** — see below |
| `Calculator` | large dead area below the controls | **fixed** — laid out to fill |
| `FiveInARow` | "Chess Board Size" overlapped "Background:"; radio captions clipped; 31px spin box | **fixed** — panel 159px → 305px |
| `Maze` | size labels wrapped into their spin boxes; Refresh sat on the trackbar | **fixed** — column 120px → 235px |

Two reusable measurements came out of this:

- **GTK spin buttons need roughly 110px** to show both steppers, where the Win32 originals were
  given 31px.
- **MFF's GTK `Form` cannot be smaller than 350×300.** The constructor issues
  `gtk_widget_set_size_request(350, 300)` (`mff/Form.bas`), and on a toplevel that is a *minimum* —
  so a form declaring `290×210`, as `Calculator` did, renders at 350×300 with dead space. Laying
  the form out to fill 350×300 is the workaround; the framework behaviour is untouched and still
  open.

The status-bar case was a genuine framework bug rather than an example bug, and is fixed in MFF:
`gtk_statusbar_new` is an ordinary widget, so without an explicit `Align` it lands top-left, whereas
Win32's `msctls_statusbar32` positions itself. The GTK `StatusBar` constructor now sets
`Align = alBottom`. See [UpstreamFixes.md](UpstreamFixes.md).

## Suggested order, when this is picked up

1. **Decide what ships.** The cheapest honest fix is to stop shipping examples that cannot build —
   `Packaging/StageRelease.sh` already curates the release tree, so this is an exclusion list, not
   a deletion.
2. **Audit the five manifest-broken projects**, which may be trivially recoverable.
3. **Port selectively**, cheapest first (group 1 needs API substitutions; group 3 is probably not
   worth it), rather than attempting all 22.
