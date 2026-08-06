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
couldn't, and why), [CHANGELOG.md](CHANGELOG.md) (milestones),
[Documentation/UpstreamFixes.md](Documentation/UpstreamFixes.md) (our GTK fixes that are really upstream
bugs) and [CLAUDE.md](CLAUDE.md) (orientation for the Linux/GTK build).

**Keep this file pruned.** It holds only the **most-recent session handoff**, the **NEXT** actions, and
the **standing facts** below — not an archive. When a session's work is done and committed, move its dated
narrative section to [HISTORY.md](HISTORY.md) (newest-first) instead of letting handoffs pile up here.
`python3 Tools/DocCheck.py` flags this file once more than two dated session sections accumulate; see
CLAUDE.md "Working practices".

---

## ✅ DONE (2026-08-06) — MCP server finished; menu-taxonomy cluster closed; workspace replaces sessions

A long session. Six pieces of work, each built, verified **by effect** on `:0`, documented and
committed separately; the per-change narratives are in [HISTORY.md](HISTORY.md) and the per-item
classifications in [AstoriaParity.md](Documentation/AstoriaParity.md).

1. **Agent MCP server Tasks 6 + 7 — the server is COMPLETE.** Task 6 made the listener a
   user-controlled opt-out: `AllowAgentControl` (default ON), the Tools ▸ Options checkbox,
   `ReconcileAgentPipe` so the toggle needs no restart, the status bar reading **"MCP Agent: On/Off"**
   in the panel that used to be the always-"UTF-8" encoding readout, and
   [AgentMcpSetup.md](Documentation/AgentMcpSetup.md) for users. Task 7 drove the whole
   create → build → read-errors → fix → run loop from a real MCP client (20 checks, all pass;
   `Primes below 1000000 = 78498`) and **found a real bug**: `run` never returned, because
   `Compile("Run")` blocks in `RunPr`'s synchronous `Shell()` until the launched program's terminal
   closes — which, with a keep-open terminal, is never. The agent path now builds plainly and
   launches from the finalizer; `run` returns in 0.1 s.
2. **Recent Projects became a dialog** (`src/frmRecentProjects.{bi,frm}`) listing file + path and
   skipping entries whose `.vfp` is gone.
3. **The Options panels**: the "When Ilwaco IDE starts" radio group removed with everything only it
   fed, and the Code Editor page grouped **Display / Editing / Completion / IntelliSense / History**.
4. **`Show Holiday Frame` → `Show Indent Guides`, done as a feature.** Astoria only relabelled the
   caption while the checkbox still drove a seasonal decoration; Ilwaco deleted the decoration and
   implemented real indent guides in `EditControl.PaintControlPriv`. **The menu-taxonomy cluster
   `49ec5ccd`/`37ba31ea` is COMPLETE.**
5. **`b9735e8e` — the workspace replaces `.vfs` sessions.** `SaveWorkspace`/`LoadWorkspace` write
   `Settings/Workspace.ini` (BOM-less, paths relative to the exe, gitignored) on close and restore it
   on start; the whole Sessions UX is gone. `CloseSession` was never about `.vfs` files — it is the
   batched save-prompt run before the IDE will exit — so it was **renamed `CloseWorkspace` and kept**,
   and that prompt was re-verified against a modified tab.
6. **`cc9e7dd5` classified N/A**, with evidence rather than assumption: two GUI projects opened in one
   session both render their form in the designer and the Toolbox populates — closing **TestPlan T3**,
   which had stood unrecorded since the plan was written. The MFF library manifest was pruned to the
   one variant that ships.

**Everything is committed and pushed** (through `2ab9c4f`); the working tree is clean and
`python3 Tools/DocCheck.py` is green.

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

## NEXT — resume the changelog walk at the `13.3.A` approachability passes

**`e5e10808` is classified (2026-08-06)** — see [AstoriaParity.md](Documentation/AstoriaParity.md).
It was mostly INVERT/SKIP (its `Slash`→`WindowsSlash` sweep flips Ilwaco's already-correct `/`
direction) and its headline Edit-menu "flat checkmark toggles" are **superseded by `4a112089`**
(further down this same backlog, which moves those settings off the Edit menu into Options) — Ilwaco's
menu is already in that post-reversal shape, so the toggles were not built. One durable bug was
**ported**: `GetFileName`'s no-extension truncation, which corrupted dot-less project-folder names at
Rename Project.

**Start here:** the `13.3.A` approachability passes (`0eaa8806`, `93bbfa28`, …). The pruned backlog
with the walk order is [AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md);
classify each item in [AstoriaParity.md](Documentation/AstoriaParity.md) as you go, and skip the pure
GTK/Linux/32-bit stripping commits (`e139c2cc`, `c494207f`, `7baebd1e`, `add4642a`, `76abaa5a`,
`15e66cc5`). When you reach **`4a112089`**, wire `ParameterInfoShow` up (INI load, the
`If Not ParameterInfoShow Then Exit Sub` gate, the Options checkbox) — it is a latent global in Ilwaco.

**Method that has been working:** read Astoria's commit *and* what its code actually does before
classifying — this session `e5e10808`'s headline feature turned out to be reversed 47 commits later
(`4a112089`), so scoping against Astoria's *final* state avoided building UI only to tear it out; and
twice before, the commit message and the shipped behaviour disagreed (`Show Indent Guides` was only a
relabel; `OpenProjectTemplate` is dead code). Build with `./build-linux.sh editor` in the background,
verify on `:0`, then document and commit per item.

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
- **Intermittent startup/shutdown SIGSEGV** is a known Astoria-fixed threading issue — don't chase it as a
  new regression (memory `project-known-segfault-threading`).
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
