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

## ⚠️ IN PROGRESS (2026-08-04) — `frmNewProject`: builds and renders, **create path NOT verified**

**Read this before touching New Project.** The dialog is new (`src/frmNewProject.{bi,frm}`, registered
in `ilwaco.vfp`, included from `Main.bas`) and `NewProject()` now calls it instead of the old
templates browser. It **builds clean and renders correctly** — pick-only *Project type* combo, no
icons, *Project name* row, OK/Cancel.

**It is not finished.** Clicking OK reported *"Selected folder exists, change the project name!"* on a
path that `Form_Create` had just chosen as the first free `ProjectN`. Not diagnosed. Suspects, in
order: (a) `Form_Create` runs once, so after a failed OK the offered name is stale; (b) `GetFullPath`
disagreeing between the two checks; (c) the folder genuinely existing from an earlier run. **Check
the filesystem first** — `ls /tmp/newprojtest` (or whatever `ProjectsPath` is set to) — before
changing any code. Nothing about the create path has been observed working end to end.

**What the dialog does when it works:** copies `Templates/Projects/<Type>/` into the chosen folder,
copies `<Type>.vfp` straight to `<FolderName>.vfp` (no rename step — FB's `Name` fails silently, see
Main.bi), then rewrites the manifest to strip the `<Type>/` path prefix, because the template's paths
are relative to `Templates/Projects` and the copied files land at the top of the new project folder.

**Design decisions already made (owner):**
- No icons; a pick-only combo, matching Astoria's current dialog.
- An explicit **whitelist**, not "everything in the folder": GUI Application (default), Console
  Application, GTK Application, Dynamic Library, Static Library, Control Library. **Windows
  Application, Android Project, Addin Project and Empty Project are deliberately not offered** —
  a Win32 GUI app cannot work on this build. Their template files are still on disk; deleting them
  is an open question.
- Not ported from Astoria's current dialog: the Author and License fields, and its "no
  auto-generated project name" rule. Ilwaco still pre-fills the first free `ProjectN`.

---

## ✅ DONE (2026-08-04) — project templates: BOM fix + default file renamed to `Main`

**Every shipped template source began with a UTF-8 BOM**, which makes FreeBASIC compile string
literals **wide**: the file builds clean and then prints UTF-32 bytes. Measured directly — the same
two-line program with and without a BOM printed `hello world` vs
`h^@^@^@e^@^@^@l^@^@^@...`. So every project created from a template, and every file added via
*Add Form* / *Add Module*, started out printing garbage. Stripped from all 9 sources under
`Templates/Projects` and all 7 under `Templates/Files`.

**Default module/form renamed to `Main`** (owner directive, matches Astoria): `Module1.bas`,
`Form1.bas` and `UserControl1.bas` → `Main.bas`; `Form1.frm` → `Main.frm`. The declared type went
with it (`Form1Type` → `MainType`), plus the `.rc` references and every `.vfp` manifest's `*File=`
line. `.vfp` manifests keep their BOMs — the IDE writes one back on save, so stripping them is churn.

**Still BOM'd and deliberately left:** `Examples/` — 93 of 111 sources. Owner: fold into the
deferred Examples work so that directory is touched once (see NEXT).

---

## NEXT — finish the menu-taxonomy cluster

**The Close Project crash is FIXED (2026-08-04)** — it was an MFF bug (`TabControl.DeleteTab` left a
surviving `TabPage`'s `_Label` pointing at a finalised GTK widget), not the close path. `Rename
Project` and `Delete Project` were blocked by it and are now verified working. Diagnosis, including
how the fault address was recovered from a core dump with no debugger installed, is in
[Controls.md](Documentation/Controls.md) and [TechnicalDebt.md](Documentation/TechnicalDebt.md).


- **The path-case cluster is closed (2026-08-04)** — all three findings fixed and live-verified; see
  TechnicalDebt "Paid down". The cosmetic breakpoint-line report turned out to be a *symptom* of the
  path-case bug (an empty tab conjured from the bad path), not a separate defect, proven by an A/B
  against the pre-fix binary. `EqualPaths` is now a direct comparison with its Win32-isms removed.
- **Menu-taxonomy cluster `49ec5ccd`/`37ba31ea` — partly done (2026-08-04).** Owner directive: *"make
  the menu system as close to Astoria as possible; later changes will fill in the blanks — same with
  the options panels, except cases like the debug flag entry we've already decided to keep."*
  **Done + verified:** the label pass (status bar "Press F1 for help", `Format`→`Designer`,
  "Not Set", "Clear Output"/"Clear Immediate", `tbDebug.Name`, numbered `Untitled1/2/…`, Goto
  "Go to line:", and the Find dialog's cryptic `Aa`/`W`/`.*`/`<`/`>` buttons relabelled); the
  **File-menu restructure** to Astoria's project-first taxonomy; **Open Project** exposed (Ilwaco had
  the handler with the menu item commented out); `Rename Project` + `Delete Project` added, the latter
  reimplemented for Linux (`rm -rf`, path-guarded) — both **verified working** once the Close Project
  crash was fixed. The Rename dialog's `InputBox` title/prompt were swapped and its default carried
  the `.vfp` extension into what becomes a folder name; both corrected, and MFF's `InputBox` gained a
  **Cancel** button (it offered only OK).
  **In progress:** `frmNewProject` — see the handoff section above; its create path is unverified and
  is the FIRST thing to pick up. **Still to port:** `OpenProjectTemplate`/`Recent Project`; the Options panels
  (remove the "When the IDE starts" radio group, Code Editor grouping into Display/Completion/
  IntelliSense/History); and `Show Holiday Frame` → `Show Indent Guides`, which is a *feature* port
  needing real indent-guide rendering in `EditControl`, not a relabel.
  Skip the pure 32-bit/GTK-strip entries (`e139c2cc` etc.). All owner directives (32-bit, UTF-8/LF,
  AI, English-only) remain cleared.
- **Examples work — deferred to just before the testing phase (owner).** The two Astoria Examples
  items (`4bd02894`, `51441d7a`), **plus a BOM sweep**: 93 of 111 sources under `Examples/` start
  with a UTF-8 BOM, which makes FreeBASIC compile their string literals wide, so they build clean and
  then print UTF-32 bytes. Measured 2026-08-04; the same defect was fixed in `Templates/` at the
  time. Do all three together so `Examples/` is touched once.
- Unverified, low priority: **Ctrl+F5 did not resume** a stopped debuggee during this session's driving. May
  be an artefact of synthetic input rather than a defect — check by hand before treating it as a bug.

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
- **Packaging/shim:** the dev shim has `libtinfo.so.5` but no `libncurses.so`, so fbc's *default* console
  link fails here. Work around it per-project with `CompilationArguments64Linux="-p <shim> -l tinfo"` — the
  IDE then compiles, links and debugs a console project end-to-end (verified 2026-08-04). Add a
  `libncurses` dev symlink when building the AppImage. AppImage packaging itself is still open (memory
  `project-packaging`).
- **GTK dark mode (REIMPLEMENT):** MFF ships a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was only
  ever set by the deleted Win32 `InitDarkMode`, so the dark-styling branches never fire on GTK. Track with
  Astoria's dark-mode commits (`56f6d180`/`b3633bc5`/`a7c7839d`).
- `UseDebugger=false` by default. GDB is gone — the Integrated engine needs no external debugger.
