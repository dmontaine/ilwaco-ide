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
