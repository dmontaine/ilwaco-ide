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
| 1 | **Themes** — *two* of them: IDE UI theme (Options ▸ General ▸ Themes) and editor theme (Options ▸ Code Editor ▸ Colors and Fonts) | Both capabilities present; editor themes **culled 96 → 13** (owner, 2026-08-07) | **Partly reversed.** `5c50f20f` (Astoria's cull to 12) is now **PORTED**, plus `Dark (Visual Studio)` retained as a 13th — owner-directed, superseding the earlier guard. The *capabilities* remain the divergence to protect; the theme **count** no longer is. `Interface/` untouched. |
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

## ⏳ HANDOFF (2026-08-08) — Stage A done: the bottom view-selector (tcView, reimplemented on GTK)

Redoes the lost Stage A stash (that prior 2026-08-08 handoff is now in [HISTORY.md](HISTORY.md)) and
**completes it — owner-verified in the running IDE across all three buttons on a form.**

**What shipped.** The three *Code / Form / Code And Form* view toggles Ilwaco added to the top toolbar
`tbrTop` are gone; a new **bottom-docked toolbar `tbrView`** (`Align = alBottom`, `Height = 26`) carries
them as a text-labelled radio-button row ordered **Code And Form / Code / Form**. The class/function
dropdowns stay on `tbrTop` (top). Astoria's mechanism — a `TabControl` styled `TabStyle.tsButtons`
(`4b643af5`) — **does not translate**: MFF's GTK `TabControl` is a `gtk_notebook` and `FTabStyle` is
never consulted, so `tsButtons` is a no-op there. The GTK reimplementation reuses the existing
`tbsCheckGroup` style (→ `gtk_radio_tool_button`, genuine single-selection), shows text via
`tbrView.List = True` (`GTK_TOOLBAR_BOTH_HORIZ`) with each button flagged
`gtk_tool_item_set_is_important` so the label draws beside the icon. Behaviour is otherwise identical to
the old toggles: same `tbrTop_ButtonClick` handler (it resolves its tab via `Button.Ctrl->Parent`, so it
works on either toolbar), and the ~30 `tbrTop.Buttons.Item("…")` call sites across `ilwaco.bas`,
`Main.bas`, `TabWindow.bas` were repointed to `tbrView`. Full rationale:
[AstoriaParity.md](Documentation/AstoriaParity.md) "UI work — staged sequence", Stage A.

**Two latent Ilwaco bugs fixed in passing.** A tab-add `.tbrTop.Buttons.Item(1)->Checked` and a
designer-path `Item(3)->Checked` were both hitting *separators* — index-based refs that never matched the
view buttons (Astoria's base used the button *names*; Ilwaco had drifted to indices). The first is
deleted (Astoria removed it too); the second is corrected to `Item("CodeAndForm")`, matching Astoria's
`SyncViewTab("CodeAndForm")` — a sync that must NOT re-fire the handler, which holds because MFF's
`ToolButton.Checked` setter is unported Win32 and on GTK only sets `FChecked`.

**Build-verified GREEN** (`./build-linux.sh editor`, exit 0) and owner-verified on `:0`; `ilwaco` is
rebuilt and staged with the source. No `ApplyView`/`ShowView` method layer was introduced — that Astoria
abstraction is deferred until Stage C's menu-greying actually needs it.

**Resume order:** the parity tail, now led by **Stage B — Form Designer depth** (`f292db0b` per-form
control tree, `0c08fe5f` PagePanel, `623aa2a7` + `1c00c1fb` designer Undo/Redo) per the staged sequence.
Still open, unchanged: the benign `CurrentView() = "Code"` → `CBool(...)` warning wrap in
`src/TabWindow.bas`, and the command-line **file**-open gap (observed again: `./ilwaco <file>` opens no
editor tab — MCP `open_in_editor` does; this is a superset of the known `.vfp`-Explorer gap).

---

## NEXT — the agent thread, then the two divergences and the parity tail

Packaging is essentially done (Ilwaco ships as an AppImage). Owner standing rule: **no release until
the whole parity list is complete**, so nothing here is release-gated — sequence by value.

0. **The agent permission thread is still mid-flight; the Examples cleanup (0b) is now done:**

   a. **The agent permission thread** — level plumbing landed; next is the **activity log** (agent
      actions into a pane), then the **Trusted-level path relaxation** (let a Trusted agent reach
      outside the project folder), then the **designer tools** that Trusted is meant to unlock.
      Until those land Trusted equals Build & Run plus a fail-closed catch-all. Rationale and the
      rejected alternatives (per-client pairing) are in
      [McpServer.md](Documentation/McpServer.md); the owner asked for checkpoints between each.

   b. **Examples — DONE** (deleted the broken half, 54 build-verified through the shipped toolchain).
      Full detail in [HISTORY.md](HISTORY.md) and [ExamplesAudit.md](Documentation/ExamplesAudit.md).

1. **Flatpak — considered and REJECTED (owner, 2026-08-07).** Raised as the one technology that gives
   a genuine two-double-click, no-root install. Rejected because the premise it serves is weak: **a
   locked-down school machine means the student installs nothing at all — IT deploys it**, so the
   no-root *download* experience matters far less than deployability, which `.deb`/`.rpm` already
   give. Against it: Flatpak is not pre-installed on Debian, and although `flatpak` is in Ubuntu's
   *universe* repo, Ubuntu dropped the GNOME Software Flatpak plugin from default installs, so the
   double-click-to-install path needs setup anyway. Its real win is **immutable Fedora**
   (Silverblue/Kinoite) — a small audience today. Revisit only if that audience grows. This
   supersedes nothing: the AppImage-over-Flatpak reasoning in
   [Packaging.md](Documentation/Packaging.md) still stands.

2. **Fresh owner directives (2026-08-07) — all DONE.** The `projects` rename, the seed-patch
   hardening, and the download question (now answered with three artefacts). See [HISTORY.md](HISTORY.md).
   **What is left is verification we cannot do here: install the `.rpm` on a real Fedora system.**
   The owner is setting up a Fedora VM for exactly this. Until that passes, the RPM is *built and
   inspected* but not *installed-and-run* anywhere. Check, in order: `dnf install ./…rpm` resolves
   without complaint, Ilwaco appears in the applications menu, it launches, `~/ilwaco-ide` is seeded,
   and a bundled example compiles and runs.

2. **Packaging** — **Ilwaco now ships as a single-file AppImage.** `Packaging/StageRelease.sh` →
   `../ilwaco-ide-release`, `Packaging/BuildInstaller.sh` →
   `../ilwaco-ide-installer/Ilwaco-IDE-1.3.8-x86_64.AppImage` (49 MB), following Astoria's
   `StageRelease.ps1`/`BuildInstaller.ps1` pattern. `--run` builds a 52 MB self-extracting fallback.
   What remains: **a release build on an old-glibc host**, and driving a build **from inside the
   IDE's UI** rather than reproducing its command line. Full design and status table:
   [Documentation/Packaging.md](Documentation/Packaging.md).
3. **The two committed divergences**, in order: **Git integration** (build the ADD chain `d61eb062` →
   `fffee489` → `fd894173` → `95b04f70`, skip removal `9d277f28`), then the **three AI templates** (Claude
   Code, ChatGPT, Kun — ADD chain `987e8b7e`/`ef5a6252`/`72ea5980`/`de8c1e5a`, skip `6de0332f`). See the
   STANDING divergences table above and its traps.
4. **The parity tail** — the deferred menu features and the rest of the `13.3.A` walk (below).

**Still explicitly NOT next: `13.72` (idle slices)** — it only removes a stall `13.71` introduced that
nobody has felt on a real project.

---

## ⏸ DEFERRED — the embedded VTE terminal (owner, 2026-08-07)

**Why an embedded terminal at all:** retire the external-terminal blank-window bug (Run shows an empty
window on some desktops — a beginner cannot tell it from their own program failing), remove the
terminal-selection option entirely, give a Flatpak/sandboxed build a terminal it can shell into, and —
the real point — provide a **true pty** so a student's `Input`/`Color`/`Locate`/`Cls` behaves as in any
terminal. Full rationale is in the header of [src/Vte.bi](src/Vte.bi).

**Foundation is committed and stands:** the hand-written `Vte.bi` binding (`515f42c`) and `libvte-2.91`
in the build shim (`19fe3e2`). Every signature in `Vte.bi` is measured, not transcribed.

**Wiring was attempted, worked, and was reverted (owner direction).** A `Terminal` tab was wired into
the **bottom pane** and verified by effect: a live, colour-rendering interactive shell running in the
projects folder, embedding + spawn + pty all real. **The owner deemed the bottom pane the wrong home:**
the terminal belongs in the **Form/Editor (central) area**, which will change substantially with later
UI work. So the wiring was reverted to this clean foundation; **pick it up again once that UI work is
much further along.** Do not re-add it to the bottom pane. That UI work is now sequenced in
[AstoriaParity.md](Documentation/AstoriaParity.md) "UI work — staged sequence"; the terminal
**re-enters after Stage A–B** (once `tcView` + the designer navigation have settled the area's shape).

**Findings to make resumption cheap** (so the next attempt starts ahead):
- The 4-step plan (create tab + embed → redirect `RunPr`'s `Shell()` → remove the terminal-picker
  option → teach `Packaging/gen-gtk-links.sh` about libvte) is spelled out in `515f42c`'s commit message.
- **Embed:** `gtk_container_add` the `VteTerminal` (a raw `GtkWidget`) into the host's GTK container,
  then `vte_terminal_spawn_async`. **Pre-realize spawn is fine** (the `Vte.bi` probe proved it).
- **The one unsolved detail is sizing.** An MFF `Panel`'s `.Handle` is a `gtk_layout_new` that places
  children at (0,0) and never resizes them; a raw `size-allocate` hook on `->Handle` did **not**
  reliably grow the VTE to fill (it stayed a narrow strip). When resuming, size the terminal from the
  host control's MFF resize path (`OnResize` + `ScaleX`/`ScaleY`) or via `LayoutHandle` / MFF's own
  `Control_SizeAllocate`/`RequestAlign` — not a bare `size-allocate` on the `GtkLayout`.
- **Run-redirect is the hard increment:** `RunPr` (TabWindow.bas) runs on a worker thread and blocks on
  `Shell()` for the exit code, while VTE spawn is async on the GTK main thread. Needs thread marshalling
  and exit reporting via the `child-exited` signal. If a persistent shell + "type the command in" model
  is chosen, `vte_terminal_feed_child` must be **probe-verified** before being added to the binding.
- **Cleanup owed regardless:** an old commented-out VTE block squats in `src/TabWindow.bas` (~10780–11020)
  — dead code to delete (strip-Windows-code hygiene), independent of when the terminal is picked up.

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
SIGSEGV was a separate deterministic close crash, now fixed (see [HISTORY.md](HISTORY.md)).

**The UI portion of this tail is now sequenced** in [AstoriaParity.md](Documentation/AstoriaParity.md)
"UI work — staged sequence" (Stages A–F, central Form/Editor area first, terminal re-entry noted) —
follow that ordering for anything UI-facing below.

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

**One item to settle before the testing phase** (in TechnicalDebt "Known gaps"): the
**blank-terminal finding** (Run shows an empty window — reproducible with
`xfce4-terminal --hold -x /bin/echo TEST`, so not ours, but it is what a user sees). *(The project
`.vfp` BOMs are FIXED, 2026-08-08 — `SaveProject` strips the BOM and the templates were de-BOM'd.)*

- **Examples — 54 projects ship, all build-verified (2026-08-07).** The 53 Astoria-ported set plus the
  kept `Class Form Example`, each in its own directory. The old BOM-sweep worry is **largely moot**: the
  BOM'd pre-existing sources were deleted (see the RESOLVED note under NEXT 0b), and the one survivor was
  BOM-stripped. The **project `.vfp` BOMs** are now **FIXED too** (2026-08-08): `SaveProject` strips the
  BOM its `Encoding "utf-8"` write adds and the 9 templates were de-BOM'd. The two Astoria Examples items
  (`4bd02894`, `51441d7a`) remain.
- Unverified, low priority: **Ctrl+F5 did not resume** a stopped debuggee — may be a synthetic-input
  artefact; check by hand before treating it as a bug.
- Cosmetic: the Tools menu still lists a stale **`VisualFBEditor64`** external-tool entry from
  `Settings/Others/Tools.ini` — branding drift.

**Repo-hygiene note:** the `./ilwaco` binary is tracked **by owner directive (2026-08-04) — do not
`.gitignore` it** (the repo moves between two machines). Rebuild it (`./build-linux.sh editor`) and commit
it alongside source changes so the tracked blob stays current. Same for the designer lib
`Controls/Framework/libmff64_gtk3.so` when framework source changes.

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
- Source `src/ilwaco.bas` → binary `./ilwaco`; designer lib `Controls/Framework/libmff64_gtk3.so`
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
  Closes are clean (exit 0), verified 20/20. Detail in [HISTORY.md](HISTORY.md) and memory
  `project-known-segfault-threading`. If a close crash recurs it is a **new** defect — diagnose fresh.
- Harmless startup warnings: resources `AppAddin`/`AppConsole` "do not exist".
- **GUI screenshots on this GNOME/Wayland box (Ubuntu 26.04):** `gnome-screenshot` and the GNOME Shell
  D-Bus screenshot are blocked (rootless XWayland has no grabbable root; the Shell API returns "not
  allowed"). The working method — launch under **`GDK_BACKEND=x11`** so the IDE is a real X window, find
  its id with `xwininfo -root -tree | grep 'Ilwaco IDE (64-bit)'`, then **`import -window <id> shot.png`**
  (ImageMagick, installed 2026-08-08). This is the `verify-ilwaco-behaviour` capture path the CLAUDE.md
  notes as an open infra item. Write captures under `/home/don` (or the scratchpad); the harness trusts
  `/home/don` + `/tmp`.

**Known gaps (tracked, not blockers).**
- **Command-line project open may not populate the Explorer (observed 2026-08-08, unresolved).** Launching
  `./ilwaco <abs-path>.vfp` reaches `OpenFiles` → `AddProject` (`Main.bas:1782`), but the project tree
  came up **empty** for `Examples/Calculator/Calculator.vfp` (relative *and* absolute path). **Not a BOM
  regression** — that `.vfp` is a pre-existing BOM-less example and the fix below touches only the *writer*
  + templates, not `OpenFiles`/`AddProject`/the loader; and the loader reads `Encoding "utf-8"` (handles
  no-BOM). Follow-up: does command-line project open work at all, or is it an `AddProject`-in-`frmMain_Show`
  timing/render issue? Verify a BOM-less `.vfp` loads via **File ▸ Open Project** / MCP `open_project` too.
- **Packaging/shim:** the vendored shim *does* carry `libncurses.so` and `libtinfo.so` under
  `Compilers/shim/gtk-dev/`, but the linker only sees them when they are on its command line — `ld` does
  **not** consult `LD_LIBRARY_PATH`. So a console link needs `-p <shim> -l tinfo`, either per-project via
  `CompilationArguments64Linux` or globally via `[Parameters] Compiler64Arguments`; without it fbc stops at
  `ld: cannot find -lncurses` (measured again 2026-08-06). This is a *from-source dev build* caution only —
  **for the shipped app it is solved**: `Packaging/make-toolchain.sh` bundles binutils, a stub `gcc` and a
  minimal C link sysroot, verified self-contained ([HISTORY.md](HISTORY.md),
  [Packaging.md](Documentation/Packaging.md)). What is still open there is the AppDir/`AppRun`, the
  writable user-data dirs, the `.AppImage` wrap, and the `-gen gas64` decision.
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- `UseDebugger=false` by default. GDB is gone — the Integrated engine needs no external debugger.
