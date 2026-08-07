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

## ✅ DONE (2026-08-07) — Examples: 53 ported, broken half deleted, 54 build-verified through the SHIPPED toolchain

Owner-requested, superseding the "defer Examples to the testing phase" note. Ported: the whole
`Learning` course except its DLL series — **`Console` 25 + `GUI` 25** (renamed from Astoria's
`WinGUI`, a misnomer on GTK) — plus **`Calculator`, `FiveInARow`, `Maze`**. Every one was compiled
with the bundled toolchain **and run**: console programs to completion (exit 0), GUI programs to a
confirmed window on screen. All converted to UTF-8-no-BOM + LF on the way in.

**Copying was not enough — four defects had to be fixed**, three of them the same class: a
case-insensitive filesystem had hidden `mff/Textbox.bi`, `mff/sys.bi` and `maze.bi`, all of which are
`error 23` here. The fourth was `crHand`, Win32-only (`LoadCursor(0, IDC_HAND)`), substituted with
GTK's `crHandPoint`. Separately, **every** GUI example needed the `#ifdef __FB_WIN32__` guard restored
around its `#cmdline "*.rc"` — an INVERT of Astoria's Win64-only stripping, without which fbc stops at
`Executable not found: "windres"`. Detail in [UpstreamFixes.md](Documentation/UpstreamFixes.md).

**Held back:** the `Learning/DLL` series, because **fbc 1.10.1 `-gen gas64 -dll` segfaults** on two of
its four lessons (minimal repro in [TechnicalDebt.md](Documentation/TechnicalDebt.md)) — shipping a
numbered course missing lessons 2 and 3 is worse than shipping none. **This is bigger than the
examples:** Ilwaco compiles everything with `-gen gas64`, so a user building a shared library can hit
a compiler crash with no diagnostic. Not yet reported upstream. Also not ported, as Windows by nature:
the DirectShow, COM, SAPI and WLan sets, plus `Sudoku` and `MultipleDisplay`.

**Then the broken half was deleted and every example put in its own directory** (owner). The 22 audited
pre-existing projects, 6 stale Windows-era duplicates under `Examples/Game/`, four empty placeholder
dirs and an orphaned `Examples/Manifest.xml` were `git rm`'d; the retained candidates were re-evaluated
against a "delete unless the port is trivial" bar and **test-compiled** — `try_catch_throw`, `Add-In`,
`Web Page`, `Graphics/CanvasDraw` deleted; `Class Form Example` compiled clean and was **kept and
finished into a real project** (BOM stripped, `.vfp` added). `Examples/` now holds **54 projects, one
per directory**. Detail and the per-candidate reasons in [ExamplesAudit.md](Documentation/ExamplesAudit.md).

**Verified against the SHIPPED build path, not just the dev shim.** The earlier "compiled with the
bundled toolchain" runs used the dev shim (`-p <shim> -l tinfo`); this session reproduced the *shipped*
path — `Packaging/make-toolchain.sh` sysroot on PATH, only `libtinfo.so.5` on `LD_LIBRARY_PATH`, the
seed-patch's `-p sysroot -p .link-shim` link args, the IDE-appended `-gen gas64`, and the main file via
`-b "<file>"` (how `.frm` reaches fbc) — and swept **all 54: 54/54 build, 0 fail**. The one sharp edge:
without `-gen gas64` the bundled `gcc` is a **stub** (crt-probe only) and fbc's default `-gen gcc`
backend dies `no C compiler in the image` — but the IDE appends `-gen gas64` for **every project**
build (`src/Main.bas:714`, `src/TabWindow.bas:11546`), and seeded examples are all `.vfp` projects, so
the shipped path is sound.

---

## ✅ DONE (2026-08-07) — MCP write safety, then agent permission levels

**Write safety first, because no permission tier makes an unversioned clobber safe.** Two live
data-loss paths, found by reading the write path during the permissions discussion rather than from a
failure report: `write_file` wrote to disk with no check for an open dirty tab (the very thing
CLAUDE.md tells humans never to do), and `set_active_file_content` replaced the whole buffer with no
version check. Now `dirty_buffer` and an opt-in `expected_version`/`version_mismatch`; `read_file` and
`get_active_file` hand out the token. Detail in [McpServer.md](Documentation/McpServer.md).

**Then five permission levels** — Off / Read-only / Edit / **Build & Run** / Trusted — replacing the
`AllowAgentControl` boolean (owner-directed, 2026-08-07). **The default stays Build & Run**: Ilwaco is
agent-first, and a default that let an agent edit but not build would break the edit-build-fix loop.
So it is two opt-in restrictions below the old capability and one opt-in expansion above it. One combo
in Tools ▸ Options ▸ General (the old checkbox became its `Off` value — an option removed, not added),
the level shown in the status bar, `AllowAgentControl=true/false` migrating to `Build & Run`/`Off`, and
**one gate at the dispatcher** so no handler can forget; unclassified commands fail **closed**.

Verified by effect at four levels over the socket, plus the Options combo and status bar by screenshot.
**Trusted gates nothing yet** — the designer tools and outside-the-project access it is meant to unlock
are still to build, which is the point of landing the mechanism once.

**Next on this thread, in order:** the activity log (agent actions into a pane — arguably the highest
value of the three, since it is what makes the Edit level trustworthy), then the Trusted-level path
relaxation, then the designer tools. Per-client pairing was considered and **rejected**: on a
same-user Unix socket any process running as the user can already read the source or the pairing
token, so it buys accountability the activity log gives more cheaply, at the cost of the "it just
works" default.

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
      Full detail in the DONE section above and [ExamplesAudit.md](Documentation/ExamplesAudit.md).

1. **⭐ FRESH owner directives (2026-08-07) — interrupted before starting; do these first.** Came out of
   the seeded-examples / AppImage investigation (which itself confirmed 54/54 seeded examples build via
   the bundled toolchain — the compile path is *not* the problem). The owner asked to:

   a. **Rename the user-data `Projects` directory to lowercase `projects`.** Owner directive, verbatim:
      "keep 'projects' lower case." The AppImage seeds `~/ilwaco-ide/Projects` (capital P) today; the
      owner wants `~/ilwaco-ide/projects`. Touch every producer/consumer of the name together (they
      must agree, and Linux is case-sensitive): `Packaging/AppRun` (the seed loop list), `Packaging/
      ilwaco.sh` (`mkdir -p "$HERE/Projects"`), `Packaging/StageRelease.sh` (`mkdir -p "$RELEASE/
      Projects"`), and **grep `src/` for `Projects`** — the IDE has a default project/output path and
      likely a `Projects`-relative default in `ilwaco.ini`; find and lower-case those too, or the IDE
      writes to `Projects` while the seed makes `projects`. Verify by effect: seed a clean
      `ILWACO_HOME`, confirm `projects/` is what's created and what New Project defaults into.

   b. **Dig into / harden the "run straight from Downloads" caveats.** Confirmed this session that a
      fresh run *does* install into `~/ilwaco-ide` and creates a user-owned, writable `Projects/`
      (reproduced AppRun's seed loop by effect). The gaps a beginner hits are upstream of AppRun:
      **(i)** the downloaded `.AppImage` is not executable — needs `chmod +x` / "allow executing";
      **(ii)** **FUSE** — Debian 13 and other recent distros lack `libfuse2`, so a double-click fails to
      mount; fallbacks are `--appimage-extract-and-run`, installing `libfuse2`, or shipping the `--run`
      self-extracting variant (which sidesteps FUSE). Decide what the product does about these (docs? a
      launcher note? default to the self-extracting build?). **(iii)** A real fragility found while
      tracing: `ilwaco.sh`'s first-run seed-patch only *rewrites existing* keys in `ilwaco.ini` and
      `die`s at launch if a target key is absent (`Compiler64Arguments`, `[Compilers] DefaultCompiler64/
      Version_0/Path_0`) — they exist today, but a future `[Compilers]` reorder/rename breaks *launch*,
      not just a build. Make the patch **insert-if-missing** instead of replace-only.

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

- **Examples — 54 projects ship, all build-verified (2026-08-07).** The 53 Astoria-ported set plus the
  kept `Class Form Example`, each in its own directory. The old BOM-sweep worry is **largely moot**: the
  BOM'd pre-existing sources were deleted (see the RESOLVED note under NEXT 0b), and the one survivor was
  BOM-stripped. What remains of the BOM question is only the **project `.vfp` BOMs** written by
  `SaveProjectFile` / carried by the template `.vfp` data (tracked just above); still worth doing with the
  two Astoria Examples items (`4bd02894`, `51441d7a`).
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
