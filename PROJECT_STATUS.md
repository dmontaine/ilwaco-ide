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

---

## ✅ DONE (2026-08-04) — left/right panel collapse: vertical-text rail + pin-repaint fix (UNCOMMITTED, verified)

Owner asked to make the **left/right tool panels collapse and reopen** with a **visual** affordance (not a
menu), and refined it to **look like Astoria's collapsed strip**: a thin **vertical-text** tab strip with a
**pin at the top**. Delivered as a **GTK REIMPLEMENT**. On collapse the panel is hidden entirely and a
separate 34px **rail** appears at the edge: a pin icon at top (re-expands to the last tab) above the tab
captions as **rotated vertical text**. **Both LEFT and RIGHT work, live-verified.** Full detail + the
hard-won GTK/MFF facts live in [AstoriaParity.md](Documentation/AstoriaParity.md) "Done 2026-08-04 —
left/right panel collapse via a vertical-text activity rail".

**State: COMPLETE, build-clean (`fbc` exit 0), UNCOMMITTED** on `bbd8ab0`. Changed files: `src/Main.bas`
+ `src/ilwaco.bas` (the `ilwaco` binary + `src/ilwaco.{asm,c}` are build byproducts — do not commit).
Verified live on `DISPLAY :0` by screenshot: each panel collapses to a vertical strip (pin icon above
rotated `Project`/`Toolbox` and `Properties`/`Events`); the pin re-expands to the last tab; each text
button re-expands and selects its tab; the **expanded-panel pin repaints after reopen** (the reported bug —
fixed); and both strips show **collapsed at startup** with `LeftClosed=true`/`RightClosed=true`. Additive
to MFF → no `.so` rebuild.

**Key implementation points (`src/Main.bas`):** the rail is text-only because MFF renders no icon on a
`CommandButton`/`Label` on GTK and rotates no toolbar text (owner chose vertical-text-only over a
custom-raw-GTK icon+text rail). Pin = one-button `ToolBar` with `gtk_toolbar_set_show_arrow(…,FALSE)`
(reuses the `PinLeft`/`PinRight` command). Tab buttons = `CommandButton`s with caption rotated via
`gtk_label_set_angle(gtk_bin_get_child(…),90/270)` (`RotateRailButton` helper), `.Designer=@frmMain` set,
`OnClick` handlers (`railLeftProjectClick` etc.). **Pin-repaint fix:** `Show{Left,Right}` now call
`gtk_widget_show_all(pnl…Pin.Handle)` + `gtk_widget_queue_resize(overlay…)` so the overlay pin remaps and
repaints. `Get…ClosedStyle → Not pnl….Visible`. `ilwaco.bas`: `Pin{Left,Right}` one-liners.

**Supersedes** the deferred `e212819d`/`ef3b43e9` left/right *persistence* item (save/load already works
via `Get…ClosedStyle` → `LeftClosed`/`RightClosed` INI keys + `frmMain_Create` re-apply). The **bottom**
panel keeps the old collapse-to-strip behaviour and its persistence is still deferred.

**NEXT:**
1. **Commit** `src/Main.bas` + `src/ilwaco.bas` + the two docs (message: vertical-text panel-collapse rail
   + pin repaint; not the binary, per precedent) — *only when the owner asks.*
2. **Optional hygiene:** `tab{Left,Right}_SelChange`/`_Click` and the focus-loss auto-collapse still carry
   dead `TabPosition = tp{Left,Right}` / `Width = 30` guards (can no longer be true); a `no-dead-code`
   pass can drop them. Rail button heights (84/96px) and rotation angles are tuneable if the text looks off.
3. **Resume the changelog walk** (see the session-handoff section below): bottom-panel *persistence*
   (`e212819d`/`ef3b43e9`), then `4bd02894`, then the `49ec5ccd` menu-taxonomy cluster.

**Test caution:** kill by PID (`pkill -x ilwaco`), `git checkout Settings/` after any launch, screenshots
via `scrot` on `DISPLAY=:0`, clicks via `xdotool`. **The Claude desktop app steals focus** — re-activate
the IDE with `xdotool windowactivate --sync $(xdotool search --name "Ilwaco IDE" | head -1)` before each
click, and verify `getactivewindow getwindowname` is the IDE. Display is 2560×1340 (screenshots come back
2000-wide → coords ×1.28). Collapsed rail buttons (real coords): left pin ≈(17,135), Project ≈(17,225),
Toolbox ≈(17,305); right pin ≈(2543,130), Properties ≈(2543,230), Events ≈(2543,305).

---

## ✅ DONE (2026-08-04) — documentation-maintenance apparatus + Astoria doc-set analogues (UNCOMMITTED)

Ported Astoria's document-maintenance discipline to Ilwaco, **adapted for Linux/GTK**, and gave every
file in Astoria's `Documentation/` folder an Ilwaco analogue. **The rule now has teeth:** a checker
catches doc drift, a skill says what to update when, and CLAUDE.md points at both.

- **`Tools/DocCheck.py`** — Astoria's checker, Linux-adapted and trimmed to 3 checks: (1) a doc names
  a *removed* feature as if it ships (`REMOVED_FEATURES` seeded with Ilwaco's removals), (2) a doc
  names a deleted file in inline code, (3) a maintained doc is missing from the rule table. Dropped
  the Windows-only bits (Chrome-PDF/`.txt` freshness, PowerShell changelog, `ROADMAP.md` §-check);
  file-suffix set is Linux (`.so`/`.sh`). Fixed a case-sensitivity bug in the FS fallback. **Green:**
  `python3 Tools/DocCheck.py` → "Documentation is current (10 documents checked)"; `--selftest` OK.
- **`Documentation/TestPlan.md`** — carries **the rule table** (which doc to update when) that
  `DocCheck` enforces, plus the current (thin) test scenarios and the Linux verify-by-effect method.
- **`.claude/skills/update-ilwaco-docs/SKILL.md`** — the trigger table as a skill (now registered).
- **`CLAUDE.md`** — Working practices now require `DocCheck` before commit and fold docs into "finish
  the whole job"; `update-ilwaco-docs` moved from pending to shipped.
- **Doc analogues** (all listed in the rule table): real content — `UpstreamFixes.md`,
  `TechnicalDebt.md`, `Testing.md`, `ControlTesting.md`, `IlwacoIDESignificantChanges.md`; honest
  scaffolds (purpose + Astoria source + "GTK review needed", per owner's choice) — `Controls.md`,
  `MyFbFrameworkGuide.md`, `FrameworkFeatures.md`, `IlwacoIDEManual.md`; plus root `CHANGELOG.md`.
  `AstoriaParity.md` + `AstoriaDetailedChangeLog.md` are excluded from `DocCheck` as historical
  records (like Astoria excludes its `DetailedChangelog`).

**NEXT:** commit when asked (all uncommitted). Fill the scaffolds as their subjects stabilise. Keep
`DocCheck` green — it runs on Documentation/*.md and is the pre-commit gate now.

---

## Session handoff (2026-08-03, earlier) — changelog walk + debug-tab visibility ported

**START HERE.** Continued the Astoria→Ilwaco changelog walk from the oldest entries in
[AstoriaDetailedChangeLog.md](Documentation/AstoriaDetailedChangeLog.md). Resolved 5 entries (backlog
**401 → 396**) plus one sub-item pulled forward. Committed+pushed: first three (doc-only) `72a741b`,
`53d8e473` `c087255`, `4cf72752` `c8c9ce7`, doc-clarification `e09fa37`. The debug-tab-visibility work
(below) is source+docs, build+runtime-verified, **staged/uncommitted** at time of writing.

- **Debug-tab visibility** (`49ec5ccd` sub-item, pulled forward at owner's request) — **DONE,
  build+runtime-verified.** The 7 debug tabs (Locals…Profiler) now show only when `UseDebugger` is on
  (Immediate stays permanently visible). Required a new **MFF `DetachTab`** method (remove a tab without
  destroying its `TabPage`, with a GTK `g_object_ref` so the page widget survives re-add) + three subs +
  4 call sites in `Main.bas`. Verified both states by screenshot (off → tabs hidden; on → re-appear, no
  crash). Additive/non-virtual MFF change → no `.so` rebuild. This is **distinct** from `4cf72752`'s
  content-*clearing*. See AstoriaParity "Done — debug-tab visibility". `49ec5ccd` stays in the backlog
  (only this sub-item is done; the menu-taxonomy bulk remains deferred).

- **`4cf72752`** (WIN32_WINNT header bug + bottom-panel tab clearing) — **PORT (partial), DONE.** The
  `_WIN32_WINNT` `=`→`>=` header fix is N/A (Windows headers, not on the GTK build path); the AI-KnowledgeBase
  path fix is N/A (AI removed). Ported the **bottom-panel/debug tab clearing**: new `ClearAnalysisPanels`/
  `ClearDebugPanels` in `Main.bas`, wired into `CloseProject` + the debug-`End` case in `ilwaco.bas`, so
  stale project/debug results don't linger after a project closes. Forward-declared `ClearThreadsWindow` in
  `Main.bi`. Build clean (`fbc` exit 0); IDE launches, all 14 bottom tabs render. See AstoriaParity
  "Done — bottom-panel/debug tab clearing (`4cf72752`)".
- **`53d8e473`** (Fix all compile warnings) — **PORT (partial), DONE, committed `c087255`.** Ilwaco's
  production build was already warning-clean; most of Astoria's fixes targeted already-stripped code (Canvas
  Direct2D, Debug `SetConsoleTitle`) or don't reproduce. Ported the 2 `@literal→WString Ptr` hunks in
  `src/Debug.bas` (`brk_comp`, `list_all` → `WStr(...)`).

- **`bbfa3999`** (Initial Win64 fork import) — the fork anchor / base snapshot itself, not a port. Pruned.
- **`5a097399`** (Update INI window-state + rebuild exe) — NONCODE (Settings + binary only). Pruned.
- **`bef92671`** (Form Designer never activating) — **REVIEW → N/A, verified.** Astoria's designer was dead
  because *its own* `strip_gtk_preprocessor.ps1` deleted the `#ifdef __EXPORT_PROCS__` blocks from MFF,
  shipping `mff64.dll` with zero exports. Ilwaco never ran that tool; our `ppstrip.py` preserved every
  such block. **Proof:** `libmff64_gtk3.so` exports 469 symbols and *all 36* dispatchers that
  `src/Designer.bas` resolves via `DyLibSymbol()` are present (`nm -D` diff empty). Full narrative +
  re-runnable verify command in AstoriaParity "N/A — Form Designer export table intact".
- **Kept (partial):** `e212819d` + `ef3b43e9` — the bottom-panel **persistence** cluster (collapse half
  already DONE 2026-08-02; persistence still deferred — needs the panel-state save/restore infra).

**NEXT — continue the walk. The two persistence entries are the oldest remaining; after them:**
1. `e212819d` / `ef3b43e9` — bottom-panel **persistence** (deferred infra: save/restore collapsed panel
   state across sessions; see AstoriaParity "Deferred, split out: bottom-panel persistence").
2. `4bd02894` — add missing example `.vfp` files + "no unnecessary options" principle + Examples audit
   (REVIEW — the `.vfp` additions may be Windows-example-specific; the guiding principle is already ours).
Then the menu-taxonomy feature ports (`49ec5ccd` cluster). All owner directives (32-bit, UTF-8/LF, AI,
English-only) remain cleared.

**Repo-hygiene note:** the tracked `./ilwaco` binary drifts from source — `c087255` committed source
without rebuilding it, and source commits generally omit the 4.6 MB artifact. Consider `.gitignore`-ing the
built binary (it rebuilds via `./build-linux.sh editor`) rather than tracking a perpetually-stale blob.

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
