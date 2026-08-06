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
this file — short version: the two Examples items are deferred to just before the testing phase, so next up
are two found debugger bugs, then the `49ec5ccd`/`37ba31ea` menu-taxonomy cluster.

**Still-open, opportunistic (not blocking):**

**Deferred strip sub-items** (low-value / off the compiled path — do opportunistically, not blocking):
- `mff/win/` (Windows headers dir) — now only reached via the excluded `SysUtils.bi` WINAPI includes
  (unreachable on our build) and the opaque `#ifdef GIFPlayOn` block in `Animate.bi`; inert. Delete once
  `SysUtils.bi`'s WINAPI includes are hand-stripped and `GIFPlayOn` is understood.
- `Controls/MyFbFramework/inc/` (CopyArray/Thread/cJSON/mongoose/raylib/`pipe.bi`…) — **not on the build
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
(`Controls/MyFbFramework/mff/TabControl.bi` + `.bas`):
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
- The built `Controls/MyFbFramework/libmff64_gtk3.so` exports **469** text symbols, including all four
  core dispatchers (`CreateComponent`, `CreateControl`, `ReadProperty`, `WriteProperty`).
- **Definitive test:** all **36** symbols `src/Designer.bas` resolves via `DyLibSymbol()` are exported —
  `comm -23 <wanted> <exported>` is empty. (Astoria's broken build had only 56/58.)

Verify command (re-runnable):
`comm -23 <(grep -oE 'DyLibSymbol\([^,]*,\s*"[^"]*"' src/Designer.bas | grep -oE '"[^"]*"$' | tr -d '"' | sort -u) <(nm -D --defined-only Controls/MyFbFramework/libmff64_gtk3.so | awk '$2=="T"||$2=="W"{print $3}' | sort -u)`

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
MyFbFramework). Removed the same from Ilwaco, build-verified clean. Scope was exactly as pre-scoped —
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
**Manifest:** removed 16 dangling `File=` entries from `MyFbFramework.vfp` (the deletions + 6
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
`ControlLibrary=Controls\MyFbFramework` left `Library.Path` as a *folder*, `DyLibLoad` on a directory
returned 0, no symbols resolved, and `Designer.CreateControl("Form")` gave the empty grey panel — plus
a refcount slip that broke every project after the first. Ilwaco cannot reach that state: the shipped
`[ControlLibraries] Path_0` names the `.so` file and a project's folder-form `ControlLibrary=` is
matched *folder-to-folder* against it, so the loaded library is reused; and the no-match branch builds
the path from the library's own `Settings.ini` (`[Setup] LibX64_gtk3`), never from a bare folder.
Astoria's second sub-fix, `GetControlLibraryVfpPath`, has no Ilwaco counterpart. **Verified by effect:**
two GUI projects opened in one session both render their form in the designer, and the Toolbox lists
the MFF controls (TestPlan T3/T24).

Found while checking it: `Controls/MyFbFramework/Settings.ini` still advertised thirteen library
variants (32-bit, GTK2, Windows DLLs) of which exactly one is reachable, plus three Windows lib-folder
keys read into fields nothing uses. Pruned to `LibX64_gtk3`, and `GetLibKey` — whose `#ifdef` ladder
could only ever pick that one — now returns it directly.

## Foundation status (2026-08-02)

- **Build baseline:** Ilwaco builds + runs on Linux (PROJECT_STATUS).
- **Rules:** `CLAUDE.md` created, carrying Astoria's practices adapted for Linux/GTK + the two rules.
- **Skills:** 9 platform-neutral FreeBASIC/MFF skills ported to `.claude/skills/` (renamed). Pending
  Ilwaco-specific rewrites: `build-ilwaco`, `verify-ilwaco-behaviour`, `release-ilwaco`,
  `update-ilwaco-docs`, `gtk-interop` (replacing `winapi-interop`).
