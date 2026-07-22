# Agent instructions for Ilwaco IDE

This project is a Linux-only, GTK3-only fork of VisualFBEditor.

Start every session by reading:
- `PROJECT_STATUS.md` — current state and what to do next
- `CHANGELOG.md` — completed work
- `CLAUDE.md` — detailed rules and orientation for working on the source

Key constraints:
- Target: 64-bit Linux, GTK3.
- Do not add or leave Windows, GTK2, or GTK4 code paths.
- Do not modify `Compilers/FreeBASIC-1.10.1-linux-x86_64/`; it is a bundled third-party compiler.
- Preserve UTF-8 BOM on existing source files that already have one.
- Keep line endings LF in `.bas`/`.bi`/`.frm` files.
- Run `make` from `src/` after source changes and verify `../ilwaco` builds.
- Update `PROJECT_STATUS.md` and `CHANGELOG.md` after non-trivial work.
