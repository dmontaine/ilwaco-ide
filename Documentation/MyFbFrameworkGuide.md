# MyFbFramework guide (GTK)

**Status: scaffold.** A tracked placeholder, not yet written for Ilwaco. It exists so the document
has an analogue, is listed in the rule table, and is caught by `DocCheck` when it goes stale — see
[TestPlan.md](TestPlan.md).

**Purpose.** The working guide to MyFbFramework (MFF) for someone building or modifying Ilwaco's UI:
the object model, how forms and controls are constructed and parented, the event-dispatch model, and
the GTK interop patterns Ilwaco relies on.

**Source to adapt.** Astoria maintains a full `MyFbFrameworkGuide.md` (~1300 lines) for its Win64
build. Adapt from it, but MFF is **our fork now** (diverged, GTK-only) — anything Win32-specific
(uxtheme, Direct2D, `SendMessage`/`Perform` message plumbing) is either gone or reimplemented, so
re-verify against the GTK source before stating it here.

**GTK interop facts already established** (durable, verified in this codebase):

- MFF `Panel` is a `GtkLayout` (absolute positioning) — raw GTK children do not auto-size to it;
  MFF-docked children (`.Align`) are the reliable path.
- A control reparented into a GTK overlay (e.g. a pin over a panel) must be shown with
  `gtk_widget_show_all` after re-show, or it stays present-but-blank; `gtk_widget_queue_resize` on
  the overlay re-runs its `get-child-position`.
- Icons come from the `ImageList`, which is backed by a `GtkIconTheme`; a `ToolBar` button loads one
  by key via `gtk_image_new_from_icon_name`.
- Event handlers dispatch as `OnClick(*Designer, This)` — set `.Designer` before wiring, or the
  dereference crashes; assigning a property that fires the handler (e.g. `.Checked`) counts.

The FreeBASIC/MFF compiler traps that apply project-wide live in [CLAUDE.md](../CLAUDE.md); fold the
GTK-specific ones into this guide as it is written. The
[find-framework-control](../.claude/skills/find-framework-control/SKILL.md) skill is the interim
lookup tool.
