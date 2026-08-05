# Fixes that may be useful upstream

Ilwaco is a permanent Linux/GTK3 fork of
[VisualFBEditor](https://github.com/XusinboyBekchanov/VisualFBEditor), built on
[MyFbFramework](https://github.com/XusinboyBekchanov/MyFbFramework). We are not proposing patches or
asking for anything. This page exists because some of what we fix are bugs in the *upstream* code
rather than in ours, and it seems unfriendly to fix them quietly and say nothing.

**Everything here is offered, not claimed.** We have not tested any of it against current upstream —
our tree has diverged (x86_64-only, GTK3, Windows branches deleted), so a fix that is right for us
may need adapting or may already be fixed there. Take what is useful and ignore the rest.

This is the **GTK-side** companion to Astoria's `UpstreamFixes.md`: Astoria collects Win64-only
fixes that cannot apply to the GTK build, so our GTK fixes belong here instead. Each entry gives the
symptom, the file, and the commit; `git show <hash>` in this repository gives the full reasoning and
the diff.

---

## Framework (MyFbFramework) — GTK

- **`TabControl` could not remove a tab without destroying its page.** Showing/hiding the debug
  tab-set needed a way to detach a `TabPage` from the bar and re-add it later without losing the
  page's widgets. Added a `DetachTab` method (removes the tab, `g_object_ref`-ing the page widget so
  it survives) — see `src/Main.bas` debug-tab-visibility work and its commit. Additive and
  non-virtual, so it needs no `.so` ABI break.

- **`NoInterface.bi` cannot be compiled on its own.** It is the header a *non-GUI* project includes
  instead of the GUI framework, but its `Debug.Print`/`Debug.Clear` bodies call `GTK_IS_TEXT_VIEW` and
  the `gtk_text_*`/`gtk_notebook_*` family while including only `UString.bi`, and they reference a
  `DebugWindowHandle` that only `Application.bas` declares. Inside the framework's own build the GTK
  headers arrive through other headers first, which hides both; a user project that includes just this
  one fails with "Variable not declared, GTK_IS_TEXT_VIEW" and then "…, DebugWindowHandle". Fixed by
  adding `#include once "gtk/gtk.bi"` and the same guarded `DebugWindowHandle` declaration
  `Application.bas` makes. Found by building the stock Console Application template.

## IDE (VisualFBEditor base) — GTK

- **`FolderCopy` copies nothing on the GTK build — silently.** `Main.bas FolderCopy` passes its paths
  straight to FreeBASIC's `FileCopy`, which takes `ZString Ptr`. The arguments there are `UString`
  expressions (MFF's wide-string type), so the call binds through `UString.Cast() As Any Ptr` and the
  raw wide buffer is read as a narrow path: it ends at the first zero byte, so every copy fails,
  returning 1, with no error raised. The Windows branch of the same routine never hit this — it stages
  into `WString * 1024` buffers (`fsrc`/`fdest`, still declared but unused in the GTK branch) and calls
  `CopyFileW`. Effect: creating a project from a template produced an **empty folder**. Measured
  directly — the identical copy returns 1 with `UString` arguments and 0 with `WString` ones. Fixed by
  routing every copy through a `FileCopy_(ByRef Source As WString, ByRef Destination As WString)`
  wrapper, which leaves the narrowing to the compiler and is correct for either string type.
  Note the same trap bites any `&` concatenation with a `UString` operand, since `&` then resolves to
  MFF's `UString` operator and yields a `UString`.

---

## Why this is short

Ilwaco is early in its Astoria-parity walk, and most work so far is **porting** Astoria's changes or
**stripping** Windows-only code — neither of which is an upstream-worthy GTK bug fix. As GTK bugs in
the shared base surface and are fixed here, list them above with symptom, file, and commit hash. The
maintenance rule: a fix to vendored upstream code (VisualFBEditor or MFF) triggers a line here — see
[TestPlan.md](TestPlan.md).
