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

## ✅ DONE (2026-08-07) — Ilwaco installs: release staging, installer, toolchain, AppDir

**There is a single-file installer, and it works.** Following Astoria's two-step pattern:
`Packaging/StageRelease.sh` exports a clean end-user tree (from `git archive HEAD`, never the working
tree — Astoria's expensive lesson) to `../ilwaco-ide-release`; `Packaging/BuildInstaller.sh` stages
then packages it into `../ilwaco-ide-installer/Ilwaco-IDE-1.3.8-x86_64.run`, 52 MB, self-extracting,
no root and nothing installed. Verified end to end: **install → launch → compile a GUI example →
run it → reinstall over the top with a user's project file and hand-edited INI left untouched.**

A `.run` rather than a self-extracting zip because `unzip` is not guaranteed on a minimal Linux install
while `tar`/`gzip` effectively are. The **AppImage** remains the better single-file answer and the
chosen primary download; `BuildInstaller.sh` emits it when `appimagetool` is present, but that branch
has never run — fetching the tool needs owner approval.

The staged tree is laid out **exactly as an installed Ilwaco**, so both packaging routes fall out of
one staging step and ship identical content. `ilwaco.sh` is the shared launcher; `AppRun` only
materialises a writable copy and hands over to it.

**The AppDir runs.** `Packaging/build-appdir.sh` assembles a 136 MB AppDir; `Packaging/AppRun` seeds a
writable app home, patches the settings the shipped INI cannot carry, regenerates the GTK link targets,
and launches the IDE. Verified end to end: window opens, and a real MFF GUI example compiled under
AppRun's environment with the seeded arguments then **ran and opened its own window**.

The design turns on one measurement: **`ExePath()` resolves symlinks**, so the IDE — which writes to
`Settings/`, `Temp/` and `.bak` files next to its own binary — cannot run from the read-only image, and
cannot be symlinked out of it either. `AppRun` therefore keeps **real copies** of the binaries in
`~/Ilwaco` (refreshed when the image ships a different build) and relinks the bulk read-only payload
into the image on every start, because the mount point moves each run. Two traps worth remembering are
in [Packaging.md](Documentation/Packaging.md): the shipped `[Compilers]` block still points at the
original author's machine, and **`ilwaco.ini`'s UTF-8 BOM** makes a naive `[Parameters]` section match
fail silently (it did, first run — the patcher now verifies each key landed).

### The bundled link toolchain

The hardest part of packaging is settled: **Ilwaco can now compile FreeBASIC with nothing from the host
but the kernel and the GTK/libc runtime a normal desktop already has.** Three scripts in
[`Packaging/`](Packaging), designed and verified this session; the full write-up, including the two
decisions below, is [Documentation/Packaging.md](Documentation/Packaging.md).

- **`make-toolchain.sh`** assembles ~12 MB: wrapped `as`/`ld` (with their private `libbfd` etc. kept off
  the app's library path), a **stub `gcc`**, and a minimal C link sysroot. Run it on the release machine.
- **`gen-gtk-links.sh`** generates the unversioned GTK `.so` link targets against the *host's runtime*
  at startup. **GTK is deliberately not bundled** — the `ilwaco` binary already links host
  `libgtk-3.so.0`, so a host GTK3 runtime is a hard requirement regardless; bundling would add ~19 MB
  plus the pixbuf-loader/gio-module/theme tax and buy nothing.
- **`verify-toolchain.sh`** compiles under `env -i` with only the bundled `bin` on `PATH`, runs the
  result, and scans the link line for host reach-back. Green, and **confirmed falsifiable**: pointing the
  gcc stub at `/usr/bin/gcc` and deleting the bundled `crt1.o` each turn it red.

**The finding that changes the plan:** fbc's *default* backend shells out to a real **`gcc`**, not just
`as`/`ld` as previously recorded — and with no gcc present it fails **silently**, dropping every crt
object from the `ld` line and dying later on `cannot find -lgcc`. The escape is **`-gen gas64`**, which
needs no C compiler; **owner confirmed 2026-08-07, and the IDE already emits it** on every compile path
(`GetFirstCompileLine` in `src/TabWindow.bas`, plus a redundant second append in `Compile` in
`src/Main.bas`). Both are gated on there being a project, which is correct — **Ilwaco has no loose
single-file compiles, everything is a project.** So no code change was needed.

---

## NEXT — packaging, then the two committed divergences, then the parity tail

The release blocker is gone, so the order is now feature/packaging work (owner: **no release until the
whole parity list is complete**, so nothing here is release-gated — sequence by value):

1. **Packaging** — **Ilwaco now installs.** `Packaging/StageRelease.sh` → `../ilwaco-ide-release`,
   `Packaging/BuildInstaller.sh` → `../ilwaco-ide-installer/Ilwaco-IDE-1.3.8-x86_64.run` (52 MB),
   following Astoria's `StageRelease.ps1`/`BuildInstaller.ps1` pattern. What remains: the
   **`.AppImage`** output (branch is written, needs `appimagetool` — a download the owner has to
   approve), **a release build on an old-glibc host**, and driving a build **from inside the IDE's
   UI** rather than reproducing its command line. Full design and status table:
   [Documentation/Packaging.md](Documentation/Packaging.md).
2. **The two committed divergences**, in order: **Git integration** (build the ADD chain `d61eb062` →
   `fffee489` → `fd894173` → `95b04f70`, skip removal `9d277f28`), then the **three AI templates** (Claude
   Code, ChatGPT, Kun — ADD chain `987e8b7e`/`ef5a6252`/`72ea5980`/`de8c1e5a`, skip `6de0332f`). See the
   STANDING divergences table above and its traps.
3. **The parity tail** — the deferred menu features and the rest of the `13.3.A` walk (below).

**Still explicitly NOT next: `13.72` (idle slices)** — it only removes a stall `13.71` introduced that
nobody has felt on a real project.

---

### After that — the parity tail (deferred backlog + small items)

**Backlog classification.** All **396** remaining entries in
[AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md) are grouped and judged in
[AstoriaParity.md](Documentation/AstoriaParity.md) "Full classification pass" — read its **"How much to
trust this pass"** section first: a PORT verdict is *cluster-level* and each entry still needs normal
scoping, and the backlog file was deliberately not pruned (sampling one cluster found four mis-filed
entries a bulk delete would have lost).

**The threading arc (`13.60`–`13.79`) is settled and was never the SIGSEGV.** `13.71` (serial IntelliSense
loader, `31a5e20`) is DONE and kept as a correctness improvement (detail in [HISTORY.md](HISTORY.md));
`13.72` (idle slices) stays deferred until its stall is felt on a real project. Astoria downgraded the
underlying race itself (`382dbb07`: 0 deaths/60 at ≥1 s/switch) — not a blocker. The actual shutdown
SIGSEGV was a separate deterministic close crash, now fixed (DONE section above).

**Deferred menu features** (each its own pass, in walk order): the **S3 toolbar merge** (7→5 bands,
single-checkable Toolbars, `ShowRunToolBar` INI migration incl. `93bbfa28`'s run-toolbar persistence, the
7-band Maximize `Bands.Count-2` fix, band renumbering), Code/Form contextual greying
(`a114ee5b`/`e1595a31`/`f3538e1c`), designer `@PopupClick` context items in the Form menu (`b05fdacb`),
and the **Git menu** (`d61eb062`+, part of the committed Git divergence above). When you reach
**`4a112089`**, wire `ParameterInfoShow` up (INI load, the `If Not ParameterInfoShow Then Exit Sub` gate,
the Options checkbox) — a latent global in Ilwaco. Skip the pure GTK/Linux/32-bit stripping commits
(`e139c2cc`, `c494207f`, `7baebd1e`, `add4642a`, `76abaa5a`, `15e66cc5`). The rest of `93bbfa28` is
N/A/INVERTED (S6 dead-UI removals already done here; "Turn on Environment variables" INVERTED — Ilwaco
wired env-vars up; S7 docs N/A).

**Method that works:** read Astoria's commit *and* what its code actually does before classifying, and
**look downstream at the whole log** (a CLAUDE.md rule) — changes get reworked later, so scope against
Astoria's *final* state. Build with `./build-linux.sh editor` (background), verify by effect on `:0`, then
document and commit per item.

**Two items to settle before the testing phase** (both in TechnicalDebt "Known gaps"): the
**blank-terminal finding** (Run shows an empty window — reproducible with
`xfce4-terminal --hold -x /bin/echo TEST`, so not ours, but it is what a user sees), and the **project
`.vfp` BOMs** written by `SaveProjectFile` and carried by the template `.vfp` data.

- **Examples work — deferred to just before the testing phase (owner).** The two Astoria Examples items
  (`4bd02894`, `51441d7a`), **plus a BOM sweep**: 93 of 111 sources under `Examples/` start with a UTF-8
  BOM, so FreeBASIC compiles their string literals wide (they build clean, then print UTF-32). Do all
  three together so `Examples/` is touched once.
- Unverified, low priority: **Ctrl+F5 did not resume** a stopped debuggee — may be a synthetic-input
  artefact; check by hand before treating it as a bug.
- Cosmetic: the Tools menu still lists a stale **`VisualFBEditor64`** external-tool entry from
  `Settings/Others/Tools.ini` — branding drift.

**Repo-hygiene note:** the `./ilwaco` binary is tracked **by owner directive (2026-08-04) — do not
`.gitignore` it** (the repo moves between two machines). Rebuild it (`./build-linux.sh editor`) and commit
it alongside source changes so the tracked blob stays current. Same for the designer lib
`Controls/MyFbFramework/libmff64_gtk3.so` when framework source changes.

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
  `ld: cannot find -lncurses` (measured again 2026-08-06). This is a *from-source dev build* caution only —
  **for the shipped app it is solved**: `Packaging/make-toolchain.sh` bundles binutils, a stub `gcc` and a
  minimal C link sysroot, verified self-contained (DONE section above,
  [Packaging.md](Documentation/Packaging.md)). What is still open there is the AppDir/`AppRun`, the
  writable user-data dirs, the `.AppImage` wrap, and the `-gen gas64` decision.
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- `UseDebugger=false` by default. GDB is gone — the Integrated engine needs no external debugger.
