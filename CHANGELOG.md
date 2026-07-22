# Ilwaco IDE — Changelog

**Repository:** `Projects/ilwaco-ide`  
This file archives completed work. For current status and open items, see [`PROJECT_STATUS.md`](PROJECT_STATUS.md).

---

## Completed work

- [x] **Language UI fully stripped; startup crash fixed (2026-07-22)** — completed the remaining multilingual infrastructure cleanup and fixed a pre-existing SIGSEGV.
  - Removed the entire language selection UI from Options dialog: `pnlLocalization`, `grbLanguage`, `pnlLanguage`, `cboLanguage`, `chkShowToolBoxLocal`, `chkShowPropLocal`, `lblShowMsg`, and the "Localization" tree node.
  - Removed `gLocalProperties` global variable from `src/Main.bi`, `src/Main.bas`, and `src/frmOptions.frm`.
  - Removed `LoadLanguageTexts` function, its declaration, and all call sites (`src/Main.bas`, `src/Main.bi`, `src/frmTrek.frm`).
  - Removed the "Language files by" translator credits from `src/frmAbout.frm`.
  - Replaced all Uzbek status-bar and history strings in `src/EditControl.bas` with English equivalents.
  - Fixed startup SIGSEGV in `SetDebugTabsVisible` by reverting to `Visible` toggle (was `DetachTab`/`AddTab`) and adding re-entrancy guard in `ChangeUseDebugger`.
  - Build: green.

- [x] **Multilingual support removed; project is English-only (2026-07-22)** — stripped the language system so Ilwaco no longer ships or loads `.lng` files.
  - Deleted all `.lng` language files and `Languages/` directories under `Settings/`, `Examples/`, and `Controls/MyFbFramework/examples/`.
  - Deleted Chinese help files `Settings/Others/KeywordsHelp.chinese(Simplified).txt` and `KeywordsHelp.chinese(Traditional).txt`.
  - Converted `ML()` in `Controls/MyFbFramework/mff/Application.bas` and `MS()`, `MLCompilerFun()`, `MC()`, `MP()` in `src/Main.bas` to pass-through.
  - Emptied `LoadLanguageTexts` in `src/Main.bas` and removed `mlCompiler`, `mlTemplates`, `mpKeys`, `mcKeys` from the shared dictionary list.
  - Hard-coded AI prompts to `"English"` in `src/VisualFBEditor.bas` and `src/Main.bas`.
  - Simplified `KeywordsHelp`/`AsmKeywordsHelp` loading to always use the English `.txt` files.
  - Removed `CurLanguagePath`/`CurLanguage` setup blocks from `src/frmAIAgent.frm` and `src/frmAddType.frm`.
  - Replaced language-specific `CompilerOptionsFile` logic in `src/frmCompilerOptions.frm`.
  - Stripped the language UI in `src/frmOptions.frm`: removed `cmdUpdateLng`, `chkAllLNG`, the `UzLot()` function, the `cmdUpdateLng_Click` handler, and the `oldIndex`/`newIndex` change-detection plumbing.
  - Simplified `Application.CurLanguage` to just store the value and removed the shared `mlKeys` dictionary from `Controls/MyFbFramework/mff/Application.bi`.
  - Fixed unbalanced `#if _MAIN_FILE_ = __FILE__` blocks left by prior edits and restored UTF-8 BOM on affected files.
  - Build: `make` from `src/` produces `../ilwaco` and `Controls/MyFbFramework/libmff64_gtk3.so` without errors.

- [x] **Windows, GTK2, and GTK4 code cleanup (2026-07-22)** — made Ilwaco a clean Linux/GTK3-only codebase.
  - Deleted GTK2/GTK4 binding headers from `Controls/MyFbFramework/mff/gir_headers/Gir/`.
  - Collapsed `#ifdef __USE_GTK2__` / `#ifdef __USE_GTK4__` blocks to the GTK3 branch across `src/` and `Controls/MyFbFramework/`.
  - Removed GTK2/GTK4 menu items from the build-configuration dropdown in `src/Main.bas`.
  - Updated framework library lookup to `libmff64_gtk3.so` / `libmff32_gtk3.so`.
  - Updated settings-path macros to the `_gtk3.ini` variants.
  - Deleted `Controls/MyFbFramework/mff/WebView/WebView2.bi` and switched `WebBrowser` to WebKitGTK only.
  - Deleted `Controls/MyFbFramework/inc/SimpleVariantPlus.bi`.
  - Deleted `Examples/try_catch_throw.bas`.
  - Deleted the `Examples/Game/Calculator` example (Windows COM/MSScriptControl).
  - Deleted `Controls/MyFbFramework/examples/WebBrowser/win32/` and other Windows-only example files.
  - Removed the `mnuWinAPI` submenu from `src/Main.bas`.
  - Collapsed `#ifdef __FB_WIN32__` / `#ifdef __USE_WINAPI__` blocks to the Linux path.
  - Removed `__fb_win32__`, `__use_winapi__`, `__use_gtk2__`, `__use_gtk4__` cases from `TabWindow.bas`.
  - Removed `#if 0` dead-code blocks and commented-out Windows/GTK2/GTK4 preprocessor blocks.
  - Verified all `.bas`/`.bi`/`.frm` files outside `Compilers/` use LF line endings.

- [x] **Baseline GTK3 build established** — `ilwaco` executable compiles and links against `libmff64_gtk3.so` with the bundled FreeBASIC 1.10.1 compiler.

- [x] **Project documentation created** — added `PROJECT_STATUS.md`, `CHANGELOG.md`, and `CLAUDE.md` to make session handoff easier.
