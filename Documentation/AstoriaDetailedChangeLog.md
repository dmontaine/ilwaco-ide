# Astoria Detailed Changelog — Ilwaco parity working copy

> **This is Ilwaco's pruned copy** of Astoria's `DetailedChangelog.md`, used to walk Astoria's
> post-fork history oldest-first and port each change into Ilwaco (Linux/GTK). As items are
> **completed in Ilwaco they are deleted from this file**, so what remains is the outstanding
> backlog. Cross-reference [AstoriaParity.md](AstoriaParity.md) for classification (PORT /
> REIMPLEMENT / INVERT-SKIP / N/A / DONE) and the detailed "Done" narratives.
>
## ⇢ Maintenance rule (how this file is kept)

**This file is a *pruned* backlog, not a mirror.** Astoria's `DetailedChangelog.md` (888 commits) is
the immutable source; here we **delete** entries that carry no remaining Ilwaco work, so what stays is
the actionable PORT / REIMPLEMENT / REVIEW queue. Two deletion triggers:

1. **DONE** — a change AstoriaParity records as *ported/realized* in Ilwaco. Delete its entry (and note
   it in AstoriaParity). Keep an entry that is only *partly* done (e.g. `e212819d` — collapse done,
   persistence deferred).
2. **NON-ACTIONABLE** — a change that will never be an Ilwaco port because of the platform or an owner
   directive. Four classes, matched on the commit **headline** (not its narrative, which name-drops
   keywords):
   - **NONCODE** — the commit touches only *Docs / Settings / Examples* (no `IDE`/`Framework/Controls`/
     `Templates`/`Build/Tools` code): status notes, INI/scratch snapshots, changelog regens, decisions.
   - **INVERT** — deletes *GTK / Linux / 32-bit* code. Ilwaco **is** the GTK build and is 64-bit, so
     these are the opposite of ours to apply.
   - **WIN32** — Windows-only implementation (uxtheme/ntdll **dark mode**, Direct2D/D2D1, COM/OLE,
     WebView2/IE, Registry, DPI…). Ilwaco needs its *own* GTK equivalent; the REIMPLEMENT need is
     tracked in AstoriaParity, so the Win32 commit itself is not a port.
   - **AI** — AI-agent / MCP-sidecar / AI-template work. Ilwaco removed the entire AI subsystem
     (commits `d99b23c`→`cb19f48`), so all of it is moot.

   Match on the **headline only** and prefer keeping when unsure — a mixed commit whose *primary* subject
   is actionable (e.g. `2aee0744` ThreadsEnter/Leave contract, `8063b20f` frmAbout URL fix) must survive
   even if it name-drops a non-actionable topic.

**Prune history**
- **2026-08-03 (pass 1):** removed the 6 AstoriaParity *done ports* — `c2672840`+`64daa66e`
  (collapse-on-pin), `ae74b31c` (Service→Tools), `ec42ea83` (Error-Handling/Line-Numbering/Close-Folder),
  `d275dc93` (Help ▸ GitHub), `b5554063` (bundled toolchain, Linux fbc equiv). Kept `e212819d`.
- **2026-08-03 (pass 2):** removed **481** non-actionable commits — NONCODE 426, INVERT 9, WIN32 20, AI 26.
  **888 → 401** actionable entries remain. (The classifier's exact regex criteria are the four classes
  above; re-derivable from this rule.)
- **2026-08-03 (walk, `4cf72752`):** removed `4cf72752` (WIN32_WINNT header bug + bottom-panel tab
  clearing) — **PORT (partial), DONE.** The `_WIN32_WINNT` `=`→`>=` header fix is Windows-only (N/A on the
  GTK build) and the AI-KnowledgeBase path fix is N/A (AI removed); ported the **bottom-panel/debug tab
  clearing** — new `ClearAnalysisPanels`/`ClearDebugPanels` in `Main.bas`, called from `CloseProject` and
  the debug-`End` case in `ilwaco.bas`, so stale project/debug results don't persist after a project
  closes. Build- + runtime-verified (all 14 bottom tabs present; IDE launches clean). See AstoriaParity
  "Done — bottom-panel/debug tab clearing (`4cf72752`)". **397 → 396.**
- **2026-08-03 (walk, `53d8e473`):** removed `53d8e473` (Fix all compile warnings) — **PORT (partial),
  DONE.** Ilwaco's production build (`build-linux.sh`, default `-w`, gas64) was already warning-clean; two
  of Astoria's fixes targeted code Ilwaco had already stripped (Canvas.bas Direct2D `@"en-us"`, Debug.bas
  Win32 `SetConsoleTitle`), and its `SelectSearchResult`/`tabBottom` fixes don't reproduce here (decl/def
  already match; Ilwaco uses `And`, not `AndAlso`). Ported the two still-applicable `@literal→WString Ptr`
  type-correctness hunks in `src/Debug.bas` (`brk_comp`, `list_all` — wrapped with `WStr(...)`);
  build-verified clean. See AstoriaParity "Done — compile-warnings port (`53d8e473`)". **398 → 397.**
- **2026-08-03 (walk, oldest 3):** removed `bbfa3999` (the fork-import anchor — the base itself, not a
  port), `5a097399` (NONCODE: INI window-state + exe rebuild only), and `bef92671` (**N/A** — Astoria's
  Form-Designer-dead bug was caused by *Astoria's own* `strip_gtk_preprocessor.ps1` deleting the
  `#ifdef __EXPORT_PROCS__` blocks from mff; Ilwaco's `ppstrip.py` preserved every such block, and the
  built `libmff64_gtk3.so` exports all 36 dispatcher symbols `src/Designer.bas` resolves — verified with
  `nm -D`. See AstoriaParity "N/A — Form Designer export table intact"). **401 → 398.** Kept `e212819d`
  + `ef3b43e9` (bottom-panel persistence cluster, partial).

---

Every change made to Astoria IDE, in date order, oldest first. Astoria's own file "does not filter for
significance"; **this pruned copy does** (see the rule above).

For Astoria's curated view aimed at users, see Astoria's
`AstoriaIDESignificantChanges.md`. Links below point into Astoria's own repo docs.

**How to read an entry.** Each line is one commit: its short hash, what changed, and where it
landed. Hashes link to the repository, so `git show <hash>` gives the full detail and diff.
Areas are: **IDE** (`src/`), **Framework/Controls** (`Controls/`), **Templates**, **Examples**,
**Docs**, **Settings**, **Build/Tools**.

**Modifications of possible interest to upstream developers.** Astoria is a permanent fork of
VisualFBEditor, built on MyFbFramework. Some of what we fixed are bugs in *their* code rather
than ours — a control removal that leaves a dangling pointer and crashes the next `Form.Show`,
a modal dialog that opens with nothing focused so `Tab` and `Escape` do nothing, a `WebBrowser`
that cannot render on current Windows. Those are collected, with symptoms and commit hashes,
in [UpstreamFixes.md](UpstreamFixes.md), alongside a second list of changes that would be
inappropriate or dangerous to apply upstream. Offered, not claimed: none of it has been tested
against current upstream.

**Maintaining this file.** It is generated from the commit history, so the way to add an entry
is to write a good commit message. Regenerate rather than hand-edit; a stale hand-edit is worse
than no entry. Run `.\GenerateChangelog.ps1` from the repository root; `-Check` reports whether
the file is current and writes nothing, which suits a pre-commit hook.

Everything above the **Total: 888 commits, 2026-07-02 to 2026-08-02.**

## 2026-07-02

- **`e212819d`** — Fix bottom panel persistence and collapse layout; add project status handoff doc.
  *Docs, IDE, Settings · 6 files* — **PARTIAL: collapse done; bottom-panel persistence deferred.**
- **`ef3b43e9`** — Fix first-start collapsed bottom layout; update handoff status and gitignore docompile.bat.
  *Build/Tools, Docs, IDE · 3 files* — **PARTIAL: same panel-persistence cluster as `e212819d`.**
## 2026-07-03

- **`b221cf2a`** — Update PROJECT_STATUS.md with tonight's session; save INI/scratch state.
  Records the debugger smoke test findings: GDB debugging confirmed working for breakpoints, Step Into, and variable inspection.
  *Build/Tools, Docs, Examples, Settings · 6 files*
- **`5eeb2f93`** — Rebuild mff64.dll and VisualFBEditor64.exe (clean compile, 0 errors/0 warnings)
  *Framework/Controls, IDE · 2 files*
- **`4bd02894`** — Add missing example .vfp project files; add "no unnecessary options" guiding principle; audit Examples/ for GTK/Linux/Win32-only
  Audited all 33 Examples/ subdirectories for GTK dependency, Linux-only code, or Win32-only (non-64-bit) source, per the owner's ad-hoc request.
  *Docs, Examples, Framework/Controls, IDE · 18 files*
- **`51441d7a`** — Fix Graphics example against current mff API; add future Examples/ review task
  CanvasDraw.bas called CreateDoubleBuffer/TransferDoubleBuffer, which no longer exist (double-buffering is now handled internally via Control's DoubleBuffered property); used bare integers against the now strictly-typed PenStyle enum property; and had an ambiguous StretchMode reference (both...
  *Docs, Examples, Framework/Controls, IDE · 4 files*
- **`e139c2cc`** — Remove leftover 32-bit GCC internals; clarify gas64/gcc are not two competing compilers
  Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/ was a complete parallel 32-bit GCC toolchain (cc1.exe, as.exe, ld.exe, 9 DLLs -- 31 MB) that the earlier 32-bit-removal commit (15e66cc) missed, since it only caught the top-level Compiler/bin/win32/ folder.
  *Build/Tools, Docs, Framework/Controls, IDE · 6 files*
- **`5fa5cf25`** — Remove Integrated (stabs) debugger and alt-compiler-backend/debugger-choice code
  GDB is now the only debugger and gcc the only compile backend, so the code that existed solely to support alternatives is gone rather than left dormant, per this project's standing rule against shipping unused code.
  *Docs, Examples, Framework/Controls, IDE · 19 files*
- **`a7c7839d`** — Fix General-options checkbox overlap; flag Form Designer scalability concern
  Un-hiding Dark Mode (previous commit) surfaced a second, pre-existing bug on the same options page, unrelated to dark mode itself and never previously noticed: pnlInterfaceFont/chkDisplayIcons/chkShowMainToolbar/chkShowPropLocal/ chkDarkMode are relocated into vbxGeneral at runtime after already...
  *Docs, Framework/Controls, IDE, Settings · 5 files*

## 2026-07-04

- **`f292db0b`** — Add per-form control tree to project Explorer; fix Close All leaving project tree behind
  Form nodes now lazily expand into a correctly-nested, real-icon control tree built from the live Designer container hierarchy, closing part (a) of the Form Designer navigation gap (owner-scoped 2026-07-03/07-04).
  *Docs, Framework/Controls, IDE · 5 files*
- **`0c08fe5f`** — Add PagePanel layer/page navigation to the Form Designer
  Closes part (b) of the Form Designer navigation gap: selecting a control now reveals its PagePanel page (tree selection and the older cboClass selector), Ctrl+PageUp/PageDown cycles pages, and the Designer's right-click menu gained "Show Panel"/"Previous Layer"/"Next Layer" entries — all reusable...
  *Docs, Framework/Controls, IDE · 10 files*
- **`d877cef0`** — Safe dark popup menus + right panel pin fix
  - Form.bas: WM_INITMENUPOPUP sets MFT_OWNERDRAW on popup items when dark mode is on (skips system menu via lParam HIWORD check) - Form.bas: WM_DRAWITEM ODT_MENU renders dark items with text, accelerator split at tab, DT_HIDEPREFIX for hidden ampersands - Control.bas: WM_MEASUREITEM ODT_MENU sets...
  *Docs, Framework/Controls, IDE · 5 files*

## 2026-07-05

- **`72612671`** — Phase 2: magic numbers, dead code, naming fixes, orphaned UI, Dev/Final compile toggle (2.1.2-2.1.3, 2.2.1, 2.3.1-2.3.2)
  *Docs, Framework/Controls, IDE, Settings · 31 files*
- **`d7608aea`** — 2.2.2 DRY: SaveTabPagePlacement extraction (19 WriteString/Integer pairs -> helper); update PROJECT_STATUS
  *Docs, Framework/Controls, IDE · 4 files*
- **`49ec5ccd`** — UI evaluation fixes: menu labels, dialog cleanup, debug tabs, Code Editor grouping, compiler options simplification, editor defaults
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 22 files*
- **`37ba31ea`** — UI evaluation: File menu restructure, frmNewProject, debug tabs, startup options, MRU fix, editor defaults
  *Docs, Examples, Framework/Controls, IDE, Settings · 16 files*
- **`b9735e8e`** — Replace .vfs sessions with automatic workspace; restructure File menu; fix bottom panel tab captions.
  Sessions are removed from UX—workspace restores on startup via Settings/Workspace.ini.
  *Build/Tools, Docs, Framework/Controls, IDE, Settings · 25 files*

## 2026-07-06

- **`cc9e7dd5`** — Fix form designer grey panel: resolve MFF control library by live module handle
  Opening a .frm showed a brief flash then an empty grey pnlForm because Designer.CreateControl("Form") returned 0: Designer.Symbols resolved the MyFbFramework library via DyLibLoad on Library.Path, which had been left as the folder "Controls\MyFbFramework" (no mff64.dll) even though the DLL was...
  *Docs, Examples, Framework/Controls, IDE, Settings, Templates · 32 files*
- **`e5e10808`** — Edit menu review: flat checkmark toggles for bubble help, autocomplete, and parameter info.
  Open Project and PathUtils fixes improve example discovery; PROJECT_STATUS records owner-approved File and Edit menu reviews.
  *Docs, Framework/Controls, IDE, Settings · 31 files*
## 2026-07-07

- **`0eaa8806`** — 13.3.A S1-S4: approachability pass (menus, toolbars, dead field) + S3 INI migration
  Opus-reviewed execution of the ROADMAP §13.3.A approachability plan:
  *Docs, Framework/Controls, IDE · 10 files*
- **`93bbfa28`** — 13.3.A S5-S7: File-menu safety, Options dead-UI removal, + Run-toolbar persistence fix
  S5 - Delete Project/Delete File: - DeleteEditorFile was a no-op stub; implemented for real (MsgBox Yes/No confirm, CloseTab, tree-node detach, disk delete) mirroring DeleteProject.
  *Docs, IDE · 5 files*
- **`d75b4b36`** — Opus Next Steps Phase A + P1: robustness fixes + AI thread responsiveness
  Verified backlog from Next Steps - Opus.md (2026-07-07 cross-review of Cursor/Deepseek/Sonnet findings against actual source):
  *Docs, Framework/Controls, IDE · 6 files*
- **`5d9cd620`** — Opus Next Steps Phase B: Suggestions preload + FormatProject disable off UI thread
  - P2: Suggestions' first-run project-content preload called LoadFunctions synchronously per file on the UI thread.
  *Docs, IDE · 3 files*
- **`a7531fb5`** — Opus Next Steps Phase C: calmer debugger text, fresh-install starter project, Options wording
  - U1: rewrote three Debug.bas user-facing messages in plain, calm language and dropped the raw "gdb" name in favor of "the debugger" -- the gdb-not-found/source-not-executable errors, the hard_closing crash dialog, and the all-caps Stop-debuggee confirm. - U2: fresh installs landed on a completely...
  *Docs, IDE · 5 files*
- **`8aba6c2d`** — Opus Next Steps Phase D (partial): feedback-channel policy + two silent-failure fixes
  - F1: wrote down the feedback-channel policy Opus asked for (status bar = transient state, Output panel = background events, MsgBox = irreversible/ blocking only) as a new guiding principle in PROJECT_STATUS.md, to apply opportunistically rather than as a big-bang sweep. - F2...
  *Docs, IDE · 4 files*
- **`640e94ed`** — Opus Next Steps Phase C completion: collapse event-handler cluster, record .lng decision
  Owner decisions (2026-07-07):
  *Docs, IDE · 3 files*
- **`cbc71d15`** — Opus Next Steps Phase E (E1): Options-Apply dirty-tracking to cut unconditional INI writes
  cmdApply_Click wrote all ~296 INI keys unconditionally on every Apply click; IniFile.WriteXxx triggers a full-file disk rewrite per call, so this was ~296 unconditional disk writes per click.
  *Docs, IDE · 2 files*
- **`a114ee5b`** — D1: grey out the Designer menu when no form with controls is open
  The top-level "Designer" menu (miFormFormat) now disables when the active document has no designable form with controls.
  *Docs, IDE · 4 files*
- **`f92a43a1`** — Fix File > Close Project crash/hang; New Project startup + dialog cross-nav
  Close Project was aborting the app (project never closed, reopened on restart).
  *Docs, Framework/Controls, IDE · 8 files*

## 2026-07-08

- **`e4d9a954`** — D1: grey the Designer menu on form/tab close
  The Designer menu didn't grey when closing a form because tabCode_SelChange's "If tb = tbOld Then Exit Sub" early-exits return before the per-select enable-logic.
  *Docs, IDE · 3 files*
- **`25e81cf4`** — R5: bounded/cancellable GDB readpipe (poll with PeekNamedPipe)
  readpipe blocked ReadFile on the debug worker thread with no timeout, so an unresponsive/terminated GDB stalled the thread (and on a broken pipe the old loop spun on repeated 0-byte reads).
  *Docs, IDE · 3 files*
- **`4e3eb17e`** — Fix Close Project (and other project-scoped menu items) greyed out on startup
  LoadWorkspace's AddProject ends with tn->SelectItem, but that's a no-op if the tree control's Win32 handle isn't realized yet at that point in startup -- so the SelChange event that normally refreshes ChangeMenuItemsEnabled never fires for a reloaded project.
  *Docs, IDE · 2 files*
- **`7ee55425`** — Fix menu-icons Options toggle applying live instead of on next run
  cmdApply_Click set Menu->ImagesList immediately on Apply, but already- rendered menu items keep their cached icon until a full rebuild, so unchecking "Display icons in the menu" dropped most icons immediately while leaving a few behind -- contradicting the "next run" message shown right after.
  *Docs, IDE · 2 files*
- **`a510b24b`** — C4: remove the .lng translation-capability at the code level (English-only)
  Owner escalated C4 from "hide the Options language UI" to full removal.
  *Docs, IDE, Settings · 67 files*
- **`820eebb7`** — C1: merge Comment into a single Toggle Comment command; remove Block Comment
  Single Comment (Ctrl+I) and Uncomment Block (Ctrl+Shift+I) collapse into one Toggle Comment bound to Ctrl+I: comments the selection if not already commented, uncomments it if it is (checked against the first selected line, same detection UnComment already used).
  *Docs, IDE · 7 files*

## 2026-07-09

- **`331b5705`** — Fix pending-delete files silently surviving Close Project
  pfSave (the shared Save-changes dialog) destroys its native listbox on WM_CLOSE -- clicking Yes/No/Cancel calls CloseForm, which sends WM_CLOSE, and since nothing overrides Action to "hide" it falls through to DefWindowProc and really tears the window down.
  *Framework/Controls, IDE · 5 files*
- **`d6fb59e8`** — Fix Delete Project crashing and silently failing to delete from disk
  DeleteProject had three separate bugs stacked on top of each other:
  *IDE · 2 files*
- **`72489b9f`** — Fix Add Module crash and duplicate-tab bug
  GetMainFile's scratch-save path (used to analyze an unsaved-to-disk tab) tried to save into ExePath/Temp/Untitled.bas without ensuring the Temp folder exists -- SaveToFile doesn't create missing parent directories, so it failed with "Save file failure!" (repeatedly, once per call site hit during a...
  *IDE · 3 files*
- **`273df0f5`** — Update local editor state, examples, and build artifacts
  Commit accumulated working-directory changes from local development sessions: compiled example binaries, temp/settings files, and source edits under src/ and Controls/MyFbFramework.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 69 files*
- **`5240ad05`** — Make Projects/MFF path settings survive moving the install folder
  Settings/VisualFBEditor64.ini's ProjectsPath had a hard-coded absolute path from before the repo moved (C:\Users\dmont\VisualFBEditor\...), which broke New Project on startup ("Parent folder not exists") once the folder no longer existed at that location.
  *Examples, IDE, Settings · 8 files*
- **`6ff623a3`** — Remove contextual-change-validation rule and skill
  *Build/Tools · 2 files*
- **`b62f18f9`** — Switch remote from Codeberg to GitHub; workspace path portability fix
  Main.bas: make saved workspace/project file paths portable across install-folder moves (MakePathPortable on save, GetFullPath on load, guard missing .vfp on load).
  *Docs, IDE, Settings · 6 files*
- **`8639e1c1`** — Make RecentFiles/RecentProject/RecentFile portable across install moves
  These INI keys stored absolute paths (e.g. from a prior "C:\Users\Public\..." location) with no resolution against the current install folder, unlike Workspace.ini's already-portable project/tab paths.
  *IDE, Settings · 3 files*
- **`f8e2ebd7`** — Track the full MinGW GCC toolchain so a fresh clone can actually compile
  .gitignore's lib*.dll*/zlib*.dll*/*.o patterns predate commit b555406 ("Track the bundled FBC compiler and GDB debugger toolchains in-repo") and were never revisited afterward -- they silently kept excluding the exact runtime DLLs (libmpfr-6.dll, libgmp-10.dll, libmpc-3.dll, libwinpthread-1.dll...
  *Build/Tools · 866 files*
- **`164c5ead`** — Prompt for a name up front when creating a new project file
  Previously, new files (Add Module/Add Form, project templates' default files) got an auto-generated default name with no chance to rename, and renaming only happened later via a repeated sequence of system Save-As dialogs at save/close time -- each of which also allowed saving outside the project...
  *IDE · 8 files*

## 2026-07-10

- **`4b643af5`** — Replace Code/Form view toggle buttons with a top tab strip
  Lazarus-style code/designer switching: each source tab's Code / Form / Code+Form toolbar toggle buttons are replaced by a top tab strip (tcView), ordered Code And Form (default) / Code / Form.
  *Docs, IDE · 6 files*
- **`84b5beef`** — Remove stale Temp/Untitled.bas scratch file
  *Build/Tools · 1 file*
- **`c93abbe0`** — Rename project VisualFBEditor -> AstoriaIDE; fix About dialog and compiler warnings
  Rebrand (full identity rename per ROADMAP §13.4): - Renamed src/VisualFBEditor.bas/.rc/.vfp -> AstoriaIDE.bas/.rc/.vfp, root VisualFBEditor.vfp/.code-workspace -> AstoriaIDE.*, Resources/VisualFBEditor.ico -> AstoriaIDE.ico, Settings/VisualFBEditor64.ini -> Settings/astoria.ini (existing settings...
  *Build/Tools, Docs, Framework/Controls, IDE, Settings · 66 files*
- **`11c033d4`** — Default all toolbars visible on first run (owner decision)
  Reverses 13.3.A O3's "Standard + Run only" minimal default -- owner wants Standard/Edit/Project/Run/Format all visible out of the box.
  *Framework/Controls, IDE · 3 files*
- **`05088583`** — Fix CI: windows.bat hardcoded wrong checkout-folder name
  The AstoriaIDE rebrand (c93abbe) updated windows.bat to cd into a folder literally named "AstoriaIDE", but GitHub's checkout action names the workspace after the actual repo, which is "astoria-ide" (lowercase, hyphenated).
  *Build/Tools · 1 file*
- **`f20012c0`** — Ignore *.dll.a MinGW import-library build byproducts
  libmff64.dll.a is auto-generated by every -dll build of mff64.dll but never consumed -- the IDE loads mff64.dll dynamically at runtime via DyLibLoad (Main.bas:86), and no build step links against the import lib.
  *Build/Tools · 1 file*
- **`62404e04`** — Fix File > Recent Files being permanently invisible (B3)
  Investigated B3 ("OpenRecentFiles() stub") as the next Sonnet task and found the dialog-based design it described had already been replaced by a live File > Recent Files submenu (miRecentFiles, populated via AddMRU/mClickMRU) -- that part worked correctly.
  *Docs, IDE · 3 files*
- **`4a112089`** — Move Bubble Help/Suggest Options/Parameter Info off Edit menu (C2)
  Bubble Help (ShowSymbolsTooltipsOnMouseHover) and Suggest Options (AutoComplete) already had fully-wired Options > Code Editor checkboxes sitting redundant alongside the Edit-menu toggles; removed the Edit-menu items (miSuggestions, miCompleteWord), their dead Checked-sync lines, their mClick...
  *Docs, IDE · 7 files*
- **`0c88cc55`** — Update splash screen text: title without version, static version line
  Top line (lblSplash) now reads "Astoria IDE for Free Basic" with no version number appended (was pulling ProductVersion from the .rc file).
  *IDE · 2 files*
- **`7c631cbf`** — Replace splash screen logo with Astoria Bridge artwork
  Resized the provided AstoriaBridge.png (1342x1172) to 343x270 to match the splash form's lblImage bounds exactly -- the framework draws this image via native Win32 SS_CENTERIMAGE (centers at native size, does not scale), so an unresized drop-in would have rendered zoomed-in and cropped.
  *Build/Tools · 1 file*
- **`121daef0`** — Double splash screen display time; fix version-line overwrite bug
  Splash has no fixed display duration -- it stays up for exactly as long as real startup work takes, closing the moment frmMain_Show fires.
  *IDE · 2 files*
- **`bbd82655`** — Fix frmAbout compile error and a latent OnClick crash
  The About dialog's close button was renamed to BtnClose in frmAbout.frm (added an lblImage logo + repositioned controls for a taller layout) but frmAbout.bi still declared the field as cmdClose -- straightforward name mismatch causing the compile to fail.
  *IDE · 3 files*
- **`6b200502`** — Set About dialog close button caption to "Close"
  *IDE · 2 files*
- **`ab75ca33`** — Session working-state: INI/MRU, .vfp file-order, Temp scratch resave
  Incidental churn from having the IDE open this session: recent-file/ project MRU entries in astoria.ini, the Designer's harmless *File= marker reorder in AstoriaIDE.vfp, a cleared VER_ORIGINALFILENAME_STR in AstoriaIDE.rc, and the usual Temp.bas/Temp.rc Designer-scratch resave (not part of the...
  *IDE, Settings · 5 files*

## 2026-07-11

- **`33e1ffd0`** — Complete Wave 1 hygiene (T9-T11): repo cleanup and shipped-state sanitization
  T9 — Repo hygiene sweep: - Delete C:\Users\don\Downloads\AstoriaBridge.png reference from src/Temp.rc - Untrack + gitignore src/Temp.bas, src/Temp.rc, src/compile_out.txt (Designer-generated scratch files, not real source per prior decisions) - Add gitignore rules for Examples/**/*64.exe and...
  *Build/Tools, Docs, IDE, Settings · 10 files*
- **`a132e23f`** — Complete Wave 1 finalization (T8, T12, T13): CI, README, identity/version
  T8 — CI cleanup: - Delete .github/workflows/windows.bat and its three unverified downloads (7-Zip 9.20, FreeBASIC 1.10.0 from SourceForge, upstream MyFbFramework master.zip) -- the repo is self-contained by policy, CI should prove exactly that instead of re-fetching artifacts it mostly didn't use...
  *Build/Tools, Docs, IDE, Settings · 9 files*
- **`4394ca2f`** — T3 done: rework PipeCmd -- drop clipboard clobber and blanket shell wrapper
  PipeCmd always ran every command through `cmd /c "..."|clip`, which silently overwrote the user's clipboard on ordinary actions (Open Containing Folder, external tools, Delete Project) and re-parsed filenames/args through cmd.exe's fragile quoting for no reason most callers needed.
  *Docs, IDE · 7 files*
- **`1fbb944a`** — T4: replace shelled project delete with native SHFileOperationW
  DeleteProject() (Main.bas) used PipeCmd "rd /s /q ..." (UseShell:=True) to remove a deleted project's folder -- a cmd.exe round-trip that permanently deleted with no error reporting; failures were silent.
  *Docs, IDE, Settings · 4 files*
- **`cda99f83`** — T7: check the 6 remaining unchecked Open For Output writes
  Replicated the R2 pattern (check result, surface failure, bail) at all 6 sites: BuildService.bas:259 (batch-compile file rewrite), frmImageManager.frm:398 (resource file), frmOptions.frm:3119 (HotKeys.txt), frmTools.frm:241 (Tools.ini), Main.bas:8364 (Immediate window scratch file -- shifted from...
  *Docs, IDE · 8 files*
- **`8d04929b`** — T2a: startup writability probe; fix main-window-size regression
  T2a: right after the splash's "Load On Startup: Settings" step, before LoadLanguageTexts/LoadSettings run, attempt a real Open For Output against a throwaway Settings/.writetest file -- not just an ACL check.
  *Docs, IDE, Settings · 4 files*
- **`e83212fc`** — T2b + T17 done: drop dead Languages.txt writes; English-only content sweep
  T2b -- delete the dead Languages.txt write sites (frmFind.frm:575, frmFindInFiles.frm:476): translation-era debug dumps to the IDE root, guarded by `tML = "ML("` -- meaningless since C4 removed the ML() system entirely.
  *Build/Tools, Docs, IDE, Settings · 15 files*
- **`d80135f9`** — Fix T16 findings: Compile() cleanup, delete path, exe quoting
  F-T16-1 (confirmed bug): Compile()'s early Return 0 on a failed batch-file rewrite (BuildService.bas) was the function's only early return and skipped the common exit's StopProgress/CompileContextFree -- left the progress marquee spinning forever and leaked the compile context on that path.
  *Docs, IDE, Settings · 5 files*
- **`d84b2ef7`** — Fix Add External Tool (and 5 other path-picker flows) silently failing
  Owner smoke-test finding: Tools > External Tools > Add, browse to chrome.exe, path fills in correctly, click OK -- dialog closes but no tool appears in the list.
  *Docs, IDE, Settings · 10 files*
- **`7a0c8294`** — Fix Add External Tool: Form_Close was clobbering ModalResult to Cancel
  Live MsgBox diagnostic tracing (owner walked through it interactively) found the actual root cause after the earlier snapshot-fields fix proved insufficient: frmPath.frm's Form_Close, wired as the framework's OnClose callback, fires on every WM_CLOSE -- including the one cmdOK_Click itself triggers...
  *Docs, IDE · 4 files*
- **`937c2f26`** — Replace sample Project1/Project2 with Project3 console app; sync tool/recent-file settings
  Add chrome and notepad++ external tools; update astoria.ini recent files/projects to point at Project3.
  *Build/Tools, Examples, Settings · 7 files*
- **`bf2bef2f`** — T5: quote the bundled GDB path in the debugger launch
  CreatePipeD (Debug.bas) concatenated szCmd (the full path to the bundled gdb.exe) into CreateProcess's lpCommandLine unquoted.
  *Docs, IDE · 3 files*
- **`b5cc3ebf`** — Debugger UI: promote Step Out, clarify step tooltips, drop T6 tracing
  - Move Step Out onto the top-level Run menu, directly under Step Over (was buried in the More Debug Options submenu); hotkey and toolbar button unchanged. - Expand the Step Into/Over/Out toolbar tooltips to describe what each command does, keeping the auto-appended hotkey. - Remove the T6...
  *IDE · 3 files*
- **`9991f765`** — WIP: T6 debugger — set_bp pipe-race fix + T14 doc consolidation (mid-session handoff)
  Committed mid-investigation for cross-machine sync (owner request); the debugger fix is NOT yet owner-verified.
  *Docs, IDE · 4 files*
- **`f40bb8a9`** — Debugger Reliability Phase 1: commit instrumented trace build (temporary)
  Cross-machine handoff — the owner will run the repros on another machine, so the trace instrumentation and its rebuilt binary are committed (the prior session kept DbgTrace working-tree-only; committing here for sync).
  *Docs, IDE · 6 files*
- **`b7af6117`** — DR-4: full repaint on breakpoint toggle (fixes .frm CodeAndForm blank)
  EditControl.Breakpoint called the partial repaint (bFull=False) after toggling a breakpoint marker.
  *Framework/Controls, IDE · 3 files*
- **`1899513d`** — Debugger 2A: strict-lockstep gate on the worker command queue (fixes DR-3 desync)
  The GDB worker loop (Debug.bas:2095) dequeued+sent a queued command at the top of every iteration unconditionally.
  *Framework/Controls, IDE · 3 files*
- **`d8a2e8fb`** — DR-12: fix dead toolbar Toggle Breakpoint button (command-name mismatch)
  The toolbar button dispatched command "ToggleBreakpoint", but no Case "ToggleBreakpoint" handler exists -- only Case "Breakpoint" (what the Run menu's Toggle Breakpoint item dispatches).
  *Framework/Controls, IDE · 3 files*
- **`f534b425`** — DR-11: commit temporary CloseProject trace instrumentation
  Adds 9 DbgTrace markers through CloseProject's teardown and tvExplorer_SelChange (src/Main.bas) to locate exactly where closing a project freezes the IDE when a non-project ("standalone") file is open (owner-reported 2026-07-11; deterministic 2/2).
  *IDE · 2 files*
- **`22271a3b`** — DR-3 slice 2D: marshal debug-panel fills to the UI thread (fixes deadlock + DR-13)
  Owner-verified ("works, no problems"): quick-F8-after-stop no longer freezes; panels + highlight intact.
  *Docs, IDE · 5 files*
- **`b90b8621`** — gitignore debugger trace logs + record DR-11 static root-cause analysis
  - .gitignore: Settings/debug_trace.log and *.pass1/pass2.log (local-only per-machine trace instrumentation output; must not be committed). - PROJECT_STATUS.md DR-11 row: read-only static analysis (no code changed) ranking the CloseProject-freeze candidates and mapping each to the last-seen DbgTrace...
  *Build/Tools, Docs · 2 files*
- **`e596c537`** — DR-8 + debug/project-close UX cleanup (owner-verified)
  Owner-verified this build: "everything works correctly."
  *Docs, IDE · 7 files*
- **`8835186d`** — Rebuild astoria.exe after theme re-curation
  No source change -- themes are loaded at runtime via a folder scan, not compiled in.
  *IDE · 1 file*

## 2026-07-12

- **`0f30654c`** — Debugger 2B: race-free Stop/kill (DR-6) + dead-inferior cleanup (DR-14)
  DR-6: Stop-while-running called kill_debug() on the UI thread, which raced the worker on the shared GDB pipe (a second readpipe) and closed hReadPipe/hWritePipe while the worker could be mid-ReadFile.
  *IDE · 3 files*
- **`47d2583d`** — Debugger 2C: unified breakpoint arm/clear (DR-1/DR-10) + DR-14 residual
  All breakpoint toggles (F9, gutter-click, Run > Toggle Breakpoint) now route through EditControl.Breakpoint -> arm_breakpoint, which ENQUEUES break/clear/ tbreak.
  *IDE · 5 files*
- **`57007dce`** — DR-15: kill the inferior on app close when running freely (fixes orphaned debuggee)
  CloseAllDocuments already enqueued "q" for an active debug session on close, but GDB does not act on stdin while the inferior is running freely in synchronous all-stop mode, so the queued q could sit unprocessed forever -- deinit's bare "q\n" + close-handles never reached GDB, orphaning the...
  *IDE · 1 file*
- **`9e40c425`** — Phase 4 dead-code sweep: remove the vestigial integrated (stabs) debugger
  Removes ~1160 lines of dead code left over from the old integrated/stabs debugger (pre-GDB), confirmed dead via a full src/ cross-reference (every symbol checked case-insensitively; none had a live reader/writer outside its own declaration):
  *IDE · 3 files*
- **`07ea7402`** — Rebuild astoria.exe with DR-15 fix + Phase 4 dead-code sweep
  The tracked exe was last rebuilt at 47d2583, before DR-15 (57007dc) and the Phase 4 sweep (9e40c42) -- every verification since used a debug build that was discarded afterward, so the committed binary never picked up the fix.
  *IDE · 1 file*
- **`8ce74f25`** — DR-7: marshal worker-thread Output/watch-edit/panel-clear touches to the UI thread
  Residual from the 2D audit, now closed.
  *IDE · 3 files*
- **`ce10b5c6`** — Rebuild astoria.exe with DR-7 marshal fix
  Release build, owner quick-tested a normal debug session behaves identically post-marshal (breakpoint/step/watch/output).
  *IDE · 1 file*
- **`7604d8dc`** — DR-4 instrumentation: trace the paint-state driving the visible-line count
  Temporary trace (EC.Paint) for the disappearing-text-on-breakpoint-toggle bug.
  *IDE · 1 file*
- **`56afc8ab`** — DR-4 FIXED: gutter click no longer horizontally scrolls the viewport
  DR-4 ("text disappears on breakpoint toggle") was never a paint/geometry bug.
  *Docs, IDE · 3 files*
- **`63104f1b`** — DR-16(b) FIXED: marshal deinit's UI touches off the worker thread
  deinit() runs on the worker thread (confirmed: its only two live callers are both inside run_debug's loop -- the 'q'-dequeue branch and the LOOP.inferiorGone branch).
  *Docs, IDE · 3 files*
- **`600a8c7f`** — DR-16(a): pre-flight GDB/exe/MainFile checks to the UI thread before debug start
  Owner design decision: fix properly rather than defer.
  *IDE · 3 files*
- **`91b054f6`** — Rebuild astoria.exe with DR-16(a) fix
  Release build, owner-verified: happy path unchanged, missing-exe error path now shows the message immediately on the UI thread.
  *IDE · 1 file*
- **`90f4dc70`** — Phase 4 dead-code sweep (cont'd): remove kill_debug() and line_highlight's unreachable branch
  The two items flagged during the DR-16 audit, both re-verified before removal:
  *IDE · 1 file*
- **`64ea0ed4`** — Rebuild astoria.exe after Phase 4 dead-code sweep
  Pure removal of unreachable code (kill_debug, line_highlight's dead branch), no behavioral change to verify live.
  *IDE · 1 file*
- **`4a0798bf`** — MFF cleanup: drop HTTPServer, Animate, and orphaned ListItemsOld
  Widget/hygiene trim of the vendored MyFbFramework (T0 residual + F-H3), per the Fable MFF review.
  *Docs, Framework/Controls, IDE · 13 files*
- **`2aee0744`** — T-OPUS-1: resolve the ThreadsEnter/ThreadsLeave contract (F-M1)
  The framework's cross-thread-safety API (ThreadsEnter/ThreadsLeave, Component.bas) is a pair of empty no-op stubs on the WinAPI build -- the framework-level root cause of the IDE's DR-3/DR-7 debugger-hang class, since every "ThreadsEnter ... touch UI ...
  *Framework/Controls, IDE · 2 files*
- **`bbf8dc29`** — T-OPUS-2: audit UString accounting; fix dead-but-unsafe AppendBuffer (F-M2)
  Audit verdict: the IDE's reachable UString memory surface is SAFE. - Resize (live at BuildService.bas:353) is used safely -- resize-then-fully- overwrite via MultiByteToWideChar; the "dealloc+calloc destroys old content on grow" quirk is harmless because the caller overwrites the whole buffer....
  *Docs, Framework/Controls, IDE · 4 files*
- **`93315267`** — T-SON-3: guard unchecked Open in MFF list/combo/bitmap controls (F-R-mff)
  Same defect class as the main review's F-R2: SaveToFile/LoadFromFile in CheckedListBox, ComboBoxEdit, and ListControl opened a file and proceeded to read/write it without checking whether Open succeeded -- on a locked/read-only/ permission-denied target (the Program-Files scenario F-S4 warned...
  *Docs, Framework/Controls, IDE · 7 files*
- **`9b19f1e1`** — T-SON-2: harden HTTPConnection -- UserAgent property, response cap, retry docs (F-N7)
  Three fixes to the HTTP client (kept when HTTPServer was dropped -- the IDE uses this one):
  *Docs, Framework/Controls, IDE · 5 files*
- **`27540aea`** — H-3: document the WM_PAINT GetDC-not-BeginPaint fence; drop the dead commented BeginPaint
  Investigating the H-3 "fix" (switch WM_PAINT from GetDC to BeginPaint/EndPaint) revealed the BeginPaint form was already present, commented out -- someone switched FROM BeginPaint TO GetDC upstream (before this fork; the -S search lands on the initial MFF-import commit, not a paint change) and left...
  *Docs, Framework/Controls · 2 files*
- **`7ff604c3`** — H-2: document the Canvas GetDevice/ReleaseDevice HandleSetted collision; defer the fix
  MFF hot-path review H-2.
  *Docs, Framework/Controls · 2 files*
## 2026-07-13

- **`934a9b6c`** — Remove duplicate Canvas GDI fill
  Remove the redundant FillRect after Canvas.Cls has already filled the selected rectangle.
  *Docs, Framework/Controls, IDE · 4 files*
- **`e1595a31`** — Fix View menu owner-review findings: 6 enablement bugs
  Owner walkthrough of the View menu (deferred sign-off item) surfaced six real bugs, all fixed and rebuilt clean:
  *Docs, Framework/Controls, IDE · 7 files*
- **`d099dc60`** — Resolve 4 deferred owner decisions: Change Log location, project paths, themes
  - Change Log: <ProjectName>_Change.log now lives in the project's own folder instead of ExePath, and appears as a node under the project tree's Others folder (double-click jumps to the Change Log tab; rename is blocked since it's a synthesized node, not a real file).
  *Docs, IDE · 5 files*
- **`faaf0860`** — Flatten Run menu: remove More Build Options and More Debug Options submenus
  All build and debug commands now sit directly in the top-level Run menu instead of split between the top level and two buried submenus, per owner's chosen "flatten into top level" approach.
  *Docs, IDE · 5 files*
- **`ffc21f30`** — Add missing tooltips to frmImageManager toolbar buttons
  Finishes the toolbar tooltip audit: Add/AddDropdown/Change/Remove/Up/Down/Sort had no hint text at all, unlike the ShowHint-only gaps fixed elsewhere.
  *IDE · 1 file*
- **`05ff9476`** — Add missing-exe check to Run; fix debug Returned code always showing 0
  Non-debug RunProgram/RunPr now checks the target exe exists before launching, matching the pre-flight check the debug path already had.
  *Docs, IDE · 6 files*
- **`f875fcc7`** — MFF hygiene: remove dead Chinese-language leftovers, close out the rest
  Deleted README_CN.md and changes_cn.txt (dead Chinese translations no longer maintained), removing their two references: the File=README_CN.md entry in MyFbFramework.vfp, and the dead language-switcher link at the top of Controls/MyFbFramework/README.md.
  *Docs, Framework/Controls · 6 files*
- **`472b4b24`** — Rename MFF DLL to astoria.dll, move it to the repo root
  Owner request: source file names stay the same, but the compiled MFF build artifact should be astoria.dll living next to astoria.exe, reflecting how much of MFF's own code is now locally owned/changed (Direct2D removal, H-1/H-4, the hot-path review).
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 19 files*
- **`d48a6cd5`** — Remove toolbox component picker; fix a real GetFullPath .. bug
  Owner decision: no more choosing which Controls\* libraries appear in the toolbox (matches the project's "no unnecessary options" posture).
  *Docs, IDE, Settings · 9 files*
- **`cc319212`** — Rename Controls/MyFbFramework to Controls/Framework
  Owner request: rename the MyFbFramework directory to Framework, and MyFbFramework.wiki/MyFbFramework.vfp to match inside it.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings, Templates · 725 files*
- **`cac01fdf`** — Rename astoria.dll to framework.dll, move back into Controls/Framework
  Owner request, for consistency with the just-renamed folder.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 18 files*
- **`7b262513`** — Redesign New Project dialog: combined name prompts, optional Form/Module
  Merges what used to be a template-picker dialog plus a separate popup name prompt into one dialog: template icons on top, inline Project Name (required)/Primary Form Name/Primary Module Name fields below.
  *Docs, IDE · 7 files*
- **`28ac835b`** — Regen app icon; sync Project4 test bench and example .vfp schema
  - AstoriaIDE.ico regenerated via new Resources/gen_step1.py script - Project4 rebuilt with New Project dialog (Module1.bas -> Main.bas, matching current default naming), .vfp picks up current schema fields - DeviceExplorer.vfp normalized to current .vfp schema from IDE open/save - astoria.exe...
  *Build/Tools, Examples, IDE · 9 files*
- **`2e160bb6`** — Examples: English-only translation cleanup + dead code sweep
  Extends the English-only mandate (a510b24/e83212f) from IDE chrome to Examples/, Controls/MyFbFramework/examples/, and Tools/, then removes dead code across the same trees.
  *Build/Tools, Docs, Examples, Framework/Controls · 261 files*
- **`e9bc31d3`** — Remove temporary project files and sync settings
  *Examples, Framework/Controls, Settings · 4 files*
- **`2f445e49`** — T01: standardize src/ indentation to tabs; normalize src/ line endings to CRLF
  Fixed 3 files with space or mixed tab/space indentation (Main.bas, TabWindow.bas, frmOptions.frm) to match the codebase-wide tab convention.
  *Build/Tools, IDE · 73 files*
- **`6f933f43`** — T16: add tooltips to build-config combo, search boxes, class/function dropdowns; flatten Tools menu; reconcile backlog
  - T16: added .Hint text to cboBuildConfiguration, the four Designer search boxes (Explorer/Toolbox/Properties/Events), and the code editor's cboClass/cboFunction dropdowns, following the existing .Hint = (...) convention. - Flattened the Tools menu: removed the "Advanced" submenu, promoting Add-Ins...
  *Docs, IDE · 4 files*

## 2026-07-14

- **`2f9d5130`** — Remove Other Editors panel from Options; External Tools covers the use case
  Owner decision: users can already register a per-extension launch tool under Tools > External Tools, making the dedicated Other Editors panel in Tools > Options > Code Editor redundant.
  *IDE · 6 files*
- **`4795d9b1`** — T01: standardize Controls/ indentation to tabs; normalize line endings to CRLF
  Converted 124 files with space-only or mixed tab/space indentation to tabs (126 flagged, 2 - SystemInformation.bas/.bi - hand-fixed instead since their original spacing was too inconsistent, 3 vs 7 spaces, for any single per-file unit to fit cleanly).
  *Build/Tools, Framework/Controls, IDE, Settings · 132 files*
- **`6682da9a`** — T01: standardize Examples/ indentation to tabs; normalize line endings to CRLF
  Small, clean scope compared to Controls/: 7 files with space indentation (Basic.bi, Calculator.frm, Com_HtmlFile2.frm, Maze.frm, Temp.bas, WlanListNetworks.bas, WellCOM2.0_vtable.bi), each with a single consistent 3- or 4-space unit throughout - auto-detected conversion produced zero remainder...
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 12 files*
- **`595e3ded`** — Add StageRelease.ps1: assemble an end-user-facing release tree
  Copies only what an end-user developer needs to run Astoria-IDE and compile their own FreeBasic programs with it - not this repo's own IDE source (src/), build scripts, or maintainer docs.
  *Build/Tools · 1 file*
- **`2a04a71b`** — Add Personal Information page to Tools > Options
  New page between Designer and Help in the Options tree: Name, Company, Web site, E-mail address, a multi-line Address field, and a multi-select License group (GPL3/LGPL/Apache/BSD/Freeware/Proprietary/Other, with the Other checkbox enabling its own description field).
  *IDE · 6 files*
- **`39d9b154`** — T08: build a per-user Windows installer with Inno Setup
  Adds AstoriaIDE.iss (packages the StageRelease.ps1 tree into a per-user, no-admin Inno Setup installer with Start Menu shortcuts and a proper uninstall entry) and BuildInstaller.ps1 (runs staging + compile together, since re-running the compile alone just repackages a stale tree).
  *Build/Tools, Docs · 4 files*
- **`b05fdacb`** — Add context-menu parity: code pane done, Designer partial
  Owner dislikes using toolbars, so both the code editor's and the Form Designer's right-click menus should offer everything the toolbars do.
  *Docs, IDE · 4 files*
- **`64a3191b`** — Ignore IDE-generated Temp.bas scratch files
  Temp.bas is the per-build file the IDE writes when compiling/previewing a form; it is machine-local generated output, not source.
  *Build/Tools, Examples, Templates · 22 files*

## 2026-07-15

- **`ab8d166e`** — Designer context menu: fix format submenus not rendering
  The Align / Make Same Size / Horizontal Spacing / Vertical Spacing / Center in Parent submenus were added to mnuDesigner with a @mClick handler on the submenu-header items (4-arg Menu.Add).
  *Docs, Framework/Controls, IDE, Settings · 5 files*
- **`036c5fa3`** — Designer context menu: format items now visible; Align submenu works
  Two fixes for the Designer right-click menu format block: - Submenu headers use 3-arg Menu.Add (no @mClick), matching the working mnuCode "Toggle" header - a handler on a header broke rendering. - Stop toggling the format items' Visible in ChangeFirstMenuItem.
  *Docs, IDE, Settings · 4 files*
- **`9d797cd8`** — Designer context menu: rule out two theories for empty format submenus
  Third attempt at the Align/Make Same Size/Horizontal Spacing/Vertical Spacing/Center in Parent submenu bug (only Align renders its children; the other four show the arrow but an empty flyout).
  *Docs, IDE · 3 files*
- **`06d0a6ac`** — New Project dialog: add Author, License, Git URL, AI-friendly fields
  Owner-requested additions to frmNewProject (dialog expanded 480x290 -> 480x418): Author (defaults from Options > Personal Information > Name, editable per-project), License dropdown (GPL/LGPL/Apache/MIT/Mozilla/BSD/ Freeware/Proprietary/Other, pick-only via cbDropDownList), Use Git checkbox + Git...
  *Docs, Framework/Controls, IDE · 5 files*
- **`894598f8`** — Add Project Setup Templates scaffolding
  Groundwork for the Project Setup Templates feature (see PROJECT_SETUP_PLAN.md): stampable, ship-with-the-app template content under Templates/, using the token set {{PROJECT}} {{AUTHOR}} {{YEAR}} {{DATE}} {{LICENSE}}.
  *Templates · 31 files*
- **`987e8b7e`** — New Project dialog: wire up Git and AI-friendly behavior; fix a framework Z-order bug
  - Replace the free-typed Git URL field with Git Provider/Username/Email fields that construct git@<host>:<user>/<project>.git for GitHub/GitLab/Bitbucket/ Codeberg. - On OK, stamp Templates/AI/<tool> into AI-friendly projects with token substitution, and run git init/commit/remote-add locally...
  *Docs, Framework/Controls, IDE · 7 files*

## 2026-07-16

- **`84d066a2`** — Fix silently non-modal first MsgBox: create the measurement window hidden
  The first MsgBox of every app run was silently non-modal: MsgBoxForm.Execute pre-creates its window for text measurement, Control's constructor defaults FVisible=True, and CreateWnd auto-shows a visible-flagged Form -- so the box appeared on screen mid-setup, and Form.ShowModal's already-visible...
  *Framework/Controls, IDE · 4 files*
- **`787cc6d3`** — New Project Git flow: verify Yes re-checks the remote; stamp .gitignore/.gitattributes; fix initial-commit ordering
  Three fixes to the Use Git path in the New Project dialog, all owner-verified live:
  *IDE · 3 files*
- **`86948b50`** — Round-trip the New Project metadata keys through project load/save
  The ten .vfp metadata keys the New Project dialog appends (Author, License, Description, UseGit, GitProvider, GitUserName, GitEmail, GitURL, AIFriendly, AITool) were write-only: AddProject's parser deliberately skipped them and the project writer regenerates the .vfp purely from the in-memory...
  *IDE · 4 files*
- **`2a515c91`** — AI templates: default FreeBASIC/Astoria rules + skills set across all five tools
  Replaces the per-tool starter scaffolds with a complete, owner-verified default set.
  *Templates · 16 files*
- **`fdb515ec`** — Add native Codex FreeBASIC skills
  *Docs, Templates · 23 files*
- **`95f81e96`** — Add Cursor-native AI project skills matching the Codex skill set
  *Docs, Templates · 18 files*
- **`708a15c8`** — Add native OpenCode FreeBASIC skills matching the Cursor/Codex/Kun set
  - Create .opencode/skills/ with 13 SKILL.md files (5 shared playbooks + 8 extended skills: add-resource, audit-project-manifest, debug-freebasic-app, edit-form-safely, find-framework-control, prepare-release, refactor-freebasic, winapi-interop) - Update opencode.json with skills.paths referencing...
  *Templates · 15 files*
- **`08ba401f`** — AI templates: bring Claude Code to the shared 13-skill set; add Kun skills
  The other agents (Codex/Cursor/OpenCode/Kun) fleshed out their template folders to a common 13-skill set.
  *Templates · 23 files*
- **`2d833f40`** — Remove the Documentation/ folder (redundant FreeBASIC HTML reference)
  Documentation/ held 1092 loose HTML pages (~15MB) of the FreeBASIC language reference.
  *Build/Tools, Docs · 1093 files*
- **`b33a2f95`** — Main-menu Code/Form restructure (WIP checkpoint for handoff)
  Owner-requested: put the code-pane and form-pane right-click commands on the main menu bar.
  *Docs, Framework/Controls, IDE · 4 files*
- **`f3538e1c`** — Code/Form menus: contextual greying by file, view, and focused pane; right-click debug-op parity
  Completes the main-menu Code/Form restructure's two open UX items (owner decisions + all seven verification tests passed live):
  *IDE · 3 files*
- **`6aa69617`** — View selector: icon buttons docked below the viewport; fix TabControl capture breaking button-style tabs
  The per-document Code+Form/Code/Form view strip rendered as flat buttons -- bare grey-on-grey text visually adrift from the viewport it controls (owner report).
  *Framework/Controls, IDE · 4 files*
## 2026-07-17

- **`e41ce94d`** — Fix Console Application template: declare DebugWindowHandle in NoInterface.bi
  mff/NoInterface.bi (included by console/no-GUI programs, e.g. the Console Application project template) used DebugWindowHandle in its Debug.Print routines but never declared it -- only Application.bas (the GUI path) did.
  *Docs, Framework/Controls · 3 files*
- **`026e4177`** — Console template: proper hello-world starter with a headless-safe pause
  Replace the bare colours+title stub (which printed nothing and used a stale "VisualFBEditor" title) with a real starter: sets the window title, prints a green "Hello, world!" plus a short hint, and pauses so the window stays open.
  *Templates · 1 file*
- **`c713f136`** — Don't block startup with a "File not found" modal when a workspace file was deleted
  Reopening the last workspace after a referenced project or tab file was deleted or moved (e.g. an agent-created test project cleaned up between sessions) popped a modal "File not found" dialog on startup that blocked the main window until dismissed.
  *IDE · 4 files*
- **`5ff2dce8`** — New Project dialog: template dropdown as a matching field row; add project.astoria description-file module
  Two things toward the New Project rework:
  *IDE · 8 files*
- **`8010c24d`** — New Project: two-mode redesign (Create Local / Use Existing Git) + write project.astoria (WIP, owner testing)
  Task 1 of the project-creation redesign (owner-confirmed design).
  *Docs, IDE · 6 files*
- **`fc9fc8a1`** — New Project: Edit Project Description menu + clearer clone refusal
  Task 2 of the two-mode redesign, plus a message tidy in the clone flow.
  *IDE · 5 files*
- **`fcf2b676`** — AI templates (ClaudeCode): add git-workflow skill + document project.astoria
  Git and MCP are now features, but the ClaudeCode template never mentioned project.astoria and had no git guidance.
  *Templates · 3 files*
- **`d61eb062`** — Add top-level Git menu (Git Pull / Git Push) between Run and Tools
  A dedicated Git menu for git-backed projects, room to grow.
  *IDE · 4 files*
- **`fffee489`** — Git menu: add Git Commit with a message prompt
  Git Commit prompts for a message (framework InputBox), then runs git add -A + git commit -F <tempfile> in the open project folder via RunGitInProject.
  *IDE · 4 files*
- **`1efc1619`** — Git Commit: themed message dialog + fix BOM in commit-message file
  Two fixes on the Git Commit item: - The commit message file was written with Open ...
  *IDE · 3 files*
- **`0fec0c55`** — Git menu: plain-English result summaries for Commit/Pull/Push
  Replaced the raw git-output dump in the result boxes with a short readable summary via ShowGitResult: commit -> "Committed to <branch> as <hash>" + the message + change line; pull -> "Pulled changes" / "Already up to date"; push -> "Pushed your commits" / "Nothing to push".
  *IDE · 1 file*
- **`60da4ee0`** — Git Commit: show the files that will be committed; ignore Temp.bas scratch
  - The Git Commit dialog now lists what git add -A will stage (git status --porcelain, formatted as modified/new/deleted/renamed), in a read-only box above the message -- so a scratch file being swept in is visible, not a surprise.
  *IDE, Templates · 4 files*
- **`415e2e94`** — PROJECT_STATUS: Git menu (Task 3) done; register frmGitCommit in .vfp
  *Docs, IDE · 2 files*
- **`fd894173`** — Git menu: Set Up SSH Key (Task 4, slice 1)
  New Git menu item (in a setup group below Commit/Pull/Push).
  *IDE · 3 files*
- **`a28ad9ea`** — Task 4 complete: gh/glab SSH-key auto-add + wire setup into New Project
  - SetupSshKey (refactored out of GitSetupSshKey, now public) tries the provider CLI first: if gh (GitHub) / glab (GitLab) is installed AND authenticated (`<cli> auth status` exit 0), it offers to add the key directly via `<cli> ssh-key add`; on decline or failure it falls back to the...
  *IDE · 3 files*
- **`95b04f70`** — Task 5: Create Remote Repository (Git menu item + New Project preflight)
  New Git menu item "Create Remote Repository" (setup group, next to Set Up SSH Key) and a New-Project preflight:
  *IDE · 4 files*
- **`7b7b435b`** — New Project: rename 'Use Existing Git Project' radio to 'Git Project' (it now creates the repo if missing)
  *IDE · 1 file*
- **`76c13aec`** — New Project: GitHub-only provider shown as a static bold label
  The four-provider dropdown is retired (GitLab/Bitbucket/Codeberg lag on the CLI automation). cboGitProvider is hidden/inert; a bold 'GitHub' label sits where the dropdown was, left-justified with its left edge, keeping the 'Git Provider:' caption.
  *IDE · 2 files*
- **`c1041696`** — New Project: 'Main' startup convention; drop Form/Module name fields
  Every template's startup file is now named Main -- Main.frm for a GUI Windows Application (with its class/instance/.rc renamed Form1->Main), Main.bas for the Console/Library templates (UserControl1->Main); each template .vfp updated.
  *IDE, Templates · 11 files*
- **`d4d775f7`** — Edit Project Description: structured dialog (Part B)
  Replaces the raw-text open with frmEditProjectDescription: a read-only block (Project Name / Template / Mode / Startup Main.frm|Main.bas / Created / Git remote) plus editable Author, License, Description, and Make-AI-friendly + AI Tool.
  *IDE · 5 files*
- **`b3689acf`** — Options Personal Information redesign + Git identity plumbing; fix missing-INI and stale-recent-project bugs
  Tools > Options > Personal Information: - Licenses in three columns (two rows of three, Other + field on a third row).
  *Docs, IDE · 9 files*
- **`29fa4d56`** — Seed a missing astoria.ini from a defaults template; drop the dead [Debuggers] section
  The empty Tools > Options terminal dropdown was a regression from the earlier missing-INI fix, not a UI bug.
  *Docs, IDE, Settings · 6 files*

## 2026-07-18

- **`92a6c240`** — Built-in terminal list, working menu icons, and help/page cleanup
  Terminals are now built in and not user-editable: the list lives in SeedBuiltInTerminals() rather than indexed [Terminals] keys, and offers only the consoles Windows ships -- Standard Windows Console, Command Prompt, Windows PowerShell, and the newly added Windows Terminal.
  *Docs, IDE, Settings · 11 files*
- **`91110174`** — Control testing: per-control test programs, results doc, and two library fixes
  Adds Documentation/ControlTesting.md - a status table for all 74 toolbox elements (Name, Visual, Compiled, Tested, Verified, Notes) - plus the 73 generated test projects under Examples/Controls/, one Windows Application per control containing exactly that control.
  *Build/Tools, Docs, Examples, Framework/Controls · 296 files*
- **`0986f182`** — Ship libmariadb.dll; correct two control-test results that were false passes
  MariaDBBox linked but would not start: the repo carried only the link-time libmariadb.lib / libmariadbclient.a (plus a stray .pdb), never the runtime libmariadb.dll.
  *Build/Tools, Docs, Framework/Controls · 3 files*
- **`a100adfc`** — Copy a control library's runtime DLLs beside the exe on build
  A program using ScintillaControl or MariaDBBox built successfully and then refused to start anywhere the DLLs were not already adjacent - which is every machine except the one that built it.
  *Docs, Framework/Controls, IDE · 6 files*
- **`1635bc4e`** — Re-enable WebBrowser, show Cursor once, and document controls and framework
  Four related changes, all from auditing what the toolbox does and does not show.
  *Docs, Examples, Framework/Controls, IDE · 9 files*
- **`acea2cc4`** — StageRelease: ship Documentation, and stop shipping Examples build output
  Documentation/ was excluded by omission, with a comment explaining why.
  *Build/Tools · 1 file*
- **`d4e36d18`** — StageRelease: export from git archive; release binaries and 1.0 handoff
  Staging now exports `git archive HEAD` into a scratch tree and copies from that, so a file that is not committed cannot ship.
  *Build/Tools, Docs, IDE, Settings · 5 files*
- **`2a16812f`** — Stop tracking the live settings file; ship defaults via astoria.default.ini
  Settings/astoria.ini is the per-user settings file: every run rewrites window geometry and MRU lists into it, and [PersonalInfo] now holds a name, e-mail and Git login.
  *Build/Tools, Docs, Settings · 4 files*
- **`e0873d98`** — Run TestPlan A1 and A4: SQLite3 data path proven, WebBrowser found broken
  A1 -- SQLite3Component data path: PASS, 26/26.
  *Build/Tools, Docs, Examples, Framework/Controls · 9 files*
- **`02d263d0`** — Run TestPlan B1, B4, B6 and B10: multi-control integration passes
  First real coverage of controls cooperating rather than each opening alone.
  *Build/Tools, Docs, Examples · 7 files*
- **`80e78044`** — Convert B1, B4 and B6 to self-driving, and run B7 (shared ImageList)
  The three externally-driven tests parked a window on the tester's desktop for as long as the driving script ran -- unacceptable for a suite meant to be re-run every release.
  *Build/Tools, Docs, Examples · 7 files*
- **`e7641539`** — Run TestPlan B13 and B3, and give the whole integration suite a manifest
  B13 -- 26 different control types on one form: 7/7.
  *Build/Tools, Docs, Examples · 19 files*
- **`8e7b39b0`** — Run TestPlan B11 and B12: database-to-view and browser composite pass
  B11 -- SQLite3 query results into a ListView: 13/13.
  *Build/Tools, Docs, Examples · 10 files*
- **`a7aee72c`** — Run TestPlan B2, B5, B8 and B9 -- Section B complete, and fix a framework shift-key bug
  All thirteen multi-component scenarios now pass.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 23 files*
- **`d72cf7d7`** — Run TestPlan A7: property and event depth on the seven common controls
  50/50 across TextBox, ComboBoxEdit, ListView, TreeView, CheckBox, RadioButton and CommandButton.
  *Build/Tools, Docs, Examples · 6 files*
- **`2518520b`** — Run TestPlan A2: SQLite3Component error handling
  20/20.
  *Build/Tools, Docs, Examples · 4 files*
- **`b02a4bc6`** — Fix the modifier-key mask across Astoria's own source, and record C2 as partial
  TestPlan B2 found the framework testing GetKeyState(VK_SHIFT) And 8000 -- decimal 8000 is &h1F40 and shares no bits with the &h8000 key-down flag.
  *Docs, Framework/Controls, IDE · 10 files*
- **`a4281211`** — Preserve a file's encoding and line endings on save; TestPlan C2 passes
  C2 asked whether a designer edit round-trips without disturbing the rest of the file.
  *Docs, IDE · 5 files*
- **`375eb914`** — Revert the encoding change: BOM-less normalisation on save is deliberate policy
  a428121 treated the IDE's BOM stripping as a fidelity defect and made saving preserve whatever encoding a file arrived with.
  *Docs, IDE · 5 files*
- **`623aa2a7`** — Add designer Undo/Redo (UNBUILT, UNTESTED) and write the session handoff
  WARNING: src/AstoriaIDE.bas carries a designer Undo/Redo implementation that has never been compiled or run.
  *IDE · 1 file*
- **`1c00c1fb`** — Split the Code and Form menus, add a never-greyed Code/Form menu
  Ctrl+Z, Ctrl+Y and the clipboard shortcuts now work on the form designer.
  *Docs, IDE · 8 files*
- **`d9c31939`** — A6 gets a project file; document what the Integration fixtures do not cover
  A6_ScintillaEditing now has a .vfp and is verified both ways.
  *Docs, Examples, IDE · 4 files*
- **`e2350590`** — Astoria is a project-based build system, not an editor; session handoff
  States plainly in the user-facing document what this session established by accident: there is no way to open a loose source file and work on it.
  *Docs, IDE · 4 files*
- **`cc23967a`** — A3 setup: keep the real DB password out of the tracked file
  The setup script shipped with a CHANGE_ME placeholder and told the owner to edit it in place.
  *Build/Tools, Examples · 2 files*
- **`b1819b1c`** — TestPlan A3 passes: MariaDBBox data path works, four defects confirmed
  Run against MariaDB 10.6.8.
  *Docs, Examples, IDE · 6 files*
- **`1f1864c0`** — Fix all four MariaDBBox defects found by TestPlan A3
  A3 now passes 34/34 against MariaDB 10.6.8, up from 24 passing with 4 defects recorded.
  *Docs, Examples, Framework/Controls · 7 files*
- **`fc9ebc9d`** — Fix C3: rename a control and its references follow (ROADMAP 13.17)
  The 1.0 blocker.
  *Examples, IDE · 5 files*
- **`35a53050`** — Fix 13.18: never raise a modal from the app-activation handler
  Clicking the IDE to focus it could raise a modal "file changed, reload?" dialog from inside frmMain_ActivateApp.
  *Docs, IDE · 5 files*
- **`cd08ffbb`** — Fix a crash I introduced in the 13.18 reload prompt, and instrument the detection
  Owner hit two problems with the first 13.18 fix.
  *Examples, IDE · 5 files*

## 2026-07-19

- **`36cacd84`** — Fix the 13.18 prompt listing two files as one, and record the cause as 13.22
  The batching worked from the first run.
  *Docs, Examples, IDE · 6 files*
- **`b2074434`** — Claude template: add the three rules this session's defects would have prevented
  Only Templates/AI/ClaudeCode, per owner instruction; it is the master copy the other AI templates are derived from.
  *Templates · 3 files*
- **`ef638983`** — Claude template: add testing discipline
  Verify by effect rather than return value; make the assertion as strong as the claim; measure before theorising.
  *Templates · 2 files*
- **`b7888651`** — TestPlan D1 passes: console app lifecycle, 12/12
  Create from the Console Application template, edit, build, run, read the output back, switch away to another project, reopen, confirm the edit survived, and rebuild.
  *Build/Tools, Docs, IDE · 7 files*
- **`08eaece3`** — Drop the gh/glab CLI dependency; Git setup steps use the browser
  Owner decision: if someone is running Astoria, a browser is available, so a command-line tool is not worth depending on.
  *Docs, IDE · 6 files*
- **`79a2c10c`** — Session handoff: D1/D2 pass, gh removed, four tasks recorded
  Documents the session and tidies two things the testing left behind.
  *Build/Tools, Docs · 3 files*
- **`b5bf4678`** — Upgrade Cursor AI template to ClaudeCode parity
  *Docs, Templates · 8 files*
- **`0b424270`** — ChatGPT template: align skills and safety rules
  *Templates · 10 files*
- **`3e2c6cc7`** — Add Kimi AI templates mirror
  *Templates · 19 files*
- **`5f0f84c4`** — Kun template: align skills and safety rules
  *Templates · 2 files*
- **`c838493b`** — Fix settings recovery and multi-form debugging
  *Build/Tools, Docs, Examples, IDE · 16 files*
- **`6f1dcee5`** — Verify clean install and remove framework warnings
  *Docs, Framework/Controls, IDE · 9 files*
- **`46078e6f`** — Revert warning cleanup that broke startup
  *Docs, Framework/Controls, IDE · 7 files*
- **`4d7499b1`** — Tidy test artefacts: complete the A8 fixture, ignore generated output
  Three separate things the recent test runs left in the tree.
  *Build/Tools, Docs, Examples · 5 files*
- **`205d0ea6`** — Remove every compiler warning from user builds and from the IDE's own
  A user building any project saw six framework warnings; building the DeviceExplorer example added two more.
  *Docs, Examples, Framework/Controls, IDE · 8 files*
- **`3f261364`** — Rebuild framework.dll so the shipped binary matches its source
  The previous commit fixed warnings in Control.bas and Application.bas but left the committed DLL as it was, on the reasoning that default arguments are resolved in the caller from the .bi declarations and so the binary could not change.
  *Framework/Controls · 1 file*
- **`0d6c6be8`** — 13.27: the IDE no longer chooses the left panel for you
  ApplyView ended both the "Form" and "CodeAndForm" branches with an unconditional tpToolbox->SelectTab, so every application of a form view dragged the left panel to the Toolbox -- including re-applications the user never asked for.
  *Docs, IDE · 5 files*
- **`0086f1aa`** — Enforce CRLF project-wide instead of freezing it, and re-sweep 374 files
  The T01 sweeps (2f445e4, 4795d9b, 6682da9) established CRLF across src/, Controls/ and Examples/, and added scoped `-crlf` .gitattributes rules so the conversion would survive core.autocrlf=true.
  *Build/Tools, Examples, Framework/Controls, IDE · 374 files*
- **`3c9dc6b1`** — 13.27 owner-verified; ship the binary that was tested
  Rebuilt at 21:27 and verified by the owner: startup lands on Project, New Project selects Project, saving / adding a file / switching views no longer move the panel, and View > Toolbox still works.
  *Docs, IDE · 2 files*
- **`03e1209d`** — Ignore local test artefacts and regenerate the changelog
  Throwaway New Project fixtures from the 13.27 verification, built binaries inside the tracked Projects/ fixtures (the existing `Projects/*.exe` rule only matched the top level, so a build inside Projects/Project3/ escaped it), and the suffixed debugger traces alongside the already-ignored...
  *Build/Tools, Docs · 2 files*
- **`25679526`** — Add the changelog generator the documentation already assumed existed
  DetailedChangelog.md has always described itself as generated from commit messages, and CLAUDE.md told contributors to "regenerate rather than hand-edit" -- but no generator existed, so every entry was appended by hand.
  *Build/Tools, Docs · 3 files*
- **`18d33255`** — TestPlan E11 passes, and fix the crash it found on a second launch
  E11 asked what happens when two Astoria processes run at once.
  *Build/Tools, Docs, IDE · 8 files*
- **`94d8caed`** — 13.30: the editor now follows the system high-contrast theme
  Astoria never called SPI_GETHIGHCONTRAST anywhere in src/.
  *Docs, IDE · 6 files*
- **`712c29bd`** — UI: remove Tip of the Day, fix the toolbars to three rows, one Toolbars toggle
  Three owner-requested changes, made together because they touch the same startup and chrome code.
  *Build/Tools, Docs, IDE · 22 files*
## 2026-07-20

- **`e8cad6f7`** — E12: shortcut sweep harness, two real defects, rest deferred
  Tools > Options > General > Shortcuts advertises 54 assigned shortcuts.
  *Build/Tools, Docs · 7 files*
- **`4ff9dd80`** — Fix both shortcut defects E12 found (13.32, 13.33)
  13.32 -- Ctrl+Shift+O (Open Project) could never fire.
  *Docs, IDE, Settings · 6 files*
- **`53186333`** — 13.28 part 1: a modal dialog can be used and closed from the keyboard
  E9 recorded the New Project dialog as taking no keyboard input at all -- no initial focus, Tab moving nothing, Escape not closing it, only Alt+F4 dismissing it.
  *Docs, Framework/Controls, IDE · 9 files*
- **`58f3fbcd`** — 13.28 part 2: the project tree can be reached and walked from the keyboard
  Ctrl+R ("Project Explorer") put the caret in the panel's search box, and Tab never carried focus on into the tree, so a keyboard-only user could reach the panel but never a file in it.
  *Docs, IDE · 5 files*
- **`824b24cf`** — Shortcut integrity: fix 13.35 at the generator, and validate at startup
  Every shortcut defect found so far has been bad DATA rather than bad dispatch: a missing entry (13.32), blank duplicates shadowing a real binding (13.33), and an accelerator quietly eating a menu mnemonic.
  *IDE, Settings · 7 files*
- **`ec554bea`** — Framework: gated diagnostics for the Alt+C/G/R defect (13.28 part 3)
  Three hypotheses formed by reading code had already been disproved, so these measure instead of proposing a fourth.
  *Framework/Controls · 2 files*
- **`5cc5417e`** — 13.28 part 3: record the investigation, its harnesses, and the rebuilt binaries
  Alt+C, Alt+G and Alt+R still do not open their menus.
  *Build/Tools, Docs, Framework/Controls, IDE · 14 files*
- **`4dcd77a1`** — 13.28 part 3: eliminate hypothesis 12 and the user-mode debugger route
  Two approaches closed off, neither of them the fix, both recorded so they are not retried.
  *Build/Tools, Docs · 4 files*
- **`07d829cd`** — 13.28 part 3: verify every kernel-debug prerequisite on the target
  Checked the setup requirements rather than assuming them, since the last two recommendations in this investigation both failed on unchecked premises.
  *Build/Tools, Docs · 2 files*
- **`0245a492`** — 13.28 part 3: target configured for kernel debugging, pending reboot
  kdnet.exe enabled network debugging on the Realtek GbE NIC.
  *Build/Tools · 1 file*
- **`b072609b`** — 13.28 part 3: the defect reproduces on the second machine, silently
  The previous session's handoff asked for three keystrokes on the other computer, on the grounds that either answer would be progress.
  *Build/Tools, Docs · 3 files*
- **`3380be43`** — 13.28 pt 3: six more hypotheses eliminated, cause still unknown
  Not solved.
  *Build/Tools, Docs, IDE · 9 files*
- **`e979d158`** — 13.28 pt 3: menu-bisect follow-up, three more hypotheses eliminated
  Not solved.
  *Build/Tools, Docs, IDE · 5 files*
- **`ae5450c7`** — 13.28 pt 3: TranslateAccelerator ruled out; every user-mode layer eliminated
  Rung 1 done.
  *Docs, Framework/Controls, IDE · 6 files*
- **`b943e3c0`** — 13.28 pt 3 WORKAROUND: move Code/Git/Run mnemonics off the swallowed letters
  Not a fix.
  *Docs, IDE · 6 files*
- **`b9061ee5`** — Add Alt+E as mnemonic for the Code/Form menu
  Code/Form was the one top-level menu without a mnemonic (index 4, "Code/Form" with no ampersand -- called out in the earlier menu-bar dump as one of the "incidental findings for 13.35").
  *IDE · 3 files*
## 2026-07-22

- **`9d277f28`** — Remove Git integration; consolidate project description into a Properties tab
  Git is an advanced feature that doesn't fit Astoria's target audience (returning Basic programmers, hobbyists, students), so every user-facing Git surface is gone:
  *Docs, Examples, IDE, Templates · 54 files*
## 2026-07-25

- **`c9da6c05`** — Designer/editor: fix two undo defects, one of them a crash
  13.36 -- designer Cut then Undo terminated the IDE, with no message and no WER record.
  *Docs, Framework/Controls, IDE · 11 files*
- **`bf5e538a`** — Designer: renaming a control now renames its handler and caption
  Renaming a control left its event handler under the old name, so btnGreet was wired to CommandButton1_Click with nothing to say which handler belonged to which control.
  *Docs, IDE · 9 files*
- **`923703ec`** — Project description: preserve legacy value, fill FileDescription; keep split view on double-click
  13.39 -- two gaps left by the Properties-tab consolidation, both fixed and owner-verified.
  *Docs, IDE · 6 files*
- **`6de0332f`** — AI: consolidate on Claude Code, and make the AI-friendly checkbox actually work
  13.43 -- Astoria now offers Claude Code and nothing else.
  *Docs, IDE, Templates · 120 files*
- **`6ccb0383`** — Remove 2,449 lines of commented-out code from src/, with a guard against regrowth
  13.42, src/ half.
  *Build/Tools, Docs, IDE · 27 files*
- **`7e23e1ca`** — Win64-only: remove Android and non-Win64 build plumbing, and dead template keys
  13.42, Win64 half.
  *Docs, IDE, Templates · 11 files*
- **`216b02c5`** — Sweep commented-out code from Controls/Framework/mff: 1,865 lines
  13.42, framework half.
  *Build/Tools, Docs, Framework/Controls, IDE · 95 files*
- **`1980d897`** — 13.47: repair cJSON and SQLite3, and give the control libraries a build target
  The bug is one word: Controls/cJSON/Main.bas called New_(CJSON_TYPE) where the framework's allocation macro is _New.
  *Build/Tools, Docs, Framework/Controls · 12 files*
- **`0c930697`** — Delete the 32-bit sqlite3.dll from the SQLite3 control library
  Owner decision, following 13.47.
  *Docs, Framework/Controls · 6 files*
- **`5077c4fc`** — Delete the unreferenced sqlite3_x64.dll and duplicate libsqlite3_x64.a
  Owner decision, completing the SQLite3 folder cleanup from 13.47.
  *Docs, Framework/Controls · 7 files*
- **`a83af325`** — 13.40: stamp ProjectName and InternalName when a project is created
  Every project template ships ProjectName="", and the GUI creation path copied it through unchanged.
  *Docs, IDE · 5 files*
- **`a00e8079`** — 13.38: stop writing UTF-8 BOMs into the files Astoria generates
  The blocker recorded in ROADMAP dissolved on inspection.
  *Docs, IDE, Templates · 18 files*
- **`99748560`** — 13.48: stop Find/Replace in Files destroying non-ASCII in the user's source
  Filed yesterday as "adds a BOM".
  *Docs, IDE · 7 files*
- **`b8195f7d`** — 13.22: MsgBoxForm grows to fit long paths instead of clipping them
  The box was a fixed 380 logical units wide and grew only in height.
  *Docs, Framework/Controls, IDE · 7 files*
- **`2f2498f2`** — 13.46: give a project only the control-library search paths it uses
  Every compile carried -i/-p for all five control libraries whether the project touched them or not.
  *Docs, IDE · 4 files*
- **`4ec96461`** — 13.24: sweep the analysis scratch file instead of leaving it in the project
  GetMainFile writes the tab's text to Temp.bas beside the user's own file when a modified tab needs to exist on disk, and nothing deleted it.
  *Docs, IDE · 6 files*
- **`4ddabcdd`** — 13.49: delete the object file a syntax check leaves in the project folder
  Spotted while verifying 13.24.
  *Docs, IDE · 4 files*
- **`44ab8e94`** — 13.50: a syntax check now reports success when the code is clean
  Compile zeroed CompileResult inside the "If WasNotCreated Or Blocked" branch, and WasNotCreated tests whether an executable exists.
  *Docs, IDE · 4 files*
- **`f183e9c9`** — 13.51: resolve #include the way the compiler does, not just relative to the file
  Also softens the WebBrowser framing in UpstreamFixes.md: making WebView2 the default is our product choice for beginners, not something to suggest upstream, and the entry now says so plainly.
  *Docs, IDE · 7 files*
- **`f4448aa0`** — Bring SignificantChanges up to date, and render it to PDF for human readers
  The document had not been reconciled with the code since 2026-07-20 and described two things Astoria no longer has.
  *Build/Tools, Docs · 3 files*
- **`3ddbcb68`** — 13.52: a multi-select designer operation is now one undo entry
  Found by the owner on the TestPlan C4 re-run against a freshly opened document -- the run that row had been waiting for.
  *Docs, IDE · 6 files*
## 2026-07-26

- **`16545e13`** — Tools/DocCheck.py: make the documentation rule enforceable instead of remembered
  The owner asked, reasonably, why rules that are loaded automatically still have to be asked for.
  *Build/Tools, Docs · 4 files*
- **`ee0883bc`** — Apply the project skills to Astoria's own development; broaden two rules
  The owner asked previously that the skills Astoria stamps into projects created WITH it should also apply to developing Astoria, and that the documentation and checking rules should be comprehensive.
  *Build/Tools, Docs · 16 files*
- **`ba0bd0ea`** — 13.53/13.54: stop an Options save unbinding shortcuts, and un-collide Ctrl+F5
  Both found by the 13.35 hand check, which passed its own subject.
  *Docs, IDE · 5 files*
- **`e3bfa7a3`** — 13.54 follow-up: sweep every HK default, and add a check so the class cannot recur
  The 13.54 entry left a sweep open, because nothing compares shortcut defaults against each other.
  *Build/Tools, Docs, IDE · 6 files*
- **`b5236c2e`** — Tools/SmokeTest.py: a regression harness, which immediately found a regression
  Today's fixes were each verified once, by a script that was then thrown away.
  *Build/Tools, Docs, Framework/Controls, IDE · 9 files*
- **`42ef10cd`** — SmokeTest: drop a duplicated BOM assignment left by an earlier edit
  *Build/Tools · 1 file*
- **`2c63fe8c`** — GenerateChangelog -Check: stop failing on the commit it cannot list
  The script has always documented the fixpoint -- a regeneration commit can never appear in the file it writes, because the entry would need a hash that does not exist until after the entry exists.
  *Build/Tools · 1 file*
- **`77d99d03`** — Tools/CheckAll.py: run every mechanical guard with one command
  Astoria has four fast guards -- commented-code budget, documentation currency, shortcut defaults, changelog currency -- plus the smoke test.
  *Build/Tools, Docs · 4 files*
- **`7595479c`** — gitignore: stop tracking Python bytecode artifacts
  Tools/__pycache__/CommentedCode.cpython-313.pyc was committed by accident -- a compiled artifact regenerated by every Python run, not source.
  *Build/Tools · 2 files*
- **`9d8d7b8c`** — SmokeTest: fix 13.56 (verified honest under a real hang); find and file 13.57
  13.56, fixed as specified: Tools/SmokeTest.py now waits for the IDE to answer (wait_for_ide) before asserting anything, SKIPs -- rather than silently evaluates -- every check that reads project output when no project was created, and rmtree_report() distinguishes "still open" from a genuine cleanup...
  *Build/Tools, Docs · 5 files*
- **`7e344b3b`** — GenerateChangelog -Check: fix the retry to use the tip's actual parent, not a list index
  The previous fix (2c63fe8) retried against $commits[$commits.Count - 2].Hash -- an entry picked out of the flattened, date-ordered commit list.
  *Build/Tools · 1 file*
- **`0a9256cb`** — 13.57: the IDE was hung on a modal prompt no agent could answer
  Not a deadlock, which is what two earlier hypotheses assumed. write_file synced the open tab's TEXT but never its DateFileTime, and the externally-changed check (frmMain_ActivateApp) compares only timestamps -- so Astoria classed its own write as "changed by another application" and raised the...
  *Build/Tools, Docs, IDE · 11 files*
- **`2da5491c`** — Tests for the two unverified items: E13 (13.57 guard) and E14 (13.58 rate)
  The rule is that a feature either works or does not ship, and 13.57 Part 2 was sitting in the tree implemented, reviewed, and never once observed to run.
  *Build/Tools, Docs · 7 files*
- **`c17cf6a0`** — T57 harness: the no-stdin escape hatch could report a PASS it had not earned
  E13's whole design rests on the negative control: case 1 observing "no dialog appeared" is equally consistent with the guard suppressing the prompt and with the change never having been detected, so the docstring states plainly that case 1 alone is not a pass.
  *Build/Tools · 1 file*
- **`081b6341`** — T57 harness: case 1's banner did not say the click must come from another app
  WM_ACTIVATEAPP fires only when the application gains activation FROM another application, which is the reason this test needs a person at all.
  *Build/Tools · 1 file*
- **`b18f61dd`** — T57 harness: case 1 tested a state the guard has never been able to reach
  The guard's condition is AgentClientConnected(), and gAgentClientConnected tracks ONE LIVE PIPE CONNECTION -- set on connect, cleared when that client's read loop exits (AgentPipe.bas 1077/1097).
  *Build/Tools · 1 file*
- **`b8ee1a69`** — T57 harness: stop printing "dialog dismissed" after a wait that timed out
  Case 2 waited up to 120s for the prompt to be dismissed and then printed "dialog dismissed" unconditionally, so a timeout -- the case where the dialog is STILL UP -- reported the exact opposite of what happened.
  *Build/Tools · 1 file*
- **`dae44cf5`** — T57 harness: detect a modal by its disabled owner, not by a window title
  The negative control failed on a live run -- "prompt DOES appear with no agent connected" reported no dialog -- while the tester was looking straight at the prompt.
  *Build/Tools · 1 file*
- **`d106c01d`** — T57 harness: the modal detector could never fire, and the two case-2 checks were racing each other
  Two defects, both mine, both in the negative control.
  *Build/Tools · 1 file*
- **`c96dced8`** — T58 harness: add 13.58's discriminator -- an open_project arm, interleaved
  13.58's open question is whether the noise is a race between create_project writing the main file and the parser resolving it, or a general failure of the parser to resolve a project's own main file.
  *Build/Tools · 1 file*
- **`8fe3c207`** — 13.58: discriminator run, and the entry's own characterisation was too narrow
  Ran the open_project discriminator this entry specified, plus both arms on the measuring machine and interleaved -- without the create arm running here too, a clean open arm could not have separated "open_project does not reproduce it" from "this machine does not reproduce it", and this is not the...
  *Build/Tools, Docs · 3 files*
- **`46f66744`** — 13.60: the IDE has been crashing all session and every harness reported green
  Found by accident.
  *Build/Tools, Docs · 4 files*
- **`98b385ea`** — 13.60 tooling: opt-in symbols/map, and a crash-repro harness for both machines
  Two things were blocking any diagnosis of 13.60, and neither was the crash itself.
  *Build/Tools, Docs · 4 files*
- **`156d1341`** — T58 harness: stop naming a mechanism the evidence contradicts, and fix the prior
  Two corrections, both from the Ryzen 5 run (ROADMAP 13.58, 13.60).
  *Build/Tools · 1 file*
- **`8cb4aa58`** — T60 harness: the readiness check could never pass, so every cycle logged a false "IDE did not answer"
  launch_and_wait() ended in `'"project"' in p.stdout`.
  *Build/Tools · 1 file*
- **`88d2c614`** — 13.60 fix: marshal the IntelliSense loader's UI work to the UI thread
  Start/EndOfLoadFunctions run on worker threads -- every caller is a ThreadCreate_ entry point -- and both touched things only the UI thread owns.
  *Build/Tools, IDE · 6 files*
## 2026-07-27

- **`90db15d1`** — 13.60: page-heap reproduction ATTEMPTED AND FAILED -- 122 cycles, zero faults
  The fix stands and a genuine race is gone.
  *Build/Tools, Docs · 2 files*
- **`1890c063`** — GenerateChangelog: pin git's output encoding so the guard stops depending on the console
  Found by the final verification run failing "changelog currency" minutes after the changelog had been regenerated and committed.
  *Build/Tools · 1 file*
- **`7eb9be27`** — 13.59: bound the UI-thread wait and make the silent reload unconditional
  Two parts.
  *Build/Tools, Docs, IDE · 8 files*
- **`51b24969`** — 13.59: clear Modified after a reload, and correct a severity claim E13 falsified
  E13 ran against the fix and failed 4 of 17.
  *Build/Tools, Docs, IDE · 6 files*
- **`86940547`** — E13 passes 16/16: 13.59 Part B verified, and the PASS banner stopped overclaiming
  The Modified fix was the whole story.
  *Build/Tools, Docs · 4 files*
- **`97cc59a0`** — 13.58: 0/32 both arms on the fixed binary -- a bound, not a result
  Re-measured against the binary carrying 13.60's EndOfLoadFunctions fix, on the theory that the loader-thread race was the mechanism: those threads populate exactly the include tables that go missing, which is the only hypothesis so far that explains a CLOSED project's main file being named.
  *Build/Tools, Docs · 2 files*
- **`8d7c78a9`** — 13.58: 64 clean cycles post-fix -- suggestive, and the prior decides it
  Second -n 32 on the same binary: 0 noise in either arm, no new crash records.
  *Build/Tools, Docs · 2 files*
- **`6fa0f87c`** — 13.58: the message says "could not FIND" and the code means "could not OPEN"
  Checked the mechanism in code rather than buying more cycles, and it redirects the entry.
  *Docs, IDE · 4 files*
- **`b3afd63f`** — 13.60: still crashes on the FIXED binary, and the site resolves to frmMain_ActivateApp
  Two crash records in one 64-cycle 13.58 run, on the build carrying the EndOfLoadFunctions fix:
  *Build/Tools, Docs, IDE · 4 files*
- **`69ecec76`** — 13.60: guard frmMain_ActivateApp against walking tabs during teardown
  Mitigation for the crash resolved to FRMMAIN_ACTIVATEAPP+0x67.
  *IDE · 4 files*
- **`35df13ec`** — 13.58: OpenSourceForInput -- close the FreeFile race with a lock AND a retry
  FreeFile returns the next free file number and does not reserve it, so `ff = FreeFile_` followed by `Open ...
  *IDE · 4 files*
- **`9e08f66e`** — 13.60: make QuitThread a real join instead of a request
  The caller is TabWindow.CloseTab, which proceeds to _Delete(tb) -- and that destructor frees txtCode.Content.FileLists, ExternalIncludes, ExternalFiles and the rest, exactly what the analyser parses into.
  *IDE · 3 files*
- **`a0170dd0`** — Docs: capture this session's traps in CLAUDE.md and the verification skill
  Swept for staleness beyond the trigger table.
  *Build/Tools, Docs · 2 files*
- **`85d817be`** — 13.28: make the diagnostic trace setting-driven and default it OFF
  The pre-release task said "strip the instrumentation".
  *Build/Tools, Docs, IDE · 8 files*
- **`796ae2cc`** — 13.55: the suspected cause was wrong; PipeCall reported an absent reply as malformed
  The entry blamed a SHAPE mismatch -- that AgentHandleBuildCmd's busy reply, {"ok":false,"error":{"code":"busy"}}, was something the client could not unwrap.
  *Docs, Examples, Framework/Controls, IDE · 8 files*
- **`edbdb969`** — 13.53 CLOSED, owner-verified through the real Options dialog (E15, 6/6)
  The one path that could not be exercised from code, and the row had been waiting on it.
  *Build/Tools, Docs · 4 files*
- **`37c2bc8e`** — Untrack scratch that leaked into the repo, and correct a stale 13.57 note
  Projects/_SmokeTestWin/project.astoria was TRACKED, committed by me in 796ae2c because I have been staging with `git add -A`.
  *Build/Tools, Docs, Examples · 3 files*
- **`0b8b87f2`** — Documentation: add the IDE user manual, with generated reference appendices
  There was no manual: the eight existing documents are developer- or tester-facing.
  *Build/Tools, Docs · 5 files*
- **`bbc26819`** — Documentation: a MyFbFramework programmer's guide, with generated event signatures
  MFF is ~60,000 lines across 196 files and is the library USER PROGRAMS are built on, so a defect or a trap in it is a defect in their application.
  *Build/Tools, Docs · 4 files*
- **`823c15a7`** — StageRelease: stop shipping this project's own working material
  Astoria is a project-based application development tool, not a code editor, and everything in the box should fit that.
  *Build/Tools · 1 file*
- **`8d2ed42d`** — Examples: build every one, and give each a REQUIREMENTS.md
  Nothing compiled Examples/ -- not Compile.bat, not the smoke test, not any harness -- and 30 example projects ship.
  *Build/Tools, Docs, Examples · 70 files*
- **`76445c25`** — Examples: 54 teaching projects under Examples/Learning, all built and run
  Adds Examples/Learning with three sets written for someone learning rather than someone evaluating, and the harness coverage to keep them honest.
  *Build/Tools, Docs, Examples · 142 files*
- **`75b2ee44`** — 13.63: the 13.60 join deadlocked the UI thread and made the IDE unopenable
  This morning's 13.60 fix (9e08f66) ended QuitThread with an unconditional ThreadWait -- a real join instead of a request.
  *Docs, IDE · 5 files*
- **`1885b75b`** — 13.63 verified and 13.64 found: the designer is drivable from outside now
  13.63's fix shipped this morning with its trigger unverified -- nobody had double-clicked a control since, because the designer could not be driven from outside and the only reproduction was a human gesture.
  *Build/Tools, Docs, IDE, Templates · 15 files*
- **`bb20df41`** — 13.64: the designer double-click crash was expand re-entrancy, not a stale pointer
  Release blocker, fixed and verified.
  *Build/Tools, Docs, IDE · 9 files*
- **`a6fc9d97`** — 13.66 site 1: the ImageList editor was restored into the wrong object
  Confirmed by measurement, fixed, and covered.
  *Build/Tools, Docs, IDE, Templates · 12 files*
- **`9de26091`** — 13.66 site 4: a closed tab left a Window-menu entry pointing at freed memory
  Confirmed, fixed and covered.
  *Build/Tools, Docs, IDE · 11 files*
- **`8cda50fd`** — 13.66 site 2: structure confirmed, defect not reproduced, and the test cannot yet find it
  Investigation only -- no fix, because nothing has been confirmed by measurement and the handoff's rule for these sites is to confirm before writing one.
  *Build/Tools, Docs, IDE · 9 files*
- **`00b65f5e`** — 13.66 site 3: narrowed to a two-project session; unreachable in single-project use
  Investigation only -- no fix, because the state that would make this dangerous cannot yet be set up, and the handoff's rule for these sites is to confirm by measurement first.
  *Docs, IDE · 4 files*
- **`8a90fec7`** — 13.66 site 2: CONFIRMED, FIXED and VERIFIED -- a project close freed the tree under a live worker
  FindSubProj/ReplaceSubProj are ThreadCreate_ entry points; FindInProj walks explorer TreeNodes and dereferences each Tag as an ExplorerElement.
  *Build/Tools, Docs, IDE · 8 files*
- **`e311e572`** — 13.66: settle the audit's two open unknowns -- one confirms site 2, one clears a suspected site
  Both were recorded as "explicitly not established" when the enumeration closed.
  *Docs, IDE · 4 files*
## 2026-07-28

- **`0414d069`** — 13.61 and 13.62: every shipped example now builds -- two IDE defects, not example rot
  All 88 example projects build for the first time (E16).
  *Build/Tools, Docs, Examples, IDE · 12 files*
- **`f30cf3c7`** — 13.65: diagnosed to a two-lock deadlock, with a full thread census -- no fix yet
  Still reproduces: open_project on AstoriaIDE.vfp returns ui_timeout after 30s and the IDE never recovers, CPU flat at 1.6s across a minute.
  *Docs, IDE · 3 files*
- **`d58b15e0`** — frmFind: strip a stray CR that left the working tree permanently dirty
  One line in the 13.66 site 2 commit carried a doubled carriage return, so the committed blob held "Next\r" where a clean CRLF checkout produces "Next".
  *IDE · 1 file*
- **`8d325eae`** — 13.65: a loader thread reported a missing include by calling into the UI thread
  Fixed and verified.
  *Build/Tools, Docs, IDE · 11 files*
- **`d31676b9`** — 13.67: write_file carried the 13.58 FreeFile race, twice over
  Fixed and verified, with the verification method being the interesting part.
  *Build/Tools, Docs, IDE · 9 files*
- **`8f41204a`** — 13.68: the IDE crashed on every close for a 40-minute window, then stopped
  Found by the run meant to close 13.60's re-verification debt, which it therefore does not close.
  *Docs, IDE · 4 files*
- **`72001ef9`** — 13.68: it never stopped -- CrashWatch was blind, and the close crash is in the tab loop
  The previous entry recorded 13.68 as "it stopped, and the stopping is the mystery", on the strength of 8 clean cycles.
  *Build/Tools, Docs, IDE · 8 files*
- **`1d123d6e`** — Untrack DebugInfo.log -- a debugger scratch file, not source
  Swept into the previous commit by `git add -A`.
  *Build/Tools · 2 files*
- **`4b1f17d8`** — 13.68: pinned to one statement -- it dies inside TabControl.DeleteTab
  The loop-index candidate from the previous commit is REFUTED by the measurement it asked for.
  *Docs, IDE · 6 files*
- **`73b58300`** — 13.68: what DeleteTab selects is fine -- the teardown path is not, in four places
  Logged what DeleteTab selects next, as asked.
  *Docs, IDE · 5 files*
- **`837159a1`** — 13.68: nothing chose the interactive close path for shutdown -- and removing it proves the cause
  Asked why shutdown uses the interactive close path.
  *Docs, IDE · 5 files*
- **`4e643a69`** — 13.68: detach OnSelChange during teardown -- works as designed, does not fix it
  CloseAllDocuments now detaches OnSelChange on every tab panel and OnSelChanged on tvExplorer before the teardown loop, and does not restore them: its only caller is frmMain_Close, and every path that can decline the close returns above that point.
  *Docs, IDE · 5 files*
- **`e409248d`** — 13.68: the SelectedTab lead is refuted too -- measured, as the entry demanded
  selIdx=33, tabCount=34, in range.
  *Docs, IDE · 5 files*
- **`9924f8aa`** — 13.68: tab count is not the variable -- and the i9 does not reproduce it at all
  Asked whether the number of open tabs makes a difference to the close crash.
  *Build/Tools, Docs · 5 files*
- **`b55904d3`** — 13.68 Tier 2: a shutdown-only teardown, gated OFF and not yet proven
  The interactive close path crashes on 100% of closes on the Ryzen, and skipping the work entirely (ASTORIA_T68_FASTCLOSE) removes that fault and produces a different one at +0x7679.
  *Build/Tools, Docs, IDE · 8 files*
- **`0e882f59`** — 13.68: the fault is mnuCode.Item("AddWatch"), and the original workspace is what reproduces it
  Two findings, both measured on the Ryzen (DESKTOP-4CSH767, Ryzen 5 7430U), where 13.68 reproduces.
  *Build/Tools, IDE · 5 files*
- **`154fb8aa`** — 13.68 FIXED: a shared context menu held a dangling ParentWindow to a destroyed editor
  It was never the close path and never tab count.
  *Build/Tools, Docs, Framework/Controls, IDE · 15 files*
- **`1f86a2e2`** — 13.68: make the reproduction portable, and hand off to the i9
  The 13.68 harness could not have run on the other machine at all.
  *Build/Tools, Docs · 3 files*
- **`448023fd`** — 13.68 confirmed on the i9: it was never machine-specific
  The experiment the Ryzen handoff asked for.
  *Build/Tools, Docs, Framework/Controls, IDE · 11 files*
- **`87223b67`** — 13.69: the libraries are loaded and then freed, and the free is what hides their controls
  The entry's premise was that the four optional control libraries are never loaded into the running IDE.
  *Docs, IDE · 4 files*
- **`2d02b35e`** — 13.69 FIXED: a ByRef parameter overwrote each control library's .dll path with its folder
  Not one control from any of the four optional libraries could be placed on a design surface.
  *Docs, IDE · 8 files*
- **`37976ea8`** — 13.69: the duplicate library on every project open, fixed -- same function, one line later
  GetControlLibraryVfpPath returned "" for every absolute .dll path, so the project-open reuse comparison was "" = "Controls/Framework" -- false for every already-loaded library.
  *Docs, IDE · 5 files*
- **`f1714d5c`** — 13.70 opened: the IDE TERMINATES during repeated open-a-form cycles
  Chased the last open thread in 13.69 and it turned out to be neither what it was called nor what it was thought to be, so it moves to its own entry.
  *Build/Tools, Docs · 2 files*
- **`4160fc61`** — 13.70: only HALF the deaths write a crash record -- a silent exit path exists
  The entry's stated first job was to determine whether every death writes a record.
  *Build/Tools, Docs · 2 files*
## 2026-07-29

- **`f2492356`** — 13.70: the IDE will not start under full page heap -- and that is the strongest lead yet
  Full page heap was meant to decide "one fixable defect or something structural": it unmaps a freed block so the instruction that writes to it faults, instead of the damage surfacing later somewhere unrelated.
  *Build/Tools, Docs · 4 files*
- **`6e659020`** — 13.70 LOCALISED: a named stack -- concurrent mutation of the process-global Globals.Functions
  Full page heap could not be used (the IDE will not start under it), so the other route was taken: a SYMBOLS=1 build under the bundled gdb, driving the same workload.
  *Docs, IDE · 3 files*
- **`8abf671b`** — 13.70: WStringList's own invariants HOLD -- three hypotheses refuted, including the best one
  The lock audit the previous entry called for came back CLEAN.
  *Docs, Framework/Controls, IDE · 6 files*
- **`e73dfc65`** — 13.70: the race is refuted here too -- WStringList is the victim, not the culprit
  A fourth probe, aimed at the one thing the other three structurally could not reach: they all test STABLE state (counts, ranges, removal success) and a race is a TRANSIENT.
  *Docs, Framework/Controls, IDE · 6 files*
- **`194ab5e2`** — 13.70 PINNED to one statement: LCase(Item(MidIndex)) reads freed data, deterministic under light page heap
  LIGHT page heap kills the IDE too, at the same point (owner watching: "stopped at main.frm").
  *Docs, IDE · 3 files*
- **`ce6b2f5d`** — 13.70: one defect NAMED and FIXED -- ComboBoxEdit.Text used a ByRef parameter aliasing the field it had just freed (PARTIAL)
  With SYMBOLS=1, FORCE_MFF=1 and the new FRAMEPTR=1, the light page-heap fault finally resolved.
  *Build/Tools, Docs, Framework/Controls, IDE · 9 files*
- **`382dbb07`** — 13.70 severity CORRECTED: it needs machine-speed switching -- a one-second pause closes the window
  The owner asked whether the harness was testing something that will never happen in real life, since it switches projects with no delay at all.
  *Build/Tools, Docs · 2 files*
- **`475500bf`** — 13.70 MECHANISM ESTABLISHED: project teardown never joins the IntelliSense loader threads
  The owner asked whether this could be a timing problem -- threads not given enough time, clashing.
  *Docs, IDE · 5 files*
- **`9afb6887`** — 13.70: the cooperative cancel and loader join -- built, works, and does NOT fix the crash
  Implemented as ASTORIA_T70_JOINLOADERS=1 (OFF by default): a cooperative cancel (bCancelLoaders, a project-scoped sibling of FormClosing, checked at the SAME three points in LoadFunctions that already check FormClosing, so it inherits checkpoints proven safe to unwind from) plus a bounded...
  *Docs, IDE · 5 files*
- **`ba0678e3`** — 13.70 CHAIN COMPLETE: form design reads the global symbol lists while up to 18 loaders write them
  Logged LoadFunctionsCount either side of the QuitThread call in TabWindow.FormDesign (TabWindow.bas:8234), fast arm, 30 switches:
  *Docs, IDE · 4 files*
- **`57a87229`** — 13.70: option 1 implemented and REFUTED -- the reader lock makes it 2.5x worse
  ASTORIA_T70_LOCKREADERS=1 (in the tree, OFF by default and it must stay off): FormDesign takes tlockSave for the duration of its parse, serialising its read of the global symbol lists against LoadFunctions' writes.
  *Docs, IDE · 4 files*
- **`32028141`** — 13.71: run the IntelliSense load SERIALLY -- this fixes 13.70
  After nine refuted hypotheses about which lock to add, the answer was to remove the concurrency instead.
  *Docs, IDE · 10 files*
- **`dd8ddf37`** — 13.72: drain the serial load in idle slices -- project open no longer blocks
  13.71 fixed 13.70 but paid for it by parsing in the foreground, so the first project open after IDE start froze the UI for ~4.8 s.
  *Docs, IDE · 10 files*
- **`158af0f5`** — 13.73: Format Project no longer runs on a worker thread
  First item of the threading audit opened by 13.72, applying the rule that came out of it: thread it when you are waiting on something outside the process, do not when you are mutating our own data.
  *Build/Tools, Docs, IDE · 10 files*
- **`535173fc`** — 13.74: measure AnalyzeTab before de-threading it -- 9.1 s, so it CANNOT simply move to the UI thread
  Second item of the threading audit.
  *Build/Tools, IDE · 4 files*
- **`4c17c297`** — 13.75 WIP: marshal AnalyzeTab results to the UI thread (verification in progress)
  *IDE · 5 files*
- **`9885357e`** — 13.75: marshal AnalyzeTab's results to the UI thread
  Second item of the threading audit, and the opposite conclusion to FormatProject.
  *Build/Tools, Docs, IDE · 10 files*
- **`338bd7de`** — 13.76: the Find/ToDo worker -- a counter bug that disabled a safety net, and the marshal
  Third item of the threading audit.
  *Build/Tools, Docs, IDE · 11 files*
- **`594bafcf`** — 13.77: the last three Find/Replace workers -- every worker-side control WRITE is now gone
  Finishes 13.76 by giving ReplaceSubProj (frmFind.frm) and FindSub/ReplaceSub (frmFindInFiles.frm) the same treatment.
  *Docs, IDE · 11 files*
- **`5b475d45`** — 13.60 re-audit: the deadlock precondition is gone, the policy is not changed
  QuitThread's timeout path does not join, so CloseTab can _Delete(tb) under a live analyser -- 13.60's original use-after-free.
  *Docs, IDE · 4 files*
- **`458b339a`** — 13.78: the gate refuted my own argument -- an unconditional join STILL hangs
  Two outcomes.
  *Build/Tools, Docs, IDE · 9 files*
- **`cfe75290`** — 13.79: 13.60 CLOSED -- no worker reaches a window, so the join is unconditional
  13.78 measured an unconditional join hanging the IDE and named the cause: AnalyzeTab -> GetTab -> ptabCode->TabCount = Perform(TCM_GETITEMCOUNT) = SendMessageW.
  *Docs, IDE · 11 files*
- **`3b18b6a6`** — 13.80: RETRACT the Format Project defect reported in 13.73 -- it does not exist
  13.73 reported that FormatProject's guard accepts only ImageKey = "Project" while a project root could also be "MainProject" or "Opened", so the command would silently do nothing.
  *Docs, IDE · 5 files*
- **`444c743a`** — 13.82: the compile path -- Compile keeps its worker, and stops touching the IDE from it
  TechnicalDebt.md named BuildService.Compile the highest-value item left: 492 lines, 41 CONTROL TOUCHES, eight entry points, 16 no-op ThreadsEnter blocks.
  *Build/Tools, Docs, IDE · 16 files*
- **`a01cb61a`** — 13.83: the FreeFile conversions -- and a feature that had never once worked
  Register item 2.
  *Build/Tools, Docs, IDE · 23 files*
- **`47be6db4`** — 13.83: the framework's FreeFile sites -- and the helper had to move to reach them
  Finishes the register's item 2.
  *Docs, Framework/Controls, IDE · 27 files*
- **`7242e9e0`** — 13.84: ReDim Preserve does NOT double-free heap-owning elements -- rule RETRACTED
  Register item 3 was "the ReDim Preserve shortlist -- six files to read; only the heap-owning ones matter", resting on a standing CLAUDE.md rule:
  *Build/Tools, Docs · 7 files*
- **`f169384c`** — 13.85: informational MsgBoxes no longer wedge the IDE
  Register item 4, and the owner's call between two approaches -- the survey changed the framing enough to be worth asking about before writing any code.
  *Build/Tools, Docs, IDE · 33 files*
- **`fe5ccdc0`** — 13.86: a question dialog is not asked when nobody can answer it
  Asked by the owner: can a session register as MCP-controlled, so a blocking dialog is not shown but sent back through MCP to be acted on there?
  *Build/Tools, Docs, IDE · 15 files*
- **`ecbec8f8`** — 13.87: an Output alert is red, and rings
  13.85 moved 122 informational MsgBoxes into the Output panel and 13.86 sent the ten question dialogs there when an agent is driving.
  *Build/Tools, Docs, IDE · 10 files*
## 2026-07-30

- **`79100d16`** — 13.90: read and report gFileNumRetries at session end
  mff/UString.bi's OpenFileRetry bumps gFileNumRetries on every error-1 retry (the §13.58 FreeFile+Open race) but has no logging of its own to call; nothing read the counter. frmMain_Close now reports it:
  *Docs, IDE · 7 files*
- **`52d1021d`** — 13.91: add per-file GPL/LGPL modification notice across the tree
  Licence hygiene: the upstream project is Free Software, and without a notice on each file carrying Astoria's changes those additions are technically unlicensed.
  *Docs, Framework/Controls, IDE · 465 files*
- **`3e72506d`** — 13.91 fix: move the license notice above '#Region "Form"' in 41 forms
  The insertion pass treated a leading '#Region "Form"' comment as part of the header block and placed the notice AFTER it -- inside the designer-managed Form region, which the designer regenerates on save.
  *Docs, Framework/Controls, IDE · 43 files*
- **`ec475679`** — 13.92: re-grade the converted MsgBox severities
  Follow-up to §13.85, which moved 122 informational MsgBoxes to ReportProblem inheriting each site's severity verbatim -- several were plainly wrong (a save failure as an mtInfo note) and the grading was internally inconsistent across files ("This name is exists!" was mtWarning in some, mtInfo in...
  *Docs, IDE · 23 files*
- **`a99ad142`** — 13.93: alert colour per severity -- green info, yellow warning, red error
  Companion to §13.92: now that each ReportProblem carries an accurate severity, the colour says which. §13.87 wrote every alert in a single luminance-aware red; AlertTextColor now takes the severity and returns a flat bright colour -- mtInfo green, mtWarning yellow, mtError red.
  *Build/Tools, Docs, IDE · 7 files*
- **`221080ad`** — 13.94-13.97: two standing rules retracted, two real defects, and the warning colour
  13.94  IIf with strings -- MEASURED and the standing rule RETRACTED.
  *Build/Tools, Docs, IDE · 20 files*
- **`8356a345`** — 13.98: audit the tag-as-pointer debt class; harden CloseTab suggestion cleanup
  The register's tag-as-pointer row (113 sites, MEDIUM) is a grep artefact.
  *Docs, IDE · 6 files*
- **`b2c9589d`** — 13.99: audit imagekey-as-type; fix a main-file form that would not expand
  The register's imagekey-as-type row (65 sites) is the 13.73/13.80 class: node type decided by a display icon name.
  *Build/Tools, Docs, IDE · 8 files*
- **`37b8eebf`** — 13.100: marshal the debugger's worker->UI writes; clear Debug.bas ThreadsEnter
  threadsenter here was not a marker tidy-up but 13.82's worker->UI audit in the debug engine.
  *Docs, IDE · 9 files*
- **`d0112dd4`** — 13.100: T100 drives a real GDB session and verifies the debug marshal
  The handoff said no harness could drive a program under GDB.
  *Build/Tools, Docs, IDE · 9 files*
- **`0436b846`** — 13.102: settle the "MainProject" question by measurement; premise was wrong
  13.80 left this "unproven in both directions" and marked it do-not-touch, on the premise (a TabWindow.bas comment) that "MainProject" is never assigned to any node.
  *Docs, IDE · 7 files*
- **`6631cb52`** — 13.104: mitigate cmdApply_Click size -- extract three cohesive blocks (1156->990)
  Register goal for the 37 over-250-line procedures is mitigation, not elimination. cmdApply_Click (the Options Apply handler) is the safest first target: it operates on the global fOptions (With fOptions) and global settings, not This or cross-block locals, so a cohesive run extracts into a...
  *Docs, IDE · 6 files*
- **`67782b79`** — 13.104: extract WriteSettingsToIni + live-verify Apply with T104 (1156->684)
  Continuing the cmdApply_Click mitigation.
  *Build/Tools, Docs, IDE · 7 files*
- **`179e73df`** — 13.104: extract WriteThemeToIni; cmdApply_Click is now a 60-line orchestrator
  Fifth and last cohesive block: WriteThemeToIni -- the ~625-line piniTheme run (every syntax element's colours and font styles: Bookmarks, Breakpoints, Comments, Keywords, ...).
  *Docs, IDE · 6 files*
- **`83c35a61`** — About/Splash: brand as 1.0 Beta, refresh credits and attribution; bump to 1.3.8
  Manual owner edits to the About dialog and Splash screen: - version marked "1.0 (Beta)" in both; file/product version bumped 1.0.0.0 -> 1.3.8.0 in AstoriaIDE.rc (matching AstoriaIDE.bas's VER_* defines) - About credits refreshed: "Primary AI Agent: Claude Code", "Primary AI Models: Anthropic Sonnet...
  *IDE · 8 files*
- **`12504f15`** — Version: use Astoria's own 1.0, stop tracking VisualFBEditor's 1.3.8
  Astoria descends from VisualFBEditor and had been carrying its 1.3.8 version number in three places.
  *IDE · 5 files*
- **`fbdf0203`** — Version: set astoria.exe FileDescription back to "Astoria IDE"
  It had been changed to "AstoriaIDE FreeBASIC Project" -- the description a project built WITH Astoria would carry, not the IDE describing itself. astoria.exe now reports FileDescription "Astoria IDE" (FileVersion 1.0.0.0, ProductVersion 1.0).
  *IDE · 3 files*
- **`8063b20f`** — frmAbout: fix the Source Code URL, which was missing its colon
  The About dialog's Source Code label read https//github.com/dmontaine/astoria-ide -- no colon after the scheme, so the address is not a URL at all.
  *IDE · 3 files*
- **`bd005d9f`** — gitattributes: CRLF for every text file, not a list of extensions
  The IDE re-saved src/AstoriaIDE.vfp during the frmAbout edit and rewrote all 110 lines, burying a two-line change in whole-file noise.
  *Build/Tools · 3 files*
- **`66f6e716`** — Docs: a plain-text SignificantChanges for forums, generated and rule-enforced
  Documentation/AstoriaIDESignificantChanges.txt is the copy to paste where only plain text is accepted: ASCII only, wrapped to 76 columns, CRLF, Markdown markers removed.
  *Build/Tools, Docs · 6 files*
- **`376be4f4`** — DocCheck: all three SignificantChanges files must move in one commit
  Owner's rule: the .md, .txt and .pdf move together.
  *Build/Tools, Docs · 4 files*
## 2026-08-01

- **`25f1ca4e`** — Release: 1.0.0-beta -- reconcile installer version, move remaining debt to 1.1
  First public beta of 1.0.
  *Build/Tools, Docs, Framework/Controls, IDE · 9 files*
- **`13a5ae10`** — Installer: install per-user to %USERPROFILE%\Astoria, drop ini seeding
  Move the per-user install from {localappdata}\Programs\Astoria IDE (hidden under AppData) to a single visible folder directly under the profile, %USERPROFILE%\Astoria, so the IDE, its Projects\ and Examples\ sit together where the user can find them.
  *Build/Tools · 1 file*
- **`4fdf2b3f`** — IDE icon: use the 'A' monogram at small sizes (bridge stays large)
  The IDE's icon (Resources/AstoriaIDE.ico) was the 256px bridge scene at every size, so the title-bar/taskbar (16px) rendered as a muddy blue blob.
  *Build/Tools, IDE · 3 files*
- **`12d298ca`** — IDE title bar: set ICON_SMALL to the 16px 'A' frame (frmMain_Show)
  The multi-resolution icon alone did not fix the title bar: MyFbFramework's Form sets only WM_SETICON ICON_BIG (mff/Form.bas), so Windows drew the title-bar/taskbar small icon by shrinking the large (bridge) frame -- the 16px 'A' frame in the .ico was never used. frmMain_Show now loads the small...
  *IDE · 3 files*
## 2026-08-02

- **`cff14b47`** — mff: Form sets ICON_SMALL from a small icon frame -> crisp title bars on all forms
  Fixes the dialog (and main-window) title-bar icons.
  *Docs, Framework/Controls, IDE · 12 files*
