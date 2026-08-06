# Ilwaco IDE — working on the IDE itself

This orients an AI assistant working on **Ilwaco's own source**. Ilwaco is a 64-bit **Linux/GTK3**
IDE for FreeBASIC, the **VisualFBEditor** codebase, written in FreeBASIC on the MyFbFramework (MFF)
GUI library. Its Windows sibling is **Astoria** (`../astoria-ide`), a more-evolved fork of the same
base; the mission is to bring Ilwaco toward parity with Astoria, adapting Win32 → GTK.

## The mission, in one place

Astoria's history is the diff from the shared VisualFBEditor base. We **walk that changelog
oldest-first and translate each change into Ilwaco**, classifying each as PORT / REIMPLEMENT (GTK) /
INVERT-or-SKIP (Astoria's Win64-only stripping) / N/A / DONE. The resumable backlog is
[Documentation/AstoriaParity.md](Documentation/AstoriaParity.md). Hobby project, no deadline —
prefer durable scaffolding and build-verified changes over speed.

## Two rules that govern every change

- **No dead code, no commented-out code** (same as Astoria). Ilwaco is the **GTK build**, so
  **Windows-specific source is dead code and must be physically deleted** — the mirror image of what
  Astoria did (it deleted the GTK branches). When you touch a file, delete its pure-Windows
  `#ifdef __FB_WIN32__` / `#ifdef __USE_WINAPI__` branches (keep the GTK/`__USE_GTK__`/else branch),
  and remove commented-out cruft. Do it incrementally, build after each pass — not one giant sweep.
  **Read each conditional first:** `_NOT_AUTORUN_FORMS_`, `__USE_GTK3__`, and many `#if Not (…WIN32…)`
  guards are *not* Windows-only.
- **Opinionated by design.** Where there is a clearly better answer, make the choice once and
  **remove the option** — one bundled compiler, no compiler picker, etc. Astoria's
  `AstoriaIDESignificantChanges.md` §2 (features removed) is the guide. Note: the settings parser
  crashes if the `[Compilers]` INI block is *restructured*, so "remove the picker" means editing the
  parser, not just the INI (see PROJECT_STATUS).

## Read these first

| Document | What it is |
| --- | --- |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | The authoritative handoff. Current state, in-flight, next. |
| [Documentation/AstoriaParity.md](Documentation/AstoriaParity.md) | The port backlog: every Astoria change, classified, with the next action. |
| `../astoria-ide/Documentation/AstoriaIDESignificantChanges.md` | Curated "how Astoria differs from VisualFBEditor" — the high-level backlog order. |
| `../astoria-ide/Documentation/DetailedChangelog.md` | Every Astoria change; `git -C ../astoria-ide show <hash>` for the diff. |
| `../astoria-ide/Documentation/UpstreamFixes.md` | Astoria's fixes offered upstream. Ilwaco keeps GTK, so **our** GTK fixes belong in our own `Documentation/UpstreamFixes.md` (to be created). |

## Building (Linux, from-source)

The full recipe and its rationale are in PROJECT_STATUS. In short, using the in-repo bundled compiler
`Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc` plus a userspace shim (Debian 13 lacks
`libtinfo.so.5` and the GTK `-dev` symlinks — no sudo needed):

- Editor (whole-program; output path set by a `#cmdline` in the source):
  `cd src && fbc ilwaco.bas -i ../Controls/MyFbFramework -d __USE_GTK3__ -p <shim> -l tinfo`
  → `ilwaco` (~5 MB, needs only GLIBC_2.34).
- Designer control library (or the toolbox errors at runtime):
  `cd Controls/MyFbFramework/mff && fbc -b mff.bi -dll -x ../libmff64_gtk3.so -d __USE_GTK3__ -p <shim> -l tinfo`

Each whole-program compile is ~3–4 min — run it in the background (a 2-min foreground limit will kill
it). Launch on the live X display with `LD_LIBRARY_PATH=<shim> DISPLAY=:0`; the spawned fbc inherits
the shim so the IDE can compile user projects. **Verify by effect** (window opens, no error dialog),
not by "it compiled". A durable `build-linux.sh` + vendored shim is an open infra task.

## Skills

`.claude/skills/` holds the platform-neutral FreeBASIC/MFF skills brought over from Astoria (renamed):
`add-form`, `add-module`, `add-control-event`, `add-resource` (pending), `edit-form-safely`,
`find-framework-control`, `fix-compile-errors`, `refactor-freebasic`, `debug-freebasic-app`,
`audit-project-manifest`, `update-ilwaco-docs` (the doc-maintenance rule — see below). **Pending
Ilwaco rewrites** (Astoria's shipped as Windows-process and would be *wrong* here): `build-ilwaco`
(Linux build above), `verify-ilwaco-behaviour` (drive the GTK build over `:0` with `wmctrl`/`scrot`),
`release-ilwaco` (AppImage — see below), and a `gtk-interop` to replace `winapi-interop`.

## FreeBASIC traps that apply here (compiler-level, not Win32)

- **UTF-8 BOM makes string literals wide** — a BOM'd source compiles then prints garbled text. Keep
  files BOM-less UTF-8. Do not write BOMs.
- **`ReDim Preserve` relocates the array**, so a pointer taken into it beforehand (`@a(0)`,
  `@List.Item(i)`) is stale after a growth.
- **A parameter is `ByRef` unless you write `ByVal`.** A routine that reassigns its argument writes
  through to the caller; if the caller passed a field the routine also mutates, the parameter ends up
  aliasing freed memory. Check every `ByRef` against the fields the routine writes; fix in the callee.
- **`IIf`'s two branches must be the same string family** — it will not implicitly convert between the
  narrow family (`String`/`ZString`/bare `"literal"`) and the wide one (`WString`/`WStr(...)`);
  mismatch is `error 24`. It short-circuits, so `IIf(p=0, 0, p->Field)` null guards are real.
- `Str(a = b)` yields `0`/`-1`, not `"false"`/`"true"`; `Str()` of a real `Boolean` gives the words.
- A local `Dim` is **procedure-scoped**, not block-scoped — deleting an `If` block can strand a name.
- **Identifiers are case-insensitive**; watch collisions with keywords (`Name`, `Step`, `Ok`, `out`,
  `pos`, `value`, `line`, `msg`, `val`).
- **A `UString` passed to a `ZString Ptr` parameter is silently truncated to its first character.**
  MFF's `UString` has a `Cast() As Any Ptr`, so it binds to a narrow-pointer parameter by handing over
  the raw *wide* buffer — read as a narrow string it ends at the first zero byte. FreeBASIC's
  `FileCopy` is declared that way, which is why copies "succeeded" while doing nothing (returning 1).
  `&` concatenation propagates it: a `&` with a `UString` operand yields a `UString`. **Use the
  `FileCopy_` wrapper, never `FileCopy` directly**; for any other such API pass a `WString` and let the
  compiler narrow. Suspect this whenever a copy/open of a correct-looking path silently does nothing.
- **`FreeFile` does not reserve its number**, so `ff = FreeFile` + `Open … As #ff` is not atomic and
  races (surfaces as a bogus *"Could not find include file"*). Prefer the project's guarded open
  helper for source/include reads.
- **Wiring an event onto an MFF control that never had one? Set `.Designer` first** — controls
  dispatch as `OnClick(*Designer, This)` and dereference it; assigning `.Checked`/`.Text` in code
  *fires the handler*. Copy the shape from a control in the same form that already works, and match
  the handler signature to the control type.

## Working practices

- **Menu variable names lie** — read the caption in the `Add(...)` call, not the variable. The
  original author used Uzbek keys (`miXizmat` = "Service"). Astoria renamed several menus; check
  AstoriaParity before telling anyone where a command lives.
- **Do not edit a file on disk while the IDE has it open** — it holds its own copy and will prompt to
  reload; a dirty tab competes with your edit.
- **Update the documents after any change that makes one wrong** — especially PROJECT_STATUS and
  AstoriaParity. A *removal* leaves nothing to trip over, so it is the easiest drift to miss.
  [Documentation/TestPlan.md](Documentation/TestPlan.md) opens with a table of **which document to
  update when**; the `update-ilwaco-docs` skill is how to satisfy it, and **`python3 Tools/DocCheck.py`
  before you commit** is what catches it being skipped (it flags a doc naming a removed feature or a
  deleted file, a maintained doc missing from the rule table, or **PROJECT_STATUS carrying too many
  finished session sections**). On a *removal*, also add a line to `REMOVED_FEATURES` in
  `Tools/DocCheck.py`. (Ilwaco drops Astoria's Windows-only doc machinery: no Chrome-PDF/`.txt`
  companions, no PowerShell changelog, no `ROADMAP.md` §-check.)
- **Keep PROJECT_STATUS pruned — it is a handoff, not an archive.** It holds only the most-recent
  session handoff, the NEXT actions, and the standing facts. When a session's work is done and
  committed, **move its dated narrative to [HISTORY.md](HISTORY.md) (newest-first)** rather than
  stacking handoffs. `DocCheck` (check 4) flags PROJECT_STATUS once more than two dated session
  sections accumulate, so this stays a regular habit.
- **Finish the whole job, not the code.** A change is done when it builds, its effect has been
  observed, PROJECT_STATUS + AstoriaParity match it, and `DocCheck` is green.

## Git sync — this repo is worked on from multiple sandboxes that reconcile ONLY through `origin`

Each session runs in its own snapshot/VM copy of the repo; GitHub `origin` is the only shared state.
A session once started against a 2-day-stale snapshot and unknowingly redid a full day of already-pushed
work. So:

- **Pull at the start of every session.** A `SessionStart` hook in the committed `.claude/settings.json`
  runs `git pull --ff-only`. If it didn't run (added mid-session, or a fresh checkout), `git fetch &&
  git status` and reconcile **before** doing any work — never assume `local == origin`.
- **Push only on the owner's signal — never after every commit or on your own initiative.** The signals:
  **end of every major task** (owner asks); **end of session**, phrased **"document, commit, push"** — do
  all three in order (update PROJECT_STATUS / affected docs, commit, push); and as a **fallback**, if the
  owner says they've **run out of credits** or that a **handoff** is happening, push then too. Before any
  push, `git fetch` and confirm a clean fast-forward (`git merge-base --is-ancestor origin/main HEAD`).
- **Commit** to capture completed, verified work is fine (it doesn't touch `origin`); the *push* is what
  waits for the signal.

## Working practices — delegation & build verification

- **Delegate mechanical work to a Sonnet subagent** (Agent tool, `model: "sonnet"`) to save the owner's
  credits — standing authorization on this hobby project. Keep *judgment* on Opus (scope against Astoria's
  final state, map the full reference set, make product calls); hand Sonnet a *precise, pre-specified* edit
  set with exact files/lines. **The worker never runs the build — it returns to Opus for compilation**
  (the Linux toolchain shim is non-trivial to load; **retain the shim, never delete it**).
- **Build-verify without false "green":** run `./build-linux.sh …` from the repo root **in-line** (the
  Bash tool's cwd persists between calls) and capture `$?` from a redirect — `> log 2>&1; echo $?` — never
  from a `… | tail`/`grep` pipe, whose exit code masks a build failure. The whole-program compile is
  ~3–4 min: background it. **Don't `pkill -f ilwaco`** (it self-matches the caller) — use `pkill -x ilwaco`
  or kill by PID; `git checkout Settings/` after any launch (the IDE writes session state on exit).

## Product standard

A feature either works or does not ship — a broken menu item costs a beginner (our audience: teachers,
students, hobbyists) more than a missing one, because they cannot tell a broken tool from their own
mistake. When there is a choice, take the more robust option. The goal is *"it just works"*.
