# Examples audit — what actually builds and runs on Linux

## RESOLVED (2026-08-07) — the broken pre-existing examples were deleted

The audit below found that **every pre-existing example failed to compile on Linux** — they are
Windows programs. Per owner decision (2026-08-07) the **22 audited pre-existing projects were
removed** (`git rm`), together with **6 stale Windows-era duplicates** of the ported `Calculator`,
`FiveInARow` and `Maze` that lingered under `Examples/Game/`, and four empty placeholder dirs
(`FreeBASIC Examples`, `MariaDBBox Examples`, `MyFbFramework Examples`, `SQLite3 Examples`). The two
loose single-file examples at the `Examples/` root (`Class Form Example.bas`, and `try_catch_throw.bas`
— Win32 SEH, also Linux-broken) were **kept as porting candidates** and each moved into its own
directory; `Add-In/`, `Graphics/` and `Web Page/` likewise remain as un-audited candidates. Every
example now lives in its **own** directory.

`Examples/` therefore ships **only the 53 Astoria-ported projects, all of which build and run**, so a
beginner no longer meets a wall of compiler errors on first Build. The failure catalogue below is
retained as the **record of what was removed and why**.

| Half | Projects | Build | Run | State |
| --- | --- | --- | --- | --- |
| **Ported from Astoria (2026-08-07)** — `Learning/Console`, `Learning/GUI`, `Calculator`, `FiveInARow`, `Maze` | 53 | **53 / 53** | **53 / 53** | **ships** |
| **Pre-existing** — inherited with the VisualFBEditor base | 22 | **0 / 17** (5 had no project file) | not reached | **deleted 2026-08-07** |

Why it mattered: these examples **were installed for the user**. They travelled in the AppImage only
as a seed, and `AppRun` copies the tree out to `~/ilwaco-ide/Examples` on first run — a writable copy
the user owns, per the packaging decision that nothing user-facing runs from the read-only image. A
beginner — the audience Ilwaco is built for — would open one, press Build, get a wall of compiler
errors, and be unable to tell a Windows-only example from a mistake of their own. That is precisely
the failure the product standard in [CLAUDE.md](../CLAUDE.md) exists to prevent, which is why they were
removed rather than left to ship.

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

## What the audit did not tell us (now moot — they were deleted)

- **Nothing here was run**, because nothing built. The layout defects catalogued below were found
  in the *ported* half only.
- **`Bass`, `MediaPlayer`, `SerialPort`, `USBView`, `Radar` and friends may also have needed hardware
  or third-party libraries** even once ported. The build failure came first, so that question stayed
  untested — and is now moot, as they were removed rather than ported.
- Whether each example was *worth* porting was a separate judgement. Several taught Windows-specific
  material (taskbar progress, COM automation) with no GTK counterpart, which is why the decision was
  to delete rather than reimplement.

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

## What was decided and done (2026-08-07)

The owner chose **deletion over an exclusion list**: sources that cannot build are gone from the
repo, not merely held back from the release tree. Sequence:

1. **The 22 audited projects were `git rm`'d**, together with 6 stale Windows-era duplicates of the
   ported `Calculator`/`FiveInARow`/`Maze` under `Examples/Game/`, and four empty placeholder dirs.
2. **The remaining pre-existing bits were then re-evaluated** against a "delete unless the port is
   trivial" bar — trivial meaning the class of fix the 53 needed (an `#ifdef __FB_WIN32__` guard on
   `#cmdline "*.rc"`, a case-corrected include, a `crHand`→`crHandPoint` swap), not API substitution
   or reimplementation. Each was **test-compiled**, not guessed:
   - `try_catch_throw` — Win32 SEH (`windows.bi`, vectored handler): **deleted**.
   - `Add-In` — an IDE-plugin `.so` (not a runnable example), two near-duplicate copies, and
     `VisualFBEditor` branding: **deleted**.
   - `Web Page` — an MFF HTTP client+server demo with a `__FB_JS__` split and a missing `Form1.rc`,
     depending on unverified MFF `HTTP`/`HTTPServer` on GTK: **deleted**.
   - `Graphics/CanvasDraw` — compiled past the trivial case-fix only to hit `CreateDoubleBuffer` /
     `TransferDoubleBuffer` (Win32-GDI double-buffering absent from the GTK Canvas) and three
     `Style()`/`StretchImage()` overload mismatches: **deleted**.
   - `Class Form Example` — a minimal MFF form (CheckBox + CommandButton) that **compiled clean with
     zero changes**: **kept**, and finished into a real project (BOM stripped, a `.vfp` added) so it
     builds through the IDE.
3. The orphaned `Examples/Manifest.xml` (a Windows app-manifest referenced by nothing) was removed.

**Outcome:** `Examples/` ships **54 projects, every one build-verified** — the 53 Astoria-ported set
plus `Class Form Example` — each in its own directory. Nothing that fails to build remains.
