# Astoria → Ilwaco parity tracking

## Current status (2026-08-04)

**Foundation strips DONE** (build + runtime-verified; committed or staged): one bundled compiler / no
picker / no `[Compilers]` INI machinery (Tasks 11–13, `0fb1746` + staged); the **whole-tree non-target
strip** — `src/`, MFF, non-MFF `Controls/`, `Examples/` (`a0919c5`/`422e931`/`d0b22a1`/`0b61d0c`);
**32-bit removal** passes 1/2a/2b/2c (`a1b2722`/`12044a1` + staged); plus the owner directives UTF-8/LF-only,
English-only, and the Ilwaco rebrand. Per-task detail lives in the "Done" narratives below and in
[HISTORY.md](../HISTORY.md) / [PROJECT_STATUS.md](../PROJECT_STATUS.md).

**Active work: the changelog walk.** Bottom-panel collapse (`e212819d`/`ef3b43e9`) landed + live-verified
2026-08-04; `5fa5cf25` (alt-compiler-backend + debugger-choice removal, inverted to keep the Integrated
engine) **completed** 2026-08-04. For the current next item see **[Next action](#next-action)** at the foot of
this file — short version: next up are two found debugger bugs, then the `49ec5ccd`/`37ba31ea`
menu-taxonomy cluster.

**Examples: 53 ported from Astoria and verified on Linux (2026-08-07, owner-requested).** The whole
`Learning` course except its DLL series (`Console` 25 + `GUI` 25, the latter renamed from Astoria's
`WinGUI`, which is a misnomer on GTK), plus `Calculator`, `FiveInARow` and `Maze`. Every one was
compiled with the bundled toolchain **and run** — the console programs to completion, the GUI ones to
a window on screen. Copying alone was not enough; see [UpstreamFixes.md](UpstreamFixes.md) for the four
defects fixed on the way (three case-sensitivity bugs a case-insensitive filesystem had hidden, and
`crHand` → `crHandPoint`) and for the `#ifdef __FB_WIN32__` guard that had to be restored around every
example's `#cmdline "*.rc"` — an **INVERT** of Astoria's Win64-only stripping, without which no GUI
example builds. **Not ported:** the `Learning/DLL` series (blocked by an fbc `-gen gas64 -dll`
compiler crash — [TechnicalDebt.md](TechnicalDebt.md)), and the DirectShow / COM / SAPI / WLan /
`Sudoku` / `MultipleDisplay` examples, which are Windows by nature.

**Still-open, opportunistic (not blocking):**

**Deferred strip sub-items** (low-value / off the compiled path — do opportunistically, not blocking):
- `mff/win/` (Windows headers dir) — now only reached via the excluded `SysUtils.bi` WINAPI includes
  (unreachable on our build) and the opaque `#ifdef GIFPlayOn` block in `Animate.bi`; inert. Delete once
  `SysUtils.bi`'s WINAPI includes are hand-stripped and `GIFPlayOn` is understood.
- `Controls/Framework/inc/` (CopyArray/Thread/cJSON/mongoose/raylib/`pipe.bi`…) — **not on the build
  path** (no include from `mff.bi` or `src/`), so not compiled; strip or drop wholesale later. Note
  `inc/pipe.bi` *unconditionally* `#define __USE_WINAPI__` — excluded from the eliminator.
- Commented-out `'#ifdef` cruft (`Graphics.bas:15`, `Form.bas:672`, `Application.bas:239/250`,
  `Application.bi:18`) and the now-unused `#define nullptr 0` in `DarkMode/DarkMode.bi` — cosmetic sweep.

**Dark-mode REIMPLEMENT gap surfaced by the strip:** MFF already has a *real GTK3* `SetDarkMode`
(`gtk-application-prefer-dark-theme`; sets `g_darkModeEnabled`), so dark mode is NOT dead on GTK and the
`DarkMode/` subsystem was kept. **But** `g_darkModeSupported` is only ever set `True` by the (now-deleted)
Win32 `InitDarkMode`, so on GTK it stays `False` — every `If g_darkModeSupported AndAlso …` dark-styling
branch in the controls and the editor (`src/Main.bas`, `MD2RTF.bi`, …) never fires. Making GTK dark mode
*fully* effective (drive `g_darkModeSupported`/per-control theming from the GTK theme) is a REIMPLEMENT
item — track with Astoria's dark-mode work (`56f6d180`/`b3633bc5`/`a7c7839d`).

---

The resumable backlog for bringing Ilwaco (Linux/GTK) toward Astoria (Windows). Astoria's history is
the diff from the shared VisualFBEditor base, so we walk it oldest-first and classify each change.
Source of truth: `../astoria-ide/Documentation/DetailedChangelog.md` (888 commits, 2026-07-02 →
2026-08-02) and `../astoria-ide/Documentation/AstoriaIDESignificantChanges.md` (curated §1 added /
§2 removed / §3 inherited-defect fixes).

**Working backlog:** [AstoriaDetailedChangeLog.md](AstoriaDetailedChangeLog.md) is a *pruned* copy of
that changelog (2026-08-03: 888 → **401 actionable** entries; DONE ports + NONCODE/INVERT/WIN32/AI
non-actionable classes deleted — see its header rule and memory `project-changelog-backlog`). Walk it
oldest-first; when an item lands, delete its entry there and add a "Done" narrative here.

## Classification per change

- **PORT** — platform-neutral (UI/behaviour/warning/base fix); bring it over, adapting Win32→GTK.
- **REIMPLEMENT** — Astoria did it in a Windows-only way (uxtheme dark mode, Direct2D); Ilwaco needs
  its own GTK equivalent, not a copy.
- **INVERT / SKIP** — Astoria *removed* GTK/Linux/32-bit code because it is Win64-only. Ilwaco **is**
  the GTK build, so these are not ours to apply (often the opposite).
- **N/A** — docs-only, installer, or Windows-packaging commits with no Ilwaco analogue.
- **DONE** — already true in Ilwaco.

## Applicability of the 888-commit log (rough scan, 2026-08-02)

A large fraction does **not** port straight across:
- ~68 commits touch **GTK/Linux/32-bit stripping** — INVERT/SKIP (Ilwaco keeps GTK).
- ~13 commits are **Win32-specific** (uxtheme dark mode, Direct2D, ntdll, COM) — REIMPLEMENT or SKIP.
- ~37 commits are **docs-only** — N/A as ports.
- ~181 commit lines mention **panel/menu/toolbar/dialog/warning** — the richest vein of PORT work.

**Coverage of Astoria's *specific* deltas in Ilwaco today: a handful of ports in** (as of 2026-08-04 —
panel collapse, debug-tab visibility, bottom-panel tab clearing, compile-warning hunks; the foundation
strips above; see the "Done" narratives). It was **~none** at scan time. Ilwaco sits at ~upstream
VisualFBEditor **1.3.8** (only 643 lines from the "Newer" upstream copy). Astoria's base `bbfa3999` is
**two layers** on that same root: (a) a ~5,000-line pre-changelog **DeepSeek/Cursor** layer (where
`bApplyingStartupLayout`, `IsLeftCollapsed`, the panel-persistence machinery live) baked into the
import, then (b) the 888-commit Claude-era changelog. **No base matches Astoria's**, so ports are
**behavioural** (match the semantics), not patch application. Walking only the changelog **misses
layer (a)** — pull prerequisites from it as-needed; do not bulk-import it. Full detail:
assistant memory `project-astoria-base-provenance`.

Some Astoria *infrastructure* choices are independently already true in Ilwaco:
- **Bundled compiler in-repo** (Astoria `b5554063`) — Ilwaco ships `Compilers/FreeBASIC-1.10.1-linux-x86_64`. **DONE** (Linux equivalent).
- **Self-contained project layout** — largely shared from the base.

## Walk log (oldest first)

| Astoria commit | Change | Class | Ilwaco status |
|---|---|---|---|
| `bbfa3999` | Initial Win64 fork import | — | base (shared ancestor, different snapshot) |
| `e212819d` | Bottom panel **collapse-on-pin** (+ persistence, split out below); add PROJECT_STATUS | PORT | **DONE** — collapse-on-pin 2026-08-02; **bottom rail REIMPLEMENT DONE + live-verified** 2026-08-04 (dedicated rail, debug-button sync, debugger-toggle fix, CSS pin trim; persistence round-trips) ↓ |
| `c2672840` | Right panel not collapsing on Pin click | PORT | **DONE** 2026-08-02 (build-clean) |
| `64daa66e` | Left panel not collapsing on Pin click | PORT | **DONE** 2026-08-02 (build-clean) |
| `bef92671` | Form Designer never activating (strip-tool root cause) | N/A | **verified does NOT reproduce** 2026-08-03 — Astoria's cause was its own `strip_gtk_preprocessor.ps1` deleting `#ifdef __EXPORT_PROCS__` blocks; Ilwaco's `ppstrip.py` preserved them, `libmff64_gtk3.so` exports all 36 Designer.bas dispatchers (`nm -D`). See ↓ |
| `b5554063` | Bundle FBC + GDB toolchain in-repo | DONE | Ilwaco bundles Linux fbc (no gdb yet) |
| `15e66cc5`,`e139c2cc` | Remove 32-bit compiler binaries | SKIP | Ilwaco is 64-bit; no Win32 toolchain to remove |
| `53d8e473` | Fix all compile warnings (WStr wrapping etc.) | PORT (partial) | **DONE** 2026-08-03 — ported the 2 still-applicable `@literal→WString Ptr` hunks (`Debug.bas` `brk_comp`/`list_all`); rest N/A (already-stripped / doesn't reproduce). Build-clean. See ↓ |
| `4cf72752` | `_WIN32_WINNT` header bug + bottom-panel tab clearing | PORT (partial) | **DONE** 2026-08-03 — ported the tab-clearing (`ClearAnalysisPanels`/`ClearDebugPanels`, wired into `CloseProject` + debug-`End`); `_WIN32_WINNT` header fix N/A (Windows headers), AI-KnowledgeBase fix N/A (AI removed). Build+runtime-verified. See ↓ |
| `56f6d180`,`b3633bc5`,`a7c7839d` | Dark mode (uxtheme/ntdll Win32) | REIMPLEMENT | Ilwaco needs GTK dark mode (settings already have `DarkMode=true`) |
| `c494207f`,`7baebd1e`,`add4642a`,`76abaa5a` | Delete dead GTK/Linux/32-bit code | INVERT/SKIP | do **not** apply — this is Ilwaco's live platform |
| `ae74b31c` | Rename "Service"→"Tools" menu, inner "Tools"→"External Tools" | PORT | **DONE** 2026-08-02 (caption-only, internal names unchanged; `Main.bas` `miXizmat`) |
| `49ec5ccd`, §menu-taxonomy | UI approachability: per-menu **Advanced** submenus; menu reorg; caption cleanups; options-dialog simplification; **debug-tab visibility** (`SetDebugTabsVisible` — show the 7 debug tabs only when the debugger is enabled) | PORT (big) | **debug-tab-visibility sub-item DONE 2026-08-03** (see ↓); the rest (menu taxonomy etc.) still **deferred/re-scoped — see "Menu taxonomy" section below** |

## Done 2026-08-03 — debug-tab visibility (Astoria `49ec5ccd` sub-item + new MFF `DetachTab`)

Ported the "show the 7 debug tabs only while the debugger is enabled" behavior — Astoria's
`SetDebugTabsVisible`, extracted from the big `49ec5ccd` UI-evaluation cluster (the rest of which stays
deferred). Locals/Globals/Procedures/Threads/Watches/Memory/Profiler are now **detached** from the bottom
bar unless `UseDebugger` is on; **Immediate stays permanently visible** (matches Astoria). Build- +
runtime-verified both ways (screenshots): `UseDebugger=false` → bottom bar ends at Immediate;
`UseDebugger=true` → all 7 re-appear in order, no crash, no blank tabs.

**Framework dependency (REIMPLEMENT for GTK).** The feature needs a tab that can be removed from the bar
*without destroying its `TabPage`* so it can be re-added. Astoria added a new MFF method `DetachTab` (Win32);
Ilwaco's MFF had only `DeleteTab` (destroys). Ported `DetachTab` into our MFF fork
(`Controls/Framework/mff/TabControl.bi` + `.bas`):
- It clears `FDynamic` across the removal so `DeleteTab` doesn't free the page (same trick as Astoria), **and**
- on GTK, `gtk_notebook_remove_page` (inside `DeleteTab`) drops the notebook's reference to the page widget,
  which would finalize it — so `DetachTab` takes an extra `g_object_ref(G_OBJECT(Value->widget))` first,
  the **same idiom `Control.BringToFront`/`IsChild` already use** when reparenting. `AddTab(tp)` rebuilds the
  tab-label widgets on re-add, so the cycle is self-contained. Additive + non-virtual → **no `.so` rebuild**
  (the designer control lib doesn't call it; the editor compiles the MFF source directly).

**Editor wiring (`src/Main.bas`).** Three subs after `ClearMessages()`: `RemoveBottomDebugTab`/
`AddBottomDebugTab` (guard on `tp->Parent`) and `SetDebugTabsVisible(bVisible)` (static idempotency guard;
add/detach the 7 pages). Call sites: `SetDebugTabsVisible False` at construction (top-level module code just
after `ptabBottom` is wired); `SetDebugTabsVisible UseDebugger` in `frmMain_Show` (startup, after settings
load), `ChangeEnabledDebug`, and `ChangeUseDebugger bUseDebugger` (the live toolbar/menu toggle); and
`If Not UseDebugger Then SetDebugTabsVisible False` as a backstop at the end of `ClearDebugPanels`
(whose 3 caption resets are now `tp->Parent`-guarded, since a detached tab has no parent). All callers are
in `Main.bas` after the definitions, so no `Main.bi` forward-declare is needed.

## Done 2026-08-03 — bottom-panel/debug tab clearing (Astoria `4cf72752`, partial)

Astoria's `4cf72752` bundled three things; only one is a port here:
- **`_WIN32_WINNT` header fix** (116 `=`→`>=` across `Compiler/inc/win/*.bi`, the exact-equality
  Windows-version gate that hid Win8.1+ APIs) — **N/A.** Those are Windows platform headers; Ilwaco's
  Linux/GTK user-project compiles never include them.
- **AI KnowledgeBase reference-doc path fix** — **N/A** (Ilwaco removed the AI subsystem).
- **Bottom-panel / debug tab clearing** — **PORTED.** A real UX-robustness fix: previously the bottom
  panels kept results from a closed project (Output/Problems/Suggestions/Find/ToDo/Change Log) and stale
  debug state (Locals/Globals/Procedures/Threads/Watches/Memory/Profiler/Immediate), so after closing one
  project and opening another the panes showed misleading leftovers — exactly the "beginner can't tell a
  stale tool from their own mistake" trap the product standard targets.

What landed in Ilwaco (line-for-line from Astoria, against verified-identical control types):
- **`src/Main.bas`** — two new subs after `ClearMessages()`: `ClearAnalysisPanels()` (clears the 6 analysis
  panels + resets their tab captions via `ML(...)`, and `mLoadLog`/`mLoadToDo`) and `ClearDebugPanels()`
  (clears the 8 debug panels; calls `ClearThreadsWindow`). Both are invoked from `CloseProject` before
  `ChangeMenuItemsEnabled`.
- **`src/Main.bi`** — forward-`Declare Sub ClearThreadsWindow()` (it's defined in `ilwaco.bas`, but
  `Main.bi` pulls in `Main.bas` first, so `ClearDebugPanels` needs the declaration in scope).
- **`src/ilwaco.bas`** — `ClearDebugPanels` at the end of the debug-`End` case in `mClick`, so the debug
  panes clear when a session ends.

Verified: control types confirmed (`ListView`→`.ListItems`, `TreeListView`/`TreeView`→`.Nodes`,
`TextBox`→`.Text`); `fbc` exit 0, zero warnings; the IDE launches clean and all 14 bottom tabs render
(screenshot). Matched Astoria's actual diff (calls in `CloseProject` + debug-`End` only; its comment names
`CloseSession` as intent, but `CloseProject` runs during session close and the commit wired nothing else).
The end-to-end clear (open → populate → close → panes empty) was not independently UI-driven here; it is a
faithful port of Astoria's owner-verified code.

**⚠ This is *not* the "debug tabs only show when a session is active" behavior.** That is a **distinct**
change — Astoria's `SetDebugTabsVisible(bVisible)` (from `49ec5ccd`) — **now also ported, 2026-08-03**; see
"Done — debug-tab visibility" below. It is orthogonal to this content-clearing.

## Done 2026-08-03 — compile-warnings port (Astoria `53d8e473`, partial)

Astoria's `53d8e473` made its build warning-clean, fixing three kinds of thing:
1. `@"literal"` passed where a `WString Ptr` is expected (FB types a bare literal as `ZString`, so the
   pointer type mismatches — `warning 4: Suspicious pointer assignment`) — in `Canvas.bas` and `Debug.bas`.
2. `SelectSearchResult`'s `SearchText As WString = ""` default (a decl/def-mismatch warning) — `Main.bas`
   + `TabWindow.bi`.
3. A `ptabBottom->TabPosition = tpBottom AndAlso …` chain flagged "mixed boolean and non-boolean operands"
   — `Main.bas`, fixed by isolating the comparison into a `Boolean` local.

**Ilwaco's production build was already warning-clean** (`build-linux.sh`, default `-w`, gas64 backend —
a full editor compile emits zero fbc output). Applicability, item by item:
- **(1) Canvas.bas `@"en-us"`** — inside the Direct2D block Ilwaco already deleted in the MFF strip. **N/A.**
- **(1) Debug.bas `SetConsoleTitle(StrPtr(...))`** — Win32 console code, already gone. **N/A.**
- **(1) Debug.bas `brk_comp` (6 `Return @"…"`) + `list_all` (6-element `@"…"` `WString Ptr` array)** —
  platform-neutral shared code, still present. These are genuine `ZString→WString Ptr` mismatches (they
  emit `warning 4` when the code is compiled in isolation). **PORTED** — wrapped each with `WStr(...)`.
- **(2) `SelectSearchResult`** — Ilwaco's decl (`TabWindow.bi`) and def (`Main.bas`) already match, and the
  `ByRef … As WString = ""` default does not warn here even at `-w pedantic`. **N/A (does not reproduce).**
- **(3) `tabBottom` comparisons** — Ilwaco's older base uses `And` (integer), not Astoria's `AndAlso`
  boolean chain, so the "mixed boolean/non-boolean" warning does not arise. **N/A (does not reproduce).**

Net Ilwaco change: `src/Debug.bas` only (12 `Return` operands + 1 array literal). Build-verified clean
(`fbc` exit 0, zero output; fresh `./ilwaco`). Not runtime-verified by launch: the change is type-only on
the integrated debugger's internal label helpers (exercised only under gdb, which isn't installed here) and
renders identical text — build-clean is adequate.

## N/A 2026-08-03 — Form Designer export table intact (Astoria `bef92671` does not reproduce)

Astoria's `bef92671` fixed a **dead Form Designer**: its `Tools/strip_gtk_preprocessor.ps1` had no
awareness of `__EXPORT_PROCS__` (unconditionally `#define`d in `mff.bi` to gate the DLL export layer),
so it evaluated every `#ifdef __EXPORT_PROCS__` block as false and deleted them — shipping `mff64.dll`
with zero exports, so every `DyLibSymbol()` in `Designer.bas` returned null and the designer never
activated.

**This is Astoria-tooling damage, not a base defect** — Ilwaco never ran that PowerShell tool. Verified
empirically that it does not reproduce here:
- Ilwaco's MFF source still contains the `#ifdef __EXPORT_PROCS__` blocks (`ppstrip.py` treated
  `__EXPORT_PROCS__` as opaque/defined and preserved every one).
- The built `Controls/Framework/libmff64_gtk3.so` exports **469** text symbols, including all four
  core dispatchers (`CreateComponent`, `CreateControl`, `ReadProperty`, `WriteProperty`).
- **Definitive test:** all **36** symbols `src/Designer.bas` resolves via `DyLibSymbol()` are exported —
  `comm -23 <wanted> <exported>` is empty. (Astoria's broken build had only 56/58.)

Verify command (re-runnable):
`comm -23 <(grep -oE 'DyLibSymbol\([^,]*,\s*"[^"]*"' src/Designer.bas | grep -oE '"[^"]*"$' | tr -d '"' | sort -u) <(nm -D --defined-only Controls/Framework/libmff64_gtk3.so | awk '$2=="T"||$2=="W"{print $3}' | sort -u)`

Pruned from the changelog backlog. (Runtime end-to-end designer-activation — cboClass populates,
Form/CodeAndForm buttons enabled, Properties panel renders — remains a general "verify by effect" item,
but the specific export-table root cause of `bef92671` is conclusively absent.)

## Done 2026-08-02 — removed legacy Error Handling + Line Numbering (Astoria `ec42ea83`)

First feature-driven menu change. Astoria removed both together as "legacy line numbering, On Error
helpers". In Ilwaco they shared the mislabeled `miTry` "Error Handling" submenu. **Rationale (owner):**
the line-numbering *toggle* was dropped because **line numbering became the standard** — this removed
only the legacy "insert line numbers into the source" machinery (which old `On Error Goto <n>` needed),
**not** the editor's gutter line-number *display*, which is a separate EditControl setting and stays. Removed **~500 lines
across 5 files**, build-verified clean:
- `Main.bas` — the `miTry` submenu, its toolbar dropdown, the `Dim Shared` menu-pointer declarations,
  and the `->Enabled` block.
- `VisualFBEditor.bas` — the numbering thread handlers, `NumberOn/Off`/`OnError*` handlers, enable-list
  entries, and a commented-out `OnErrorResumeNext`.
- `TabWindow.bas` — 483 lines of workers: `NumberingOn/Off`, `PreprocessorNumbering On/Off`,
  `GetProcedureLines`, member `NumberOn/Off`, `Procedure/PreprocessorNumberOn/Off`, `SetErrorHandling`,
  `RemoveErrorHandling`, `NumberingProject/Module`, plus a project `->Enabled` block.
- `TabWindow.bi` — the matching declarations.
- **Kept:** FreeBASIC `Try/Catch` language construct (`C_Try`, EditControl.bas).

**Removal-process lessons (for the next feature removal):** grep **all** src files (not just Main.bas)
for (a) command-name strings, (b) function/method names, **and (c) the `mi*/dmi*` menu-pointer
variable names** — the last were missed and caught by the compiler in `TabWindow.bas`. Also watch
**shared `Var` declarations**: `tbButton` was declared in the deleted toolbar block but reused later
(the "Use" dropdown), so its declaration had to be re-homed. The `fbc` build is the real safety net —
it flagged both; grep alone did not.

**Spotted in passing (future strip-windows item):** `Main.bas` "Use → WinAPI" toolbar dropdown
(Windows NT/2000/XP/Vista/7/8, `_WIN32_WINNT`) is Windows-only — remove on the GTK build. See
[[project-strip-windows-code]].

## Done 2026-08-02 — removed "Close Folder" (Astoria `ec42ea83`, cont.)

Second item from `ec42ea83`. Astoria dropped the folder-based "Close Folder" command (project-based
workflow). Removed from Ilwaco, build-clean, **no compiler stragglers** (all-files sweep upfront):
`Sub CloseFolder` (Main.bas 1613–1637, single caller), the File-menu item + `HK("CloseFolder","Alt+F4")`,
the `miCloseFolder` `Dim Shared` entry, the `->Enabled` line (TabWindow.bas), the `Case "CloseFolder"`
handler (VisualFBEditor.bas), and 3 stray commented `'miCloseFolder` lines. `ec42ea83` also dropped
"bundled 32-bit tools" (N/A — Ilwaco is 64-bit).

## Done 2026-08-02 — removed the "Use" target-selector dropdown (matches Astoria final)

Astoria removed the whole "Use" toolbar dropdown (target-define selector: WinAPI + Windows-version
targets, GTK/GTK2/3/4, JNI/Android, WASM) — no `mClickUseDefine` survives there. Owner confirmed the
same for Ilwaco (single-target GTK, opinionated design). **First task delegated to a Sonnet worker**
per [[feedback-delegate-mechanical-to-sonnet]] (I scoped; Sonnet executed). Removed: the toolbar block
(`Main.bas`), the `mClickUseDefine` handler (`VisualFBEditor.bas`) + its `Main.bi` declaration, and
`miUseDefine` from the `Common Shared` line. Re-homed the shared `Var tbButton` onto the build-config
button (same trap as the Error-Handling removal). Build-clean.

**Kept (deliberate):** the `UseDefine` global (`Main.bi`) and its build-path consumers
(`TabWindow.bas` ~12100–12109 preprocessor-target checks, ~12202 `-d` append). With the selector gone
`UseDefine` is always `""`, so those are no-ops/False — harmless, no build-logic change. **Follow-up
(deeper cleanup):** since Ilwaco is always GTK3, the `__use_gtk3__` target check could be hardcoded
True and `UseDefine` retired — a build/parse-logic refinement, separate from this UI removal.

**Delegation note:** the Sonnet worker's *edits* were correct, but its *build* kept getting SIGTERM'd
(never a real error) and it didn't report a final status — I ran the confirming build myself. Next time,
tell the worker to run the build via a mechanism that survives (background job) and to report the log.
**Superseded rule (2026-08-02):** don't have workers build at all — a worker does the edits and hands
back to Opus for compilation, so it never has to load the toolchain shim (memory
`feedback-worker-returns-for-compilation`).

## Done 2026-08-02 — removed the Help ▸ GitHub submenu (Astoria `d275dc93`)

Astoria dropped the Help ▸ GitHub submenu (repo/wiki/discussions links for FreeBasic, VisualFBEditor,
Framework). Removed the same from Ilwaco, build-verified clean. Scope was exactly as pre-scoped —
an all-files grep of the command strings found them only in the two edited locations (no `.lang`,
HotKeys.txt, `.bi` decls, or enable-lines):
- **`src/Main.bas`** — the whole `Var miGitHub = miHelp->Add(ML("GitHub"))` block (the submenu + its 8
  items + 2 separators). Kept the two FreeBasic WiKi/Forums items above it and the separator / Tip of
  the Day / About below.
- **`src/VisualFBEditor.bas`** — the 8 `Case` handlers, including the orphan `GitHubWebSite`. **Kept
  `OpenUrl`** (still used by FreeBasicForums/FreeBasicWiKi and other Help commands).

Done directly by Opus (edit is trivial once scoped); no worker needed. `HK(...)` calls for removed
commands just returned empty and had no HotKeys.txt entries, so removing the callers was safe.

## Done 2026-08-02 — removed the Direct2D user option (Astoria `DIRECT2D_REMOVAL.md` §1, Phase 1)

Astoria removed Direct2D entirely (owner decision: it had been force-disabled the whole time, zero
real-world verification, didn't fit "no unnecessary options"). Ilwaco's situation is sharper: on the
GTK build the **entire Direct2D render path is already `#ifdef __USE_WINAPI__`-gated and never compiled**
— only the *toggle* (a "Use Direct2D (For Windows)" toolbar button + Options checkbox + settings key)
was live-but-useless. Removed that toggle, **build-verified clean** (fbc exit 0, no warnings):
- `Main.bas` — `tbtUseDirect2D` (shared-list decl + button add + the `Var b`/`Checked`/restore dance),
  the `imgList.Add "UseDirect2D"`, and the ungated `UseDirect2D = iniSettings.ReadBool(...)` load.
- `VisualFBEditor.bas` — the ungated `Case "UseDirect2D"` dispatch.
- `frmOptions.frm` (via **edit-form-safely**) — the `chkUseDirect2D` designer block + its load/save/
  WriteBool references. `frmOptions.bi` — `chkUseDirect2D` out of the shared `Dim As CheckBox` list.
- `Settings/VisualFBEditorX64_gtk3.ini` — dropped `UseDirect2D=true` (an `[Options]` key, safe).

**Phase 2 re-scoped (do NOT treat as a Direct2D task):** the editor's remaining Direct2D lives inside
EditControl's whole Windows branch (23 `#ifdef __USE_WINAPI__` blocks + 137 `#ifdef __USE_GTK*…#else…
#endif` pairs, ~2,135 lines, GDI+D2D interleaved) and is inseparable from it. Retargeted as **staged
task A** at the top of this file (full EditControl WINAPI strip). MFF's Direct2D is **staged task B**.

## Done 2026-08-02 — whole-tree non-target strip (src + Controls + Examples)

After MFF (task B) and the full `src/` strip (both build- + runtime-verified), the owner asked to extend
the strip to **all** of `src`, `Controls`, `Examples` ("removing all the cruft made subsequent edits much
simpler when developing Astoria"). Landed:
- **`src/`** (`a0919c5`) — 11 files, 626 chains; editor builds clean + runtime-verified. No src file
  defines the truth symbols and `inc/pipe.bi` is not in the editor TU, so the `-d __USE_GTK3__` table holds.
- **Non-MFF `Controls/`** (`422e931`) — MariaDBBox, SQLite3, ScintillaControl, cJSON (11 files, 28 chains).
- **`Examples/`** — cross-platform demos branch-stripped (`422e931`, 10 files); **16 Windows-only demos
  deleted** (`d0b22a1`): directshow, directsound, MediaFoundation, Midi, Sapi, WMI, WLan, Com_VBA,
  WellCOM Example, IFileDialog, gdipClock, gdipGoldFish, ChineseCalendar, MultipleDisplay, NTPClient,
  AndroidProject. **Astoria kept its whole Examples/ tree** (it is the Windows build); the mirror for the
  GTK build is to keep the runnable demos and drop the Windows-only ones (dead code on Linux).
- **Caveat:** `Controls/` and `Examples/` are **off the Ilwaco build path**, so those strips are not
  IDE-build-verified — the eliminator was run conservatively (compiler-builtin `__FB_WIN32__` guards are
  safe anywhere; `__USE_*` guards under the GTK-target assumption) and every edit was subsequence-checked.

## Done 2026-08-02 — MFF non-target strip (staged task B) — build-verified

The framework-wide non-target strip. **~134,600 lines removed across 274 files** (91 files deleted):
the MFF control-code strip is **198 files / ~41,250 lines** (incl. 14 whole-file deletions); the
`gir_headers/` GTK4 binding tree is another **77 files / 93,349 lines**. Both artifacts rebuild **clean**
(`fbc` exit 0, zero warnings): the editor (`VisualFBEditor64_gtk3`) and the designer control lib
(`libmff64_gtk3.so`). The compiled surface now has **zero** real non-target `#if`/`#ifdef` directives
(WINAPI dropped 954 → 0 outside the 3 excluded derivation files); residual guard tokens are only in
commented cruft or the derivation files.

**Method (durable — a superset of the task-A eliminator).** Unlike EditControl, MFF has `#elseif`
chains and `#if`-*expressions* (`defined()`, `AndAlso`/`OrElse`/`Not`, `_WIN32_WINNT` comparisons), so
the eliminator (`scratchpad/ppstrip.py`) was extended to a full recursive-descent parser:
- **Ground-truth symbol table, not guesses** — probed the compiler under `-d __USE_GTK3__` with MFF's
  own `SysUtils.bi` preamble. **Defined:** `__USE_GTK__`, `__USE_GTK3__`, `__FB_LINUX__`, `__FB_UNIX__`,
  `__FB_64BIT__`, **`__USE_CAIRO__`** (SysUtils.bi `#define`s it whenever `__USE_GTK__`). **Undefined:**
  `__USE_GTK2/4__`, `__USE_WINAPI__`, `__FB_WIN32__`, `__USE_JNI__`, `__FB_ANDROID__`, `__FB_JS__`,
  `__USE_WASM__`, `__FB_DARWIN__`, `__USE_WEBKITGTK__`, `__USE_GDIP__`, `__FB_ARM__`. **Opaque (never
  evaluated, blocks left intact):** `pango_version`, `PANGO_VERSION`, `UNICODE`, `__USE_MAKE__`,
  `_WIN32_WINNT`, and any unlisted symbol (e.g. the `GIFPlayOn` feature toggle).
- **Conservative by construction:** a chain is collapsed only if *every* branch condition is known; any
  opaque condition leaves the whole chain intact but still recurses into its branches (so nested known
  blocks inside an opaque one are still stripped). It only ever *deletes* whole lines — verified each
  edited file is a strict line-**subsequence** of the original (166/166, then the rest).
- **Exclude list (must NOT strip — they *define* the truth):** `mff/mff.bi`, `mff/SysUtils.bi`,
  `inc/pipe.bi` (`SysUtils.bas` turned out safe and was stripped). Stripping `SysUtils.bi` would delete
  the very `#define __USE_GTK__`/`__USE_CAIRO__` the table depends on.
- **Traps hit & fixed:** (a) UTF-8 **BOM** on line 1 hid a leading `#ifdef` (WebKitWebView.bi,
  SystemInformation.bi) — parser made BOM-aware (preserve, don't add/remove). (b) A trailing `'comment`
  on `#ifdef __USE_WINAPI__ '…` (TreeView.bi) got swallowed into the operand — now takes the first
  identifier token only. Build-checkpointed in chunks (top-level → subdirs → SysUtils.bas/gir), `.so` +
  editor rebuilt clean after each.

**Whole dirs/files deleted (non-target, orphaned after the include-strip):** `mff/Android/`,
`mff/D2D1/`, `mff/CDataObject/`, `mff/CDropSource/`, `mff/CDropTarget/` (COM drag-drop), `mff/Web/`
(WASM/JS export shell), `mff/gir_headers/` (GTK4 bindings, 6.2 MB — included only under `#ifdef
__USE_GTK4__`), and files `WebView/WebView2.bi`, `DarkMode/IatHook.bi`, `DarkMode/UAHMenuBar.bi`.
**Kept:** `WebView/WebKitWebView.bi` (GTK), `DarkMode/DarkMode.bas`+`.bi` (live GTK `SetDarkMode`),
`fbsound/` (cross-platform), the `gtk/gtk.bi`+`glib-object.bi` GTK3 includes in `SysUtils.bas`.
**Manifest:** removed 16 dangling `File=` entries from `Framework.vfp` (the deletions + 6
pre-existing dangling entries like `ColorDialog.bi`/`.gitignore`; it is a flat list, not index-keyed).

Direct2D is fully retired from MFF too (the `D2D1/` tree + `Canvas` D2D branches went with the strip).
Dark-mode REIMPLEMENT gap: see NEXT ACTION above.

## Done 2026-08-02 — full `EditControl.bas`/`.bi` non-target strip (staged task A)

The single largest strip in `src/`. **`EditControl.bas` 9405 → 6582 lines, `EditControl.bi` 845 → 764**
(−2,904 total). Every non-target branch deleted (Windows GDI+Direct2D, GTK2), the target-GTK guard
wrappers collapsed, and the commented-out `'#ifdef …` cruft blocks removed. **Build-verified clean** at
every step (fbc exit 0, zero warnings) and the IDE **launches to a fully-loaded editor** (menus, panels,
"IntelliSense fully loaded"); no crash.

**Method (durable — reuse for task B and any large guard strip):** all conditionals in the file were
**single-symbol** `#ifdef`/`#ifndef` with **no `#if`-expressions and no `#elseif`**, so a *correct
guard-evaluating* eliminator (not blind `#else` deletion) was safe. Truth table on the `-d __USE_GTK3__`
build (auto-derived in `mff/SysUtils.bi`): `__USE_GTK__`,`__USE_GTK3__`,`__FB_64BIT__` = **defined**;
`__USE_WINAPI__`,`__FB_WIN32__`,`__USE_GTK2__`,`__USE_GTK4__`,`__USE_JNI__`,`__USE_WASM__`,`__FB_DARWIN__`
= **undefined**. Left fully opaque: `pango_version`/`PANGO_VERSION` (GTK/pango API version checks) and
`__USE_MAKE__` (build-mode, not platform). Done in **two build-checkpointed phases**: **A** = delete the
directly-non-target-guarded blocks (`__USE_WINAPI__`/`__FB_WIN32__`/`__USE_GTK2__`/`#ifndef __USE_GTK__`),
leaving the positive GTK wrappers; **B** = collapse `#ifdef __USE_GTK__`/`__USE_GTK3__` (keep body, drop
their Windows/GTK2 `#else`). The eliminator + a nesting-aware balance checker are in scratchpad
(`ppstrip.py` / `ppmap.py`). No typo'd guards were present in this file.

**Also dropped (finishing the Direct2D retirement):** the now-unused ungated `UseDirect2D` global
(`EditControl.bi`), and the two dead `#ifdef __USE_WINAPI__` D2D init blocks in `Main.bas`
(`LoadD2D1`/`UnloadD2D1`/`g_Direct2DEnabled`). Zero D2D/`ID2D1`/`pRenderTarget` references remain in
`src/`. **In-file guards remaining:** only the 6 legitimate pango version-checks.

## Done 2026-08-02 — compiler path hard-coded, no picker dialog (opinionated design, stage 1)

Owner direction: *"The compiler path should be hard coded into the system, there is no choice anymore."*
The bundled FreeBASIC is now **the one compiler**, hard-coded and resolved relative to the executable so
it travels inside the AppImage. **Build-verified clean; the IDE now starts straight to the editor with no
"Invalid defined compiler path / Find Compilers from Computer?" dialog** (the standing first-run blocker
noted in PROJECT_STATUS is gone).
- `Main.bi` — new `#define BundledCompilerPath "./Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"`
  (`GetFullPath` turns the leading `./` into `ExePath & …`).
- `Main.bas` `LoadSettings` (~6851) — `Compiler32Path`/`Compiler64Path` now assigned from
  `BundledCompilerPath` instead of the INI `Compilers.Get(...)` lookup. **The fragile `[Compilers]` INI
  parse loop is untouched** (it reads 10 sections keyed by one index and crashes if restructured —
  PROJECT_STATUS); `CurrentCompiler64` is still read so the per-compiler *argument* template
  (`CompilerTool`, ~686) still resolves. Include-path derivation follows the hard-coded path automatically.
- `Main.bas` — deleted `Function CheckCompilerPaths` (the startup validator that showed the dialog) and
  set its one call site `bSharedFind = True` (the compiler is now always present).

**Stage 2 (pending — "no choice" completion, its own session):** remove the *picker UI* — the Options ▸
compilers list + "Find Compilers from Computer" button (`frmOptions`), the per-project `CompilerPath`
override (build branch `Main.bas:612-613`, `frmProjectProperties` `txtCompilerPath`, `.vfp` `CompilerPath`
parse/save), and — carefully — the now-vestigial `[Compilers]` INI machinery (the fragile 10-section loop
must be refactored, not just deleted). Landing stage 1 first keeps each change build-checkpointed.

## Menu taxonomy — the surface of feature-parity, not a standalone task

Established 2026-08-02 by comparing **final** menu states (method: port to Astoria's final state, not
replay commits — the menus saw churn incl. added-then-removed Advanced submenus). Top-level delta:
Ilwaco `File, Edit, Search, View, Project, Format, Build, Debug, Run, Tools, Window, Help` →
Astoria `File, View, Project, Code, Code/Form, FormFormat, Run, Tools, Window, Help`
(Edit→Code, Search folded into Code, new Code/Form, Build+Debug consolidated into Run, reorder,
Advanced submenus).

**Key finding — menu changes are driven by feature changes, so they cannot be done as an upfront
menu pass.** The Code menu alone (Ilwaco Edit+Search vs Astoria Code) decomposes into:
- **Remove** (options Astoria dropped): the **Error Handling** cluster (`OnErrorGoto*`,
  `OnErrorResumeNext`, `OnLocalErrorGoto*`, `Try`, `RemoveErrorHandling`) and most **Line Numbering**
  macro variants (~20 `*NumberOn/Off`). Remove the *feature*, and the menu item goes with it.
- **Add** — needs the **feature** ported first: code folding (`CollapseAll`/`Fold*`), text conversion
  (`ConvertTo*case`, hex/unicode), line ops (`SortLines`/`CombineLines`/`SplitLines`), split view
  (`Split{Horizontally,Vertically}`), `SyntaxCheck`, `AnalyzeSuggestions`, `FormatWithBasisWord`.
- **Relocate:** `Cut/Copy/Paste/Undo/Redo/SelectAll` → Code/Form; `AddProcedure/AddType` → into Code.
- **Fold in:** the whole Search menu.

**Method going forward:** drive menu edits **from the feature-parity walk** — when a feature is ported,
add its menu entry; when an option is removed ([[project-opinionated-design]]), delete its entry. Only
pure cosmetic **renames** with unchanged contents are safe standalone (done: `ae74b31c` Service→Tools).
Do **not** pre-reorganize menus ahead of the features (would create dead entries — violates the mantra).
| `4bd02894` | "No unnecessary options" guiding principle | PORT (policy) | matches Ilwaco's opinionated-design goal |

*(Table continues as the walk proceeds.)*

## Done 2026-08-02 — panel collapse-on-pin (e212819d/c2672840/64daa66e, behaviour half)

Replaced the three one-line `Pin{Left,Right,Bottom}` handlers in `src/VisualFBEditor.bas` (mClick
`Select Case`) with the Astoria one-click-collapse pattern: when the panel is expanded
(`spl{Left,Right,Bottom}.Visible`), uncheck the pin and call `Set{…}ClosedStyle True, True` so it
collapses to the tab strip in one click instead of only restyling and waiting on a later focus change.
Ilwaco's `Set{…}ClosedStyle(Value, WithClose)` already honoured `WithClose` (`If WithClose Then Close…`),
so no `Main.bas` change was needed for the behaviour. **Build-clean** (0 errors/0 warnings); live
click-through not yet exercised (per owner's steer against chasing the runtime now).

### Deferred, split out: bottom-panel *persistence* (rest of e212819d)

**Superseded 2026-08-04** — see "Done 2026-08-04 — bottom-panel collapse via a horizontal activity
rail" below; the bottom rail landed and persistence round-trips. The note below is the original plan.

The other half of `e212819d` — remembering collapsed-vs-closed state across restart — is a separate,
riskier change and is **not** done. It needs infrastructure Ilwaco's older base lacks: `IsBottomCollapsed`
(+ Left/Right), `bApplyingStartupLayout`, `SaveMainWindowPanelLayout`, the `*Collapsed` INI keys, and
`UpdateBottomPinLayout` / `MIN_BOTTOM_PANEL_HEIGHT` / `BOTTOM_PIN_STRIP_WIDTH`, plus edits to
`frmMain_Create`/`frmMain_Show`/`frmMain_Close`. Track as its own item; do after more of the panel
infrastructure is understood. Ilwaco's `CloseLeft/Right/Bottom` also still carry `#ifdef __USE_GTK__ …
#else …` branches — strip the `#else` (Windows) side when this work touches them.

## Done 2026-08-04 — left/right panel collapse via a vertical-text "activity rail" (GTK REIMPLEMENT)

Owner asked to make the **left/right tool panels collapse and reopen** with a **visual** affordance,
not a menu, and — refined 2026-08-04 — for the collapsed strip to **look like Astoria's** thin
**vertical-text** tab strip (rotated captions) with a **pin at the top**. This is a **GTK REIMPLEMENT**,
not an Astoria port: Astoria's Win32 collapse-to-vertical-tab-strip cannot reuse the GTK notebook — a
notebook always paints its current page, so the panel can't shrink while shown, and a left/right-docked
panel collapses to zero once its notebook is hidden. **Solution:** on collapse, hide the panel entirely
and show a separate, always-visible **rail** at that edge — a thin (34px) vertical strip whose buttons
reopen the panel to a specific tab.

**Rail contents (the Astoria look, `src/Main.bas`):** MFF renders **no icon** on a `CommandButton` or
`Label` on GTK (their `GraphicChange` is an empty stub), and nothing in MFF rotates toolbar text — so an
"icon + text" rail is impossible without custom raw-GTK widgets, and MFF `Panel` is a `GtkLayout`
(absolute positioning) that fights raw children. Owner chose **vertical text only**. Each rail holds:
- **Pin at top** — a one-button `ToolBar` (`tb{Left,Right}RailPin`) with the `"Pinned"` icon, reusing the
  `"PinLeft"/"PinRight"` mClick command (while collapsed → re-expands to the last tab). A single toolbar
  button collapses to an overflow chevron in a 34px strip, so `gtk_toolbar_set_show_arrow(…, FALSE)`
  forces the icon to draw.
- **Tab buttons** — `CommandButton`s (`btn{Left,Right}Rail{Project,Toolbox/Property,Event}`) whose
  captions are rotated with `gtk_label_set_angle(GTK_LABEL(gtk_bin_get_child(GTK_BIN(btn.Handle))), a)`
  (`a`=90 left, 270 right) via the `RotateRailButton` helper — the same call TabControl uses for vertical
  tabs. Each has `.Designer = @frmMain` set (else the `OnClick(*Designer,…)` dispatch null-derefs) and an
  `OnClick` handler (`railLeftProjectClick` etc.) that `Set…ClosedStyle False` then selects its tab.

**Collapse/expand plumbing (`src/Main.bas` + `src/ilwaco.bas`, both sides symmetric):**
- `Close{Left,Right}` hide `spl…`, the pin (`pnl…Pin`, in a GTK *overlay* → hidden explicitly), and
  `pnl…` itself, then show `pnl…Rail`. `Show{Left,Right}` reverse it.
- `Get{Left,Right}ClosedStyle` → `Return Not pnl….Visible`; `Set…ClosedStyle` sets the pin icon + delegates.
- **Pin-repaint fix:** after re-show, `Show{Left,Right}` call `gtk_widget_show_all(pnl…Pin.Handle)` (remap
  the overlay toolbar + its icon so the expanded-panel pin repaints) **and** `gtk_widget_queue_resize` on
  the stored `overlay{Left,Right}` handle (re-run its `get-child-position` against the restored width).
  Without the `show_all`, the reopened pin was present/clickable but blank.
- `ilwaco.bas`: `Pin{Left,Right}` simplified to `If spl….Visible Then Set…ClosedStyle True,True Else
  Set…ClosedStyle False,True`.

**Hard-won GTK/MFF facts (do not re-derive):** (1) collapse **must** hide the panel entirely —
width-shrinking fails; visibility toggles are reliable. (2) The pin is in an overlay → hide it in Close,
and `gtk_widget_show_all` it in Show or it won't repaint. (3) A single `ToolBar` button chevrons in a
narrow strip unless `gtk_toolbar_set_show_arrow(FALSE)`. (4) `CommandButton`/`Label` render **no image**
on GTK; only `ToolBar` shows icons (`gtk_image_new_from_icon_name(key,…)`, key = imgList key). (5) Rotate
a button caption via `gtk_label_set_angle` on `gtk_bin_get_child` of the button.

**Verified live (DISPLAY :0, screenshots):** both panels collapse to a vertical strip showing the pin icon
above rotated `Project`/`Toolbox` (left) and `Properties`/`Events` (right); the pin re-expands to the last
tab; each text button re-expands and selects its tab; the **expanded-panel pin repaints** after reopen;
and with `LeftClosed=true`/`RightClosed=true` both strips show **collapsed at startup**. Build clean
(`fbc` exit 0); additive to MFF, no `.so` rebuild.

**Supersedes** the deferred `e212819d`/`ef3b43e9` left/right *persistence* item: save/load already
worked (`GetLeft/RightClosedStyle` write `LeftClosed`/`RightClosed`; `frmMain_Create` re-applies).
The **bottom** panel got its own horizontal rail on 2026-08-04 (section below); its persistence round-trips.

**Left-over dead conditions (both sides, pre-existing, harmless):** `tab{Left,Right}_SelChange` /
`tab{Left,Right}_Click` and the focus-loss auto-collapse still guard on `TabPosition = tp{Left,Right}` /
`Width = 30`, which can no longer be true; a `no-dead-code` cleanup pass can drop them.

## Done 2026-08-04 — bottom-panel collapse via a horizontal activity rail (GTK REIMPLEMENT)

Completes the bottom half of `e212819d`/`ef3b43e9`. Same problem and solution shape as the left/right
rail (a docked GTK notebook can't shrink while shown), applied to the **bottom** edge and **built +
live-verified** this session. On collapse, `pnlBottom` is hidden and a separate 25px `pnlBottomRail`
(`alBottom`) is shown: a **pin at the right** (matching the expanded panel's `pnlBottomPin`, so it
doesn't jump) plus **14 tab buttons** — `Output..Immediate` always, `Locals..Profiler` only with the
debugger on.

**`src/Main.bas`:**
- New globals `pnlBottomRail`, `tbBottomRailPin`, `btnBottomRail(0..13)`, `bBottomRailReady`.
- `CloseBottom` hides `splBottom`/`pnlBottomPin`/`pnlBottom`, shows `pnlBottomRail`; `ShowBottom`
  reverses and calls `gtk_widget_show_all(pnlBottomPin.Handle)` so the expanded pin repaints on re-show
  (same fix as the left/right rails, but the bottom pin is a plain child, not an overlay).
- `Get/SetBottomClosedStyle` mirror the left side (`Not pnlBottom.Visible`; set pin icon + delegate).
- Rail built after `pnlBottomPin`: pin `ToolBar` (`alRight`, `PinBottom`, `show_arrow` FALSE), then a
  loop creating the 14 `btnBottomRail(i)` (`alLeft`, `.Text=tab->Caption`, `.Tag=tab ptr`,
  `.Designer=@frmMain`, `OnClick=@railBottomTabClick`; i>=7 start hidden). `railBottomTabClick`
  re-opens then `->SelectTab`.
- `tbBottom`'s `PinBottom` button `tbsCheck`→`tbsButton` (a *checked* `tbsCheck` on that vertical
  toolbar drew no icon).

**Hard-won GTK/MFF facts specific to the bottom rail (do not re-derive):**
- **Debug buttons need a re-assert + re-align on show.** `pnlBottomRail.Visible=True` runs
  `gtk_widget_show_all` (MFF `Panel.Visible` path), which un-hides *every* child regardless of its own
  state, and MFF's manual `alLeft` dock never sized the debug buttons because they were hidden when the
  rail first laid out. So `CloseBottom` re-sets `btnBottomRail(7..13).Visible = UseDebugger` and calls
  `pnlBottomRail.RequestAlign`; `SetDebugTabsVisible` does the same live re-align when the rail is
  already on-screen. Without this the debug buttons never appeared (or wrongly appeared with the
  debugger off).
- **Pin must be `alRight`**, not `alLeft` — the expanded pin is `alRight`, so a left-docked rail pin
  visibly jumped from right to left on collapse.
- **GtkToolbar has a min-height taller than a 25px strip**, which clipped the 16px pin's bottom. Fixed
  with a `GtkCssProvider` (`gtk_css_provider_load_from_data` → `add_provider_for_screen`) trimming
  `min-height/padding/margin`, **scoped by a `.ilwacorailpin` style class** set only on that toolbar so
  no other toolbar is touched. `gtk_widget_set_valign(GTK_ALIGN_START)` was tried first and pushed the
  icon *down* (it anchors the toolbar's oversized natural box) — do not use it here.

**Debugger-toggle desync fixed (`ChangeUseDebugger` + `ilwaco.bas` `"UseDebugger"`), surfaced by this
work:** the menu handler read MFF's cached `MenuItem.Checked` (`FChecked`), which a native GTK check-item
click flips *without* updating, so `Not …Checked` drifted from `UseDebugger` → "click twice to enable,
once to disable". Now the handler reads GTK's real post-click state
(`gtk_check_menu_item_get_active`) as the source of truth, and `ChangeUseDebugger` only re-sets the menu
check when it actually differs (calling MFF's setter when already-correct primes its activate-guard and
would eat the next click). Single, symmetric click each way.

**Verified live (DISPLAY :0, screenshots):** collapse → rail with pin (right) + `Output..Immediate`;
pin re-opens to the last tab; each tab button re-opens to its tab; expanded pin repaints on reopen;
enabling the debugger adds `Locals..Profiler` to both notebook and rail (and removes them when off);
the debugger toggles in one click; the rail pin renders unclipped. Build clean (`fbc` exit 0); additive
to MFF, no `.so` rebuild. **Persistence** (`BottomClosed` INI key via `GetBottomClosedStyle` +
`frmMain_Create`/`_Close`) already round-tripped and is unchanged.

## Next action

The bottom-panel collapse cluster (`e212819d`/`ef3b43e9`) is **done** (now in [HISTORY.md](../HISTORY.md));
`ae74b31c` (Service→Tools) and `53d8e473` (compile warnings) are already done/pruned. The two **Examples
items** (`4bd02894`, `51441d7a`) are **deferred to just before the testing phase** (owner, 2026-08-04).

**DONE — `5fa5cf25` (PORT with INVERTED debugger choice).** Astoria removed the Integrated engine and
kept GDB; **Ilwaco does the opposite — keeps the built-in Integrated (stabs) debugger and removes GDB** —
because the Integrated engine reads FreeBASIC's `.dbgdat`/`.dbgstr` sections that only the **gas64** backend
emits with `-g` (Ilwaco is gas64-only; gdb isn't installed; Astoria's bundled-gdb doesn't transfer). See
memory `project-debugger-keep-internal`. Completed 2026-08-04 across four build-verified passes; the full
narrative is in [HISTORY.md](../HISTORY.md).

- **Compiler-backend half + Pass 1** — alt-backend picker, optimization radios and `frmAdvancedOptions`
  removed (`-gen gas64` hardcoded); the whole GDB engine deleted from `Debug.bas` (−2130 lines) plus the
  `ilwaco.bas` GDB dispatch, `TimerProcGDB`/`GDBCommand`/`miGDBCommand`.
- **Pass 2A/2B** — `RunWithDebug` rewritten Integrated-only; `frmParameters`'s `cboDebug64` combo removed.
- **Pass 2C** — the `frmOptions` debugger-choice UI, its 5 handlers, LoadSettings/SaveSettings and the
  `[Debuggers]` INI writer. **Deviation from plan:** `pnlDebugger` was **kept**, because it still hosts the
  live `chkDisplayWarningsInDebug`; only the choice UI went. **Terminal** promoted to a top-level options
  node (it drives Run, not the debugger). `LimitDebug` removed as never-functional.
- **Pass 2D** — `DebuggerTypes`, `DefaultDebuggerType64`/`CurrentDebuggerType64`, `pDebuggers`/`Debuggers`,
  the `[Debuggers]` load/save/dealloc, the five `*Debugger64*` path globals, and the statically-dead
  `build_create_shellscript`. **Trap:** `LoadSettings`'s `Do Until … = -10` sentinel had to drop to `-9`.
- **Residual cleanup** — the orphan declare/`Extern "C"`/`pollfd`/global block at the foot of `Debug.bas`,
  the dead `tlockGDB` cluster, and the no-op debug "Update" toggle.

**2E — divergence from Astoria (deliberate).** Astoria removed its "Turn on Environment variables" checkbox as
confirmed non-functional (`frmOptions.frm` comment, 13.3.A S6 O4) and left its debug-parameters box in place but
inert — `Debug64Arguments` is saved and never read, and `RunWithDebug` ignores the `ProjectCommandLineArguments`
it receives. **Ilwaco wires both up instead.** Rationale: the project's Command-line arguments field lives on a
tab named *Debugging* and was honoured by Run while silently dropped by Debug, so this fixes an existing broken
promise rather than adding a feature; Astoria's blocker was Win32-specific (`CreateProcess` with
`lpEnvironment=0`) whereas on `fork`/`execv` it is contained; and on Linux `LD_LIBRARY_PATH` for the debuggee is
a real need. Owner decision 2026-08-04 ("students using linux would usually be a bit more advanced"). The
debuggee now gets a real `argv` (including `argv(0)`, previously absent) and an environment built pre-fork and
passed via `execve`.

Then the **menu-taxonomy cluster** `49ec5ccd`/`37ba31ea` (menu labels, File-menu restructure, Code-Editor
grouping, compiler-options simplification — the debug-tabs sub-item is already done). Skip the pure
GTK/Linux/32-bit stripping commits (`e139c2cc`, `c494207f`, `7baebd1e`, `add4642a`, `76abaa5a`, `15e66cc5`).

**Menu-taxonomy progress (2026-08-04).** The label pass, the File-menu restructure, Open/Rename/Delete
Project and the new **New Project dialog** (`frmNewProject`) are done and live-verified — New Project
creates a project on disk from a whitelisted template, which needed the `FileCopy`/`UString` fix (see
[TechnicalDebt.md](TechnicalDebt.md) and [UpstreamFixes.md](UpstreamFixes.md)). **Recent Projects is now the dialog (2026-08-06)** — Ilwaco's
MRU submenu is replaced by Astoria's `frmRecentProjects`, a File/Path list that skips entries whose
`.vfp` is no longer on disk. `OpenProjectTemplate` is **N/A**: it is defined in Astoria's `Main.bas`
and called from nowhere (dead code), and Ilwaco's `frmTemplates` has no `DialogMode` counterpart, so
there is nothing to port. **The Options panels are done (2026-08-06)**: the "When Ilwaco IDE
starts" radio group is removed along with the settings only it fed (`WhenVisualFBEditorStarts`,
`LastOpenedFileType`, `DefaultProjectFile`, plus the never-read `AutoReloadLastOpenFiles`), and the
Code Editor page is grouped into **Display / Editing / Completion / IntelliSense / History**:
Astoria's four groups with its `History` catch-all split (there it also held Tab Size, Treat Tab as
Spaces, the IntelliSense limit and the tooltip hover time). Tab settings → **Editing**, the two
IntelliSense settings → **IntelliSense**, History keeps the history/autosave limits. A deliberate
deviation from Astoria, owner call 2026-08-06. **`Show Holiday Frame` → `Show Indent Guides` is
done (2026-08-06) — as a feature, not Astoria's relabel.** Astoria changed that checkbox's caption to
"Show Indent Guides" but left it driving `ShowHolidayFrame`, which still blits `Resources/Frame.png`
over the editor in December and January (`WithFrame = Month(Now) = 12 OrElse Month(Now) = 1`) — the
label describes something the code does not do. Ilwaco deletes the decoration (`WithFrame`,
`EditControlFrame`, the PNG) and implements real guides in `EditControl.PaintControlPriv`, renaming
the setting to `ShowIndentGuides`. **The menu-taxonomy cluster is COMPLETE.**
Detail in [HISTORY.md](../HISTORY.md).

**Next: `b9735e8e` — replace `.vfs` sessions with an automatic workspace.** **Stage 1 done + verified
(2026-08-06):** `SaveWorkspace`/`LoadWorkspace` in `src/Main.bas` write `Settings/Workspace.ini` on
close and restore it on start, so the IDE reopens the project and tabs it had — BOM-less, with paths
stored relative to the executable so a workspace survives the repo moving between machines, and the
file removed rather than left stale when nothing is open. **Stage 2 done + verified (2026-08-06):** the Sessions UX is gone —
File ▸ Open/Save/Close Session, Recent Sessions, `AutoSaveSession`, `RecentSession`/`MRUSessions`,
`frmTemplates`' Sessions category (its remaining three renumbered), the `.vfs` file-dialog filters
and the `Session` icon. **`CloseSession` was never about `.vfs` files** — it is the batched
save-prompt `frmMain_Close` runs before the IDE will exit — so it was renamed **`CloseWorkspace`**
and kept, and the exit prompt was re-verified against a modified tab. Astoria's `LoadWorkspace` also
prompts New Project when there is nothing to reopen; Ilwaco leaves the IDE empty, which is what it
did before.

**`cc9e7dd5` (designer grey panel) — N/A (2026-08-06).** Astoria's bug was Win32-shaped: a project's
`ControlLibrary=Controls\Framework` left `Library.Path` as a *folder*, `DyLibLoad` on a directory
returned 0, no symbols resolved, and `Designer.CreateControl("Form")` gave the empty grey panel — plus
a refcount slip that broke every project after the first. Ilwaco cannot reach that state: the shipped
`[ControlLibraries] Path_0` names the `.so` file and a project's folder-form `ControlLibrary=` is
matched *folder-to-folder* against it, so the loaded library is reused; and the no-match branch builds
the path from the library's own `Settings.ini` (`[Setup] LibX64_gtk3`), never from a bare folder.
Astoria's second sub-fix, `GetControlLibraryVfpPath`, has no Ilwaco counterpart. **Verified by effect:**
two GUI projects opened in one session both render their form in the designer, and the Toolbox lists
the MFF controls (TestPlan T3/T24).

Found while checking it: `Controls/Framework/Settings.ini` still advertised thirteen library
variants (32-bit, GTK2, Windows DLLs) of which exactly one is reachable, plus three Windows lib-folder
keys read into fields nothing uses. Pruned to `LibX64_gtk3`, and `GetLibKey` — whose `#ifdef` ladder
could only ever pick that one — now returns it directly.

**`e5e10808` (Edit-menu review) — mostly INVERT/SKIP + superseded; one bug fix PORTED (2026-08-06).**
A large, mixed commit whose parts land very differently for Ilwaco:

- **The slash-rename sweep is INVERT/SKIP.** Astoria renamed `Slash`→`WindowsSlash` (`"\"`) and
  `BackSlash`→`UnixSlash` (`"/"`) across ~30 files to hard-code Windows path semantics. Ilwaco's
  `Main.bi` already defines `Slash "/"` / `BackSlash "\"` — the Linux-correct direction — and every
  call site already uses `Slash` correctly, so there is nothing to adopt (the rename would flip us
  back to Windows). The same applies to Astoria's `WinOsPath`→`CanonicalWinPath` (normalise to `\`)
  and `OsPathForDir`: Ilwaco's `WinOsPath`/`GetOSPath` normalise to `/`, which is what a Linux `Dir()`
  needs. `IsIniPathDriveAvailable` (drive-letter + `GetFileAttributesW` probe) is Win-only and a no-op
  on Linux — there are no drive roots to be unavailable. (The commit's sed rename even corrupted
  comments, e.g. AIService's "Forward slash" → "Forward WindowsSlash"; not carried.)
- **The headline "flat checkmark toggles" for Bubble Help / Suggest Options / Parameter Info are
  SKIP — superseded by `4a112089`** (in this backlog), which four days later "Move[d] Bubble
  Help/Suggest Options/Parameter Info off Edit menu (C2)": the toggles were deleted, those settings
  moved to Options only, and Parameter Info became a plain invoke-now command. Ilwaco's Edit menu is
  *already* in that post-reversal shape — `miSuggestions` runs the analyse action and `miParameterInfo`
  invokes now — so building the intermediate toggle UI (the three `Change*` subs, the `mClick`
  rewiring to `SuggestOptions`/`InvokeParameterInfo`/`AnalyzeSuggestions`, the `.Checked` styling)
  only to tear it out at `4a112089` is exactly the churn the project forbids. `ParameterInfoShow` is a
  latent global in Ilwaco (`Main.bi`, declared but never read/written); the `4a112089` Options-placement
  port is where it gets wired up (INI load, the `If Not ParameterInfoShow Then Exit Sub` gate,
  the Options checkbox). Handle it there.
- **PORTED: the `GetFileName` no-extension truncation fix.** With `WithExtension = False` and a name
  with no extension after the last separator, `nPos` was set to `Len(FileName)` and the extract length
  `nPos - Posi - 1` dropped the final character — reachable in Ilwaco at Rename Project
  (`Main.bas` ~2744: `GetFileName(OldFolder & Slash & tn->Text, False)`; a dot-less project-folder name
  like `MyProject` became `MyProjec`, so the rename targeted the wrong `.vfp`). Ported Astoria's exact
  fix (a `hasExt` guard). The residual no-separator/no-extension edge in the `Else` branch is left
  matching Astoria.
- **The `SanitizeIni*`/`CollapseRepeatedSlashes` path helpers are DEFERRED/low-value on Linux.** Their
  substance is drive-availability fallback (Win-only) plus slash canonicalisation to `\` (wrong
  direction here); what remains — trim + collapse `//` when reading MRU/tool paths from INI — is a
  marginal robustness gain. Not worth the surface now; revisit only if a concrete Linux path-INI bug
  appears. The MRU-list sanitising-on-load expansion (also pruning MRUFiles/MRUFolders) rides on those
  helpers and is deferred with them.
- **N/A: the MFF `#ifndef UNICODE` guards** (`Sys.bas`/`SysUtils.bi`/`UString.bi`) — those are the
  Windows MFF units that `#include "windows.bi"`; not part of the GTK build.

**Menu-taxonomy cluster — COLLAPSED to Astoria's FINAL menu, not walked commit-by-commit (2026-08-06).**
The Astoria menu is a ~15-commit evolution whose intermediate states rework each other, so walking it
step-by-step would build UI only to delete it (memory `project-menu-collapse-to-final`). Downstream of
`0eaa8806` in this backlog: `faaf0860` flattens the "More Build/Debug Options" submenus it creates,
`6f933f43` removes the Tools "Advanced" submenu, `11c033d4` reverts its minimal-toolbar default,
`4a112089` removes its Edit-menu toggles, and `b33a2f95`/`f3538e1c` add the Code/Form restructure.
**Owner-agreed to jump to the final taxonomy in one designed pass.**

- **Stage 1 (menu bar) — DONE + verified on `:0`.** Rewrote `CreateMenusAndToolBars`' menu-bar section
  to Astoria's final top-level order **File · View · Project · Code · Code/Form · Form · Run · Tools ·
  Window · Help**. Edit→**Code** (internal name `Tahrir` kept), Designer→**Form** (name `FormFormat`
  kept), new **Code/Form** menu holding the shared Undo/Redo/Cut/Copy/Paste/Duplicate/Select All (kept
  in its own never-greyed menu so its shortcuts survive contextual greying). **Search folded into Code**
  as a submenu; **Build+Debug merged into a flattened Run** menu. Advanced submenus on File / Code /
  Project; **Fold** and **Debug Windows** submenus; Split H/V and Convert/Lines moved onto Code; Command
  Prompt moved to Tools; Add Procedure/Add Type moved from Tools to Code. S2 relabels applied
  (Define→Go to Definition, Compile→Build, End→Stop, Start→Run Without Building, CompileAll→Rebuild All,
  MakeClean→Clean, StartWithCompile→Run). **Linux adaptations:** no GDB Command and no Continue (Ilwaco's
  Integrated engine has neither); one compiler (Astoria is one-compiler too). **Principle:** every
  dispatch key / `mi*` var name preserved — only structure, grouping, captions, top-level names changed,
  so `mClick` needed no rewiring. Verified by opening the Code and Run menus on `:0`; all submenus
  populate; clean startup, no error dialog. Collapses `0eaa8806`/`93bbfa28`/`11c033d4`/`4a112089`/
  `faaf0860`/`6f933f43`/`e1595a31` (menu-bar parts).
- **`0eaa8806`'s TabWindow.bas non-menu parts — DONE.** (1) **Window-menu index fix** (regression the
  reorg introduced): `bEnabledTab = miWindow->Count > 3 → > 1` and the tab-check loop `For i = 3 → 1`,
  since Split H/V left the Window menu so only the separator is static now — else Code/Go-to-Definition/
  Split were greyed until 3 tabs were open. Verified on `:0`. (2) **Go-to-Definition (F2) reliability
  pass**: a `DefineOverlapsCaretWord` helper so the same-line skip only skips the definition that
  actually overlaps the caret word (not every match on the caret's line); stale-symbol refresh
  (`If TextChanged Then FormDesign(True)`); a string/comment guard; word-bounds via `GetWordAt`'s
  out-params; `#define`/`#macro` lookup (new `Content.Defines` + `pGlobalDefines` loops); a `te`→`te1`
  bug fix; and status-bar feedback (`No word at cursor` / `No definition found for '…'`) plus the match
  count in the picker title. Ilwaco's `Define` was Astoria's exact pre-image and every dependency was
  present, so it ported cleanly. Verified on `:0`: F2 on a call opened the picker titled
  "Definitions for 'Start' (3)". (3) **`tbtToggleBreakpoint` double-assign fixed** — line 6308 reassigned
  `tbtToggleBreakpoint` (should be `tbtShowNextStatement`); no functional impact in Ilwaco (neither is
  read by enable-logic, unlike Astoria) but corrected. Folded in the later **`d8a2e8fb`** command-name fix
  on the *same* toolbar button (per the whole-log rule, to avoid touching it twice): its command was
  `"ToggleBreakpoint"` with no handler — a **dead button** — now `"Breakpoint"`, matching the menu, so it
  actually toggles.
  **The other `0eaa8806` folded fixes are N/A / deferred / INVERTED for Ilwaco:** the **7-band Maximize
  SIGSEGV** is N/A (that crash was *introduced* by the S3 toolbar merge — a `Bands.Item(5)` on a 5-band
  ReBar; Ilwaco still has 7 bands and no such Maximize loop; fix it *with* S3). The **`frmTools` save
  handler** fix is N/A: it repaired a break from moving "External Tools" into a Tools▸Advanced submenu,
  which Ilwaco didn't do (External Tools is a flat child named `"Tools"`, so the `Name` lookup still
  works). **S4 (`*nix/*bsd Icon Resource File` field) is INVERTED → keep**: Astoria removed it as dead on
  Windows, but on a Linux IDE the `.xpm`/`IconResourceFileName` field is the *live* one (tracked, renamed,
  marked `*` in the tree), so Ilwaco keeps it; any dead *Windows* `.ico` field is a separate non-target
  strip. The **band renumbering + `ShowRunToolBar` INI migration** are deferred with the S3 toolbar merge.
- **Deferred to their own passes** (final menu also contains these, but they are separate features to
  port when the walk reaches them): the **Code/Form contextual greying** (`UpdateCodeFormMenuEnabled`,
  D1 Designer greying `a114ee5b`), the designer `@PopupClick` context items in the Form menu
  (context-menu parity `b05fdacb`), the **Git menu** (`d61eb062`+), and the **toolbar** merge/
  single-checkable simplification (S3 — Ilwaco keeps its current Toolbars submenu + bands for now).
- **Android/APK — REMOVED (2026-08-06), a dedicated feature-removal pass** (Astoria did the same in
  `7e23e1ca`; Ilwaco is Linux-only so Android cross-build was dead weight). Removed: the two Run-menu
  submenus + four `mi*` vars + their `->Enabled` lines; the `mClick` cases; `CompileBundle`/`CompileAPK`/
  `CreateKeyStore`/`GenerateSignedBundleAPK` subs; the `gradlew` branch in `Compile()` and its `set NDK=`
  rewrite (the general makefile/batch-compile path was **kept** — it is a legit Linux feature); `RunPr`'s
  whole APK-deploy (`adb`) branch, collapsed so the normal run runs unconditionally; the
  `AndroidSDKLocation`/`NDKLocation`/`JDKLocation` fields in `ProjectElement` + destructor frees + `.vfp`
  reader/writer; the entire Project-Properties **"Android Settings"** tab with its load/save logic, six
  click handlers and control declarations; the dead `chkAndroidProject` declares; the unused `AppAndroid`
  icon registration; and the `Templates/Projects/Android Project/` template (55 files, which
  "Add From Templates" would otherwise still offer). Verified by effect on `:0`: build clean, Run menu has
  no Android, an example project opens (`.vfp` reader OK), and Project Properties opens with the Android
  tab gone (tabs now General/Make/Compile/Includes/Debugging) and no crash.

- **`93bbfa28` S5 + `331b5705` (B1) — Delete File, DONE (2026-08-06).** Scoped against Astoria's
  **final** state, not `93bbfa28`'s: that commit's tab-based ~18-line `DeleteEditorFile` was reworked
  twice afterwards — `331b5705` added deferred deletion (`PendingDelete`) and `273df0f5` unified the
  command with the tree's right-click "Remove", deleting `RemoveFileFromProject` outright. Owner chose
  **full parity**, so Ilwaco ships the final shape: one `DeleteFile` command on the File menu (new
  `miDeleteFile`), the Project menu, the tree context menu and the explorer toolbar; confirmation
  prompt defaulting to No; tree-selection based, so a project member can be deleted whether or not it
  is open. A project member is only marked `ee->PendingDelete` (label `(pending delete)`, project
  flagged `*`); `SaveProject` collects them into a `PendingKill` `WStringList`, excludes them from both
  `.vfp` write branches and from `ppe->Files`, and `Kill`s them **only after** the project file is
  written. `CancelFileDeletion` undoes a queued delete; `CloseProject` lists queued files as
  informational `(delete pending)` rows (`ItemData=0`, skipped on save) and `tvExplorer_NodeActivate`
  refuses to reopen one. **`331b5705`'s save-dialog half was already partly present** — `frmSave`
  had `SelectedItems` and `CloseWorkspace` used it, but `CloseProject`/`SaveAllBeforeCompile` still read
  `.lstFiles.Selected(i)` *after* `ShowModal` returned; both converted, plus `Case Else: Return False`
  so closing the prompt via the window X counts as Cancel, and `SelectAll` moved to `Form_Show` where
  the control actually has a handle. **Removed** with it: Ilwaco's old unconfirmed `RemoveFileFromProject`
  (which silently `Kill`ed loose files off disk after a hidden `Temp/` copy, and leaked an
  `ExplorerElement` per call), and `frmSave`'s **10-second auto-Yes countdown** — a timer that answered
  the save prompt by itself, which with B1 would have executed file deletions with no user action.
  Astoria has no such timer. Verified by effect on `:0`: confirm prompt → `(pending delete)` label with
  the file still on disk → Close Project prompt listing `DelTest.vfp*` + the `(delete pending)` row →
  **Yes** deletes it and rewrites the `.vfp` without it, **No** leaves file and `.vfp` untouched;
  Cancel Deletion reverts the label and the file then survives a real project save.
- **`0c08fe5f`'s standalone-node `ExplorerElement` Tag — N/A (project-only product).** Astoria gives
  the tree node created for a "File ▸ Open" file (one matching no project or folder) an
  `ExplorerElement` Tag, without which `DeleteEditorFile` exits at its `ee = 0` guard. Ported, then
  **reverted on owner direction (2026-08-06): Ilwaco is for project-based development only — files
  outside a project are not a supported mode**, so this is not a gap to close. Consequence to be aware
  of: File ▸ Open still creates such a node, and Delete File is a no-op on it. Constraining that entry
  point is a separate product question, not part of this item.
- **Two GTK defects found while verifying the above, both pre-existing and now fixed** (detail in
  [UpstreamFixes.md](UpstreamFixes.md)): `tvExplorer_MouseUp` never ran on GTK, so the explorer context
  menu had shown stale captions and enablement since the port — its logic moved to
  `UpdateExplorerMenuState`, called from `tvExplorer_SelChange` (and directly after a delete/undo,
  since re-clicking an already-selected row fires no selection change); and `node->Text &= "*"` updated
  the node's internal string without repainting, so the project dirty marker was invisible in the tree —
  changed to an explicit assignment at all five live sites.

## Full classification pass — all 396 remaining entries (2026-08-06)

Astoria is **frozen** (owner, 2026-08-06), so the backlog is a fixed target and a classification made
now cannot be invalidated by later Astoria work. This pass therefore covers **every one of the 396
entries** still in [AstoriaDetailedChangeLog.md](AstoriaDetailedChangeLog.md), grouping them into the
arcs they actually belong to rather than treating each commit as independent — the same
"port the final state, not the intermediates" method the rest of this document uses.

### How much to trust this pass

**Read this before acting on a verdict.** The grouping is exhaustive (all 396 assigned, none dropped),
but the *confidence* is not uniform, and pretending otherwise would repeat the mistake that cost this
project a day on `93bbfa28`:

- **High confidence — the non-actionable clusters.** These rest on facts already established about
  Ilwaco (GDB removed, own branding, LF-only, testing deferred). Safe to treat as settled.
- **Cluster-level only — the PORT clusters.** The *cluster* is actionable; the individual entries have
  **not** each been checked against Ilwaco's source. Each still needs the normal per-item scoping when
  the walk reaches it. A cluster verdict of PORT means "this arc is ours to do", not "these 36 commits
  are each verified applicable".
- **The backlog file was deliberately NOT pruned by this pass.** Its own rule says "prefer keeping when
  unsure", and a mechanical grouping is exactly the situation that rule is for — see the carve-outs
  below, which a bulk delete would have silently lost.

### Carve-outs found while checking the grouping

Sampling the largest "non-actionable" cluster immediately produced four entries that a mechanical sweep
would have mis-filed. This is the evidence for the caution above, and these four are now correctly
classified:

| Entry | Looks like | Actually |
| --- | --- | --- |
| `d8a2e8fb` DR-12 toolbar Toggle Breakpoint | GDB → N/A | **DONE** — ported in Ilwaco `d978e66` |
| `5fa5cf25` Remove Integrated (stabs) debugger | GDB → N/A | **INVERT** — Ilwaco kept Integrated and removed GDB, the exact opposite |
| `b7af6117` DR-4 full repaint on breakpoint toggle | GDB → N/A | **PORT** — `EditControl` paint; Ilwaco has breakpoints (10 sites in `EditControl.bas`) |
| `56afc8ab` DR-4 gutter click scrolls the viewport | GDB → N/A | **PORT** — editor gutter behaviour, nothing to do with the debug engine |

**The lesson generalises:** a debugger-era commit is only N/A when it touches the *engine*. Anything it
fixed in the editor, the tree, the framework or the build path is still ours.

### Summary

| Cluster | Verdict | Entries |
| --- | --- | --- |
| GDB debugger engine | **N/A** (Ilwaco removed GDB; Integrated only) — less the 4 carve-outs | 26 |
| 13.28 Alt+C/G/R menu-mnemonic saga | **N/A** — Win32 accelerator/kernel-debug investigation | 14 |
| 13.68 close-crash investigation | **REVIEW** — Win32 symptom, but `154fb8aa`'s cause (a shared context menu holding a dangling `ParentWindow`) is framework-level | 13 |
| **13.60–13.79 threading / IntelliSense** | `13.71` **DONE**; rest **DEFERRED** — severity downgraded, see the correction below | 36 |
| Agent MCP + AI templates | **DONE** (MCP server) / **INVERT-KEEP** (templates) | 38 |
| Git integration | **INVERT-KEEP** — port the add chain, skip `9d277f28` | 15 |
| Windows packaging / installer / release | **REIMPLEMENT** — AppImage, tracked separately | 7 |
| Astoria branding, version, icon, splash, About | **N/A** — Ilwaco has its own identity | 22 |
| CRLF / tabs normalisation | **INVERT** — Ilwaco is LF-only | 6 |
| Rebuild-binary commits | **N/A** — no source change | 3 |
| Docs / changelog / DocCheck tooling | **N/A** — Ilwaco has its own (`Tools/DocCheck.py`); PowerShell machinery dropped | 24 |
| Examples / control testing / TestPlan | **DEFER** — owner deferred to just before the testing phase | 20 |
| Designer / form editor | **PORT** | 17 |
| Menus / toolbars / UI taxonomy | **MOSTLY DONE** — the taxonomy collapse landed in `3ef11eb` | 24 |
| MsgBox → Output panel (13.85–13.93) | **PORT** | 8 |
| Options dialog / settings / INI | **PORT** | 16 |
| Project create / open / save / `.vfp` | **PORT** | 16 |
| MFF framework fixes | **PORT** | 12 |
| Win32-only implementation | **REIMPLEMENT** | 3 |
| Compile / build path | **PORT** | 10 |
| Residual — classified individually below | mixed | 66 |

### The actionable queue, in priority order

1. ~~**13.60–13.79 — the threading / IntelliSense arc. Do this first.**~~ **CORRECTED 2026-08-06 —
   see "The threading arc, re-judged" below.** `13.71` is done; the rest is deferred. This item claimed
   the arc was "the single highest-value thing left" and that it fixed our SIGSEGV. Both claims were
   inherited rather than checked, and both are wrong.
2. **The deferred menu features** — S3 toolbar merge, Code/Form contextual greying, designer
   `@PopupClick` context items (unchanged from the previous NEXT).
3. **Git integration** and **the three AI templates** — the two build-work divergences.
4. **MFF framework fixes** and the **MsgBox → Output panel** arc — both platform-neutral.
5. **Examples / control testing** — deferred by the owner to just before the testing phase.

### UI work — staged sequence (2026-08-07)

A look-ahead pass over everything UI-facing still in the backlog, ordered by dependency into stages.
This **refines queue items 2–4 above for the UI portion** — same items, sequenced. **Owner decision
(2026-08-07): "parity first, redesign later."** The near-term target for the central **Form/Editor
area** is the Astoria-parity restructure below (Stages A–C); a broader redesign of that area — and the
**final home of the deferred embedded terminal** (see PROJECT_STATUS "⏸ DEFERRED — the embedded VTE
terminal") — is a deliberate *later* revisit, once the parity shape has landed.

Standard caveat (per "How much to trust this pass"): each entry still needs its own scoping against
Ilwaco source when the walk reaches it — a stage is an ordering, not a promise every listed commit
applies verbatim.

**Stage A — the source-tab view model (the central-area spine).**
- `4b643af5` **tcView** — replace the three *Code / Form / Code And Form* `tbsCheckGroup` toggles Ilwaco
  still adds to `tbrTop` (`TabWindow.bas:10226`–`10228`) with a **bottom-docked button row** reading
  *Code And Form* / *Code* / *Form*. In Astoria this is a `TabControl` named `tcView` **styled as
  buttons** — `tcView.TabStyle = TabStyle.tsButtons`, `.Align = DockStyle.alBottom`, `.Height = 26`,
  icons from `imgList` (see `TabWindow.bas` ~10696–10713) — so despite the "tc"/"tab strip" naming it
  reads and behaves as **buttons**, not notebook tabs (owner, 2026-08-07). It is **header-only**: the
  three entries carry no page content; `tcView_SelChange` drives which panel — code editor vs designer
  — is shown. The class/function *(General)* / *(Declarations)* dropdowns stay at the **top** of the
  pane; only the view selectors move down. This is the reshape the owner means by "much different," and
  it gates the rest of the central-area work.
- **Visual target (owner's Astoria screenshot, 2026-08-07)** for Stages A–B: bottom *Code And Form /
  Code / Form* tabs under the editor; in **Code And Form** the live form renders as a designer window
  over/beside the code; the Explorer shows a **per-form control tree** (`Calculator.frm → Panel1
  (Panel)` — that is Stage B's `f292db0b`); Properties / Events panels on the right.

**Stage B — Form Designer depth (central area).**
- `f292db0b` — per-form **control tree** in the project Explorer (designer navigation, part a).
- `0c08fe5f` — **PagePanel** layer/page navigation (part b). Its standalone-node `ExplorerElement` Tag
  sub-part stays **out** (reverted, owner: project-only product — see the Delete-File notes above).
- `623aa2a7` + the designer half of `1c00c1fb` — designer **Undo/Redo** (Ctrl+Z/Y on the form). Note
  `623aa2a7` shipped in Astoria UNBUILT/UNTESTED, so treat it as a spec, not a port.

**Stage C — context menus & contextual greying** (owner dislikes toolbars, so right-click must carry
everything the toolbars do).
- `b05fdacb`, `ab8d166e`, `036c5fa3`, `9d797cd8` — code + Designer context-menu parity and the
  format-submenu (Align / Make Same Size / Spacing / Center) rendering fixes.
- `a114ee5b`, `e4d9a954`, `e1595a31`, `f3538e1c` — Code/Form menu **contextual greying**
  (`UpdateCodeFormMenuEnabled`; grey the Form menu when no designable form is active, and re-grey on
  form/tab close).

**Stage D — toolbars & menu tail.**
- **S3 toolbar merge** — 7→5 bands, single-checkable Toolbars submenu, `ShowRunToolBar` INI migration
  (incl. `93bbfa28`'s run-toolbar persistence), the 7-band Maximize `Bands.Count-2` fix, band
  renumbering. (The Maximize SIGSEGV is *introduced by* this merge — fix it here, not before.)
- `4a112089` — wire up `ParameterInfoShow` (a latent global in `Main.bi`: INI load, the
  `If Not ParameterInfoShow Then Exit Sub` gate, the Options checkbox).
- Residual UX: `0d6c6be8` (stop `ApplyView` forcing the left panel to Toolbox), `b5cc3ebf` (Step Out
  onto the top-level Run menu), `820eebb7` (merge into one Toggle Comment), `164c5ead` (name a new file
  up front), `d48a6cd5` (drop the toolbox component picker — opinionated-design parity).

**Stage E — the two committed divergences (UI-facing).**
- **Git menu** — ADD chain `d61eb062` → `fffee489` → `fd894173` → `95b04f70`, skip removal `9d277f28`.
- **Three AI templates** — Claude Code / ChatGPT / Kun (see "Deliberate divergences" below).

**Stage F — feedback surfaces.**
- **MsgBox → Output panel** — `f169384c` (13.85, 122 informational MsgBoxes → the Output panel),
  `ec475679` (13.92 severity re-grade), `84d066a2` (first-MsgBox non-modal fix), `b8195f7d` (grow to
  fit long paths) + the status-bar / Output / MsgBox channel policy.
- Options-dialog tail: `a7c7839d` (General-page checkbox overlap + the flagged Form-Designer
  scalability concern), the licenses page `52d1021d`/`3e72506d`.

**↩ Terminal re-entry point:** after Stage A–B, once tcView and the designer navigation have settled
the central area's shape, the deferred VTE terminal is picked up and placed in its real central-area
home (revisited with the "redesign later" pass).

### The threading arc, re-judged (2026-08-06)

The classification above rated `13.60`–`13.79` the highest-value item left, on the strength of a phrase
carried in PROJECT_STATUS — that Ilwaco's intermittent SIGSEGV was "a known Astoria-fixed threading
issue". **Implementing `13.71` and then trying to measure it showed that rating was wrong.** Recorded
here because the error is more useful than the verdict:

- **Astoria downgraded the defect** in `382dbb07`. The death rate is a function of *switching speed*:
  ~0.35 s/switch gave 6, 6 and 9 deaths in 60; **1 s/switch gave 0 in 60**; 4 s/switch 0 in 60. Its own
  conclusion is that this needs project teardown to overlap still-running loader threads, which no user
  produces — **explicitly not a release blocker**.
- **It is probably not our defect at all.** Ours hits on startup/analysis when opening **large files**;
  this one needs rapid project *switching*. Nothing ever established they were the same bug.
- **Our A/B could not measure it, and that is itself a finding.** 40 cycles against the **pre-fix
  threaded** binary (recovered from git — no rebuild needed for a control arm) gave **0 deaths**. The
  harness paces at six MCP round trips per cycle, well over the 1 s/switch Astoria measured as closing
  the window. **A harness paced by MCP round trips cannot reproduce a race that needs sub-second
  switching.** The serial arm was not run: another 0/40 would have proved nothing, and reporting it as
  success would have been the exact false green this project keeps guarding against.

**Verdicts now:** `13.71` **DONE** (`31a5e20`) — kept on its merits, since the race is real, the serial
load is strictly safer, and the threading it removed never bought throughput (the loaders were already
serialised on `tlock` and `tlockSave`). `13.72` (idle slices) **DEFERRED** — it exists only to remove the
stall `13.71` introduces, so it is worth doing when that stall is actually felt. The `13.65`/`13.66`
teardown use-after-free entries stay **PORT**; they are a different and more plausible family for our crash.

**Method note worth keeping:** a control arm cost nothing here — the previous binary is tracked in git,
so `git show <rev>:ilwaco` gives an A/B without a rebuild. Use it, and confirm the control actually
fails before believing anything about the treatment.

### The 66 residual entries, classified individually

These did not fall into any arc, so each is judged on its own. Several are **more valuable than their
cluster-mates**, which is the argument for having done this rather than leaving them as "unmatched".

**DONE already in Ilwaco** — `331b5705` (Delete File B1, this session), `a510b24b` + `e83212fc`
(`.lng` removal / English-only sweep — Ilwaco is already English-only).

**N/A — Astoria repo, identity, Windows CI or CRLF artefacts:** `6ff623a3`, `b62f18f9` (Codeberg→GitHub),
`84b5beef`, `05088583`, `33e1ffd0`, `a132e23f`, `2d833f40`, `d58b15e0` (stray CR — we are LF-only),
`27540aea` (Win32 `WM_PAINT` `GetDC`), `5077c4fc` (32-bit/Windows SQLite DLLs), `8cb4aa58`, `86940547`,
`a0170dd0`.

**DEFER to the testing phase:** `4d7499b1`, `cc23967a`, `d9c31939`, `0986f182`.

**PORT — worth pulling forward, in rough value order:**

- **`c713f136`** — a deleted workspace file must not block startup with a modal "File not found".
  Ilwaco *now has* a workspace loader (`b9735e8e`, ported this month), so we have inherited exactly the
  situation this fixes.
- **`d6fb59e8`** — Delete Project crashing *and* silently failing to delete from disk. PROJECT_STATUS
  already records that Ilwaco's Rename/Delete Project "inherit a pre-existing crash in Close Project";
  this is very likely the same defect, already diagnosed.
- **`13.66` stale-pointer sites** (`8cda50fd`, `00b65f5e`, `8a90fec7`, `e311e572`) and **`13.65`**
  (`f30cf3c7`) — use-after-free and deadlock in project teardown, the same family as our known SIGSEGV.
  Take these with the threading arc, not separately.
- **`13.69` control-library loading** (`87223b67`, `2d02b35e`, `37976ea8`) — libraries loaded then
  freed, and a `ByRef` parameter overwriting each library's path with its folder, so no control from an
  optional library could be placed. Ilwaco has the same toolbox/control-library mechanism, and the
  `ByRef`-overwrite is a trap CLAUDE.md already warns about.
- **`13.99` imagekey-as-type** (`b2c9589d`) and **`13.102` "MainProject"** (`0436b846`) — deciding a
  node's type from its display-icon name. Directly relevant: the Delete File work this session turned on
  exactly this (`ImageKey = "Opened"` is a folder icon, not a file).
- **`13.91` licence notices** (`52d1021d`, `3e72506d`) — **DONE (2026-08-08).** Per-file *"Ilwaco IDE
  Modifications / copyright 2026 Donald Montaine"* LGPL v3 block appended below the original
  MyFBFramework attribution on all 199 retained `Controls/Framework/mff/*.bi`/`*.bas`, placement mirrored
  from Astoria. Files also LF-normalised; framework BOMs deliberately kept (a strip needs the `WStr("")`
  literal rewrite and is functionally moot — a BOM does not leak into an including file; see PROJECT_STATUS).
- **`4a0798bf` MFF cleanup (drop HTTPServer/Animate/ListItemsOld)** — **PARTLY DONE (2026-08-08):**
  `HTTPServer.{bi,bas}` removed (HTTP client + `HTTPConnection` kept) together with `NativeFontControl`
  (dead here, dropped upstream + Astoria). **Residual for the deep-clean pass:** Astoria's same commit
  also drops **Animate** and orphaned **ListItemsOld**, still present here.
- **`13.83`/`13.90` FreeFile** (`a01cb61a`, `79100d16`) — partly satisfied already (Ilwaco has the
  guarded open helper), so scope before porting.
- Editor/UX: `820eebb7` (merge into one Toggle Comment), `05ff9476` (missing-exe check on Run),
  `0d6c6be8` (stop forcing the left panel to Toolbox), `b5cc3ebf` (Step Out onto the top-level Run menu),
  `62404e04` (Recent Files), `8639e1c1` (portable Recent paths), `164c5ead` (name a new file up front).
- Robustness: `cda99f83` (unchecked `Open For Output` sites), `d84b2ef7` + `7a0c8294` (Add External Tool
  silently failing — `Form_Close` clobbering `ModalResult`), `72489b9f` (Add Module crash),
  `35a53050` + `cd08ffbb` + `36cacd84` (never raise a modal from the app-activation handler),
  `8356a345` (tag-as-pointer audit), `6ccb0383` (commented-out code sweep — our standing rule),
  `4ec96461` (analysis scratch file left in the project), `e3bfa7a3` (shortcut-default sweep),
  `9b19f1e1` (MFF `HTTPConnection`), `d099dc60` (Change Log location, project paths, themes),
  `5d9cd620` + `8aba6c2d` + `640e94ed` (the "Opus Next Steps" fixes).

**REIMPLEMENT:** `a100adfc` (copy a control library's runtime DLLs beside the exe → `.so` on Linux).

**REVIEW:** `7242e9e0` — Astoria *retracted* a standing `ReDim Preserve` rule after measuring it.
Ilwaco's CLAUDE.md still carries a `ReDim Preserve` warning; the two claims are not identical (ours is
about a stale pointer into a relocated array, Astoria's retraction is about double-freeing heap-owning
elements), so read `7242e9e0` before trusting either. `273df0f5` and `d4d775f7`/`923703ec` are mixed
commits tied to `project.astoria`, which Ilwaco does not have — scope before porting.

### What this pass did not do

- It did not verify each entry inside a PORT cluster against Ilwaco's source; that stays part of
  scoping each item when the walk reaches it.
- It did not prune the backlog file. Pruning is still correct per that file's rule, but it should follow
  a per-entry pass, not this grouping — the four carve-outs above show why.
- It did not re-check the clusters' *internal* membership beyond the sample that produced the four
  carve-outs. Others of the same kind are likely; expect them and check before treating an entry as
  settled.

---

## Deliberate divergences from Astoria — INVERT (owner, 2026-08-06)

**These override the "port Astoria's final state" rule.** Ilwaco's audience is *somewhat more advanced*
than Astoria's (returning Basic programmers, hobbyists, students), so where Astoria removed capability to
simplify, Ilwaco keeps it. The standing rule would make a walker reach the removal commit and drop the
feature — exactly the wrong outcome. Where Astoria added a feature and later deleted it (**Git**, the
**AI templates**): **port the ADD chain, do NOT port the removal.** Where Ilwaco already has what we want
(**themes**, **multiple instances**): these are **guards** — no work, just do not port the removal when
the walk reaches it, and do not let an "opinionated by design" pass collapse them.

### 1. Themes — KEEP **both** capabilities; **do not port `5c50f20f`** (the editor-theme cull)

**There are two distinct theme capabilities, and both are retained:**

| Capability | Where in the UI | Backing code | Theme files |
| --- | --- | --- | --- |
| **IDE UI theme** (the whole interface) | Tools ▸ Options ▸ **General ▸ Themes** | `cboInterfaceTheme`, `cmdInterfaceThemeAdd`/`Remove` | `Settings/Themes/Interface/` |
| **Editor theme** (syntax colours/fonts) | Tools ▸ Options ▸ **Code Editor ▸ Colors and Fonts** | `cboTheme`, `frmTheme` | `Settings/Themes/*.ini` |

The later-in-the-log deletion Ilwaco has not yet reached is **`5c50f20f`** — *"T15 re-curation:
shortlist shipped editor themes to 12 (owner picks)"*. It touches **only the editor themes**: it deletes
**84 of the 96** `Settings/Themes/*.ini` (keeping Default Theme, dracula, github, gradient-dark,
hopscotch, kimbie.dark, kimbie.light, monokai, night-owl, purebasic, qtcreator_dark, qtcreator_light)
and leaves `Themes/Interface/` untouched. **Ilwaco does not port it — we keep all 96.**

Be precise about what that commit is, because it is easy to remember as a bigger removal than it was: a
**content** cull with **zero code change** (its own message notes the picker scans the folder
dynamically, so nothing needed rewiring). **Neither capability was ever removed from Astoria** — both
pickers, `frmTheme` and the interface-theme Add/Remove buttons are still in its source today, and in
ours. So there is **no code work here**; this entry is a **guard**: keep the 96 files, keep both pickers,
and do not let an "opinionated by design" pass collapse either — they are explicitly retained options.

### 4. Multiple instances — KEEP; **do not port Astoria's single-instance handover**

**Ilwaco already allows several IDE windows open at once and that is deliberate; Astoria permits exactly
one.** Astoria enforces it at `Main.bas:110`: `If App.PrevInstance Then` captures `Command(-1)`, strips a
`2>CON` suffix and any `.exe`, and hands the payload to the already-running instance through
`EnumWindows`/`EnumWindowsProc`, then leaves without FB's `End` — so a second launch always surfaces the
first window instead of starting a new IDE (broadened in 13.29, which made the handover unconditional so
a plain second launch would at least raise the existing window).

Ilwaco has **none** of this — `App.PrevInstance` appears nowhere in our source. The whole mechanism is
Win32 (`EnumWindows`, `LPARAM`, `.exe` handling), so it fell away with the Windows strip; the owner has
now confirmed the resulting behaviour is the wanted one. **Do not port `App.PrevInstance`, the handover,
or a GTK re-implementation of either.** If a future change needs to reach "the running IDE" (as the MCP
agent socket does), it must not assume there is only one.

### 2. Git integration — KEEP, port the ADD chain

Astoria built it and then deleted it in **`9d277f28`** ("Git is an advanced feature that doesn't fit
Astoria's target audience"). That reasoning does not apply to Ilwaco. Port, in order:
`d61eb062` (top-level **Git** menu — Pull / Push — placed between Run and Tools) → `fffee489`
(Git Commit with a message prompt) → `fd894173` (Set Up SSH Key) → `95b04f70` (Create Remote Repository,
plus its New Project preflight). `9d277f28` also lists what a full restore covers, so read it as the
*inventory* even though we skip it: the `frmGitCommit` dialog; New Project's "Git Project" clone mode with
Provider/Username/Email and `CloneGitRepository`/`BuildGitURL`/`SetupGitRepository`/`WriteGitSupportFiles`/
`SshKeyExists`/`RemoteRepoExists`; the Options ▸ Personal Information **Git identity** group
(Login / User Name / E-mail) with its INI plumbing; the `UseGit`/`GitProvider`/`GitUserName`/`GitEmail`/
`GitURL` project keys; `Templates/Git/` (gitignore/gitattributes stamps and the sshkeys/github/gitlab/
codeberg guides); and `Templates/AI/*/skills/git-workflow/`. Everything is Win32-flavoured shell-out work,
so expect REIMPLEMENT rather than straight PORT in places.

### 3. Multiple AI templates — KEEP FOUR, port the ADD chain

Astoria consolidated onto Claude Code alone in **`6de0332f`**, deleting five vendor template folders:
**ChatGPT, Cursor, Kimi, Kun, OpenCode**. Ilwaco keeps **three**: **Claude Code, ChatGPT, Kun** — i.e.
restore ChatGPT and Kun alongside ClaudeCode, and leave Cursor, OpenCode and **Kimi** out (Kimi dropped
by the owner, 2026-08-06). **The three are chosen to span both access models, which is the actual
rationale — record it, because the set looks arbitrary otherwise:** Claude Code and ChatGPT are kept
because **their agents run on a subscription** (no API key, no metered billing — the thing most users
already have), and Kun is kept because it is **API-key only but works with most available model API
keys**, covering every model without a template of its own. That combination is also why dropping Kimi
loses little. Each agent
carries its own **Skills and Rules**. Relevant add-chain commits: `987e8b7e` (New Project wires up Git and
AI-friendly), `ef5a6252` (the **data-driven AI Agent dropdown**), `72ea5980` (MCP `create_project` marks
AI-friendly and stamps the creating agent's template), `de8c1e5a` (template parity work).

**Do not re-import the three drifts that motivated the removal — `6de0332f` documents them, and they are
real bugs, not reasons to avoid the feature:**
1. The two dropdowns (New Project, Project Properties ▸ Description) were populated by **enumerating
   `Templates/AI` subdirectories**, while `AgentMcp` and `AgentPipe` each carried a **hardcoded list of
   five**, with nothing reconciling the two. One list, one source of truth.
2. **Kimi was selectable but supported nowhere**, so it resolved to no template folder at all. Every
   offered agent needs a real folder *and* backing support.
3. The GUI stored `AITool=ClaudeCode` while the MCP path defaulted to `"Claude Code"`, which
   `AgentAiToolFolder` then did not recognise — and both dropdowns showed **folder names** rather than
   product names. Keep display label and folder name distinct and mapped in one place.

**Current Ilwaco state: none of this machinery exists yet.** The MCP server deliberately dropped
`create_project`'s `ai_tool` stamping ("Ilwaco has no AI-template machinery"), so this is a build, not a
restore — `AgentPipe`'s `aiToolMeta` is presently hardcoded. Astoria's deleted folders are recoverable
from its history (`git -C ../astoria-ide show 6de0332f^:Templates/AI/...`).

## Foundation status (2026-08-02)

- **Build baseline:** Ilwaco builds + runs on Linux (PROJECT_STATUS).
- **Rules:** `CLAUDE.md` created, carrying Astoria's practices adapted for Linux/GTK + the two rules.
- **Skills:** 9 platform-neutral FreeBASIC/MFF skills ported to `.claude/skills/` (renamed). Pending
  Ilwaco-specific rewrites: `build-ilwaco`, `verify-ilwaco-behaviour`, `release-ilwaco`,
  `update-ilwaco-docs`, `gtk-interop` (replacing `winapi-interop`).
