# Ilwaco IDE — Working on the IDE itself

This file orients an AI assistant working on **Ilwaco's own source**. It is not the file that ships to users; that is `Templates/AI/` territory.

Ilwaco is a 64-bit Linux IDE for FreeBASIC, forked from VisualFBEditor, written in FreeBASIC itself on the MyFbFramework (MFF) GUI library. It is the Linux/GTK3 parallel to Astoria IDE (Windows/Win64).

## Read these first

| Document | What it is |
| --- | --- |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | The authoritative handoff. Start here: current state, what is in flight, what to do next. |
| [CHANGELOG.md](CHANGELOG.md) | Completed work and notable deletions. |
| [README.md](README.md) | High-level project overview and build instructions. |

## Layout

- `src/` — the IDE. `Main.bas` is large and central; `TabWindow.bas` owns open documents and the designer bridge; `VisualFBEditor.bas` is the entry point.
- `Controls/MyFbFramework/` — the vendored MFF GUI framework (`mff/`). Linux/GTK3-specific fixes live here.
- `Controls/<Name>/` — optional control libraries (SQLite3, MariaDBBox, ScintillaControl, cJSON), each with its own `Settings.ini`.
- `Examples/` — example projects and MFF usage demos.
- `Templates/` — project and file templates installed into new user projects.
- `Settings/` — shipped defaults. The live user file is tracked for now.
- `Compilers/FreeBASIC-1.10.1-linux-x86_64/` — bundled compiler. **Read-only third-party bundle.** Do not modify.

## Building

```bash
cd src
make
```

Run with the framework library on the library path:

```bash
cd ..
LD_LIBRARY_PATH=Controls/MyFbFramework ./ilwaco
```

- The build produces `../ilwaco` and `Controls/MyFbFramework/libmff64_gtk3.so`.
- The framework emits a handful of `warning 36: Mismatching parameter initializer` lines; those are pre-existing and expected.
- **Verify the build actually ran.** Check that `ilwaco` is newer than your edit.

## Hard rules for this codebase

1. **Linux/GTK3 only.** Do not add Windows, GTK2, or GTK4 code paths. Remove them when found.
2. **Do not edit `Compilers/`.** It is a bundled third-party compiler distribution.
3. **Preserve UTF-8 BOM on existing files.** Many sources contain WString literals and rely on their BOM. If you rewrite a file, restore the BOM if the original had one.
4. **Line endings are LF.** Do not introduce CRLF into `.bas`/`.bi`/`.frm` files.
5. **Update handoff docs.** After any non-trivial change, update `PROJECT_STATUS.md` and `CHANGELOG.md`.

## FreeBASIC traps that have actually cost time here

- `IIf(...)` cannot yield a `String`/`WString` reliably — use explicit `If/Else`.
- A local `Dim` is **procedure-scoped**, not block-scoped — deleting an `If` block can leave later code referencing a name that is no longer declared.
- Identifiers are case-insensitive. Watch for collisions with FB keywords (`Name`, `Step`, `Ok`, `out`, `pos`, `value`, `line`, `msg`, `val`).
- `Str(a = b)` gives `0`/`-1`, not `"false"`/ `"true"`. `Str()` of a real `Boolean` does give `"true"`/ `"false"`.
- Never `ReDim Preserve` an array whose elements own heap memory (UDT holding `String`/`WString`/`UString`). It relocates with a shallow copy.

## Working practices

- **Make minimal changes.** This is a cleanup and stabilization fork, not a feature factory.
- **Verify with a build.** Run `make` from `src/` after any source edit.
- **Use grep to confirm platform assumptions.** After removing Windows/GTK2/GTK4 code, search for `__FB_WIN32__`, `__USE_WINAPI__`, `GTK2`, `GTK4`, `__USE_GTK2__`, `__USE_GTK4__` outside `Compilers/`.
- **Delete, don't just comment out.** Dead code should be removed, not left as comments.
