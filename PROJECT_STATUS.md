# Ilwaco IDE — Project Status & Handoff

Ilwaco is a Linux (GTK3) IDE for FreeBASIC — the **VisualFBEditor** codebase — being brought toward
parity with its Windows sibling **Astoria** (`../astoria-ide`). The plan is to walk Astoria's change
history and translate each change into Ilwaco, adapting Win32 → GTK, and — following Astoria's
"opinionated by design" stance — *removing* options and dialogs rather than accumulating them
(e.g. one bundled compiler, no compiler picker). Hobby project, no deadline: prefer durable
scaffolding over speed.

See also (to be created as work proceeds): `HISTORY.md` (session narratives), `CHANGELOG.md`
(milestones), `Documentation/DetailedChangelog.md`, `Documentation/AstoriaParity.md` (what we ported
and what we couldn't, and why), `Documentation/UpstreamFixes.md` (fixes useful to VisualFBEditor —
Ilwaco keeps GTK, so our GTK fixes apply upstream where Astoria's Win64-only ones cannot), and
`CLAUDE.md` (orientation for the Linux/GTK build).

---

## Session handoff (2026-08-03, latest) — UTF-8/LF-only DONE (build+runtime-verified); AI-removal is next

**START HERE.** Two things landed this session, both **build-verified (`fbc` exit 0) and runtime-verified**
(IDE launches to a stable "Ilwaco IDE (64-bit)" window, full editor, "IntelliSense fully loaded", no error
dialog, no `DebugInfo.log`). All uncommitted in the working tree (`git status`: `PROJECT_STATUS.md`, `ilwaco`,
`src/EditControl.bas`, `src/Main.bas`, `src/Main.bi`, `src/frmOptions.bi`, `src/frmOptions.frm`).

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

### TASK 2 (NEXT) — remove ALL AI elements (large; own session)
Owner: remove the AI pane, model selection, and all AI support code — `tbAIAgent`/`frmAIAgent`, the AI-agent
command cases (`AIAddComment`/`AIOptimizeCode`/`AIIntellicode`/`AITracepointError`/`AITranslate`), the AI knowledge
prompt block in `Main.bas ~7560-7620` + the chunking/JSON-packet code `~7380-7980`, `AIContext`, all `AIAgent*`
globals (`Main.bi`), the "AI Agent" panel/tab, `MD2RTF.bi` (AI markdown→RTF renderer) if AI-only, and the Options
AI page (`cboAIAgent`/`grbAIAgent`/`pnlAIAgent`). Survey first — it is woven through Main.bas/ilwaco.bas/frmOptions.

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
