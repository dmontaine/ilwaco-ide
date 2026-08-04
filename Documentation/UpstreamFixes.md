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

## IDE (VisualFBEditor base) — GTK

*(none recorded yet beyond what is captured in `AstoriaParity.md` as ports)*

---

## Why this is short

Ilwaco is early in its Astoria-parity walk, and most work so far is **porting** Astoria's changes or
**stripping** Windows-only code — neither of which is an upstream-worthy GTK bug fix. As GTK bugs in
the shared base surface and are fixed here, list them above with symptom, file, and commit hash. The
maintenance rule: a fix to vendored upstream code (VisualFBEditor or MFF) triggers a line here — see
[TestPlan.md](TestPlan.md).
