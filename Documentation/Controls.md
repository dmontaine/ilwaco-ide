# Controls — the MyFbFramework control reference (GTK)

**Status: scaffold.** This is a tracked placeholder, not yet written for Ilwaco. It exists so the
document has an analogue, is listed in the rule table, and is caught by `DocCheck` when it goes
stale — see [TestPlan.md](TestPlan.md).

**Purpose.** Describe each MyFbFramework control Ilwaco uses — what it is, its key properties and
events, and the constructor/idiom to create one — as it behaves on the **GTK3** build.

**Source to adapt.** Astoria maintains a full `Controls.md` (~800 lines) for its Win64 build. Adapt
from it, but **do not copy wholesale**: MFF renders and dispatches differently on GTK, and Astoria's
text carries Win32-specific claims. Anything about rendering, theming, dark mode, or Win32 message
handling must be re-verified against the GTK build before it is stated here.

**What is already known** (verified on GTK — see [ControlTesting.md](ControlTesting.md)):

- `ToolBar` is the only control that renders icons on this build (`gtk_image_new_from_icon_name`);
  `CommandButton` and `Label` have empty image stubs on GTK.
- A single `ToolBar` button in a narrow strip needs `gtk_toolbar_set_show_arrow(FALSE)` or it
  collapses to an overflow chevron.
- A `CommandButton`/`Label` caption rotates with `gtk_label_set_angle` on the label child; wiring an
  event needs `.Designer` set first (the dispatch dereferences it).

Fill this in control-by-control as controls are used and observed. The
[find-framework-control](../.claude/skills/find-framework-control/SKILL.md) skill locates a
control's header, API, and examples in the meantime.

---

## Changes made to the vendored framework

MFF is Ilwaco's own fork, but a framework change still gets recorded here so it is not mistaken for
upstream behaviour.

- **`Control` destructor clears a shared `ContextMenu`'s back-pointer (2026-08-04,
  `mff/Control.bas`).** `Control.ContextMenu`'s setter does `FContextMenu->ParentWindow = @This`, and
  nothing cleared it. When one menu is shared across N controls — as Ilwaco does, pointing every
  tab's editor at the single `mnuCode` — the last control to bind wins the back-pointer, and
  destroying that control leaves the menu holding a dangling `Component Ptr`. The next
  `MenuItem.Enabled` write then dereferences it; a null check cannot help, because reaching
  `->Handle` derefs the dead object first. The destructor now nulls it, **only when it still points
  at the dying control**, so a menu already re-bound to a living control keeps its binding.
  Ported from Astoria `154fb8aa` (their 13.68), which proved it with matched pointers over a 78-tab
  close. Note: this did *not* cure Ilwaco's Close Project crash — it is a real latent bug fixed on
  its own merits.

- **`TabControl.DeleteTab` clears a surviving page's `_Label`/`_Box` (2026-08-04,
  `mff/TabControl.bas`). This was the Close Project crash.** `gtk_notebook_remove_page` drops the
  last reference to the tab's box and label, so GTK finalises them — but `_Label` was assigned in
  four places and nulled nowhere, leaving a non-dynamic `TabPage` pointing at freed widgets.
  `TabPage.Text` then does `If GTK_IS_LABEL(_Label) Then gtk_label_set_text(...)`, and
  `GTK_IS_LABEL` reads the instance's class pointer — so, exactly like `IsWindow()` in the entry
  above, **it cannot detect a freed widget; it dereferences it first.**

  Diagnosed from a core dump without a debugger: parsing the core's `NT_PRSTATUS` note gave
  `RIP = 0x6b331d`, which `nm` placed in `TabPage.Text__set__` and `objdump` showed as the third
  dereference of the `GTK_IS_LABEL` chain. The faulting address was `RAX = 0x0000006600000061` —
  not a pointer at all, but the UTF-32 text `"af"`, i.e. the label's heap already recycled into a
  wide string. Reproduced via `CloseProject → ClearAnalysisPanels → tpProblems->Caption = …`.

  Regression-checked: `SetDebugTabsVisible` removes and re-adds the seven debug tabs, and their
  captions still render after the change (`AddTab` re-creates `_Label`).

- **`InputBox` gained a Cancel button (2026-08-04, `mff/Application.bas`).** It offered only OK;
  `Escape` and the window-manager close both worked but were not discoverable — poor for Ilwaco's
  beginner audience. Cancel is packed left of OK (GTK/GNOME order) and responds
  `GTK_RESPONSE_CANCEL` without copying the entry text, so `InputBox` returns `""` — exactly what
  Escape already produced and what every caller treats as "cancelled". No call site changed.

**Framework behaviour worth knowing (not a change):** FreeBASIC's `Name` statement **fails silently**
on a directory rename inside the IDE — it reports through `Err` and carries on. A standalone test
renamed a directory fine, so the difference is the call context (MFF's `UString` operands rather
than plain `String`). `RenameProject` now calls libc `rename(2)` directly and shows `strerror(errno)`
on failure. Prefer `rename(2)` over `Name` for paths held in `UString`.
