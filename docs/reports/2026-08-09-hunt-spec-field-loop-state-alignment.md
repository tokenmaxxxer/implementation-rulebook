---
proposal: docs/issue-75/proposals/2026-08-09-spec-field-loop-state-alignment.md
---

# Hunt record — spec-field-loop-state-alignment

## before-landing — stance: assume the gate just touched is bypassable — find the bypass

Verdict: FINDING — no-leading-`---` fallback treats the entire body as the frontmatter block, so any loose `key: value` lines anywhere in free text satisfy the new (and pre-existing) presence checks without real YAML frontmatter existing.
Kind: silent-failure
Seed: git diff HEAD -- record-shape/hooks/record-shape-gate.sh (extends frontmatter presence check with `type:`, `breaking:`, `verdict:`)
cap_seconds: 180
tier: default
diff_stat_lines: 9 insertions in record-shape-gate.sh (plus unrelated README/spec/test churn elsewhere in the diff)
started_at: 2026-08-09T05:50:00Z
ended_at: 2026-08-09T06:05:00Z

### Reproduce
Gate logic (record-shape/hooks/record-shape-gate.sh, ~line 145):

    lines = new_text.split("\n")
    frontmatter = ""
    if lines[:1] == ["---"]:
        ...
    else:
        frontmatter = new_text   # whole body used as "frontmatter" when no leading '---'

Drive the gate directly with a `Write` payload whose content has no `---` delimiters at all, but contains five loose `key: value` lines plus the required heading, targeting `docs/issue-75/reports/implementation.md`:

    Some notes about the change.
    type: feature
    breaking: false
    verdict: pass
    code_under_review: something
    loop_state: iterating

    ## What did not work

    None.

Package this into a PreToolUse-style JSON payload `{"tool_name":"Write","tool_input":{"file_path":"<root>/docs/issue-75/reports/implementation.md","content":"<above>"}}` and pipe it to the gate against a fake project root that has a `.git` dir and `docs/specs/role-handoff-contract.md`:

    CLAUDE_PROJECT_DIR=<fake-root> bash record-shape/hooks/record-shape-gate.sh < payload.json
    echo "EXIT CODE: $?"

### Observed
`EXIT CODE: 0` — the gate approves the write. All five `missing` checks (`code_under_review:`, `loop_state:`, `type:`, `breaking:`, `verdict:`) pass because the regexes are applied `(?m)^key:` against the entire document body (since it never starts with a literal `---` line), not against an actual YAML frontmatter block. The file has no real frontmatter at all — it is prose with scattered key-like lines — yet the gate treats it as fully compliant.

### Expected
A `docs/issue-<n>/reports/implementation.md` write with no genuine `---`-delimited frontmatter block should be denied (as "missing frontmatter" / all keys missing), the same way the gate already fail-closes when the closing `---` is absent (the `end is None` branch sets `frontmatter = ""`). Instead the "no opening `---`" branch silently falls back to scanning the whole body, which lets any document with plausible-looking `key: value` prose lines masquerade as having valid frontmatter — a bypass that predates this diff but is now reachable for three additional required keys (`type:`, `breaking:`, `verdict:`), widening the same hole.
