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

- **Every GTK app built on MFF crashes with SIGSEGV on close.** FreeBASIC runs each module-level
  object's destructor at `_GLOBAL__D`, *after* `main()` returns — but closing the main window has
  already made GTK free the entire widget tree. Each control/toolbutton/menu-item destructor then runs
  `If widget <> 0 AndAlso GTK_IS_WIDGET(widget) Then gtk_widget_destroy(widget)`, and `GTK_IS_WIDGET`
  **dereferences the freed pointer** — a use-after-free on every close, surfacing in whichever
  widget-owning global destructs first (`~Control`, `~ToolButton`, `~MenuItem`, … — the site is
  build-nondeterministic). The **Win32 build is safe for free** because `IsWindow(Handle)` validates a
  destroyed window handle rather than dereferencing it; GTK has no equivalent, so the same guards that
  protect Win32 are the thing that crashes on GTK. Per-object nulling of the widget on GTK's `"destroy"`
  signal was tried and is both large (~20 destructors across the type zoo) and unreliable (the signal
  does not fire uniformly for all container/child widget types). Fixed the way **Astoria** fixes exactly
  this — the framework terminates the process on main-form close: Astoria's `Form.bas` does FB `End 0`
  the instant the main form's `OnClose` returns (and Astoria itself falls back to `ExitProcess(0)` when
  teardown is what crashes, its §13.29). `End` cannot be used on GTK (it *runs* the crashing
  destructors), so `mff/Form.bas`'s two main-form close paths (`ProcessMessage` GDK_DELETE and
  `CloseForm`) now call a `CloseOnMainForm` that does libc `_exit(0)`, skipping the destructor walk. By
  that point `OnClose` has returned, so all state is saved (`IniFile` writes through to disk on every
  write); the OS reclaims memory and GTK/X resources. Non-main forms are unaffected — they still hide.

## IDE (VisualFBEditor base) — GTK

- **`frmMain_Close` dereferenced a null `Parent`, crashing on close whenever the debugger was off.**
  The 7 debug panes (Locals/Globals/Procedures/Threads/Watches/Memory/Profiler) are detached from the
  bottom tab bar by `SetDebugTabsVisible(False)` — the default state, since `UseDebugger=false` — and
  `DetachTab` sets each page's `Parent = 0`. The shutdown handler then wrote
  `iniSettings.WriteString("MainWindow", "LocalsParent", tpLocals->Parent->Name)` for all 18 panes
  unguarded, so `tpLocals->Parent->Name` dereferenced null. This was the deterministic close crash long
  misfiled as "an intermittent threading SIGSEGV" — the real variable was debugger on/off. Fixed by a
  guarded `SaveTabPagePlacement(key, tp)` helper that skips a pane whose `Parent` is null (a detached
  pane has no placement to persist; the next launch restores it to its default bar), collapsing the 36
  duplicated write lines to 18 calls. Guarded on the same principle as MFF's own `RemoveBottomDebugTab`.

- **A `TreeView`'s `OnMouseUp` never fires on GTK, so a context menu prepared there shows stale
  state.** `Control.bas` raises `OnMouseUp` only inside
  `If gtk_widget_get_window(widget) = e->motion.window OrElse (layoutwidget AndAlso …)`. A
  `GtkTreeView` delivers its button events on its *bin* window and is not a `GtkLayout`, so neither
  arm holds and the callback is never invoked — while the same `GDK_BUTTON_RELEASE` case pops
  `ContextMenu` unconditionally a few lines below. `Main.bas` prepared the explorer menu in a
  `tvExplorer_MouseUp` handler (captions, enabled/disabled, "Set as Main" vs "Set as Start Up"), so on
  GTK that menu had shown fixed, stale entries since the port; the handler also opened with
  `If MouseButton <> 1 Then Exit Sub`, which is a second bug behind the first, since MFF reports
  `e->button.button - 1` (left 0, middle 1, right **2**). Fixed on our side by moving the logic to a
  plain `UpdateExplorerMenuState` Sub called from the tree's selection-change handler — right-clicking
  a row does move the selection, and that fires before the popup. Note a selection handler is not
  sufficient alone: re-clicking the already-selected row raises no change, so anything that alters a
  node's state must refresh the menu itself.

- **`node->Text &= "*"` changes the string but does not repaint.** `TreeNode.Text` is a property pair
  whose getter is `ByRef As WString`, so the compound assignment appends through the returned
  reference instead of routing back through the setter — and the setter is what calls
  `gtk_tree_store_set`. The IDE marks a modified project by appending `*` to its node this way (five
  live sites in `Main.bas`/`AgentPipe.bas`), so on GTK the model held `Project.vfp*` while the tree
  went on displaying `Project.vfp`: the dirty marker was invisible, and code reading
  `EndsWith(tn->Text, "*")` still worked, which is why it went unnoticed. Appending in place into an
  exactly-sized buffer is also dubious in its own right. Fixed by writing
  `tn->Text = tn->Text & "*"`, which builds a temporary and goes through the setter.

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

- **`StatusBar` did not dock to the bottom on GTK (2026-08-07).** Symptom: a form with a status bar
  rendered it **top-left**, over the client area (`Examples/Learning/GUI/20_MenuAndStatusBar`).
  Win32 gets this free — `msctls_statusbar32` positions itself at the bottom of its parent — whereas
  `gtk_statusbar_new` returns an ordinary widget that MFF then places like any other control, at its
  default position. MFF already had the machinery (`DockStyle.alBottom`, honoured by `Control.bas`);
  the GTK `StatusBar` constructor simply never set it. Fixed in `mff/StatusBar.bas` with
  `.Align = DockStyle.alBottom`. Benefits **every MFF app**, not just the IDE — which had been
  papering over it by setting `stBar.Align` itself in `src/Main.bas`. Verified: the example now docks
  correctly, and the IDE's own status bar is unchanged.

---

## Examples ported from Astoria (2026-08-07)

Four defects found by actually building Astoria's examples on Linux. The first three are the same
class of bug: **a case-insensitive filesystem hid them**, so they were invisible on Windows and fatal
here.

- **`#include once "mff/Textbox.bi"`** (`Examples/Calculator`) — the file is `TextBox.bi`.
  `error 23: File not found`.
- **`#include once "mff/sys.bi"`** (`Examples/FiveInARow`) — the file is `Sys.bi`. Same error.
- **`#include once "maze.bi"`** (`Examples/Maze`) — the file is `Maze.bi`. Same error.
- **`crHand` is Win32-only** (`Examples/FiveInARow`) — Astoria's MFF defines it as
  `LoadCursor(0, IDC_HAND)` (`Controls/Framework/mff/Cursor.bi`), which has no GTK equivalent under
  that name. Ilwaco's MFF calls the hand cursor **`crHandPoint`** (`"pointer"`), so the six uses were
  changed to that. Not a bug in either fork — a genuine Win32→GTK substitution.

A fifth is **not** a defect but the inverse of Astoria's Win64-only stripping, and is worth recording
because it hits *every* GUI example: Astoria removed the `#ifdef __FB_WIN32__` around each example's
`#cmdline "*.rc"`. That line runs the Windows resource compiler, so on Linux fbc stops with
`Executable not found: "windres"`. The guard was put back in all 30 files that carry the line.

---

## Why this is short

Ilwaco is early in its Astoria-parity walk, and most work so far is **porting** Astoria's changes or
**stripping** Windows-only code — neither of which is an upstream-worthy GTK bug fix. As GTK bugs in
the shared base surface and are fixed here, list them above with symptom, file, and commit hash. The
maintenance rule: a fix to vendored upstream code (VisualFBEditor or MFF) triggers a line here — see
[TestPlan.md](TestPlan.md).
