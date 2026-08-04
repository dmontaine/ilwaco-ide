# Ilwaco IDE — Session History

**Extracted from [PROJECT_STATUS.md](PROJECT_STATUS.md) on 2026-08-03.** These are the session handoffs
that have scrolled off the top of PROJECT_STATUS — a faithful record kept for provenance, newest-first.
They are **snapshots of their own moment**: some describe state (e.g. the shim living only in scratchpad,
work "staged/uncommitted") that later sessions superseded. For the **current** state, next actions, and
the live build/run recipe, always read [PROJECT_STATUS.md](PROJECT_STATUS.md) — not this file.

For the mission, the port method, and the Linux/GTK build rules, see [CLAUDE.md](CLAUDE.md);
for the classified port backlog, [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md).

---

## ✅ DONE (2026-08-04) — bottom-panel collapse: dedicated horizontal rail (COMMITTED)

Finished `e212819d`/`ef3b43e9` (bottom-panel collapse + persistence). The collapsed-panel affordance is a
horizontal activity rail mirroring the left/right rails: on collapse `pnlBottom` is hidden and a 25px
`pnlBottomRail` (`alBottom`) is shown — a pin at the right plus 14 tab buttons (`Output..Immediate` always;
`Locals..Profiler` only with the debugger on). Live-verified on `:0` by the owner. Full detail + the GTK/MFF
facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 — bottom-panel collapse via
a horizontal activity rail". Changed `src/Main.bas` + `src/ilwaco.bas`. Key fixes: pin repaint on reopen
(`ShowBottom` → `gtk_widget_show_all(pnlBottomPin.Handle)`); pin docked `alRight` (was `alLeft`, which jumped);
debug buttons re-asserted on the rail via `CloseBottom`/`SetDebugTabsVisible`; rail pin unclipped via a
`.ilwacorailpin` `GtkCssProvider`; and a **debugger-toggle desync fix** — `ilwaco.bas "UseDebugger"` reads
GTK's real `gtk_check_menu_item_get_active` instead of MFF's stale `Checked`. Persistence via the
`BottomClosed` INI key round-trips.

---

## ✅ DONE (2026-08-04) — left/right panel collapse: vertical-text rail + pin-repaint fix (UNCOMMITTED, verified)

Owner asked to make the **left/right tool panels collapse and reopen** with a **visual** affordance (not a
menu), and refined it to **look like Astoria's collapsed strip**: a thin **vertical-text** tab strip with a
**pin at the top**. Delivered as a **GTK REIMPLEMENT**. On collapse the panel is hidden entirely and a
separate 34px **rail** appears at the edge: a pin icon at top (re-expands to the last tab) above the tab
captions as **rotated vertical text**. **Both LEFT and RIGHT work, live-verified.** Full detail + the
hard-won GTK/MFF facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 —
left/right panel collapse via a vertical-text activity rail".

**State: COMPLETE, build-clean (`fbc` exit 0), UNCOMMITTED** on `bbd8ab0`. Changed files: `src/Main.bas`
+ `src/ilwaco.bas` (the `ilwaco` binary + `src/ilwaco.{asm,c}` are build byproducts — do not commit).
Verified live on `DISPLAY :0` by screenshot: each panel collapses to a vertical strip (pin icon above
rotated `Project`/`Toolbox` and `Properties`/`Events`); the pin re-expands to the last tab; each text
button re-expands and selects its tab; the **expanded-panel pin repaints after reopen** (the reported bug —
fixed); and both strips show **collapsed at startup** with `LeftClosed=true`/`RightClosed=true`. Additive
to MFF → no `.so` rebuild.

**Key implementation points (`src/Main.bas`):** the rail is text-only because MFF renders no icon on a
`CommandButton`/`Label` on GTK and rotates no toolbar text (owner chose vertical-text-only over a
custom-raw-GTK icon+text rail). Pin = one-button `ToolBar` with `gtk_toolbar_set_show_arrow(…,FALSE)`
(reuses the `PinLeft`/`PinRight` command). Tab buttons = `CommandButton`s with caption rotated via
`gtk_label_set_angle(gtk_bin_get_child(…),90/270)` (`RotateRailButton` helper), `.Designer=@frmMain` set,
`OnClick` handlers (`railLeftProjectClick` etc.). **Pin-repaint fix:** `Show{Left,Right}` now call
`gtk_widget_show_all(pnl…Pin.Handle)` + `gtk_widget_queue_resize(overlay…)` so the overlay pin remaps and
repaints. `Get…ClosedStyle → Not pnl….Visible`. `ilwaco.bas`: `Pin{Left,Right}` one-liners.

**Supersedes** the deferred `e212819d`/`ef3b43e9` left/right *persistence* item (save/load already works
via `Get…ClosedStyle` → `LeftClosed`/`RightClosed` INI keys + `frmMain_Create` re-apply). The **bottom**
panel keeps the old collapse-to-strip behaviour and its persistence is still deferred.

**NEXT:**
1. **Commit** `src/Main.bas` + `src/ilwaco.bas` + the two docs (message: vertical-text panel-collapse rail
   + pin repaint; not the binary, per precedent) — *only when the owner asks.*
2. **Optional hygiene:** `tab{Left,Right}_SelChange`/`_Click` and the focus-loss auto-collapse still carry
   dead `TabPosition = tp{Left,Right}` / `Width = 30` guards (can no longer be true); a `no-dead-code`
   pass can drop them. Rail button heights (84/96px) and rotation angles are tuneable if the text looks off.
3. **Resume the changelog walk** (see the session-handoff section below): bottom-panel *persistence*
   (`e212819d`/`ef3b43e9`), then `4bd02894`, then the `49ec5ccd` menu-taxonomy cluster.

**Test caution:** kill by PID (`pkill -x ilwaco`), `git checkout Settings/` after any launch, screenshots
via `scrot` on `DISPLAY=:0`, clicks via `xdotool`. **The Claude desktop app steals focus** — re-activate
the IDE with `xdotool windowactivate --sync $(xdotool search --name "Ilwaco IDE" | head -1)` before each
click, and verify `getactivewindow getwindowname` is the IDE. Display is 2560×1340 (screenshots come back
2000-wide → coords ×1.28). Collapsed rail buttons (real coords): left pin ≈(17,135), Project ≈(17,225),
Toolbox ≈(17,305); right pin ≈(2543,130), Properties ≈(2543,230), Events ≈(2543,305).

---

## ✅ DONE (2026-08-04) — documentation-maintenance apparatus + Astoria doc-set analogues (UNCOMMITTED)

Ported Astoria's document-maintenance discipline to Ilwaco, **adapted for Linux/GTK**, and gave every
file in Astoria's `Documentation/` folder an Ilwaco analogue. **The rule now has teeth:** a checker
catches doc drift, a skill says what to update when, and CLAUDE.md points at both.

- **`Tools/DocCheck.py`** — Astoria's checker, Linux-adapted and trimmed to 3 checks: (1) a doc names
  a *removed* feature as if it ships (`REMOVED_FEATURES` seeded with Ilwaco's removals), (2) a doc
  names a deleted file in inline code, (3) a maintained doc is missing from the rule table. Dropped
  the Windows-only bits (Chrome-PDF/`.txt` freshness, PowerShell changelog, `ROADMAP.md` §-check);
  file-suffix set is Linux (`.so`/`.sh`). Fixed a case-sensitivity bug in the FS fallback. **Green:**
  `python3 Tools/DocCheck.py` → "Documentation is current (10 documents checked)"; `--selftest` OK.
- **`Documentation/TestPlan.md`** — carries **the rule table** (which doc to update when) that
  `DocCheck` enforces, plus the current (thin) test scenarios and the Linux verify-by-effect method.
- **`.claude/skills/update-ilwaco-docs/SKILL.md`** — the trigger table as a skill (now registered).
- **`CLAUDE.md`** — Working practices now require `DocCheck` before commit and fold docs into "finish
  the whole job"; `update-ilwaco-docs` moved from pending to shipped.
- **Doc analogues** (all listed in the rule table): real content — `UpstreamFixes.md`,
  `TechnicalDebt.md`, `Testing.md`, `ControlTesting.md`, `IlwacoIDESignificantChanges.md`; honest
  scaffolds (purpose + Astoria source + "GTK review needed", per owner's choice) — `Controls.md`,
  `MyFbFrameworkGuide.md`, `FrameworkFeatures.md`, `IlwacoIDEManual.md`; plus root `CHANGELOG.md`.
  `AstoriaParity.md` + `AstoriaDetailedChangeLog.md` are excluded from `DocCheck` as historical
  records (like Astoria excludes its `DetailedChangelog`).

**NEXT:** commit when asked (all uncommitted). Fill the scaffolds as their subjects stabilise. Keep
`DocCheck` green — it runs on Documentation/*.md and is the pre-commit gate now.

---

## Session handoff (2026-08-03, earlier) — changelog walk + debug-tab visibility ported

**START HERE.** Continued the Astoria→Ilwaco changelog walk from the oldest entries in
[AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md). Resolved 5 entries (backlog
**401 → 396**) plus one sub-item pulled forward. Committed+pushed: first three (doc-only) `72a741b`,
`53d8e473` `c087255`, `4cf72752` `c8c9ce7`, doc-clarification `e09fa37`. The debug-tab-visibility work
(below) is source+docs, build+runtime-verified, **staged/uncommitted** at time of writing.

- **Debug-tab visibility** (`49ec5ccd` sub-item, pulled forward at owner's request) — **DONE,
  build+runtime-verified.** The 7 debug tabs (Locals…Profiler) now show only when `UseDebugger` is on
  (Immediate stays permanently visible). Required a new **MFF `DetachTab`** method (remove a tab without
  destroying its `TabPage`, with a GTK `g_object_ref` so the page widget survives re-add) + three subs +
  4 call sites in `Main.bas`. Verified both states by screenshot (off → tabs hidden; on → re-appear, no
  crash). Additive/non-virtual MFF change → no `.so` rebuild. This is **distinct** from `4cf72752`'s
  content-*clearing*. See AstoriaParity "Done — debug-tab visibility". `49ec5ccd` stays in the backlog
  (only this sub-item is done; the menu-taxonomy bulk remains deferred).

- **`4cf72752`** (WIN32_WINNT header bug + bottom-panel tab clearing) — **PORT (partial), DONE.** The
  `_WIN32_WINNT` `=`→`>=` header fix is N/A (Windows headers, not on the GTK build path); the AI-KnowledgeBase
  path fix is N/A (AI removed). Ported the **bottom-panel/debug tab clearing**: new `ClearAnalysisPanels`/
  `ClearDebugPanels` in `Main.bas`, wired into `CloseProject` + the debug-`End` case in `ilwaco.bas`, so
  stale project/debug results don't linger after a project closes. Forward-declared `ClearThreadsWindow` in
  `Main.bi`. Build clean (`fbc` exit 0); IDE launches, all 14 bottom tabs render. See AstoriaParity
  "Done — bottom-panel/debug tab clearing (`4cf72752`)".
- **`53d8e473`** (Fix all compile warnings) — **PORT (partial), DONE, committed `c087255`.** Ilwaco's
  production build was already warning-clean; most of Astoria's fixes targeted already-stripped code (Canvas
  Direct2D, Debug `SetConsoleTitle`) or don't reproduce. Ported the 2 `@literal→WString Ptr` hunks in
  `src/Debug.bas` (`brk_comp`, `list_all` → `WStr(...)`).

- **`bbfa3999`** (Initial Win64 fork import) — the fork anchor / base snapshot itself, not a port. Pruned.
- **`5a097399`** (Update INI window-state + rebuild exe) — NONCODE (Settings + binary only). Pruned.
- **`bef92671`** (Form Designer never activating) — **REVIEW → N/A, verified.** Astoria's designer was dead
  because *its own* `strip_gtk_preprocessor.ps1` deleted the `#ifdef __EXPORT_PROCS__` blocks from MFF,
  shipping `mff64.dll` with zero exports. Ilwaco never ran that tool; our `ppstrip.py` preserved every
  such block. **Proof:** `libmff64_gtk3.so` exports 469 symbols and *all 36* dispatchers that
  `src/Designer.bas` resolves via `DyLibSymbol()` are present (`nm -D` diff empty). Full narrative +
  re-runnable verify command in AstoriaParity "N/A — Form Designer export table intact".
- **Kept (partial):** `e212819d` + `ef3b43e9` — the bottom-panel **persistence** cluster (collapse half
  already DONE 2026-08-02; persistence still deferred — needs the panel-state save/restore infra).

---

## Session handoff (2026-08-03, earlier) — UTF-8/LF-only DONE + ALL AI REMOVED (both build+runtime-verified)

**START HERE.** This session landed, in order, all committed+pushed to `main`: (1) verified prior commit
`1dc1650`; (2) **UTF-8/LF-only** (`d99b23c`); (3) **AI removal slice 1/2** — Options AI page + `frmAIAgent.frm`
(`d7bf853`); (4) **AI removal slice 2/2** — the entire main-window AI subsystem (this commit, pending push at
time of writing). All build-verified (`fbc` exit 0) and runtime-verified (IDE launches to a stable window, full
editor, "IntelliSense fully loaded", status bar UTF-8/LF, no error dialog, no `DebugInfo.log`).

**TASK 2 (remove ALL AI elements) — COMPLETE.** Slice 2/2 removed (~−1360 lines): from `Main.bas` the AI
tab/panel/toolbar creation, the 13 AI subs (cboAIAgentModels_Change, EscapeJsonForPrompt/EscapeFromJson,
AIGetMaxChunkSize/AIPrintAnswer/AISplitText, HTTPAIAgent_Complete/_Receive, AIRequest, txtAIRequest_Activate,
AIChatPaste/AIRelease/AIResetContext, AddMRUAIChat), the knowledge-prompt block, the `mnuAIChat` menu, the
LoadToolBox wiki/markdown→AIContext generation (kept the toolbox build + DyLibFree cleanup), the `[AIAgents]`
INI load body (⚠ **kept the `AIAgents` KeyExists term in the fragile 10-section `Do Until` loop** per task-13
precedent — removing a term would force restructuring `= -10`), the AIChat MRU save + exit save, the tpAIAgent
INI write, the deallocs, and the AI toolbar `imgList.Add` icons; from `ilwaco.bas` the `mClickAIChat` sub +
all AI dispatch cases; from `Main.bi` the AI declares/globals + the `ModelInfo` type; from `TabWindow.bi` the
`MD2RTF.bi` include; deleted `src/MD2RTF.bi` + its `.vfp` entry. **Verified:** left panel is now Project|Toolbox
(no "AI Agent" tab); clean build+launch. Slice 2 built green on the first try.
**Follow-up (minor, deferred):** the `.rc` still registers now-unused AI toolbar icons (NewChat/AddComment/…);
harmless. The kept `[AIAgents]` INI loop term is the only remaining "AI" token in `src/` (functional, not dead).

**Changelog backlog seeded (2026-08-03).** Created [Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md)
— a **pruned** copy of Astoria's 888-commit `DetailedChangelog.md`. Deleted everything already resolved for
Ilwaco: the 6 AstoriaParity *done ports* (pass 1), then **481 non-actionable** commits (pass 2 — NONCODE 426,
INVERT 9, WIN32 20, AI 26), leaving **401 actionable** entries oldest-first. The file's header carries the
**maintenance rule** (delete DONE + the four non-actionable classes, matched on the commit *headline*). The
one-off classifier is in scratchpad (`prune_changelog.py`) — criteria are re-derivable from the rule.

**NEXT — resume the changelog walk from the 5 oldest remaining in that file:**
1. `bbfa3999` — the fork-import anchor (base; not a port — the walk's start marker).
2. `e212819d` — bottom-panel **persistence** (collapse half DONE; persistence still deferred — see the
   "panel collapse-on-pin" Done section below for the infrastructure it needs).
3. `ef3b43e9` — fix first-start collapsed bottom layout (same panel-persistence cluster).
4. `5a097399` — "update INI + rebuild exe" (near-noise; a rebuild/state-save — low value).
5. `bef92671` — Form Designer never activating (**REVIEW** — Astoria's root cause was a Win build tool;
   verify whether the underlying designer export-table issue reproduces in Ilwaco).
The 32-bit strip and the UTF-8/LF + AI strips are the standing owner directives, now all cleared.

---

### Detail from earlier in this session (kept for reference)

1. **Verified prior commit `1dc1650`** (removed dead `EditControl2.bi`; consolidated the two AI "Translate"
   buttons — "TranslateE" gone, kept "Translate" now targets `ML("English")`) which had been committed
   WITHOUT a build. Rebuilt the stale tracked `./ilwaco` binary in the process.
2. **UTF-8-only + LF-only — DONE (TASK 1 below, now complete).**

### TASK 1 — UTF-8-only + LF-only — DONE (build+runtime-verified; −295/+22 across 6 files)
Owner directives: UTF-8-only + LF-only; remove the encoding/newline *selection* and collapse the engine to
**UTF-8 + LF**. Decision kept: **new files = UTF-8 no-BOM**; **existing BOM preserved on load/save round-trip**.
The `FileEncodings`/`NewLineTypes` enums stay in MFF `Application.bi` (MFF untouched); `PlainText/Utf16BOM/
Utf32BOM` + `WindowsCRLF/MacOSCR` are now unused enum values. What was done:
- **Menu** (`Main.bas`): deleted the whole `File ▸ File format` submenu block (the 5 encoding items + 3 newline
  items + separators + the two `->Checked=True`), keeping one `miFile->Add("-")` so no doubled separator.
- **Dispatch** (`ilwaco.bas`): deleted both `Case "PlainText"…` and `Case "WindowsCRLF"…` blocks.
- **`ChangeFileEncoding`/`ChangeNewLineType`** (`Main.bas`): bodies collapsed to just set the status panel to
  `"UTF-8"` / `"LF"`. Signatures + both caller sites (`Main.bas` 9105-9106, `TabWindow.bas` 424-425) kept.
- **Status setup** (`Main.bas`): `"UTF-8 (BOM)"`→`"UTF-8"`, `"CR+LF"`→`"LF"`.
- **Globals** (`Main.bi`): deleted the now-unused `mi*` MenuItem-pointer line. Kept `DefaultFileFormat`/
  `DefaultNewLineFormat`.
- **Init** (`Main.bas`): the two `ReadInteger` lines are now hard-sets `DefaultFileFormat = FileEncodings.Utf8`,
  `DefaultNewLineFormat = NewLineTypes.LinuxLF`. `TabWindow.bas` still reads these for new tabs → UTF-8 no-BOM + LF.
- **`EditControl.bas` LoadFromFile:** BOM block collapsed to `If <UTF-8 BOM> Then Utf8BOM/"utf-8" Else Utf8/
  "ascii"`; newline forced to `LinuxLF`. Removed the now-dead write-only `NewLineStr` local. (`CheckUTF8NoBOM`
  is an MFF function — still used inside MFF — so not orphaned.)
- **`EditControl.bas` SaveToFile:** encoding block → `If Utf8BOM Then "utf-8" Else "ascii"`; newline → `Chr(10)`;
  removed the unused `FileEncodingSymbols`; folded the PlainText write branch into the Else.
- **`frmOptions`:** removed the **entire "Defaults" options page** — it existed *only* for these two combos
  (tree node `Defaults` → `pnlDefaults` → `grbDefaults` "Default Settings for New Files" → `vbxDefaults` → the
  two `hbx` → lbl+cbo, plus a duplicate `cboDefaultNewLineFormat` designer block). Removed the tree node, the
  panel-switch line, the populate/save/INI-write, and all `.bi` declarations. (Same pattern as the English-only
  session's removal of the Localization page.)
- **Verified by effect:** status bar reads "UTF-8" / "LF"; File menu has no "File format" submenu (no doubled
  separator); Options ▸ Code Editor has no "Defaults" node and opens cleanly. **Not** UI-verified: the on-disk
  save round-trip (deferred per owner — "as we walk the Astoria changelog it'll likely be covered"; the
  Load/Save code path is straightforward and compiles).
- **Deferred (low value):** the `Open … Encoding "utf-16"/"utf-32"` fallback chains in `Main.bas` (~15 places;
  some open utf-32/16 *first*, not as fallback — don't blind-sed). Optional secondary cleanup.

### TASK 2 (NEXT, IN PROGRESS) — remove ALL AI elements (large; own session)
Owner: remove the AI pane, model selection, and all AI support code. **Surveyed 2026-08-03 — full map below.**
The AI system is tightly interwoven; it is NOT cleanly separable into independently-building halves **except one
slice**: the Options "AI Agent" page + `frmAIAgent.frm` (that form is `#include`d *only* by `frmOptions.frm:9`).
MD2RTF and the main-window panel/backend must come out together (their symbols reference each other).

**Confirmed facts (survey):**
- `MD2RTF.bi` is **AI-only** — entry `MDtoRTF` is called only from AI paths (`Main.bas:8057`, `ilwaco.bas:130/181`),
  and it uses the AI global `AIRTF_HEADER`. Delete with Slice B. Included by `TabWindow.bi:24`; `.vfp` line 23.
- `frmAIAgent.frm` — whole form, referenced **only** by `frmOptions.frm:9` (`#include once`). `.vfp` line 29.

**SLICE A — Options "AI Agent" page + `frmAIAgent.frm` — DONE (build+runtime-verified, uncommitted).**
Removed from `frmOptions.frm`: the `#include once "frmAIAgent.frm"`, the `AI Agent` tree node (its `tnHelp` Var
dropped as now-unused), the `pnlAIAgent.Visible` panel-switch, the `pnlAIAgent` panel + all AI designer blocks
(`grbDefaultAIAgent`/`cboAIAgent`/`lvAIAgentTypes`/`hbxAIAgent`/`grbAIAgent` + 4 `cmd*AIAgent` buttons — interleaved
with Help blocks, removed per-block), the Form_Create `lvAIAgentTypes.Columns` setup, the LoadSettings populate, the
`cmdApply` rebuild + `[AIAgents]` INI write, and the 4 `cmd*AIAgent_Click` + `lvAIAgentTypes_ItemActivate` handlers.
`.bi`: the 6 handler `Declare`s + all AI control decls. Deleted `src/frmAIAgent.frm` + its `.vfp` entry.
⚠ **Trap hit & fixed:** the `cmdApply` `Dim i As Integer` sat *inside* the AI block but was shared by the MakeTools/
Debuggers/etc. bare-`i` loops below — removing it stranded `i` (error 42). Re-added a bare `Dim i As Integer` where
the block was. **Verified:** build exit 0; IDE launches; Options ▸ Help has no "AI Agent" child; dialog opens clean.
Kept the `AIAgent*` **globals** (Main.bi) + `pAIAgents` dict + INI *load* (Main.bas) — the backend still uses
  them; Slice A only removes the *editing UI*. Build-verify → intermediate state: AI still runs from INI, not
  editable in Options.

**SLICE B (the interdependent remainder) — main-window AI tab/panel/toolbar + backend + globals + MD2RTF:**
- `Main.bas` (~191 refs): globals `txtAIRequest`(88)/`HTTPAIAgent`(96)/`AIMessages`+`AIContext`(98)/`pHTTPAIAgent`(128);
  the AI tab/panel/toolbar creation (`tpAIAgent` 7183, `tbAIAgent` 7311-7331 buttons, `pnlAIAgent`, `txtAIAgent`
  7344, `txtAIRequest` 8125, `splAIAgent` 8135); `AIContext.Add` population (5128-5168, inside the component-scan
  sub); the knowledge-prompt block (~7514-7551); `EscapeJsonForPrompt`(7346)/`EscapeFromJson`(7429)/
  `AIGetMaxChunkSize`(7565)/`AIPrintAnswer`(7583)/`AISplitText`(7595)/`HTTPAIAgent_Complete`(7674)/
  `HTTPAIAgent_Receive`(7686)/`AIRequest`(7832)/`txtAIRequest_Activate`(7904); the `imgList.Add` AI images +
  `pimgListAIProviders32`/`pimgListAIModels32` image lists.
- `ilwaco.bas` (~16 refs): the AI dispatch cases (`AINewChat`/`AIAddComment`/`AIOptimizeCode`/`AIIntellicode`/
  `AITracepointError`/`AIWebBrowserItem`/`AIConvertCtoFB`/`AITranslate`/`AIRelease`) + AI-model handlers + the
  `MDtoRTF` renders (130/181).
- `Main.bi` (~9 refs): `pimgListAIProviders32`/`pimgListAIModels32`(82), `pHTTPAIAgent`(92), `bAIAgentFirstRun`(107),
  `AIAgentPort`/`AIAgentContentSize`(122), `AIAgentStream`(123), `AIAgentTop_P`/`AIAgentTemperature`(124),
  `AIAgentHost`/`Address`/`APIKey`/`ModelName`/`Provider`/`Name`/`AIRTF_HEADER`/`AIEditorFontName`(125),
  `DefaultAIAgent`/`CurrentAIAgent`(131), `pAIAgents`(196); plus the INI load/cleanup of these in `Main.bas`.
- `TabWindow.bi:24`: remove `#include once "MD2RTF.bi"` + its 1 AI ref. Delete `src/MD2RTF.bi`.
- `.vfp`: remove `File=src/MD2RTF.bi` (23) and `File=src/frmAIAgent.frm` (29).

## Session handoff (2026-08-03, earlier) — English-only (all other languages removed)

**START HERE.** Owner directive: **the app is English-only; remove other languages.** Build- and
runtime-verified (`fbc` exit 0; the IDE launches and renders fully in English — all menus, panels, and
the 14 bottom tabs; no garble, no `DebugInfo.log`; screenshot-confirmed).

- **How it works (no call-site churn):** MFF's `ML(V)` returns its argument `V` unchanged when
  `App.CurLanguage = App.Language`, and `English.lng`'s `[General]` values are empty (so English already
  resolves to the literal `ML("…")` argument). Forcing English makes all 1,829 `ML()` call sites pass
  through to their English text — **no call sites changed**. `LoadLanguageTexts` now hard-codes
  `App.CurLanguage = "english"` (dropped the `iniSettings.ReadString("Options","Language",…)`), and still
  loads the kept `Settings/Languages/English.lng`.
- **Removed the entire "Localization" Options page** (`frmOptions.frm`/`.bi`): the language picker
  (`cboLanguage`), the `grbLanguage`/`pnlLanguage`/`pnlLocalization` container tree, the "Localization"
  options-tree node + its panel-switch line, the `Language` INI save, the `newIndex`/`oldIndex`
  change-detect + "Localization changes… next run" message, the `Languages` `WStringList`, **and the whole
  ~665-line `cmdUpdateLng_Click` translator tool** ("Scan and Update … language files") with its
  `chkAllLNG` checkbox, `lblShowMsg` status label, and the unused `cmdUpdateLngHTMLFolds`/`cmdReplaceInFiles`
  vestigial declares. All six Localization-page child controls were accounted for (no orphans); tree-wide
  grep of every removed symbol is clean.
- **Deleted files:** all `Settings/Languages/*.lng` **except `English.lng`** (22 files incl. the `-AI`
  variants, `default.lng`, `tester`/`swabian`, `english.html`, translator `Readme.txt`) and the 4
  non-English per-language assets in `Settings/Others/` (`Compiler options.chinese(*)`, `KeywordsHelp.chinese(*)`;
  kept the base `KeywordsHelp.txt`/`AsmKeywordsHelp.txt`/`Compiler options.txt`).
- **Residual (harmless, deferred):** `English.lng` + the `LoadLanguageTexts` parser are kept as the active
  English path (not dead code). A few per-asset runtime guards (`If CurLanguage="english" … Else <lang>`) in
  Main.bas now always take the English branch — left as-is (runtime-guarded, low value). MFF's `ML`/
  `CurLanguage` i18n *mechanism* stays (framework capability, now inert for our app).

## Session handoff (2026-08-03, earlier) — rebrand VisualFBEditor → Ilwaco IDE

**START HERE.** Owner directive: rebrand the product. **User-facing name is "Ilwaco IDE"; files, the
executable, and build artifacts are "ilwaco" (lowercase).** Build- and runtime-verified.

- **User-facing strings → "Ilwaco IDE":** `APP_TITLE`, the main-window title (dropped the now-redundant
  `(x64)`), splash, About box, ~10 MsgBox captions, file-dialog filter labels (`Ilwaco IDE Project/Session/
  Project Group` — these are `ML()` keys, English fallback shows the new text), "When Ilwaco IDE starts",
  the `.rc` `ProductName`/`ApplicationTitle`/`FileDescription`, and the AI-prompt knowledge block prose.
- **Files/executable → `ilwaco`:** `git mv` of `src/VisualFBEditor.bas`→`src/ilwaco.bas`,
  `src/VisualFBEditor.rc`→`src/ilwaco.rc`, `VisualFBEditor.vfp`→`ilwaco.vfp`, `.vfs`, `.code-workspace`,
  `_Change.log`, `Resources/VisualFBEditor.ico`→`Resources/ilwaco.ico`, `VisualFBEditor64.desktop`→
  `ilwaco.desktop` (rewritten clean — the old one had the original author's `/mnt/media` paths),
  `Settings/VisualFBEditorX64_gtk3.ini`→`Settings/ilwaco.ini`. The whole-program `#cmdline` output is now
  `-x ../ilwaco`; `SettingsPath` is `Settings/ilwaco.ini`. Updated `build-linux.sh`, `makefile`, `.poseidon`,
  and every internal file reference (icon path, `.vfp` refs). Renamed `Help/AI prompt/KnowledgeBase/…
  VisualFBEditor IDE Environment.md`→`Ilwaco IDE Environment.md` + its two code refs.
- **Deleted** the 3 dead-platform settings INIs (`VisualFBEditor32.ini`, `…64.ini`, `…X64_gtk2.ini` — 32-bit
  and GTK2 are stripped platforms) and the old committed binary `VisualFBEditor64_gtk3` (rebuilt as `ilwaco`).
- **Left intact (functional/invisible):** the FB `Namespace VisualFBEditor` + `VisualFBEditorApp` type/global,
  the `WhenVisualFBEditorStarts` INI key + variable, `frmSplash`'s `This.Icon = "VisualFBEditor"` resource
  name, the AI-agent's upstream GitHub URL / `site_name` / `InStr(filename, "VisualFBEditor")` request-detection
  (these key off the original name deliberately), and historical/provenance mentions in docs. Also unchanged:
  a few commented-out `gtk_window_set_icon_name("VisualFBEditor…")` dead lines (no-comment sweep).
- **Caution (updated):** the old `pkill` note now applies to `ilwaco` — `pkill -f ilwaco` risks matching the
  caller; use `pkill -x ilwaco` or kill by PID. `git checkout Settings/` after any launch (writes `ilwaco.ini`).

## Session handoff (2026-08-03, earlier) — 64-bit-only strip COMPLETE (passes 1, 2a, 2b, 2c all DONE)

**START HERE.** Owner directive: **Ilwaco is 64-bit only — strip all 32-bit code** (memory
`project-64bit-only`). The whole 32-bit strip is now **done and build+runtime-verified**. Passes 1 and 2a
were committed in prior sessions (`a1b2722`, `12044a1`); **passes 2b and 2c are staged in the working tree,
uncommitted** (build-verified `fbc` exit 0 each; the IDE launches to the "Visual FB Editor (64-bit)" window
and idles clean — no error dialog, no `DebugInfo.log`, only the documented-harmless AppAddin/AppConsole
resource warnings). Grep of `Compiler32|LibX32|CompilationArguments32` (excluding the kept `…321` control)
is **empty**.

- **Pass 1 — DONE (committed `a1b2722`).** Removed the `tbt32Bit`/`tbt64Bit` 32/64 build-target toolbar
  toggle; collapsed every `Bit32`/`tbt32Bit->Checked` consumer to the 64 branch. Fixed a latent
  both-branches-32 bug. `Bit32`/`tbt32Bit`/`tbt64Bit` refs are zero.

- **Pass 2a — debugger-32 subsystem: DONE (committed `12044a1`).** Removed all `*Debugger32*`/
  `*DebuggerType32`/`Debug32Arguments` globals + the `cboDebug32`/`txtDebug32`/`lblDebug32` (frmParameters)
  + `cboDebugger32`/`cboGDBDebugger32`/`lblDebugger32` (frmOptions) controls with populate/apply/save +
  the shared Add/Change/Remove/Clear handlers repointed to `cboDebugger64`; fixed two latent 32/64 bugs.
  Kept `lblDebugger321` (different control).

- **Pass 2b — compiler-32: DONE, build-verified (staged).** Removed `Compiler32Path`/`Compiler32Arguments`
  (`Main.bi` globals + `Main.bas` assign/read/dealloc), `LibX32Folder` (`Main.bi` struct field + `Main.bas`
  library-load line); collapsed the `Main.bas` include-resolver and the `TabWindow.bas` lib-path pair to the
  64 attempt only; removed the frmParameters `txtfbc32`/`lblfbc32`/`lblAddCompilerOption32` designer blocks
  + populate/apply/save + the `lblAddCompilerOption32_Click` Sub + `.bi` declare/dims. Kept the `…64`
  equivalents (`txtfbc64`/`lblfbc64`/`lblAddCompilerOption64`).

- **Pass 2c — `CompilationArguments32` project property: DONE, build+runtime-verified (staged).** Removed the
  frmProjectProperties `lblCompilationArguments32`/`…32Linux` labels + `txtCompilationArguments32Windows`/
  `…32Linux` textboxes + their populate/apply/clear (`.frm`) and `.bi` dims; the `TabWindow.bi` struct fields
  `CompilationArguments32Windows`/`…32Linux` + `TabWindow.bas` deallocs; and the `Main.bas` `.vfp` parse
  (`ElseIf Parameter = "CompilationArguments32…"`) + save (`Print #Fn, "CompilationArguments32…`). Kept
  `lblCompilationArguments321` ("Command Line Arguments", a different control). Also collapsed the three live
  `#ifdef __FB_64BIT__` guards (frmSplash `lblSplash1.Text`, frmComponents `LibKey`, frmOptions `MFFDll`) to
  the 64 branch. **Deferred (not part of the 32-bit feature strip):** three commented-out `#ifdef __FB_64BIT__`
  lines inside large pre-existing dead-comment blocks in `Debug.bas` (~914/4568/9498) — sweep them with the
  standing "no commented-out code" cleanup of `Debug.bas`, not here.

**NEXT:** the 32-bit strip is complete. Resume the Astoria→Ilwaco changelog walk (AstoriaParity item 3:
`53d8e473` compile-warning fixes, then the menu-taxonomy feature ports). Optionally do the standing
"no commented-out code" sweep of `Debug.bas` (the three deferred `__FB_64BIT__` comment blocks live there).

## Session handoff (2026-08-02, earlier) — compiler stage 2 COMPLETE (tasks 11, 12, 13 all DONE)

**START HERE.** The whole-tree non-target strip (below) is done, committed, and pushed. Then **compiler
removal stage 2** (the "one compiler, no picker" completion) was finished. Stage 2 had three parts — 11
(Options picker UI), 12 (per-project `CompilerPath` override), 13 (`[Compilers]` INI machinery). **All three
are DONE and build+runtime-verified. Tasks 11 & 13 are staged (uncommitted); task 12 was committed `0fb1746`.**
The "one bundled compiler, no picker, no INI machinery" goal is fully realized — the only compiler path in the
system is the hard-coded `BundledCompilerPath`.

- **Task 13 — `[Compilers]` INI machinery: DONE — build-verified (`fbc` exit 0) AND runtime-verified with a
  real compile.** Retired the entire vestigial machinery: the `Compilers` `Dictionary` + `pCompilers` pointer,
  `Current/DefaultCompiler32/64` globals, the `[Compilers]` INI **read** (`Main.bas` load loop) and **write**
  (`frmOptions.frm`), the compiler lookup in the compile-command builder, and the cleanup/dealloc. **−441
  lines net** across `Main.bas`/`Main.bi`/`frmOptions.frm`. Key safety points honoured:
  - **Kept the fragile 10-section load loop's `Compilers` KeyExists term** (`Main.bas:5498`) so the shared
    `Do Until … = -10` loop still terminates correctly; only dropped the `Compilers.Add` body inside it.
  - **Kept `Compiler32Path`/`Compiler64Path`** (set from `BundledCompilerPath`; used by `FbcExe` and the
    include/lib path resolvers) — those are the bundled paths, not the retired picker machinery.
  - Compile-command builder (`Main.bas` ~604-613): dropped the `Else` branch that set `CompilerTool` from
    `pCompilers`; for a normal compile `CompilerTool` stays 0 and `CompileWith` is built entirely by the
    in-code `WAdd` flag chain (every `Command_N` template was empty anyway, so this is behaviour-preserving).
  - **Runtime-verified by real compile:** opened a trivial `.bas` in the IDE and hit Compile — fbc ran with
    the **bundled compiler** and compiled `.bas → .c → .asm → .o` cleanly. Only the final `ld` link failed
    with `cannot find -lncurses` — a **missing system lib in the dev shim** (fbc's default console link wants
    libncurses; task 13 never touched link flags), **not** a code regression. See "Known env gap" below.
  - **Known env gap (packaging/shim, not a code bug):** the dev shim provides `libtinfo.so.5` but no
    `libncurses.so`, so the IDE can't fully *link* a console app in this environment. Pre-existing; relevant to
    the AppImage/shim packaging task (add a `libncurses` dev symlink to `$SHIM`), tracked separately from the
    compiler work.

- **Task 11 — Options + Parameters picker UI: DONE — build-verified (`fbc` exit 0, zero warnings) AND
  runtime-verified.** Staged in the working tree (not yet committed). Removed the entire compiler-picker
  subsystem across 4 files, **−398 lines in `frmOptions.frm`** alone:

- **Task 11 — Options + Parameters picker UI: DONE — build-verified (`fbc` exit 0, zero warnings) AND
  runtime-verified.** Staged in the working tree (not yet committed). Removed the entire compiler-picker
  subsystem across 4 files, **−398 lines in `frmOptions.frm`** alone:
  - `frmOptions.frm`/`.bi` — the `grbDefaultCompilers`/`grbCompilerPaths` groupboxes, `lvCompilerPaths`,
    `cboCompiler32`/`cboCompiler64`, the `hbxCompilers` Add/Change/Remove/Clear button bar, the
    `cmdFindCompilers` button + `lblFindCompilersFromComputer`, the whole `FindCompilers`/
    `FindProcessStartStop`/`FindCompilersSub`/`FindedCompilersCount`/`FolderName` disk-scan subsystem, the
    4 handler bodies + their `Declare`s, the `lvCompilerPaths_ItemActivate` + `cmdFindCompilers_Click`
    handlers, and the LoadSettings populate + `cmdApply_Click` save blocks. **Kept** (shared): `bStop`
    (used by `HistoryCodeClean`), `Dim As UString tempStr` + `Dim As ToolType Ptr Tool` (used by the
    MakeTools/Debuggers/etc. save loops).
  - `frmParameters.frm`/`.bi` — the per-build `cboCompiler32`/`cboCompiler64` selector (designer, populate,
    apply). **Kept** `txtfbc32/64` (fbc-arguments), `lblfbc32/64`, `lblAddCompilerOption32/64`,
    `frmCompilerOptions` — the arg-string editor is a separate feature.
  - **Bonus fix:** both the Options Apply and the frmParameters OK used to `WLet(Compiler32/64Path,
    pCompilers->Get(...))`, **clobbering** the hard-coded bundled path on every OK/Apply. That clobber is
    now gone — the bundled `Compiler32/64Path` (set from `BundledCompilerPath` in LoadSettings) survives.
  - **Design decision:** kept `pnlCompiler` + the "Compiler" tree node — it is a *parent* category
    (children Build Configurations / Includes / Make Tool), so it now shows an **empty parent panel**
    (normal tree behaviour). Runtime-verified: Options opens, Compiler node shows empty panel, Apply works,
    no crash, no `DebugInfo.log`.
  - **Left intact for task 13:** `pCompilers`/`Compilers`, `Current/DefaultCompiler32/64`, and the
    `[Compilers]` INI read (`Main.bas` ~5506-5512) + write (`frmOptions.frm` save loop ~4353) — retiring
    that machinery is task 13, which touches the hot compile path and the fragile 10-section loop.

**Prior status (still current for task 12; task 11 now superseded above):**

- **Task 12 — per-project `CompilerPath` override: DONE — build-verified (`fbc` exit 0, zero warnings) and
  committed.** Runtime spot-check still advisable (open Project Properties ▸ Compile tab — the compiler row
  should be gone; leaves a harmless gap at y≈285). 5 files, −103 net lines:
  - `frmProjectProperties.frm` — removed the Compile-tab "Compiler" row (designer blocks for `lblCompiler`,
    `cboCompiler`, `txtCompilerPath`, `cmdCompiler`), their 3 dispatch stubs + 3 handler bodies, the
    `cboCompiler` population in `Form_Create`, and the load/save of `ppe->CompilerPath`. (Leaves a visual gap
    at y≈285 on `tpCompile` — controls use absolute bounds, so harmless; reflow later if desired.)
  - `frmProjectProperties.bi` — removed the 6 handler `Declare`s and `cmdCompiler`/`lblCompiler`/`cboCompiler`/
    `txtCompilerPath` from the `Dim As` lines.
  - `TabWindow.bi` / `TabWindow.bas` — removed the `CompilerPath As WString Ptr` project field + its `WDeAllocate`.
  - `Main.bas` — build branch now always `WLet(FbcExe, GetFullPath(IIf(Bit32, *Compiler32Path, *Compiler64Path)))`
    (dropped the `Project->CompilerPath` override); removed the `.vfp` `CompilerPath` parse (~1462) and save (~2078).
  - Verified by grep: zero remaining `CompilerPath`/`cboCompiler`/`txtCompilerPath`/`cmdCompiler` refs in `src/`.
    **Do NOT touch `Compiler32Path`/`Compiler64Path`** — those are the global bundled-compiler paths (keep).
  - Resume build: `./build-linux.sh editor` then runtime-check (open Project Properties ▸ Compile tab: the
    compiler row should be gone). Commit message ready in spirit: "Compiler stage 2: remove per-project
    CompilerPath override".

- **Task 11 — Options picker UI: DONE (see the DONE block at the top of this handoff for the full surface).**

- **Task 13 — `[Compilers]` INI machinery: DONE (see the DONE block at the top of this handoff).** Original
  survey notes retained below for reference. Key finding: every `Command_N` (the fbc
  argument template) is **empty** in the INIs, so `CompileWith` starts empty and all real flags are built in code
  (`Main.bas` ~622-677). So `pCompilers`/`Compilers` is used only by (a) the picker UI removed in task 11, (b) the
  arg-template lookup `Main.bas:616-617` (`CompilerTool = pCompilers->Item(Idx)->Object`; empty → contributes
  nothing), and (c) the `LoadSettings` read (~5513-5520 `Compilers.Add`) + cleanup (~10565). After task 11,
  replace 616-621 with `WLet(CompileWith, "")` for the non-Make branch, drop the `Compilers.Add` block **without
  touching the shared 10-section `Do Until…Loop` termination condition** (5509-5512 — leave the `Compilers` term
  in the KeyExists sum so the loop still ends correctly), then retire `Compilers`/`pCompilers`/`CurrentCompiler32/64`/
  `DefaultCompiler32/64` if nothing else references them. Build after each micro-step. **Exact surface after task 11
  (verified 2026-08-02):** the `[Compilers]` write lives in `frmOptions.frm` cmdApply save section, now
  **`4142-4151`** (`WriteString "Compilers", "DefaultCompiler32/64"` + the `Version_/Path_/Command_` loop + the
  `Do…KeyRemove` cleanup) — remove it in task 13. Main.bas anchors are unchanged by task 11: dict/pointer
  `84`/`122`/`199` (`Compilers`/`pCompilers = @Compilers`), lookup `612-613`, load `5502`/`5506-5512` +
  `5593-5596`, cleanup `10507-10510`/`10558-10559`. Note: after task 11 the `If CompilerTool <> 0` guard at
  `615-617` already yields empty `CompileWith` when `pCompilers` is empty, so real fbc flags are still built in
  code — retiring the machinery is safe.

**Build/run:** `./build-linux.sh` (committed `0b61d0c`) — `editor` | `lib` | `all`; run with
`LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`. `git checkout Settings/`
after any IDE launch (it writes session state on exit). *(Source is `src/ilwaco.bas`, binary `./ilwaco`,
settings `Settings/ilwaco.ini` since the 2026-08-03 rebrand.)*

---

## Session handoff (2026-08-02, earlier) — whole-tree non-target strip complete (MFF + src + Controls + Examples)

**START HERE.** Following the MFF strip below, the non-target strip was **extended across the whole tree**
per owner direction ("extend to all code in src, Controls and Examples"). Landed in these commits (on
`main`): `172aa23` MFF strip · `0b61d0c` build-linux.sh · `a0919c5` src/ strip · `422e931` non-MFF
Controls + cross-platform Examples strip · `d0b22a1` delete 16 Windows-only Examples demos · `b389866`
docs. **`src/` is build- + runtime-verified** (editor rebuilds clean, IDE launches + idles stably ~60 s,
no crash/`DebugInfo.log`). **`Controls/` (non-MFF) and `Examples/` are off the Ilwaco build path** so are
not IDE-build-verified — stripped conservatively (builtin `__FB_WIN32__` safe anywhere; `__USE_*` under
the GTK-target assumption) with every edit subsequence-checked. 16 Windows-only demos deleted (directshow,
directsound, WMI, SAPI, WLan, MediaFoundation, Midi, gdipClock/gdipGoldFish, IFileDialog, Com_VBA,
WellCOM, ChineseCalendar, MultipleDisplay, NTPClient, AndroidProject) — the Astoria mirror (Astoria, being
the Windows build, kept its whole Examples/ tree). Full detail: AstoriaParity "Done — whole-tree
non-target strip". **All committed; working tree clean.** Details of the MFF portion follow.

---

## Session handoff (2026-08-02, earlier) — MFF framework non-target strip (AstoriaParity task B) landed

The framework-wide non-target strip is done and **build- + runtime-verified**: both the
editor (`VisualFBEditor64_gtk3`, 4.99 MB) and the designer control lib (`libmff64_gtk3.so`, 1.69 MB)
rebuild **clean** (`fbc` exit 0, zero warnings), and the IDE **launches to a full editor window and idles
stably ~80 s** — no error dialog, no crash, no `DebugInfo.log` (only the documented-harmless
`AppAddin`/`AppConsole` resource warnings).

**Scale:** ~**134,600 lines removed across 274 files, 91 files deleted**. Two parts: (a) MFF control-code
strip — **198 files / ~41,250 lines** incl. 14 whole-file deletions; (b) `mff/gir_headers/` GTK4 binding
tree — **77 files / 93,349 lines** (included only under `#ifdef __USE_GTK4__`, so pure non-target). WINAPI
`#ifdef` occurrences in `mff/` went **954 → 0** outside the 3 excluded derivation files; the compiled
surface now has **zero** real non-target directives.

**How (durable tooling, reusable):** extended the task-A eliminator (`scratchpad/ppstrip.py`) into a full
recursive-descent `#if`/`#elseif` parser handling `defined()`/`AndAlso`/`OrElse`/`Not`/comparisons. It is
**conservative**: a chain collapses only if *every* branch condition is known (ground-truth symbol table
probed from the compiler — notably `__USE_CAIRO__` is **defined** on our build); any **opaque** symbol
(`pango_version`, `UNICODE`, `__USE_MAKE__`, `_WIN32_WINNT`, `GIFPlayOn`, …) leaves the chain intact but
still recurses inside. It only deletes whole lines — every edited file verified a strict line-subsequence
of the original. **Exclude list (they *define* the truth): `mff/mff.bi`, `mff/SysUtils.bi`, `inc/pipe.bi`.**
Two traps fixed mid-run: a **BOM** on line 1 hiding a leading `#ifdef`, and a **trailing `'comment`** on an
`#ifdef` line swallowed into the operand. Full method + symbol table + deleted-dir list in AstoriaParity
"Done — MFF non-target strip (staged task B)".

**Dark mode (REIMPLEMENT gap surfaced):** MFF already ships a real GTK3 `SetDarkMode`
(`gtk-application-prefer-dark-theme`), so `DarkMode/` was **kept** (not stubbed). But `g_darkModeSupported`
was only ever set by the deleted Win32 `InitDarkMode`, so on GTK it stays `False` and the
`If g_darkModeSupported AndAlso …` styling branches never fire — a REIMPLEMENT item (track with Astoria's
dark-mode commits). See AstoriaParity NEXT ACTION.

**Deferred strip sub-items (non-blocking, off the compiled path):** `mff/win/` (Windows headers, now inert),
`Controls/MyFbFramework/inc/` (not on the build path — incl. the WINAPI-forcing `pipe.bi`), a few
commented-out `'#ifdef` cruft lines, and `#define nullptr 0` in `DarkMode.bi`. Listed in AstoriaParity.

**Build note:** the shim (`$SHIM` GTK dev-symlink dir + vendored `Compilers/shim/libtinfo.so.5`) is
recreated per session in scratchpad; the durable `build-linux.sh` is still the open infra task. Nothing
committed yet this session — the strip is staged in the working tree for review.

---

## Session handoff (2026-08-02, earlier) — EditControl fully stripped; compiler hard-coded (no picker dialog)

**START HERE.** Two substantive landings, both **build-verified clean** (fbc exit 0, zero warnings) and
**runtime-verified** (the IDE launches to a fully-loaded editor — full menus/panels, "IntelliSense fully
loaded" — with **no error dialog**; no crash, no `DebugInfo.log`).

**1. Full `EditControl.bas`/`.bi` non-target strip (AstoriaParity staged task A — DONE).** The single
largest strip in `src/`: **`EditControl.bas` 9405 → 6582, `EditControl.bi` 845 → 764** (−2,904). Deleted
every non-target branch (Windows GDI + Direct2D, GTK2), collapsed the target-GTK guard wrappers, and
removed the commented `'#ifdef …` cruft. Also finished the Direct2D retirement: dropped the unused ungated
`UseDirect2D` global (`EditControl.bi`) and the two dead `#ifdef __USE_WINAPI__` D2D init blocks in
`Main.bas` — **zero D2D refs remain in `src/`**. Method was a *correct guard-evaluating* eliminator (every
conditional here is single-symbol `#ifdef`/`#ifndef`, no `#if`-exprs, no `#elseif`), run in two
build-checkpointed phases (A: delete non-target-guarded blocks; B: collapse `__USE_GTK__`/`__USE_GTK3__`
wrappers). Tools + full method in AstoriaParity's "Done — staged task A" section; scripts (`ppstrip.py`,
`ppmap.py`) in scratchpad. **Remaining strip = task B** (MFF), top of AstoriaParity.

**2. Compiler path hard-coded, first-run dialog gone (opinionated design, stage 1).** Owner: *"The
compiler path should be hard coded into the system, there is no choice anymore."* Added
`#define BundledCompilerPath "./Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"` (Main.bi; `./` resolves
to `ExePath` via `GetFullPath`, so it travels in the AppImage) and assigned `Compiler32/64Path` from it in
`LoadSettings` — **without touching the fragile 10-section `[Compilers]` INI parse loop** (kept
`CurrentCompiler64` so the argument template still resolves). Deleted `Function CheckCompilerPaths` and set
its call site `bSharedFind = True`. **The "Invalid defined compiler path / Find Compilers?" first-run
blocker (see Known issues below) is now gone.** **Stage 2 pending** (remove the picker UI + per-project
`CompilerPath` override + vestigial INI machinery — needs the fragile loop refactored, own session; see
AstoriaParity "Done — compiler path hard-coded" for the exact surface).

**Verification note / caution for next session:** driving the GTK build over `:0` with `xdotool type` is
**focus-fragile** — keystrokes leaked into the *host* window during this session. Prefer opening a file via
CLI args or verifying by effect (window loads, no error dialog) over synthetic typing. Also: **`pkill -f
VisualFBEditor64_gtk3` matches its own shell** (kills the caller, exit 144) — use `pkill -x` on the exact
name, or `pgrep`/`kill` by PID. The IDE **writes window/session state into the INI on exit** — `git
checkout` the `Settings/*.ini` afterward to keep it pristine.

**Follow-up pass (2026-08-02, this handoff):** removed the remaining commented-out Win32 lines in
`EditControl.bas` (`'txtCode.*`, the `'SendMessage`/`ComboBoxInfo`/`PostMessage` block, `'…SelectObject(bufDC…)`)
— build re-verified (fbc exit 0), IDE relaunched to a fully-loaded editor. **Caveat on the "no crash"
claim above:** on the first launch this session the process exited with **SIGSEGV (139) ~1 min in**; it did
**not** reproduce on relaunch (91 s idle, clean, no `DebugInfo.log`), so it is an *unconfirmed, possibly
interaction-triggered* crash, not a verified idle regression. Get a source-line backtrace next session by
rebuilding with `-g` (FreeBASIC's handler then reports error 12 with a line) and opening a file. A handful
(~4) of `'txtCode`-style dead comments still remain elsewhere in `EditControl.bas` for a later full sweep.

---

## Session handoff (2026-08-02, earlier) — GitHub menu + Direct2D option removed; build shim vendored; non-target strip scoped

**START HERE.** Continued the parity walk, removed the Direct2D user option, closed a standing infra
gap (vendored the fbc shim), and scoped the big non-target-platform strip for a fresh session.

**Landed this session (both build-verified clean, committed + pushed):**
- **Removed the Help ▸ GitHub submenu** (Astoria `d275dc93`) — `src/Main.bas` (the `miGitHub` block,
  8 items + 2 separators) and `src/VisualFBEditor.bas` (8 `Case` handlers incl. orphan `GitHubWebSite`).
  Kept `OpenUrl` (used by other Help commands) and the FreeBasic WiKi/Forums items. Commit `6f79c39`.
- **Removed the Direct2D user option** (Astoria `DIRECT2D_REMOVAL.md` §1, "Phase 1") — the
  "Use Direct2D (For Windows)" toolbar button + Options checkbox + INI key + dispatch. On GTK the whole
  Direct2D *render* path was already `#ifdef __USE_WINAPI__`-gated (never compiled); only the toggle was
  live-but-useless. `frmOptions.frm` done via **edit-form-safely**. Commit `5bc101d`.

**Re-scoping discovered (important):** the editor's remaining Direct2D can't be stripped on its own —
it's interleaved through **EditControl's entire Windows branch** (23 `#ifdef __USE_WINAPI__` blocks +
137 `#ifdef __USE_GTK*…#else…#endif` pairs, ~2,135 lines, GDI+D2D together). Retargeted as the **full
EditControl WINAPI strip**, staged in AstoriaParity (task A), with MFF Direct2D as task B. Owner steer:
prefer a **comprehensive global strip** of all non-GTK code (delete, never comment/no-op) — it makes
later work much easier (memory `project-strip-windows-code`). **GTK-guard trap:** `__USE_GTK2__` vs
`__USE_GTK3__` differ — the `#else` of a `__USE_GTK2__` block can be the live GTK3 branch; no blind
`#else` deletion.

**Infra fixed — the build shim no longer lives only in scratchpad:**
- `libtinfo.so.5` (the one piece `fbc` needs that Debian 13 dropped) is now **vendored in-repo at
  `Compilers/shim/libtinfo.so.5`** (183 KB, extracted from the Debian 11 `libtinfo5` .deb, owner-approved).
  Survives across sessions — no more re-downloading it.
- The GTK `-dev` `.so` symlinks are still recreated per session into a scratchpad shim dir
  (`$SHIM = <scratchpad>/fbclibs`) but now point `libtinfo.so.5` at the vendored copy. **Owner rule:
  retain the shim, do not delete it.** A `build-linux.sh` that farms the symlinks + references the
  vendored lib is the remaining infra step (memory `reference-linux-build`).
- **Delegation rule updated:** Sonnet workers do edits and **hand back to Opus for compilation** — a
  worker never rebuilds/loads the shim (memory `feedback-worker-returns-for-compilation`).

**Build recipe (this session, working):**
`cd src && LD_LIBRARY_PATH=$SHIM ../Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__ -p $SHIM -l tinfo`

**NEXT (staged for a fresh session — see AstoriaParity "NEXT ACTION"):** strip **all non-target-platform
code** (target = x86_64 Linux/GTK3; strip Windows, Android/JNI, GTK4, GTK2, Darwin, WASM, 32-bit — delete,
never no-op). Two staged tasks: **A** = full `EditControl.bas`/`.bi` strip (~2,135 lines, its own
carefully-chunked, build-after-each session); **B** = MFF non-target strip (MFF holds the multi-platform
bulk — WINAPI 945, GTK4 125, WASM 129, JNI 88, GTK2 35 — rebuild `libmff64_gtk3.so`). Guard/keep lists
+ typo-guard landmines in memory `project-strip-windows-code`. Phase 1 is the parity win already banked.

---

## Session handoff (2026-08-02, earlier) — parity walk begun: 5 changes landed, all build-clean

**START HERE.** Build baseline was established earlier (section below). This session began the actual
**Astoria→Ilwaco parity walk**. Method and full backlog: [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md).
Key realization: **menus are the *surface* of feature-parity** — items appear/vanish because features
are ported/removed, so we drive menu edits from the feature walk (never pre-reorganize menus). And
**port to Astoria's *final* state, not replay commits** (the changelog has churn: things added then
removed).

**Landed this session (each `fbc`-verified, exit 0, no warnings — last clean binary 10:22):**
1. **Panel collapse-on-pin** — `VisualFBEditor.bas` `Pin{Left,Right,Bottom}` handlers now collapse in
   one click (Astoria `e212819d`/`c2672840`/`64daa66e`, behaviour half). Bottom-panel *persistence*
   half deferred (needs infra Ilwaco lacks — see AstoriaParity).
2. **Service→Tools menu rename** (`ae74b31c`), caption-only.
3. **Removed legacy Error Handling + Line Numbering** (`ec42ea83`) — ~500 lines across 5 files.
   Line-numbering *toggle* went because line numbering is now standard; the FB `Try/Catch` language
   construct and the editor's gutter line-number display are untouched.
4. **Removed "Close Folder"** (`ec42ea83`).
5. **Removed the "Use" target-selector dropdown** — WinAPI/GTK/JNI/WASM define picker (Astoria removed
   it wholesale; kept the `UseDefine` global + consumers, now always-empty — a follow-up cleanup).
   **First task delegated to a Sonnet worker** (owner asked: push mechanical work to Sonnet to save
   Opus credits — memory `feedback-delegate-mechanical-to-sonnet`).

**Infrastructure stood up this session:** `CLAUDE.md` (Linux/GTK rules), `Documentation/AstoriaParity.md`
(the classified backlog), 9 platform-neutral skills in `.claude/skills/`, and assistant memory
(project overview, port strategy, packaging=AppImage+external writable dirs, base provenance
[Newer≈Ilwaco≈upstream 1.3.8; Astoria = your DeepSeek/Cursor layer + the 888-commit changelog],
opinionated design, strip-windows mantra, feature-removal process, delegation).

**NEXT (fully scoped, ready to apply — see top of AstoriaParity.md):** remove the **Help ▸ GitHub**
menu (`d275dc93`) — `Main.bas` 7776–7785 + `VisualFBEditor.bas` 1171–1178, ~18 lines, no other files.
Delegate to Sonnet.

**Removal-process lessons (in memory `project-strip-windows-code`):** grep **all** src files for (a)
command strings, (b) function names, **and (c) `mi*/dmi*` menu-pointer variable names** — (c) was
missed twice and caught by the compiler in `TabWindow.bas`. Watch **shared `Var` declarations**
(`tbButton` had to be re-homed twice). The `fbc` build is the real safety net.

**Delegation gotcha:** the Sonnet worker's *edits* were correct but its *build* kept getting SIGTERM'd
and it never reported a final status — I ran the confirming build. Next time instruct the worker to run
the build as a **surviving background job** and report the log.

**Build/run env:** in-repo bundled `fbc` (`Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc`, tracked)
and the GTK-capable MFF source (`Controls/MyFbFramework/`, now vendored as real files — the old
submodule gitlink was dropped, commit `60015e4`), so the repo is self-contained **except** for a
userspace shim for `libtinfo.so.5` and the GTK `-dev` symlinks, **currently in the assistant's
scratchpad** (`/tmp/claude-.../scratchpad/fbclibs`) — NOT yet vendored into the repo (ephemeral;
recreate per memory `reference-linux-build`). A durable
`build-linux.sh` + vendored shim remains an open infra task (memory `reference-linux-build` has the
exact recipe). Build command:
`cd src && LD_LIBRARY_PATH=<shim> fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__ -p <shim> -l tinfo`

---

## Session handoff (2026-08-02) — Linux build baseline established

**START HERE.** Ilwaco now **builds from source and runs** on this Debian 13 machine. That was not
possible at the start of the session: no compiler was on the box, the framework source was missing,
and the committed binary would not run. All three are resolved.

### What was done
- **Compiler:** found the bundled `Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc` inside the repo.
  It needs `libtinfo.so.5` (dropped by Debian 13) and the GTK `-dev` `.so` symlinks (no `-dev`
  packages installed). Both are handled by a **userspace shim** (no sudo): a real `libtinfo.so.5`
  extracted from the Debian 11 `libtinfo5` package on `LD_LIBRARY_PATH`, plus unversioned dev
  symlinks for the GTK stack passed via `fbc -p`, plus `-l tinfo` on the link line. Full recipe is
  in the assistant's project memory (`reference-linux-build`); **it still needs to be captured as a
  repo build script** — see Next.
- **Framework (MFF):** `Controls/MyFbFramework/` was empty. Vendored the **GTK-capable** MFF source
  from the original download (`~/pCloudDrive/VisualFBEditor - original/Controls/MyFbFramework`) —
  *not* Astoria's copy, which has GTK stripped. Skipped its `lib/` (48M, Windows-only import libs),
  `examples/`, `help/`.
- **Built, from `src/`:** `fbc VisualFBEditor.bas -i ../Controls/MyFbFramework -d __USE_GTK3__`
  (whole-program; output path is set by a `#cmdline` in the source) →
  `VisualFBEditor64_gtk3` (~5 MB, needs only **GLIBC_2.34**, far more portable than the committed
  binary's 2.42). Then the designer's control library:
  `cd Controls/MyFbFramework/mff && fbc -b mff.bi -dll -x ../libmff64_gtk3.so -d __USE_GTK3__`
  → `Controls/MyFbFramework/libmff64_gtk3.so` (~1.7 MB). Each whole-program compile is ~3–4 min.
- **Verified by effect:** the IDE launches (splash "Visual FB Editor 1.3.8 64-bit", main window,
  live GTK event loop), and with the `.so` present the control-toolbox "libmff64_gtk3.so not found"
  error is gone.

### Known issues surfaced (not blockers for the restructuring work)
- **First-run "Invalid defined compiler path" dialog — RESOLVED 2026-08-02** (see the latest handoff,
  stage 1). The shipped `[Compilers]` pointed at the original author's dead `/mnt/media/...` paths. Rather
  than restructure the fragile parse loop (it crashes if the `[Compilers]` block is restructured — a
  null-deref), the compiler path is now **hard-coded** from `BundledCompilerPath` after the loop and the
  `CheckCompilerPaths` validator/dialog was removed. The INI block is left intact (ignored for path). The
  full "one compiler, no picker" UI removal is **stage 2** (AstoriaParity).
- **Runtime needs the fbc shim on `LD_LIBRARY_PATH`** when the IDE spawns fbc to build a user
  project. Launching the IDE with the shim env makes the child fbc inherit it; a shipped build needs
  a launcher/wrapper that sets this (packaging concern).
- Harmless startup warnings: resources `AppAddin`, `AppConsole` "do not exist".
- `gdb` is not installed (debugger default won't resolve); `UseDebugger=false` by default.
- `UseDirect2D=true` in settings — Direct2D is Windows-only; Astoria has a `DIRECT2D_REMOVAL.md`.
  A clear early parity item on the GTK side.

### Next
1. **Capture the build as a repo script** (`build-linux.sh` + vendor the shim `libtinfo.so.5` under
   `Compilers/`) so the toolchain isn't trapped in the assistant's scratchpad.
2. **Stand up the doc infrastructure** listed at the top (parity backlog is the keystone).
3. **Begin the changelog walk** from `astoria-ide/Documentation/AstoriaIDESignificantChanges.md`
   (§1 added features → port; §2 removed features → decide keep/drop; §3 inherited-defect fixes →
   port + upstream), classifying each item in `AstoriaParity.md`.

### Environment note
No FreeBASIC on PATH, no sudo, `/opt` not writable. Everything builds via the in-repo bundled fbc +
the userspace shim. Rebuilt binary and vendored MFF are untracked/modified in git; nothing committed
this session.
