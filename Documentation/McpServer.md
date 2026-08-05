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
| 1 | Read-only tools: `get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output` | not started |
| 2 | The sidecar `ilwaco-mcp` (`AgentMcp.bas`), wired to Task 1 from a real MCP client | not started |
| 3 | Mutations: `write_file`, `add_file`, `set_active_file_content`, `open_in_editor` + path guard | not started |
| 4 | Build/run/errors: `build`, `syntax_check`, `run`, `get_errors` (async completion; save-dirty-first) | not started |
| 5 | Project ops: `create_project` (plain template), `open_project` | not started |
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
agent-driven launch), and stops it in `frmMain_Close`.

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
