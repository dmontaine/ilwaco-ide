# Framework features (GTK)

**Status: scaffold.** A tracked placeholder, not yet written for Ilwaco. It exists so the document
has an analogue, is listed in the rule table, and is caught by `DocCheck` when it goes stale — see
[TestPlan.md](TestPlan.md).

**Purpose.** The framework surface **beyond the toolbox controls** — the capabilities Framework
provides that are not a placeable control: settings/INI handling, the image list, dialogs, drawing
(`Canvas`), theming/dark mode, clipboard, timers, and the like — as they behave on GTK3.

**Source to adapt.** Astoria maintains `FrameworkFeatures.md` (~290 lines). Adapt from it, but the
Win32-only capabilities (uxtheme dark mode, Direct2D canvas) are stripped or reimplemented here — do
not carry their descriptions over unverified.

**Known GTK-side notes:**

- **Dark mode does not fire yet.** MFF has a real GTK3 `SetDarkMode`, but `g_darkModeSupported` was
  only set by the deleted Win32 `InitDarkMode`, so the styling branch never runs. Reimplement is
  tracked in [TechnicalDebt.md](TechnicalDebt.md).
- **`ImageList` is a `GtkIconTheme`** — icons are looked up by key name, not by index into a bitmap
  strip.

Fill this in capability-by-capability. A change to a non-toolbox framework capability triggers an
update here — see the rule table in [TestPlan.md](TestPlan.md).
