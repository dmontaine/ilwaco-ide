# Testing — what is proven, and what is not

Written for outside testers and for future-me. The forward-looking companion is
[TestPlan.md](TestPlan.md) (named scenarios to run); this file records **results** — and, just as
important, **the gaps**. If something is unproven, it says so. An honest gap is worth more than a
confident sentence that turns out to be false.

**How Ilwaco is verified.** There is **no automated/headless harness yet.** Everything below is
verified *by effect*: build with `./build-linux.sh`, run on the live X display
(`DISPLAY=:0 ./ilwaco`), and observe with `scrot` / `xdotool` / `wmctrl`. A clean `fbc` exit is
necessary but not sufficient — "it compiled" is not "it works".

---

## Proven

- **Editor builds from source and runs.** `./build-linux.sh editor` produces `ilwaco`; the window
  opens on `:0` with no error dialog (harmless `AppAddin`/`AppConsole` "does not exist" warnings
  aside). Standing result — see [PROJECT_STATUS.md](../PROJECT_STATUS.md).
- **Left/right panel collapse (2026-08-04).** Each tool panel collapses to a thin vertical-text
  rail (pin icon + rotated `Project`/`Toolbox`, `Properties`/`Events`); the pin re-expands to the
  last tab; each text button re-expands and selects its tab; the expanded-panel pin repaints after
  reopen; both rails show collapsed at startup when the INI says so. Verified by screenshot.
- **Debug-tab visibility.** The seven debug tabs (Locals…Profiler) show only when the debugger is
  enabled; Immediate stays visible. Verified both states by screenshot.
- **Bottom/debug panel clearing.** Stale project/debug results are cleared on project close and on
  debug end; all bottom tabs render. Build + launch verified.
- **End-to-end user-project build *and debug* through the IDE (2026-08-04).** A console `.vfp`
  compiles, links and launches under the Integrated debugger from the IDE itself — the exe was
  deleted before each run, so the IDE genuinely produced it. Confirmed: tracing stop with the
  current-line marker, Locals populated, and the debuggee's real `argv` and environment read from
  `pgrep -a` / `/proc/<pid>/environ`. Caveat: in *this* dev environment the project needs
  `CompilationArguments64Linux="-p <shim> -l tinfo"`; that is a dev-shim artefact, not an IDE
  limitation (see [TechnicalDebt.md](TechnicalDebt.md)).
- **Debuggee arguments and environment (2026-08-04).** Arguments arrive in order (program name, the
  Parameters *Debug* arguments, then the project's *Command-line arguments*); environment variables
  are injected, the inherited environment is preserved, a user variable overrides the inherited one
  of the same name leaving exactly one entry, and the IDE's own environment is untouched.
- **Debugging from a mixed-case path (2026-08-04).** A project under `/tmp/ArgTest_MixedCase/` loads
  its source and debugs without the old "File not found" — the path-case regression test.

## Not proven (known gaps)
- **Designer control library load.** `Controls/MyFbFramework/libmff64_gtk3.so` must be built or the
  toolbox errors at runtime; that it loads cleanly is relied upon but not formally recorded as a
  scenario.
- **Control behaviour at large.** No systematic control sweep has been run on the GTK build — see
  [ControlTesting.md](ControlTesting.md). Compiles-and-opens is not properties-events-and-docked.
- **GTK dark mode.** Never exercised — the styling branch does not fire on GTK yet (TechnicalDebt).

---

## Maintenance

A test run updates the matching scenario row in [TestPlan.md](TestPlan.md) and, if what is proven or
unproven changed, this file — in the same commit as any fix it produced. `python3 Tools/DocCheck.py`
before committing.
