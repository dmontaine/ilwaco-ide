# Astoria → Ilwaco parity tracking

## ⇢ NEXT ACTION (staged for a fresh session) — compiler removal COMPLETE; resume the changelog walk

The big non-target strip is **done** for the whole compiled surface: `src/` (EditControl as staged task A,
then the rest of `src/*.bas`/`*.bi` — 11 files, 626 chains — **landed 2026-08-02**) and the MFF framework
(**staged task B — landed 2026-08-02**, see "Done — MFF non-target strip" below). The editor +
`libmff64_gtk3.so` are clean of *real* non-target `#if`/`#ifdef` directives; both build clean and the IDE
runtime-verified after each. The strip was then **extended across the whole tree** — non-MFF `Controls/`
(MariaDBBox, SQLite3, ScintillaControl, cJSON) and `Examples/` (cross-platform demos branch-stripped;
16 Windows-only demos deleted, Astoria-mirror) — landed 2026-08-02 in commits `a0919c5`, `422e931`,
`d0b22a1` (+ infra `0b61d0c`). See "Done — whole-tree non-target strip" below. Remaining:

1. **Compiler removal stage 2 — COMPLETE (2026-08-02). All three tasks DONE + build+runtime-verified.**
   - *Task 12 (per-project `CompilerPath` override)* — DONE, committed `0fb1746`.
   - *Task 11 (picker UI)* — DONE, **staged (uncommitted)**. Removed the Options compilers ListView +
     Default-Compilers combos + Add/Change/Remove/Clear + "Find Compilers" scan subsystem, and the
     frmParameters per-build compiler selector; also removed the `Compiler32/64Path` clobber on OK/Apply.
     Compiler tab is now an empty parent node.
   - *Task 13 (`[Compilers]` INI machinery)* — DONE, **staged (uncommitted)**. Retired `Compilers`/
     `pCompilers`/`Current/DefaultCompiler32/64` + the `[Compilers]` INI read/write; kept the fragile
     10-section load loop's `Compilers` KeyExists term and the bundled `Compiler32/64Path`. Runtime-verified
     by a real in-IDE compile (bundled fbc ran, `.bas→.c→.asm→.o` clean; only a shim `-lncurses` link gap
     remains — a packaging concern, not a code bug). Full surface in PROJECT_STATUS "Task 13 DONE" block.
   - **Net result:** the only compiler path in the system is the hard-coded `BundledCompilerPath`. "One
     compiler, no picker, no INI machinery" fully realized.
2. **Strip all 32-bit code (Ilwaco is 64-bit only) — STARTED 2026-08-02; pass 1 DONE.** Owner directive:
   "we can remove anything 32-bit related, ilwaco will be 64-bit only." Incremental, build after each pass.
   - **Pass 1 — DONE, build+runtime-verified, staged (uncommitted).** Removed the `tbt32Bit`/`tbt64Bit`
     32/64 build-target toolbar toggle and collapsed every `Bit32`/`tbt32Bit->Checked` consumer to the 64
     branch (compile path, debugger picks, `-gen gas64`, lib folder). Fixed a latent both-branches-32 bug in
     the intellisense temp-compile. `Bit32`/`tbt32Bit`/`tbt64Bit` now zero refs. Files: Main.bas,
     TabWindow.bas, Debug.bas, VisualFBEditor.bas.
   - **Pass 2a — debugger-32 subsystem — DONE, build-verified, committed.** Removed all `*Debugger32*`/
     `*DebuggerType32`/`Debug32Arguments` globals + the `cboDebug32`/`txtDebug32`/`cboDebugger32`/
     `cboGDBDebugger32` form controls (frmParameters + frmOptions) + load/save/dealloc; repointed shared
     debugger handlers to the 64 combo; fixed two more latent 32/64 bugs. Kept `lblDebugger321`.
   - **Pass 2b — compiler-32 — NOT started; EXACT edits in PROJECT_STATUS "Pass 2b" bullet** (context all
     read). `Compiler32Path`/`Compiler32Arguments`/`LibX32Folder`, the `Main.bas` include-resolver collapse,
     `TabWindow.bas` lib-path line, and frmParameters `txtfbc32`/`lblfbc32`/`lblAddCompilerOption32` + handler.
   - **Pass 2c — `CompilationArguments32` project property (~54 refs) — NOT started.** frmProjectProperties
     32-bit compilation-arg rows + TabWindow.bi struct + save/load. **Trap:** `lblCompilationArguments321`
     is a different control, keep it. Then a final `#ifdef __FB_64BIT__` guard sweep (keep the 64 branch;
     not Windows-only). See memory `project-64bit-only`.
3. **Resume the changelog walk** — next candidates: `53d8e473` (compile-warning fixes — check Ilwaco's
   shared files), then the menu-taxonomy feature ports.

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
