# Ilwaco IDE — Project Status & Handoff

Ilwaco is a Linux (GTK3) IDE for FreeBASIC — the **VisualFBEditor** codebase — being brought toward
parity with its Windows sibling **Astoria** (`../astoria-ide`). The plan is to walk Astoria's change
history and translate each change into Ilwaco, adapting Win32 → GTK, and — following Astoria's
"opinionated by design" stance — *removing* options and dialogs rather than accumulating them
(e.g. one bundled compiler, no compiler picker). Hobby project, no deadline: prefer durable
scaffolding over speed.

See also: [HISTORY.md](HISTORY.md) (past session narratives, extracted from this file),
[Documentation/AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md) (the pruned port
backlog), [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md) (what we ported and what we
couldn't, and why), [Documentation/IlwacoVsAstoria.md](Documentation/IlwacoVsAstoria.md) (the
user-facing Ilwaco-vs-Astoria comparison), [CHANGELOG.md](CHANGELOG.md) (milestones),
[Documentation/UpstreamFixes.md](Documentation/UpstreamFixes.md) (our GTK fixes that are really upstream
bugs) and [CLAUDE.md](CLAUDE.md) (orientation for the Linux/GTK build).

**Keep this file pruned.** It holds only the **most-recent session handoff**, the **NEXT** actions, and
the **standing facts** below — not an archive. When a session's work is done and committed, move its dated
narrative section to [HISTORY.md](HISTORY.md) (newest-first) instead of letting handoffs pile up here.
`python3 Tools/DocCheck.py` flags this file once more than two dated session sections accumulate; see
CLAUDE.md "Working practices".

---

## COMPLETE — Agent MCP server (Tasks 0–7)

Astoria's Agent MCP server is ported to Linux/GTK and finished: a real MCP client → `ilwaco-mcp` sidecar →
Unix socket → the live IDE, auto-launching it, with the read-only, project (`open_project`/`create_project`),
mutation and build/run/errors tools all verified against a real project, the project-root path guard blocking
`..` escapes, the listener gated by the Tools ▸ Options opt-in (default ON) with its state in the status bar,
and the whole create → build → fix → run loop driven end to end. Design, the three Win32→Linux substitutions,
the owner decisions, the per-task narratives and the v1 limits are in
[Documentation/McpServer.md](Documentation/McpServer.md); the user-facing setup is
[Documentation/AgentMcpSetup.md](Documentation/AgentMcpSetup.md). Only the `designer_*` tools remain deferred
(owner) — revisit as Ilwaco's designer matures.

---

## ✅ DONE (2026-08-06) — Delete File shipped with deferred deletion; three GTK defects fixed

`93bbfa28` S5 **plus** `331b5705` (B1), scoped against Astoria's *final* state rather than the handoff's
note — that note described `93bbfa28`'s intermediate version, which Astoria reworked twice afterwards
(`331b5705` deferred deletion, `273df0f5` merged "Remove" into "Delete File"). Owner chose **full
parity**, superseding the earlier "keep both commands" product call.

**Shipped:** one **Delete File** command (File menu, Project menu, tree context menu, explorer toolbar),
confirmation defaulting to No, tree-selection based. A project member is queued — `(pending delete)`,
project flagged `*` — and only `Kill`ed by `SaveProject` after the `.vfp` is written; **Cancel Deletion**
undoes it; Close Project lists queued files as informational rows. **Removed:** the old unconfirmed
`RemoveFileFromProject` (it silently deleted files off disk), and `frmSave`'s **10-second auto-Yes
countdown**, which would have executed deletions with no user action.

**Three pre-existing GTK defects found while verifying**, all fixed: the explorer context menu's state
handler (`tvExplorer_MouseUp`) could never fire on GTK — MFF only raises `OnMouseUp` when the event
window is the widget window, never true for a `GtkTreeView` — so the menu had shown stale captions and
enablement since the port (logic moved to `UpdateExplorerMenuState`, driven from `tvExplorer_SelChange`
plus an explicit refresh after delete/undo, since re-clicking the selected row fires no change);
`node->Text &= "*"` never repainted, hiding the project dirty marker (five live sites, now explicit
assignment); and `CloseProject`/`SaveAllBeforeCompile` read the save dialog *after* it was torn down
(now `.SelectedItems`, with the window-X close treated as Cancel). Details in
[UpstreamFixes.md](Documentation/UpstreamFixes.md) and [AstoriaParity.md](Documentation/AstoriaParity.md).

**Owner direction (2026-08-06): Ilwaco is for project-based development only — files outside a project
are not supported.** Astoria's `0c08fe5f` standalone-node `ExplorerElement` Tag was therefore ported and
then **reverted**; it is recorded N/A. Two follow-ups this raises, neither actioned: **File ▸ Open still
creates a root-level node for a file outside any project**, where Delete File is a no-op — constraining
that entry point is a product question; and `DeleteEditorFile`'s non-project branch is consequently
unreachable in supported use (Astoria's own code, kept as a guard, but a no-dead-code candidate).

Verified by effect on `:0` throughout, using the MCP agent to open projects: confirm → pending → Close
Project **Yes** deletes and rewrites the `.vfp`; **No** leaves file and `.vfp` untouched; Cancel Deletion
reverts and the file then survives a real save.

**Also this session — the whole remaining backlog was classified, and `13.71` was ported.** All **396**
entries are now judged in [AstoriaParity.md](Documentation/AstoriaParity.md) "Full classification pass"
(cluster-level, with its own confidence caveats; the backlog file was deliberately not pruned).
**`13.71`** — the serial IntelliSense loader — is implemented and committed (`31a5e20`). Trying to
*measure* it then overturned the priority this file had been asserting for weeks; that correction is in
the NEXT section and is the more useful outcome of the two.

**Also this session — the product direction below was set, and documented for users.** The owner recorded
the project-only stance and the four divergences (next section), and asked that the Ilwaco/Astoria
differences be written down "in case users assume they are exactly the same". New
**[IlwacoVsAstoria.md](Documentation/IlwacoVsAstoria.md)** does that, carefully separating what **ships
today** from what is **planned** (Git and the AI templates are in neither product yet) and correcting the
comparison that is easiest to get wrong — there are **two** theme capabilities and Astoria removed
neither. `README.md` was a single line, so the comparison was undiscoverable; it now leads with it and
indexes the user-facing docs. One stale claim fixed: `IlwacoIDESignificantChanges.md` had the
multi-assistant AI integration under "features removed (opinionated by design)", which the divergence
decision reverses.

---

## ⚠️ STANDING — four deliberate divergences from Astoria (owner, 2026-08-06)

Ilwaco targets a **somewhat more advanced audience** than Astoria, so four capabilities Astoria removed
(or never had) are **retained here**. These **override the "port Astoria's final state" rule** — a walker
who reaches the removal commit and follows it would destroy them. Full detail, with commit sets and the
traps, is in [AstoriaParity.md](Documentation/AstoriaParity.md) "Deliberate divergences".

| # | Capability | Ilwaco state | Action |
| --- | --- | --- | --- |
| 1 | **Themes** — *two* of them: IDE UI theme (Options ▸ General ▸ Themes) and editor theme (Options ▸ Code Editor ▸ Colors and Fonts) | Both present; all **96** editor themes | **Guard.** Do not port `5c50f20f` (culls 84 of 96 editor themes; content only, zero code change). Neither capability was ever removed from Astoria. |
| 2 | **Git integration** | Absent | **Build.** Port the ADD chain `d61eb062` → `fffee489` → `fd894173` → `95b04f70`; **skip the removal `9d277f28`** (read it as the inventory of what a full restore covers). |
| 3 | **Multiple AI templates** — Claude Code, ChatGPT, Kun | Absent (MCP dropped `ai_tool` stamping; `AgentPipe` hardcodes `ClaudeCode`) | **Build.** Port the ADD chain (`987e8b7e`, `ef5a6252`, `72ea5980`, `de8c1e5a`); **skip `6de0332f`** (consolidated to Claude only, deleting ChatGPT/Cursor/Kimi/Kun/OpenCode). Keep 3; leave Cursor, OpenCode and **Kimi** out (owner, 2026-08-06). |
| 4 | **Multiple IDE instances** | Already allowed | **Guard.** Do not port Astoria's `App.PrevInstance` handover (`Main.bas:110`, Win32 `EnumWindows`). Anything reaching "the running IDE" must not assume there is one. |

**Do not re-import the three drifts that made Astoria drop the AI templates** (`6de0332f` documents them;
they are bugs, not reasons to skip the feature): the dropdowns enumerated `Templates/AI` subdirectories
while `AgentMcp`/`AgentPipe` each carried an unreconciled hardcoded list of five; one agent was
**selectable but supported nowhere**, resolving to no template folder (so every agent offered needs a
real folder *and* backing support); and the GUI stored `AITool=ClaudeCode` while the
MCP path defaulted to `"Claude Code"`, which `AgentAiToolFolder` did not recognise — with both dropdowns
showing folder names instead of product names. One list, one source of truth; display label and folder
name distinct and mapped in one place.

---

## ✅ DONE (2026-08-07) — the shutdown SIGSEGV is diagnosed and fixed

The "intermittent SIGSEGV" that hampered `:0` verification for weeks is **resolved**. It was never
intermittent, never a startup/large-files bug, and not the threading arc — all three were inherited
assumptions. **Measured:** 23/23 launches — startup 100% clean, window-close 100% SIGSEGV. The real
variable was **`UseDebugger` on/off**, the default being off. Two distinct close-path crashes, both fixed
and **verified 20/20 clean close (exit 0), IDE renders correctly**:

1. **`frmMain_Close` dereferenced a null `Parent`.** With the debugger off, `SetDebugTabsVisible(False)`
   detaches the 7 debug panes (`DetachTab` → `Parent = 0`); the close handler read `tpLocals->Parent->Name`
   for all 18 panes unguarded. Fixed with a guarded `SaveTabPagePlacement` helper in `src/Main.bas`
   (skips a detached pane), collapsing 36 duplicated lines to 18 calls.
2. **Global-destructor use-after-free over freed GTK widgets (framework).** FreeBASIC runs every
   module-level destructor at `_GLOBAL__D` *after* `main()`, but GTK freed the widget tree on window
   close; each `GTK_IS_WIDGET(widget)` guard then dereferenced freed memory (crash site
   build-nondeterministic: `~Control`/`~ToolButton`/`~MenuItem`/…). **Win32 is safe here for free via
   `IsWindow()`; GTK has no equivalent.** Fixed the Astoria way — the framework fast-exits on **main-form**
   close: `mff/Form.bas`'s two main-form paths call a `CloseOnMainForm` doing libc `_exit(0)`, skipping the
   destructor walk (the GTK port of Astoria's `End 0`-on-close; Astoria itself fast-exits via
   `ExitProcess(0)`, §13.29). The fix lives in **MFF**, so **every MFF app** — not just the IDE — gets a
   clean shutdown; a per-object null-on-`"destroy"` alternative was tried and rejected as large *and*
   unreliable (the signal doesn't fire uniformly). No data loss: `IniFile` writes through on every write,
   and all app state is saved in `frmMain_Close` before the exit. Non-main forms still hide. Detail in
   [UpstreamFixes.md](Documentation/UpstreamFixes.md); memory `project-known-segfault-threading` rewritten.

---

## NEXT — packaging, then the two committed divergences, then the parity tail

The release blocker is gone, so the order is now feature/packaging work (owner: **no release until the
whole parity list is complete**, so nothing here is release-gated — sequence by value):

1. **Packaging** — the AppImage is the difference between a project and something people can install
   (memory `project-packaging`); it should ship the console-link libs so users need no shim.
2. **The two committed divergences**, in order: **Git integration** (build the ADD chain `d61eb062` →
   `fffee489` → `fd894173` → `95b04f70`, skip removal `9d277f28`), then the **three AI templates** (Claude
   Code, ChatGPT, Kun — ADD chain `987e8b7e`/`ef5a6252`/`72ea5980`/`de8c1e5a`, skip `6de0332f`). See the
   STANDING divergences table above and its traps.
3. **The parity tail** — the deferred menu features and the rest of the `13.3.A` walk (below).

**Still explicitly NOT next: `13.72` (idle slices)** — it only removes a stall `13.71` introduced that
nobody has felt on a real project.

---

### After that — the deferred menu features; the threading arc is DOWNGRADED (see below)

**A full classification pass over the whole remaining backlog was done on 2026-08-06** — all **396**
entries in [AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md) are now grouped and
judged in [AstoriaParity.md](Documentation/AstoriaParity.md) "Full classification pass". Read its
**"How much to trust this pass"** section before acting: the non-actionable clusters are settled, but a
PORT verdict is *cluster-level* and each entry still needs normal scoping. The backlog file was
deliberately **not** pruned — sampling one cluster produced four mis-filed entries (a DONE, an INVERT and
two real PORTs hiding inside the "GDB → N/A" group), which a bulk delete would have destroyed.

### ⚠️ CORRECTION — the threading arc is NOT the emergency this file claimed (2026-08-06)

**The previous entry here said `13.60`–`13.79` was "the known intermittent startup/analysis SIGSEGV …
the fix is in the backlog and has been all along". That was wrong on both halves, and it was wrong
because it inherited a phrase from an earlier handoff instead of checking it.** Corrected on evidence:

1. **Astoria downgraded the defect itself** (`382dbb07`). Its death rate depends on *switching speed*:
   ~0.35 s/switch gave 6, 6 and 9 deaths in 60; **1 s/switch gave 0 in 60; 4 s/switch 0 in 60.** A
   one-second pause closes the window. Astoria's own conclusion: *"it needs project teardown to overlap
   IntelliSense loader threads that are still running … No user opens a project, opens its form and
   moves on three times a second"* — **explicitly not a release blocker.**
2. **It is a different bug from this arc, now fully diagnosed (see the DONE section above, 2026-08-07).**
   The SIGSEGV was a **deterministic close crash** (null `Parent` + a global-destructor UAF over freed
   GTK widgets), not project-teardown racing loaders and not the "opening large files" trigger this file
   once guessed. "A known Astoria-fixed threading issue" was an assumption, never a diagnosis — and it is
   now retired. This arc did not address it; the real fix did.

**Our own A/B measurement is consistent with (1) and is itself inconclusive:** 40 cycles against the
**pre-fix threaded** binary (recovered from git, so no rebuild) produced **0 deaths**. The harness
paces at six MCP round trips per cycle — far slower than 1 s/switch — so Astoria's table predicts
exactly that result on an unfixed build. **A harness paced by MCP round trips cannot reproduce a race
that needs sub-second switching**; the serial arm was not run, because another 0/40 would prove nothing.

**What this means for the work:** `13.71` is **DONE and kept** (below) — the race is real, the serial
load is strictly safer, and the threading it removed never bought throughput. But it is a correctness
improvement, not a fix for the crash we actually see. **`13.72` (idle slices) is DEFERRED**: it exists
only to remove the stall `13.71` introduces, so do it if that stall is felt on a real project.

**Ilwaco's actual SIGSEGV is now diagnosed and fixed** (DONE section above, 2026-08-07) — a deterministic
close crash, unrelated to this arc.

### ✅ DONE — `13.71`, the serial IntelliSense loader (`31a5e20`)

All five loader sites (three in `AddProject`, `TabWindow.SaveTab`, `TabWindow.FormDesign`) call the new
`SpawnLoader` instead of `ThreadCounter(ThreadCreate_(...))` and run one at a time;
`ClearLoaderQueue()` runs from `CloseProject`/`CloseWorkspace` so nothing queued outlives what it reads.
Astoria's `ASTORIA_T70_SERIALLOAD` env gate was deliberately **not** ported — the A/B is over and it
would be dead code. **Verified:** no deadlock on project open (the real trap — `SpawnLoader` must queue,
never call through, or it re-enters `MutexLock tlock` and FB mutexes are not recursive), forms open,
symbols resolve. **Not verified:** any reduction in crashes, for the reasons above.

### Then — the deferred menu features + rest of the 13.3.A walk

**This session (2026-08-06, pushed through `d978e66`):** classified `e5e10808` (+ ported its `GetFileName`
no-extension truncation fix, `68c4d91`); **collapsed the whole menu-taxonomy cluster to Astoria's final
menu bar** in one designed pass (`3ef11eb` — File · View · Project · Code · Code/Form · Form · Run · Tools ·
Window · Help); **removed the Android/APK feature** whole (`a299511`); added the **"scope each Astoria-log
entry against the WHOLE log" rule** to CLAUDE.md (`17a9232`); and finished **`0eaa8806`** — its
Window-menu-index regression (`133501f`, a fallout of the reorg: `miWindow->Count > 3 → > 1`), the
**Go-to-Definition (F2) reliability pass** (`ea10cad`), and the **dead toolbar Toggle Breakpoint button**
(`d978e66`, folding in `d8a2e8fb`'s command-name fix). All build-verified and verified by effect on `:0`.
Per-item detail in [AstoriaParity.md](Documentation/AstoriaParity.md); menu strategy in memory
`project-menu-collapse-to-final`; the whole-log rule in memory `feedback-scope-against-whole-astoria-log`.

**`93bbfa28` S5 is DONE (see the section above).** The rest of `93bbfa28` is **N/A / deferred / INVERTED**:
S6's dead-UI removals are already done in Ilwaco (no compiler picker, UTF-8/LF-only ⇒ no encoding/newline
pickers) — grep of `frmOptions` finds none; its "Turn on Environment variables" removal is **INVERTED**
(Ilwaco wired env-vars up). S7 (docs GTK) N/A. The **Run-toolbar-persistence / `ShowRunToolBar` INI
migration** is deferred **with the S3 toolbar merge**.

**A method note worth keeping.** The handoff's scoping for S5 was written against `93bbfa28` alone and was
wrong in two ways that only a whole-log scan caught: Astoria reworked the feature twice afterwards, and the
"keep both Remove and Delete File" product call had been made without knowing Astoria later merged them. It
also asserted `bNestedInProject = (tn->ParentNode <> 0)` was memory-safe "matching the Win32 behaviour" —
true, but for a reason the note got backwards: loose files are *root* nodes (`ParentNode = 0`), and it is
`CloseTab` freeing exactly those that makes the final version's post-`CloseTab` node access unsafe. **Read
the current source, not the previous session's summary of it.**

**Then the deferred menu features** (each its own pass, in walk order): the **S3 toolbar merge** (7→5 bands,
single-checkable Toolbars, `ShowRunToolBar` INI migration, the 7-band Maximize `Bands.Count-2` fix, band
renumbering — all deferred here), Code/Form contextual greying (`a114ee5b`/`e1595a31`/`f3538e1c`), designer
`@PopupClick` context items in the Form menu (`b05fdacb`), and the Git menu (`d61eb062`+). When you reach
**`4a112089`**, wire `ParameterInfoShow` up (INI load, the `If Not ParameterInfoShow Then Exit Sub` gate,
the Options checkbox) — a latent global in Ilwaco. Skip the pure GTK/Linux/32-bit stripping commits
(`e139c2cc`, `c494207f`, `7baebd1e`, `add4642a`, `76abaa5a`, `15e66cc5`).

**Method that has been working:** read Astoria's commit *and* what its code actually does before
classifying, and **look downstream at the whole log** (now a CLAUDE.md rule) — repeatedly a change was
reworked later (`e5e10808`'s toggles by `4a112089`; the menu cluster by ~15 commits; the toolbar breakpoint
button by `d8a2e8fb`), so scoping against Astoria's *final* state avoids building what a later commit undoes.
Build with `./build-linux.sh editor` in the background, verify on `:0`, then document and commit per item.
**Note:** the shutdown SIGSEGV that used to hamper live `:0` verification is **fixed** (2026-08-07 DONE
section) — closes are now clean (exit 0).

**Two items to settle before the testing phase** (both in TechnicalDebt "Known gaps"): the
**blank-terminal finding** (a user pressing Run sees an empty window — reproducible with
`xfce4-terminal --hold -x /bin/echo TEST`, so not ours, but it is what they would see), and the
**project `.vfp` BOMs** written by `SaveProjectFile` and carried by the template `.vfp` data.

- **Examples work — deferred to just before the testing phase (owner).** The two Astoria Examples
  items (`4bd02894`, `51441d7a`), **plus a BOM sweep**: 93 of 111 sources under `Examples/` start
  with a UTF-8 BOM, which makes FreeBASIC compile their string literals wide, so they build clean and
  then print UTF-32 bytes. Measured 2026-08-04; the same defect was fixed in `Templates/` at the
  time. Do all three together so `Examples/` is touched once.
- Unverified, low priority: **Ctrl+F5 did not resume** a stopped debuggee during this session's driving. May
  be an artefact of synthetic input rather than a defect — check by hand before treating it as a bug.
- Cosmetic: the Tools menu still lists a stale **`VisualFBEditor64`** external-tool entry from
  `Settings/Others/Tools.ini` — branding drift, found 2026-08-06.

**Repo-hygiene note:** the `./ilwaco` binary is tracked **by owner directive (2026-08-04) — do not
`.gitignore` it** (the repo moves between two machines and the built editor must travel with each push).
Instead, **rebuild it (`./build-linux.sh editor`) and commit it alongside source changes** so the tracked
blob stays current rather than drifting.

---

## Current state (standing facts — not a session narrative)

**Where things stand.** Ilwaco builds from source and runs on this Debian 13 machine. All owner
directives are cleared: 64-bit-only, one bundled compiler (no picker), UTF-8/LF-only, English-only,
rebrand to Ilwaco IDE, and the whole-tree non-target (Windows/GTK4/GTK2/32-bit) strip. The active work
is the **Astoria→Ilwaco changelog walk** (backlog: [AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md),
classified in [AstoriaParity.md](Documentation/AstoriaParity.md)). Past session narratives now live in
[HISTORY.md](HISTORY.md).

**Astoria is frozen (owner, 2026-08-06)** — stable, with no further changes anticipated until after
Ilwaco reaches release. The walk therefore has a **fixed endpoint**: the remaining backlog is the whole
of it, a whole-log scan stays valid once done, and no classification will be invalidated by later
Astoria work. Ilwaco is the moving fork now, which also means the GTK fixes we log in
[UpstreamFixes.md](Documentation/UpstreamFixes.md) will not be taken up on that side in the meantime.

**The Agent MCP server is live and ON by default.** `./ilwaco-mcp` (sidecar) → a per-user Unix socket →
the running IDE; it auto-launches the IDE if needed. It is genuinely useful as a *test instrument* — this
session used it to open projects and files and to read `get_status` back while verifying UI work. Turn it
off in Tools ▸ Options ▸ General; the status bar shows which. See
[AgentMcpSetup.md](Documentation/AgentMcpSetup.md).

**Build / run (self-contained — shim is vendored).**
- Build: `./build-linux.sh` — `editor` | `lib` | `all`.
- Run: `LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`.
- Source `src/ilwaco.bas` → binary `./ilwaco`; designer lib `Controls/MyFbFramework/libmff64_gtk3.so`
  (rebuild with `lib` or the toolbox errors); settings `Settings/ilwaco.ini`.
- The shim is now **fully in-repo**: `Compilers/shim/libtinfo.so.5` + the GTK `-dev` symlinks under
  `Compilers/shim/gtk-dev/` — no per-session scratchpad shim needed. `build-linux.sh` wires them up.
- A whole-program editor compile is ~3–4 min — run it in the background (a 2-min foreground limit kills it).

**Operational cautions.**
- **`git checkout Settings/` after any IDE launch** — it writes window state into `ilwaco.ini` on exit.
  Careful: that also reverts *uncommitted* deliberate edits to `ilwaco.ini`, so commit those first (it bit
  twice on 2026-08-06). `Settings/Workspace.ini`, written on every exit, is gitignored and can be deleted
  freely to start the IDE empty.
- **`pkill -f ilwaco` matches its own caller** — use `pkill -x ilwaco` or kill by PID.
- **Shutdown SIGSEGV — FIXED 2026-08-07.** Was a deterministic close crash (null `Parent` in
  `frmMain_Close` when the debugger is off, plus a global-destructor use-after-free over freed GTK
  widgets); fixed by a `Main.bas` null-guard and an MFF `Form.bas` main-form `_exit(0)` (Astoria parity).
  Closes are clean (exit 0), verified 20/20. Detail in the DONE section above and memory
  `project-known-segfault-threading`. If a close crash recurs it is a **new** defect — diagnose fresh.
- Harmless startup warnings: resources `AppAddin`/`AppConsole` "do not exist".

**Known gaps (tracked, not blockers).**
- **Packaging/shim:** the vendored shim *does* carry `libncurses.so` and `libtinfo.so` under
  `Compilers/shim/gtk-dev/`, but the linker only sees them when they are on its command line — `ld` does
  **not** consult `LD_LIBRARY_PATH`. So a console link needs `-p <shim> -l tinfo`, either per-project via
  `CompilationArguments64Linux` or globally via `[Parameters] Compiler64Arguments`; without it fbc stops at
  `ld: cannot find -lncurses` (measured again 2026-08-06). The AppImage should ship the libraries so users
  need neither. AppImage packaging itself is still open (memory `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- `UseDebugger=false` by default. GDB is gone — the Integrated engine needs no external debugger.
