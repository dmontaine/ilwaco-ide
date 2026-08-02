# Astoria → Ilwaco parity tracking

## ⇢ NEXT ACTION (fully scoped, ready to apply) — remove Help ▸ GitHub menu (Astoria `d275dc93`)

Owner-approved 2026-08-02; **delegate execution to a Sonnet worker**. Self-contained, ~18 lines, no
`.bi` decls / enable-lines / HotKeys.txt entries. Exact set:
- **`src/Main.bas` 7776–7785** — the whole `Var miGitHub = miHelp->Add(ML("GitHub"))` submenu (8 items:
  FreeBasic/VisualFBEditor/MyFbFramework Repository/WiKi/Discussions + 2 separators). **Keep** 7774–7775
  (FreeBasic WiKi/Forums) and 7786+ (separator, Tip of the Day, About).
- **`src/VisualFBEditor.bas` 1171–1178** — the 8 `Case` handlers (`GitHubWebSite` [orphan],
  `FreeBasicRepository`, `VisualFBEditorRepository/WiKi/Discussions`, `MyFbFrameworkRepository/WiKi/
  Discussions`). **Keep `OpenUrl`** (used by ~10 other Help commands).
- No other files. Build with the recipe in PROJECT_STATUS / memory `reference-linux-build`; expect clean.
- Then continue the walk (e.g. Direct2D strip — see Menu-taxonomy / strip-windows notes).

---

The resumable backlog for bringing Ilwaco (Linux/GTK) toward Astoria (Windows). Astoria's history is
the diff from the shared VisualFBEditor base, so we walk it oldest-first and classify each change.
Source of truth: `../astoria-ide/Documentation/DetailedChangelog.md` (888 commits, 2026-07-02 →
2026-08-02) and `../astoria-ide/Documentation/AstoriaIDESignificantChanges.md` (curated §1 added /
§2 removed / §3 inherited-defect fixes).

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

**Coverage of Astoria's *specific* deltas in Ilwaco today: ~none.** Ilwaco sits at ~upstream
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
| `e212819d` | Bottom panel **collapse-on-pin** (+ persistence, split out below); add PROJECT_STATUS | PORT | **collapse-on-pin DONE** 2026-08-02 (build-clean); persistence deferred ↓ |
| `c2672840` | Right panel not collapsing on Pin click | PORT | **DONE** 2026-08-02 (build-clean) |
| `64daa66e` | Left panel not collapsing on Pin click | PORT | **DONE** 2026-08-02 (build-clean) |
| `bef92671` | Form Designer never activating (strip-tool root cause) | REVIEW | root cause was a Win build tool; underlying designer export-table issue may be base-general — verify against Ilwaco |
| `b5554063` | Bundle FBC + GDB toolchain in-repo | DONE | Ilwaco bundles Linux fbc (no gdb yet) |
| `15e66cc5`,`e139c2cc` | Remove 32-bit compiler binaries | SKIP | Ilwaco is 64-bit; no Win32 toolchain to remove |
| `53d8e473` | Fix all compile warnings (WStr wrapping etc.) | PORT | check if same warnings exist in Ilwaco's shared files |
| `56f6d180`,`b3633bc5`,`a7c7839d` | Dark mode (uxtheme/ntdll Win32) | REIMPLEMENT | Ilwaco needs GTK dark mode (settings already have `DarkMode=true`) |
| `c494207f`,`7baebd1e`,`add4642a`,`76abaa5a` | Delete dead GTK/Linux/32-bit code | INVERT/SKIP | do **not** apply — this is Ilwaco's live platform |
| `ae74b31c` | Rename "Service"→"Tools" menu, inner "Tools"→"External Tools" | PORT | **DONE** 2026-08-02 (caption-only, internal names unchanged; `Main.bas` `miXizmat`) |
| `49ec5ccd`, §menu-taxonomy | UI approachability: per-menu **Advanced** submenus; menu reorg; caption cleanups; options-dialog simplification | PORT (big) | **deferred, and re-scoped — see "Menu taxonomy" section below** |

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

The other half of `e212819d` — remembering collapsed-vs-closed state across restart — is a separate,
riskier change and is **not** done. It needs infrastructure Ilwaco's older base lacks: `IsBottomCollapsed`
(+ Left/Right), `bApplyingStartupLayout`, `SaveMainWindowPanelLayout`, the `*Collapsed` INI keys, and
`UpdateBottomPinLayout` / `MIN_BOTTOM_PANEL_HEIGHT` / `BOTTOM_PIN_STRIP_WIDTH`, plus edits to
`frmMain_Create`/`frmMain_Show`/`frmMain_Close`. Track as its own item; do after more of the panel
infrastructure is understood. Ilwaco's `CloseLeft/Right/Bottom` also still carry `#ifdef __USE_GTK__ …
#else …` branches — strip the `#else` (Windows) side when this work touches them.

## Next action

After the deferred persistence item (optional), continue the walk. **Candidate next PORT:** `ae74b31c`
— rename the top-level **"Service"** menu (Uzbek `miXizmat`) to **"Tools"** and the inner "Tools"
submenu to "External Tools"; verify Ilwaco still has the old naming first. Also `53d8e473` (compile
warning fixes) — check whether Ilwaco's shared files emit the same warnings. Skip the GTK/Linux/32-bit
stripping commits (`c494207f`, `7baebd1e`, `add4642a`, `76abaa5a`, `15e66cc5`, `e139c2cc`).

## Foundation status (2026-08-02)

- **Build baseline:** Ilwaco builds + runs on Linux (PROJECT_STATUS).
- **Rules:** `CLAUDE.md` created, carrying Astoria's practices adapted for Linux/GTK + the two rules.
- **Skills:** 9 platform-neutral FreeBASIC/MFF skills ported to `.claude/skills/` (renamed). Pending
  Ilwaco-specific rewrites: `build-ilwaco`, `verify-ilwaco-behaviour`, `release-ilwaco`,
  `update-ilwaco-docs`, `gtk-interop` (replacing `winapi-interop`).
