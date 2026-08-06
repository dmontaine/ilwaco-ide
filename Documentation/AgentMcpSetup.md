# Connecting an AI agent to Ilwaco IDE (MCP)

Ilwaco can act as an **MCP server**, letting a local AI agent (Claude Code, Claude Desktop, or any
MCP-compatible client) drive the running IDE — create a project, write a module, build it, read the
compiler errors, fix them, and run it — all from a chat prompt.

No Python, Node, or other runtime is required. The bridge is a small native FreeBASIC console
program, **`ilwaco-mcp`**, that ships next to `ilwaco`.

## How it fits together

```
  MCP client  ── stdio (JSON-RPC 2.0) ──►  ilwaco-mcp  ── Unix socket ──►  ilwaco
 (Claude Code)                             (the sidecar)   ilwaco-agent.sock   (the IDE)
```

- `ilwaco-mcp` is the only piece that tracks the MCP spec. It forwards each tool call to the IDE
  over a local Unix-domain socket at `$XDG_RUNTIME_DIR/ilwaco-agent.sock` (falling back to
  `/tmp/ilwaco-agent-<uid>.sock`).
- The IDE listens on that socket only while **"Allow AI agent control"** is ticked. The socket is
  local and per-user; it is not a network port.
- If Ilwaco isn't running when your agent makes its first request, the sidecar **launches it for
  you** and waits for it to come up (it won't open a second copy if one is already running). The
  opt-in below still governs — a launch alone doesn't grant access.

The architecture, the protocol, and the task-by-task build record are in
[McpServer.md](McpServer.md).

## 1. Confirm it's on in the IDE

Ilwaco is agent-first, so the agent socket is **on by default**. Its state shows in the **status
bar**, which reads **"MCP Agent: On"** or **"MCP Agent: Off"**.

To change it: **Tools ▸ Options ▸ General ▸ "Allow AI agent control (MCP)"**. The listener
starts/stops the moment you click **Apply/OK** — no restart. The setting is remembered between
sessions (stored as `AllowAgentControl` under `[Options]` in `Settings/ilwaco.ini`).

## 2. Point your MCP client at the sidecar

Add Ilwaco to your client's MCP server list, using the **full path** to `ilwaco-mcp` in your install
directory (it sits beside the `ilwaco` binary).

**Claude Code** — from a terminal:

```bash
claude mcp add ilwaco /path/to/ilwaco-ide/ilwaco-mcp
```

**Claude Desktop** — edit `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "ilwaco": {
      "command": "/path/to/ilwaco-ide/ilwaco-mcp",
      "args": []
    }
  }
}
```

Restart the client so it picks up the new server.

**Running from a source build?** The IDE needs the vendored shim on its library path. The sidecar
launches the IDE with its own environment inherited, so set it once for the client — either export
it before starting the client, or add it to the server entry:

```bash
export LD_LIBRARY_PATH="$(./build-linux.sh --print-shim)"
```

## 3. Use it

With the checkbox ticked, ask your agent something like:

> Create a FreeBASIC console project that prints every prime below 1,000,000, build it, fix any
> errors, and run it.

The agent will use the tools below to do the work directly in the IDE.

## Available tools (15)

| Tool | What it does |
|------|--------------|
| `get_status` | Whether a project is open, active file, build state |
| `list_files` | Files in the current project |
| `read_file` | Contents of a project file |
| `get_active_file` | Path + contents of the file in the active editor |
| `get_build_output` | Text from the last build |
| `get_errors` | Structured errors/warnings from the last build |
| `write_file` | Overwrite a project file on disk |
| `add_file` | Add a new module or header to the project |
| `set_active_file_content` | Replace the active editor's contents |
| `open_in_editor` | Open a project file in the editor |
| `build` | Compile the current project (async) |
| `syntax_check` | Syntax-check without producing an executable |
| `run` | Build and run the program in a terminal |
| `create_project` | Create a new project from a template |
| `open_project` | Open an existing project by path |

Form-designer tools (`designer_*`) are deliberately not offered yet — see McpServer.md.

## Security notes

- **On by default, but user-controllable.** Because Ilwaco is meant to be driven by an agent, the
  socket listens out of the box. Un-tick **"Allow AI agent control (MCP)"** (or close Ilwaco) to stop
  the listener; the status bar shows the current state.
- **Local only.** The transport is a Unix-domain socket owned by your user, not a network port.
- **Project-scoped.** File tools resolve paths inside the open project's folder and reject anything
  that escapes it (`bad_path`). The check is lexical, so a symlink *inside* a project could still
  point outside it — acceptable for a local, single-user, opt-in tool.
- If you don't want any local process able to drive the IDE, turn the toggle off when you're not
  working with an agent.

## Troubleshooting

- **Client can't connect / tools error out** — the sidecar auto-launches Ilwaco, but the **"Allow AI
  agent control" checkbox must be ticked** for the socket to open. Check the status bar; if it reads
  "MCP Agent: Off", tick the box (Tools ▸ Options ▸ General) and retry. The sidecar says so in its
  error text.
- **The IDE opened but nothing happens** — a modal dialog blocks the agent, because commands run on
  the IDE's UI thread. Dismiss it and retry.
- **A tool reports the IDE "closed the connection without a complete reply"** — the command may
  already have run. Check the IDE before retrying; retrying is not safe for anything that writes
  files.
- **Wrong path** — the `command` must be the absolute path to `ilwaco-mcp`.
