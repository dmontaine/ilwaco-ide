# Ilwaco IDE

A Linux-only, opinionated FreeBASIC IDE based on VisualFBEditor and MyFbFramework.

Ilwaco is the parallel project to Astoria IDE: the same deliberate design choices,
but targeting 64-bit Linux with GTK3 instead of Windows.

## Current state

This is a work in progress. The baseline GTK3 build compiles and produces the
`ilwaco` executable. Runtime polish, feature stripping, and the AI/MCP port are
still in flight.

## Build requirements

- 64-bit Linux
- GTK3 development libraries (`gtk+-3.0`)
- GDB (system package)
- The bundled FreeBASIC compiler in `Compilers/FreeBASIC-1.10.1-linux-x86_64/`

## Building

```bash
cd src
export FBC=/path/to/fbc   # or use the bundled compiler
make
```

Run with the framework library on the library path:

```bash
cd ..
LD_LIBRARY_PATH=Controls/MyFbFramework ./ilwaco
```

## Design notes

- GTK3 only; GTK2 and GTK4 code paths are being removed.
- Windows-specific code and build artifacts are being removed.
- 64-bit Linux only.
- Git integration is intentionally omitted.
- AI/MCP integration will be ported from Astoria IDE.
