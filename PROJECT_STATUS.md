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

## ✅ DONE (2026-08-07) — Ilwaco ships three ways: `.deb`, `.rpm` and a no-root `.tar.gz`

Owner directive: ".deb and .rpm — between them they cover over 90% of the Linux market", then the
clarifying concern, "what about a user who wants to use Ilwaco but does not have root access". The
resolution is **two tiers chosen by one question — does the user have root**, documented for users in
the new [Installation.md](Documentation/Installation.md) and for maintainers in
[Packaging.md](Documentation/Packaging.md).

| user | artefact | root? |
| --- | --- | --- |
| own laptop | `.deb` (39 MB) / `.rpm` (47 MB) — double-click install, menu entry, `apt`/`dnf` upgrades | yes |
| managed school/work machine | `.tar.gz` (44 MB) wrapping the AppImage | **no** |

**The bare `.AppImage` is no longer offered.** It is shipped inside the `.tar.gz` because tar restores
mode 755 while a browser download is always 644 — so the no-root path needs **no `chmod`**, verified
by extracting and checking the bit. Offering both would invite a beginner to pick the dead-end one.

**One implementation of the writable-home problem.** A system package installs a *root-owned*
payload, and the IDE cannot run from a directory it cannot write to (`ExePath()` follows symlinks) —
the identical constraint the AppImage hit. So `Packaging/seed-app-home.sh` was factored out of
`AppRun` and is now shared by both routes; `/usr/bin/ilwaco` (`Packaging/ilwaco-launcher`) is a
12-line wrapper over it. `/opt/ilwaco-ide` holds only the immutable payload; every user still gets
their own `~/ilwaco-ide` with **no per-user configuration**.

**The two dependency traps, both real, both caught before shipping:**
- **RPM:** Fedora/RHEL call the GTK package `gtk3`, SUSE calls it `libgtk-3-0`, so a name-based
  `Requires:` reaches at most two of the three. rpmbuild's **SONAME** auto-requires
  (`libgtk-3.so.0()(64bit)`) satisfy all three — the auto-generated deps *are* the portability
  mechanism. But the generator had to be fenced off the bundled toolchain: `fbc` needs
  `libtinfo.so.5`, which we ship ourselves and Fedora does not install, so an unfenced scan would
  have baked in an unsatisfiable dependency and made the package refuse to install. Verified: the
  built RPM requires `libtinfo.so.6` (legitimate, the IDE's own) and no `.so.5`.
- **DEB:** `dpkg-shlibdeps` names packages as the *build host* has them, and Debian's 64-bit `time_t`
  transition renamed `libgtk-3-0` → `libgtk-3-0t64` (plus glib, atk) in Debian 13 / Ubuntu 24.04
  while **Debian 12, Ubuntu 22.04 and Mint 21 keep the old names**. Built here, the first `.deb` was
  uninstallable on half the targets. Each renamed dep is now rewritten to an alternative,
  `libgtk-3-0t64 (>= 3.16.2) | libgtk-3-0 (>= 3.16.2)`, modern name first.

**Reinstall safety — the owner's explicit requirement — proven, not asserted.** Planted a project and
a custom setting in a seeded home, then re-ran both the package launcher and the real AppImage over
it: `projects/` came back **byte-identical**, the custom setting survived, and a user-edited example
survived. It holds at three independent levels: neither package contains any path under a home
directory at all (checked), their scriptlets touch only desktop/icon caches, and the seed loop skips
anything that already exists. Uninstalling deliberately leaves `~/ilwaco-ide` behind.

**A display is now required, and said so politely (owner, 2026-08-07).** "Ilwaco should never be
installed on a headless system — I would prefer it fail gracefully with a message that a display is
required." Implemented at **launch**, not install: an install-time check would misfire on the
ordinary `sudo apt install` over SSH into one's own desktop, where `DISPLAY` is unset on a machine
that plainly has a GUI (owner agreed, install left alone). `Packaging/ilwaco.sh` now exits 1 with a
plain message when neither `DISPLAY` nor `WAYLAND_DISPLAY` is set, and every shipped route launches
through it. **The obvious in-binary guard does not work** — a check at the top of `src/ilwaco.bas`
never runs, because GTK initialises in a global constructor and FreeBASIC runs those before the main
module's statements; it was tried, measured as ineffective, and reverted rather than left looking
like protection. Detail in [TechnicalDebt.md](Documentation/TechnicalDebt.md).

**Verified by effect:** the `.deb` extracted to a scratch root, its launcher run from there → seeded a
correct home → **the IDE opened on `:0`** with IntelliSense loaded, and the `/opt` payload was
confirmed untouched afterwards. With no display the same launcher prints the message and exits 1. Glibc floor 2.34 gives Debian 12+, Ubuntu 22.04+, Mint 21+,
Fedora 35+, RHEL 9+, openSUSE Leap 15.5+. **Not yet verified: installing the `.rpm` on real Fedora**
— it is built and inspected only (see NEXT 1).

---

## ✅ DONE (2026-08-07) — user-data dir is lowercase `projects`; the seed-patch can no longer break launch

**The rename (owner directive: "keep 'projects' lower case").** Every producer and consumer moved
together, because Linux is case-sensitive and a half-rename means the IDE writes to one directory
while the packaging seeds another. Nine files: `Packaging/AppRun` (seed loop), `Packaging/ilwaco.sh`
(`mkdir`), `Packaging/StageRelease.sh`, `Packaging/installer-header.sh` (the upgrade `--exclude` — a
miss here would have made an upgrade **overwrite the user's work**), `Settings/ilwaco.ini`
(`ProjectsPath`, `CommandPromptFolder`), `src/Main.bas` (both INI-read defaults), `src/frmOptions.frm`
(two designer defaults), and the `ExePath & "Projects"` fallbacks in `src/TabWindow.bas` (×2) and
`src/frmImageManager.frm`. The dev tree's own `Projects/` was `git mv`'d. **`Templates/Projects/` was
deliberately left capitalised** — it is the shipped New-Project template store, not the user's work.

**Verified by effect at all three layers**, not just compiled: `AppRun` against a stub payload seeds
`projects/` and no capital `Projects/`; `ilwaco.sh` `mkdir`s `projects/`; and the **running IDE**,
asked over the MCP socket for a new project, answered
`/home/don/Projects/ilwaco-ide/projects/RenameProbe/RenameProbe.vfp` — so `ProjectsPath` resolves
lowercase through the real code path.

**One adjacent defect fixed while in there:** `src/ilwaco.bas:74` built its no-main-file fallback as
`*ProjectsPath & "\1"` — a **Windows** separator. `GetFolderName` never finds a `\` on Linux, so
Run ▸ command prompt opened in the exe directory instead of the projects directory. Now uses `Slash`.

**The seed-patch is insert-if-missing (was replace-only).** `ilwaco.sh`'s first-run patch rewrote only
*existing* keys and `die`d if one was absent — so any future rename or reorder of `Compiler64Arguments`
or the `[Compilers]` keys would have broken **launch**, not merely a build. The awk now appends a
missing key to its section, and a missing section to the file. Six fixtures pass (replace; insert into
an existing section; append an absent section; BOM on line 1 preserved byte-for-byte; our section last
in the file; and a same-named key in a *different* section left untouched).

**FUSE was measured and is not the problem people assume.** Our AppImage carries the modern static-pie
[type2-runtime](https://github.com/AppImage/type2-runtime) — `readelf -d` shows **no `NEEDED` entries
at all**, so the widely-repeated "AppImages need `libfuse2`" is about the *old* AppImageKit runtime, not
ours. It wants a `fusermount` **binary** (`fuse3`, present on desktop Debian 13), and
`APPIMAGE_EXTRACT_AND_RUN=1` works with `fusermount` deliberately broken. What remains is the
executable bit, which is a packaging-format decision — see NEXT 1.

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
   hardening, and the download question (now answered with three artefacts). See the DONE sections.
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
much further along.** Do not re-add it to the bottom pane.

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
