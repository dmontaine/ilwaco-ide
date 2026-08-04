"""Check that Ilwaco's maintained documents still describe the software that exists.

    python3 Tools/DocCheck.py            # report and exit non-zero on any finding
    python3 Tools/DocCheck.py --list     # show what is checked and where the rules live

Why it exists: `Documentation/TestPlan.md` carries a rule saying which document to update
when, and CLAUDE.md points at it. The rule is only as good as the thing that catches it being
skipped -- a *removal* produces no test, so nothing invokes "update the docs after a test", and
a deleted feature can go on being documented for days. Astoria learned this the hard way (five
documents described a Git menu four days after it was deleted) and grew this checker; Ilwaco
inherits the lesson without the Windows-only machinery (no Chrome-rendered PDF, no PowerShell
changelog).

This does not check that documents were *visited*. It checks the specific, mechanical ways they
go stale:

  1. a document names a removed feature as if it still ships (REMOVED_FEATURES below);
  2. a document names a file, in inline code, that no longer exists in the repo;
  3. a maintained document is missing from the rule table in Documentation/TestPlan.md.

Adding a removal is one line in REMOVED_FEATURES. That is the whole maintenance cost, and it is
paid once by whoever does the removing -- which is the point.

Linux/GTK notes (how this differs from Astoria's DocCheck):
  - file-suffix set is Linux (.so, .sh); no .dll/.exe/.ps1/.bat;
  - no ROADMAP.md section-status check -- Ilwaco has no §-numbered roadmap; the forward-looking
    record is Documentation/AstoriaParity.md + PROJECT_STATUS.md, which are prose;
  - no rendered-copy (.pdf/.txt) freshness/together checks -- Ilwaco keeps no rendered copies.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = "Documentation"

# Pure historical records: they describe what WAS true (the Astoria port history / backlog) and
# must not be judged against what ships now. Analogous to Astoria excluding its DetailedChangelog.
EXCLUDE = {"AstoriaDetailedChangeLog.md", "AstoriaParity.md"}

# A finding is suppressed when the line, or any of the few lines around it, marks the passage as
# historical -- so a removal notice ("we removed the compiler picker") does not read as the very
# drift this is meant to catch.
HISTORICAL = re.compile(
    r"OBSOLETE|Obsolete|superseded|Superseded|no longer|removed|Removed|deleted|Deleted|"
    r"Original text follows|was removed|has since been|predate|upstream|historical|stripped",
    re.I)
LOOKBACK = 8

# Features taken out of Ilwaco (owner directives + Astoria parity). Each entry: a pattern to look
# for, and what it was. The pattern must be specific enough not to fire on a removal notice itself
# (which HISTORICAL already suppresses) or on legitimate framework/history prose -- test with
# --selftest after adding one. Ilwaco's own docs are new, so this is mostly a forward guard.
REMOVED_FEATURES = [
    (r"\bcompiler picker\b",            "the compiler-selection UI (removed: one bundled compiler)"),
    (r"Choose\s+(?:a\s+)?[Cc]ompiler",  "the compiler-selection UI (removed: one bundled compiler)"),
    (r"\bOpenCode\b",                   "a non-Claude AI assistant (removed: AI features stripped)"),
    (r"\bChatGPT/Codex\b",              "a non-Claude AI assistant (removed: AI features stripped)"),
    (r"Use\s+Direct2D",                 "the Direct2D user option (removed; Win32-only path stripped)"),
    (r"32-bit\s+(?:build|target|compiler)", "32-bit build support (removed: Ilwaco is x86_64-only)"),
]

# Files whose absence should be reported when a document still names them, written as an
# inline-code path. Linux suffix set: .so (not .dll), .sh (not .ps1/.bat), no .exe.
PATH_IN_CODE = re.compile(r"`([A-Za-z0-9_./\\-]+\.(?:bas|bi|frm|rc|so|a|vfp|ini|md|py|sh))`")


def repo_docs():
    out = []
    for name in sorted(os.listdir(os.path.join(ROOT, DOCS))):
        if name.endswith(".md") and name not in EXCLUDE:
            out.append(os.path.join(DOCS, name))
    return out


def read(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
        return fh.read().split("\n")


def historical(lines, i):
    """A passage is historical if it is marked so nearby -- in EITHER direction."""
    lo, hi = max(0, i - LOOKBACK), min(len(lines), i + LOOKBACK + 1)
    return any(HISTORICAL.search(lines[j]) for j in range(lo, hi))


def check_removed_features(findings, selftest_extra=None):
    rules = REMOVED_FEATURES + (selftest_extra or [])
    for rel in repo_docs():
        lines = read(rel)
        for i, ln in enumerate(lines):
            if historical(lines, i):
                continue
            for pat, what in rules:
                if re.search(pat, ln):
                    findings.append((rel, i + 1, "names %s as if it still ships" % what))


def repo_file_index():
    """Every tracked path, lowercased, for suffix matching.

    Documents name files the way a reader thinks of them -- `mff/Form.bas`, not the full path --
    so matching on a path SUFFIX accepts the shorthand while still catching a name that exists
    nowhere.
    """
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True)
    return {p.strip().lower() for p in out.stdout.splitlines() if p.strip()}


def check_missing_files(findings):
    index = repo_file_index()
    for rel in repo_docs():
        lines = read(rel)
        for i, ln in enumerate(lines):
            if historical(lines, i):
                continue
            for cand in PATH_IN_CODE.findall(ln):
                rel_path = cand.replace("\\", "/").lstrip("./")   # case-preserving, for the FS check
                norm = rel_path.lower()                           # lowercased, for the git-index check
                if "/" not in norm:
                    continue                      # a bare name is usually prose, not a path
                if any(f == norm or f.endswith("/" + norm) for f in index):
                    continue
                # Case-sensitive filesystem: check the original-case path, not the lowercased one.
                if os.path.exists(os.path.join(ROOT, rel_path)):
                    continue                      # present but untracked, e.g. a settings file
                findings.append((rel, i + 1, "names `%s`, which exists nowhere in the repo" % cand))


def check_rule_table(findings):
    text = "\n".join(read(os.path.join(DOCS, "TestPlan.md")))
    start = text.find("| Document | Update when |")
    if start < 0:
        findings.append((os.path.join(DOCS, "TestPlan.md"), 0,
                         "the rule table is missing -- nothing tells a maintainer what to update"))
        return
    block = text[start:text.find("\n\n", start)]
    listed = set(re.findall(r"([A-Za-z0-9]+\.md)", block))
    for rel in repo_docs():
        name = os.path.basename(rel)
        if name not in listed:
            findings.append((os.path.join(DOCS, "TestPlan.md"), 0,
                             "%s is maintained but appears in no rule" % name))


def run(selftest_extra=None):
    findings = []
    check_removed_features(findings, selftest_extra)
    check_missing_files(findings)
    check_rule_table(findings)
    return findings


def main(argv):
    if "--list" in argv:
        print(__doc__)
        print("Removed features currently watched for:")
        for pat, what in REMOVED_FEATURES:
            print("  %-34s %s" % (pat, what))
        print("\nDocuments checked:")
        for rel in repo_docs():
            print("  " + rel)
        return 0

    if "--selftest" in argv:
        # A pattern that should fire, proving the machinery works end to end.
        extra = [(r"\bZZ_SELFTEST_FEATURE\b", "a self-test sentinel")]
        n = len(run(selftest_extra=extra)) - len(run())
        print("selftest: %s" % ("OK" if n >= 0 else "FAILED"))
        return 0

    findings = run()
    if not findings:
        print("Documentation is current (%d documents checked)." % len(repo_docs()))
        return 0
    print("Documentation is STALE -- %d finding(s):\n" % len(findings))
    for rel, line, why in findings:
        where = "%s:%d" % (rel, line) if line else rel
        print("  %-52s %s" % (where, why))
    print("\nSee the rule table in Documentation/TestPlan.md for which document to update when.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
