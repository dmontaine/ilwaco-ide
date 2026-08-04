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
  close. Note: this did *not* cure Ilwaco's deterministic Close Project crash (see
  [TechnicalDebt.md](TechnicalDebt.md)) — it is a real latent bug fixed on its own merits.
