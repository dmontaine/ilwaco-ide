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
couldn't, and why), and [CLAUDE.md](CLAUDE.md) (orientation for the Linux/GTK build). Still to be created
as work proceeds: `CHANGELOG.md` (milestones) and `Documentation/UpstreamFixes.md` (our GTK fixes useful
to VisualFBEditor upstream, where Astoria's Win64-only ones cannot apply).

**Keep this file pruned.** It holds only the **most-recent session handoff**, the **NEXT** actions, and
the **standing facts** below — not an archive. When a session's work is done and committed, move its dated
narrative section to [HISTORY.md](HISTORY.md) (newest-first) instead of letting handoffs pile up here.
`python3 Tools/DocCheck.py` flags this file once more than two dated session sections accumulate; see
CLAUDE.md "Working practices".

---

## ✅ DONE (2026-08-04) — bottom-panel collapse: dedicated rail (BUILT + LIVE-VERIFIED)

Finished `e212819d`/`ef3b43e9` (bottom-panel collapse + persistence). The collapsed-panel affordance is a
**horizontal activity rail** mirroring the left/right rails: on collapse `pnlBottom` is hidden and a 25px
`pnlBottomRail` (`alBottom`) is shown — a **pin at the right** plus **14 tab buttons** (`Output..Immediate`
always; `Locals..Profiler` only with the debugger on). **Live-verified on `:0` by the owner.** Full detail
+ the GTK/MFF facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 —
bottom-panel collapse via a horizontal activity rail". Changed `src/Main.bas` + `src/ilwaco.bas`
(the `ilwaco` binary is a build byproduct — not committed, per precedent).

**What landed (beyond the WIP `a8300e9` scaffold):**
- **Pin repaint on reopen** — `ShowBottom` calls `gtk_widget_show_all(pnlBottomPin.Handle)`.
- **Pin stays put** — rail pin docked `alRight` (was `alLeft`, which jumped on collapse).
- **Debug buttons carry to the rail** — `CloseBottom` re-asserts `btnBottomRail(7..13).Visible = UseDebugger`
  + `pnlBottomRail.RequestAlign` (MFF `show_all` un-hides all children and never sized the debug buttons
  while hidden); `SetDebugTabsVisible` re-aligns the rail live when it's already collapsed.
- **Rail pin unclipped** — a `GtkCssProvider` scoped to a `.ilwacorailpin` class trims GtkToolbar's
  min-height/padding so the 16px pin fits the 25px strip (`gtk_widget_set_valign` pushed it *down* — not used).
- **Debugger toggle desync fixed** (surfaced here) — `ilwaco.bas` `"UseDebugger"` now reads GTK's real
  post-click state (`gtk_check_menu_item_get_active`) instead of MFF's stale `Checked`, and
  `ChangeUseDebugger` only re-sets the menu check when it differs (avoids priming MFF's activate-guard).
  One symmetric click each way (was "twice to enable, once to disable").

**Persistence** (`BottomClosed` INI key via `GetBottomClosedStyle` + `frmMain_Create`/`_Close`) already
round-tripped and is unchanged. **The reflow concern is resolved** — the editor reclaims the freed vertical
space on collapse (the rail approach mirrors left/right, whose reflow was fine).

---

## NEXT — continue the changelog walk

`e212819d`/`ef3b43e9` (bottom-panel collapse **and** persistence) are **DONE** (see above). The two
**Examples items** (`4bd02894` audit + "no unnecessary options"; `51441d7a` Graphics-example fix) have been
**moved out of chronological order to just before the testing phase** (owner, 2026-08-04) — they now sit
just above `91110174` in
[AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md), to pair with the control-testing /
TestPlan work. So the next actionable ports are the post-bottom-panel code entries — `5fa5cf25` (remove the
alt-compiler-backend / debugger-choice code, aligns with the one-compiler directive) and the
**menu-taxonomy cluster** (`49ec5ccd`/`37ba31ea`); skip the pure 32-bit/GTK-strip entries
(`e139c2cc` etc.). All owner directives (32-bit, UTF-8/LF, AI, English-only) remain cleared.

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

**Build / run (self-contained — shim is vendored).**
- Build: `./build-linux.sh` — `editor` | `lib` | `all`.
- Run: `LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`.
- Source `src/ilwaco.bas` → binary `./ilwaco`; designer lib `Controls/MyFbFramework/libmff64_gtk3.so`
  (rebuild with `lib` or the toolbox errors); settings `Settings/ilwaco.ini`.
- The shim is now **fully in-repo**: `Compilers/shim/libtinfo.so.5` + the GTK `-dev` symlinks under
  `Compilers/shim/gtk-dev/` — no per-session scratchpad shim needed. `build-linux.sh` wires them up.
- A whole-program editor compile is ~3–4 min — run it in the background (a 2-min foreground limit kills it).

**Operational cautions.**
- **`git checkout Settings/` after any IDE launch** — it writes window/session state into `ilwaco.ini` on exit.
- **`pkill -f ilwaco` matches its own caller** — use `pkill -x ilwaco` or kill by PID.
- **Intermittent startup/shutdown SIGSEGV** is a known Astoria-fixed threading issue — don't chase it as a
  new regression (memory `project-known-segfault-threading`).
- Harmless startup warnings: resources `AppAddin`/`AppConsole` "do not exist".

**Known gaps (tracked, not blockers).**
- **Packaging/shim:** the dev shim has `libtinfo.so.5` but no `libncurses.so`, so the IDE can't fully *link*
  a console user-project in this environment (fbc's default console link wants libncurses). Add a
  `libncurses` dev symlink when building the AppImage. AppImage packaging itself is still open (memory
  `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- **`gdb` not installed** here (debugger default won't resolve); `UseDebugger=false` by default.
