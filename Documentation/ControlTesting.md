# Control testing — per-control results (GTK)

Per-control test results for the Framework controls as they behave in Ilwaco's **GTK3** build.
The companion documents are [Controls.md](Controls.md) (what each control is) and
[TestPlan.md](TestPlan.md) (scenarios to run). Results here are the record of what was actually
observed on `DISPLAY=:0`.

**Status: no systematic sweep has been run yet.** Astoria ran a 73-control sweep on its Win64
build; that result does **not** transfer — GTK renders, docks, and dispatches events differently, so
each control has to be re-observed on the live GTK display. This table is the ledger for that work.

Passing "alone" is not passing "in use": a control that opens its window can still break when docked
inside a container, or when its events fire while another control holds focus. Record the condition,
not just PASS/FAIL.

---

## Results

| Control | Condition tested | Result | Date | Notes |
| --- | --- | --- | --- | --- |
| `ToolBar` | icon renders in a narrow (34px) strip only with `gtk_toolbar_set_show_arrow(FALSE)` | **PASS** | 2026-08-04 | else it collapses to an overflow chevron |
| `CommandButton` | caption rotates 90°/270° via `gtk_label_set_angle` on `gtk_bin_get_child`; `OnClick` fires with `.Designer` set | **PASS** | 2026-08-04 | renders **no** image on GTK (empty `GraphicChange` stub) |
| `Label` | renders no image on GTK (empty `GraphicChange` stub) | **NOTE** | 2026-08-04 | icons come only from `ToolBar` |
| `TabControl` | vertical tab labels rotate; detachable tabs; `DetachTab` preserves the page | **PASS** | 2026-08-03 | see debug-tab-visibility work |

*(extend as controls are exercised; a new observation triggers a row here and, if the control's API
or behaviour is what changed, `Controls.md` — see the rule table in `TestPlan.md`)*
