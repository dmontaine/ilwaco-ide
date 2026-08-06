# Agent MCP server — design & progress (Ilwaco, Linux/GTK)

Ilwaco is gaining an **Agent MCP server**: a small console sidecar (`ilwaco-mcp`) that speaks MCP /
JSON-RPC 2.0 over stdio to an MCP client (Claude Code/Desktop) and forwards each `tools/call` to the
running IDE over a **local Unix-domain socket**. Inside the IDE, a worker thread marshals each command
onto the GTK UI thread and runs the *same* code the menus call — letting an agent drive the live IDE:
create/open a project, add & edit files, build, run, and read compile errors and output back.

This is the Linux/GTK counterpart of Astoria's Windows design (`MCP_SERVER_PLAN.md` in the sibling
astoria-ide repo). Everything portable is carried over; the platform layer is rebuilt. See PROJECT_STATUS.md for the live
handoff and HISTORY.md for the session narrative.

## Architecture

```
MCP client  ──MCP/JSON-RPC over stdio──►  ilwaco-mcp  ──line-JSON over a Unix socket──►  ilwaco
(Claude)    ◄────────────────────────────  (sidecar)  ◄──────────────────────────────  (worker thread
                                                                                          → g_idle_add
                                                                                          → UI thread)
```

- **Layer A — the sidecar** (`ilwaco-mcp`, source `AgentMcp.bas`): the only component that tracks the
  MCP spec. `initialize` / `tools/list` / `tools/call`, owns the tool schemas, maps each call 1:1 to a
  socket command. Auto-launches the IDE if it isn't running.
- **Layer B — the socket**: `$XDG_RUNTIME_DIR/ilwaco-agent.sock` (fallback `/tmp/ilwaco-agent-<uid>.sock`),
  newline-delimited JSON, one request/response per connection.
- **Layer C — the IDE server** ([src/AgentPipe.bas](src/AgentPipe.bas)): a worker thread that never
  touches GTK widgets. It publishes each request in a single in-flight slot, schedules execution with
  `g_idle_add` onto MFF's `gtk_main` loop, and waits on an FB condition variable for the UI thread to
  complete it.
- **JSON** ([src/JsonLite.bas](src/JsonLite.bas)): dependency-free UTF-8 parser/serializer shared by
  both the sidecar and the IDE, so neither needs a JSON library.

## The three Win32 → Linux/GTK substitutions (the whole difficulty)

| Astoria (Win32) | Ilwaco (Linux/GTK) |
| --- | --- |
| Named pipe + `CreateNamedPipe`/`CreateFileW` | Unix-domain socket (`socket`/`bind`/`listen`/`accept`; client `connect`) |
| `PostMessage(WM_APP)` + `WaitForSingleObject` event | `g_idle_add` onto `gtk_main` + FB `Cond`/`Mutex` completion handshake |
| Raw Win32 std handles for the sidecar's stdio | libc `read`/`write` on fd 0/1 |
| `GetModuleFileName` + Toolhelp + `CreateProcess` (auto-launch) | `/proc/self/exe` + socket-connect probe + `exec` |
| `WideCharToMultiByte` UTF-8⇄UTF-16 | MFF's `ToUtf8`/`FromUtf8` |

## Owner decisions (2026-08-05)

- **Toggle default ON** — agent-first; the listener is up unless the user unticks Tools ▸ Options.
- **v1 scope: the 13-tool core loop** — omit Astoria's two `designer_*` form-designer tools; revisit as
  Ilwaco's designer matures.
- **Auto-launch ON** — if the IDE isn't running, the sidecar starts it and polls the socket.

## Task progress (phased; build + verify after each)

| Task | What | Status |
| --- | --- | --- |
| 0 | Socket + `g_idle_add` marshal skeleton + `ping` | **DONE + verified (2026-08-05)** |
| 1 | Read-only tools: `get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output` | **DONE + verified (2026-08-05)** |
| 2 | The sidecar `ilwaco-mcp` (`AgentMcp.bas`), wired to Task 1 from a real MCP client | **DONE + verified (2026-08-05)** |
| 3 | Mutations: `write_file`, `add_file`, `set_active_file_content`, `open_in_editor` + path guard | **DONE + verified (2026-08-05)** |
| 4 | Build/run/errors: `build`, `syntax_check`, `run`, `get_errors` (async completion; save-dirty-first) | **DONE + verified (2026-08-06)** |
| 5 | Project ops: `create_project` (plain template); `open_project` **DONE (brought forward for Task 1 verification)** | **DONE + verified (2026-08-06)** |
| 6 | Security/opt-in + packaging: Options toggle (default ON), INI key, ship `ilwaco-mcp`, setup doc | not started |
| 7 | End-to-end verify: drive the create → build → read-errors → fix → run loop from a real MCP client | not started |
| — | (later) `designer_list_controls` / `designer_double_click` — deferred by owner | deferred |

### Task 0 — DONE + verified (2026-08-05)

The socket server, the cross-thread marshal, and the shutdown path all work. Verified by effect against
the live IDE on `:0`: the socket appeared at `/run/user/1000/ilwaco-agent.sock`; a `{"cmd":"ping"}`
request returned `{"ok":true,"result":{"pong":true}}` (twice — the worker loop keeps serving); an
unknown command and malformed JSON returned the correct `unknown_cmd` / `bad_json` errors; the
"Ilwaco IDE (64-bit)" window stayed live throughout; and a graceful window-close ran `StopAgentPipe`,
which removed the socket file and let the process exit cleanly. No startup errors beyond the two known
harmless `AppAddin`/`AppConsole` resource warnings.

Wiring: [src/Main.bas](src/Main.bas) includes `AgentPipe.bi`, starts the listener in `frmMain_Show`
(with a `--mcp-agent` guard that suppresses the New Project / Tip-of-the-Day startup modals for an
agent-driven launch), and stops it in `frmMain_Close`. The implementation (`AgentPipe.bas`) is
included **late**, at the end of [src/ilwaco.bas](src/ilwaco.bas), because its handlers reference IDE
symbols (`MainNode`, `TabPanels`, `txtOutput`, `ProjectElement`, …) that only exist after every
`.bi`/`.bas` has been pulled in; `AgentPipe.bi` (Main.bas) carries just the declarations the startup
hooks call.

### Task 1 — DONE + verified (2026-08-05)

`get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output`, plus `open_project`
(brought forward from Task 5, because loading a project is what every project-scoped tool needs, and
Ilwaco's command-line project-open does not populate `MainNode`). All handlers run on the UI thread via
`g_idle_add`, reading the live project model:

- **open project** = the global `MainNode` (its `Tag` is a `ProjectElement`); **active tab** =
  `ptabCode->SelectedTab` cast to `TabWindow`; **full tab text** = `EditControl.Text`; **build output**
  = `txtOutput.Text` (a `TextBox`).
- **`list_files` walks the explorer tree** under `MainNode`, not `ProjectElement.Files` — the latter is
  only rebuilt from the tree at compile time, so it is empty after a plain open.
- **Path-traversal guard (security).** `read_file` resolves the client path and rejects anything
  escaping the project folder. The first cut prefix-checked the raw `GetFullPath` result, which does
  **not** collapse `..`, so `Project/../../etc/passwd` text-matched the project folder and leaked
  outside files (verified: it returned `/etc/hostname`). Fixed with a lexical `..`/`.` normalizer
  (`AgentNormalizePath`) applied before the containment check; re-verified that an absolute
  `/etc/hostname`, a plain `..`-relative escape, and a project-anchored `..`-laden escape all return
  `bad_path` with zero bytes, while absolute-in-project and relative-in-project reads (main `.frm`
  6746 bytes; `.vfp` 1067 bytes) succeed.
  Lexical only — a symlink inside the project could still point out; acceptable for the opt-in,
  local, single-user model.

Verified by effect against the live IDE: `open_project` a sample `.vfp` → `get_status`/`list_files`
reflect it → `read_file` returns correct content → the five traversal probes above are all blocked.
`get_active_file`'s happy path (a focused tab) waits on `open_in_editor` (Task 3); its no-tab error
path is verified.

### Task 2 — DONE + verified (2026-08-05)

The sidecar [src/AgentMcp.bas](src/AgentMcp.bas) → `./ilwaco-mcp`, a Linux port of Astoria's
`astoria-mcp.exe`. The MCP/JSON-RPC layer (initialize, tools/list, tools/call, ping; the tool table;
the reachable/complete reply handling) ports almost verbatim; the platform layer is rebuilt:

- **stdio** = libc `read`/`write` on fd 0/1/2 (no CR/LF reinterpretation); **socket client** =
  `socket`/`connect` to the same per-user path; **auto-launch** = `readlink("/proc/self/exe")` for the
  IDE's folder, `pgrep -x ilwaco` for "already running", and `system("…/ilwaco --mcp-agent … &")` to
  start it detached (the child inherits the sidecar's env, so an `LD_LIBRARY_PATH` the client set for
  the shim carries through).
- Dropped Astoria's `create_project` `ai_tool` stamping (Ilwaco has no AI-template machinery).
- The tool table advertises **only the tools the IDE implements today** (the six read-only + project
  tools); rows for the mutation/build/project tools land with their IDE-side handlers in later tasks.

Built via `./build-linux.sh sidecar` (also folded into `all`). Verified by effect through a real MCP
client flow over the sidecar's stdio, **with no IDE running beforehand**: `initialize` →
`serverInfo.name = ilwaco-ide`; `tools/list` → the six tools; `tools/call get_status` **auto-launched
the IDE** (0 processes before, 1 after) and returned status; `open_project` + `list_files` then
forwarded correctly. Ship `ilwaco-mcp` alongside `ilwaco` (tracked in git; the built binaries travel
with the repo).

### Task 3 — DONE + verified (2026-08-05)

Mutation tools, all UI-thread, all path-guarded via `AgentResolveProjectPath`:

- **`write_file`** `{path, content, register?, open?}` — writes BOM-less bytes; `register` mirrors
  `AddFilesToProject`'s non-dialog branch (add a tree node under `MainNode` with an `ExplorerElement`,
  mark the project dirty); `open` calls `AddTab`.
- **`add_file`** `{name, kind}` — module (`.bas`) or header (`.bi`) from a minimal stub, registered +
  opened by default. Forms are refused (`unsupported`) — they need designer scaffolding a stub can't
  provide.
- **`set_active_file_content`** `{content}` — sets `AgentActiveTab()->txtCode.Text` and marks the tab
  modified.
- **`open_in_editor`** `{path}` — `AddTab` opens/focuses a code tab.

Verified by effect: `write_file` a new `.bas` (register+open) → `list_files` now includes it →
`read_file` returns the exact LF bytes → `get_active_file` shows it focused (also closes Task 1's
deferred happy-path) → `set_active_file_content` replaces its text → `write_file` to `../../ESCAPE.txt`
is rejected `bad_path` → `add_file` creates a module and refuses a form. Note: `set_active_file_content`
reads back with `\r\n` — the EditControl normalizes to CRLF internally (whereas `write_file` to disk
stays LF); harmless for compilation, noted against the LF-only directive.

### Task 4 — DONE + verified (2026-08-06)

`build`, `syntax_check`, `run`, `get_errors`, in [src/AgentPipe.bas](src/AgentPipe.bas) (+ 4 rows in the
sidecar tool table, [src/AgentMcp.bas](src/AgentMcp.bas), now `gTools(0 To 13)`). How it landed:

- **The build runs the SAME code the menu runs — `Compile()` — which is designed to run OFF the UI
  thread** (it does its own `ThreadsEnter/ThreadsLeave` around every widget touch; running it inside the
  `g_idle` callback would freeze the loop and deadlock `ThreadsEnter`). So the async shape is:
  `AgentStartBuild` (UI thread) saves dirty tabs, sets `gAgentBuilding`, spawns a build thread via MFF's
  `ThreadCreate_`, and returns **`async=True`** so `AgentIdleExec` does **not** complete the command slot.
  `AgentBuildThread` runs `Compile(param)`; when it returns it `g_idle_add`s `AgentBuildFinalize`, which
  (UI thread) reads the results, clears `gAgentBuilding`, fills the slot and signals the still-blocked
  pipe worker. The single-slot model guarantees no other agent command runs meanwhile.
- **`async` plumbed through `AgentDispatch`** as a by-ref out-param: build/syntax_check/run set it; a
  synchronous failure (e.g. `no_project`) leaves it False and replies normally.
- **Command → `Compile()` parameter:** `build` → `""`, `syntax_check` → `"Check"` (adds `-c`, no exe),
  `run` → `"Run"` (builds, and on success `RunPr` launches the exe in a terminal). All three return
  `{ success, error_count, warning_count, errors[] }`.
- **Diagnostics from `lvProblems`, not text-parsing.** `Compile()` already fills the Problems ListView:
  `Text(0)`=message, `Text(1)`=line, `Text(2)`=file. `AgentProblemsArray` reads them into
  `{severity, message, file, line}`. Severity is re-derived from the message text (an fbc line contains
  "error"/"warning") because the item's image-key severity isn't cleanly readable back — matching
  `Compile`'s own fallback. **Locationless rows (no file, line ≤ 0) are skipped** — that drops fbc's
  version banner and summary lines, the same effect as Astoria matching only `file(line) error/warning`.
  A locationless failure (a bare linker error) is therefore not in this list; it stays visible via
  `get_build_output`. `get_errors` is synchronous (reads the last build's Problems list).
- **Save-dirty-first uses `SaveAll()` (silent), not `SaveAllBeforeCompile()`** — the latter's mode-3
  "which files to save" **modal** would stall a headless agent (no user to answer). `SaveAll` writes all
  modified tabs + projects with no dialog.
- **Console link works now:** the vendored shim (`Compilers/shim/gtk-dev`) already carries
  `libncurses.so` + `libtinfo.so` symlinks, so a console project that passes `-p <shim> -l tinfo` via
  `CompilationArguments64Linux` links cleanly (the old `libncurses` gap is closed).

**Verified by effect** against the live IDE over the socket (Python `AF_UNIX` client) with a minimal
console project: `open_project` → `syntax_check`/`build`/`run` all `success=true, errors=[]` (banner
filtered); `run` produced a working `Main` exe (`Sum 1..100 = 5050`); `get_status` reported
`building=false` throughout; then `set_active_file_content` with a syntax error → `syntax_check`
`success=false, error_count=1` with a structured `{error, file, line:1}`, and `get_errors` returned the
same. No `DebugInfo.log`, clean shutdown.

**Known limitations (v1, acceptable for opt-in single-user; track for hardening):**
- **Closing the IDE while an agent build is in flight can hang shutdown** — `StopAgentPipe` joins the
  worker, which is blocked waiting for the build finalizer that can't run once the closing UI thread is
  in `ThreadWait`. This window is inherent to the marshal design (sync commands share it, microseconds
  wide); builds widen it to seconds. A proper fix is an interruptible/abandoning shutdown.
- **A locationless linker error reports `success=true`** (no file/line row to count) — matches Astoria;
  the raw text is in `get_build_output`. Rare now that the shim resolves libs.
- **Pre-existing MFF noise:** when the Problems ListView is drawn with items, MFF's column iteration
  reads one past the end and prints `List.Item … Out of Index boundary. Index = 3 of 3` to stderr
  (benign, `List.bas:41` returns 0). Render-only; not from the agent path. Fix belongs in MFF ListView.

### Task 5 — DONE + verified (2026-08-06)

`create_project` (`open_project` was already done, brought forward for Task 1). `AgentCmdCreateProject`
in [src/AgentPipe.bas](src/AgentPipe.bas) mirrors the New Project dialog's proven copy flow
(`frmNewProject.frm`) so the two paths stay in step:

- Args `{ name, template? }` (`template` default "Console Application"). `name` must be a **bare** folder
  name — no `/`, `\`, or `..` — so it can only land under `ProjectsPath`.
- `Templates/Projects/<Template>.vfp` is the manifest; `Templates/Projects/<Template>/` holds its files.
  `FolderCopy` flattens the template folder into the new project folder; the manifest's `<Template>/…`
  path prefixes are then stripped (`Replace`), and it's written as `<name>.vfp` beside the files. Reuses
  `AgentReadFileBytes`/`AgentWriteFileBytes`, so the written `.vfp` is **BOM-less** (verified).
- Errors: `bad_args` (missing/path-y name, unknown template), `exists` (folder present), `write_failed`,
  `open_failed`.

**Bug found & fixed — a create/open while another project is open must switch the active project.**
`AddProject` only auto-sets `MainNode` **when none is open** (`Main.bas:1282` `If MainNode = 0 Then
SetMainNode tn`), so opening a second project left the *first* one "main" and `AgentProject()` (hence
every project-scoped tool and the returned `project`) kept pointing at it. Fixed with a shared helper
**`AgentOpenProjectNode`** (`AddProject` + **`SetMainNode`** + `WLet(RecentProject,…)` — everything
`OpenFiles`' `.vfp` branch does, plus the `SetMainNode`); **both `create_project` and `open_project`**
now use it. Verified: creating a 2nd project switches `get_status` to it.

**AI extension point (deferred, not dropped):** where Astoria's `create_project` stamps AI-friendliness
(`AIFriendly`/`AITool` + the AI template), Ilwaco has a marked comment. Ilwaco's AI features are coming
back later (owner, 2026-08-06); when they land, this handler and `frmNewProject` should stamp the same
keys so the two creation paths never drift.

**Verified by effect** over the socket: `create_project` (default Console template) → `{project,
main_file}`; `get_status`/`list_files`/`read_file` reflect it; `syntax_check` on the created project
`success=true`; the three error paths return the right codes; a second `create_project` switches the
active project. No `DebugInfo.log`.

**Pre-existing issue surfaced (not Task 5, tracked separately):** project `.vfp` files get a UTF-8 **BOM**
from the IDE's `SaveProjectFile` (`Open … For Output Encoding "utf-8"`, `Main.bas:2048/2058`) and from the
template `.vfp` files themselves — violating the no-BOM directive. `create_project` writes BOM-less, but
the first `SaveProject` re-adds it. Fix belongs in the project writer + template data.

### Notes for the next session (facts learned this session)

- **Include ordering is load-bearing.** `AgentPipe.bi` (included in `Main.bas`) is **declarations only**;
  the implementation `AgentPipe.bas` is `#include`d **last, at the end of `ilwaco.bas`**, so its handlers
  see the IDE symbols (`MainNode`, `TabPanels`, `txtOutput`, `ProjectElement`, `Compile`, …). Adding a
  handler that calls a new IDE function just works as long as that function is defined by then.
- **Loading a project:** use the `open_project` tool. Ilwaco's *command-line* `.vfp` open runs
  `OpenFiles` but does **not** populate `MainNode` here (an IDE-side quirk, not chased); `open_project`
  (which also calls `OpenFiles` on the UI thread) does set it. `open_project` asserts `MainNode` after,
  returning `open_failed` if the project didn't load.
- **`ProjectElement.Files` is empty after a plain open** — it's only rebuilt from the explorer tree at
  compile time. `list_files` walks the tree under `MainNode` instead (see `AgentCollectFiles`).
- **CRLF vs LF:** `write_file` writes exact LF bytes to disk; `set_active_file_content` reads back CRLF
  because the EditControl normalizes internally. Watch this against the LF-only directive if it matters
  for a build.
- **Verify by effect.** Build the editor (~4 min, background it), launch on `:0`, drive the socket with a
  `socket.AF_UNIX` Python client (recipe below) or spawn `./ilwaco-mcp` and speak MCP over its stdio.
  Always `git checkout Settings/` after a launch (the IDE writes session state on exit), and remove any
  agent-created test files (from `Examples/`, or `Projects/` for `create_project` tests) before
  committing. Kill leftover instances with `pkill -x ilwaco` (not `-f` — it matches the caller).
- **Relaunch race (cost a cycle):** `pkill` doesn't run `StopAgentPipe`, so the **socket file lingers**.
  On relaunch, an `until [ -S <sock> ]` check passes instantly on the *stale* file while the new server
  hasn't bound yet → `ConnectionRefused`. `StartAgentPipe` unlinks+rebinds, so just wait a beat: gate on
  the new process being alive AND give it ~1–2s to bind (or `rm -f` the socket before launch), don't
  trust the socket file's mere existence.

## Verification recipe

Build and run the editor (`./build-linux.sh editor`, then
`LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)" DISPLAY=:0 ./ilwaco`), then drive the socket with a
`socket.AF_UNIX` client (Python):

```python
import socket, os, json
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(os.path.join(os.environ["XDG_RUNTIME_DIR"], "ilwaco-agent.sock"))
s.sendall((json.dumps({"id": 1, "cmd": "ping", "args": {}}) + "\n").encode())
print(s.recv(4096).decode())   # -> {"id":1,"ok":true,"result":{"pong":true}}
```

For the full loop (Task 7), register `ilwaco-mcp` in an MCP client and assert a primes program builds,
fails, is fixed, and runs to `Primes below 1000000 = 78498`. Watch the BOM trap — a BOM'd source prints
wide garbage; the sidecar writes BOM-less UTF-8.
