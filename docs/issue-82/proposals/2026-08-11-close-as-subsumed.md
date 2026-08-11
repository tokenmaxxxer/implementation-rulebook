---
status: proposed
files:
  - docs/issue-82/reports/implementation/survey.md
  - docs/issue-82/proposals/2026-08-11-close-as-subsumed.md
---

## Request

Issue #82: implementation role sessions repeatedly hit on-the-record's
`record-claim-guard` (bare counts need a citation) and
`record-fields-gate` (non-terminal `loop_state` needs next-steps + an
open-finding resolution path) when writing their board records, because
this rulebook's record-shape guidance doesn't pre-satisfy those gates.
The issue explicitly notes on-the-record#730 (proactive claim-citation
injection to every role) and tokenmaxxxer-core#204 (shared record-shape
rules) have since landed, and asks for a survey of what per-rulebook
template gap remains after those two — fixing only the residual, or
proposing closure as subsumed if none remains.

## Constraints

- Write set confined to `docs/issue-82/**`; no code change unless the
  survey finds an actual residual gap.
- Do not restate on-the-record's or core's gate rules in a way that can
  drift from them — this repo mirrors, never duplicates authoritatively.
- Follow the issue's stated fallback: if the residual is fully covered,
  say so and propose closing as subsumed rather than inventing work.

## Rationale

Two structural options existed: (a) add explicit next-steps/citation
example language into `coding/hooks/directive.sh` and
`record-shape/hooks/directive.sh` so this repo's own record-shape text
mirrors the gates directly, or (b) survey first and, if core's
already-landed shared rule already reaches this repo's sessions (it
does — confirmed live in this session's own injected reminders), close
as subsumed instead of adding redundant guidance.

Option (a) was considered and rejected: `docs/issue-82/reports/implementation/survey.md`
shows neither directive in this repo ever asserts a bare count (so
there is nothing to add a citation requirement onto) and the
non-terminal-loop_state-needs-next-steps rule is already delivered to
every session in this repo by tokenmaxxxer-core's own SessionStart
directive (core#204), not by this repo's `coding` or `record-shape`
plugins. Adding the same rule a second time in this repo's directive
text would create exactly the drift risk the issue's own Constraints
section warns against ("Do not restate on-the-record's gate rule in a
way that can drift") — two copies of the same rule that could diverge
over time, for zero behavioral gain, since core's copy already reaches
these sessions. Option (b) is therefore the correct outcome, not a
default fallback taken for lack of effort.

## What will be done

Nothing further under this issue's write set beyond the survey already
committed. Recommend the human closes #82 as subsumed by
on-the-record#730 + tokenmaxxxer-core#204, with a comment linking
`docs/issue-82/reports/implementation/survey.md` as the evidence trail.

## Open finding (not fixed here)

The after-proposal hunt
(`docs/issue-82/reports/implementation/2026-08-11-hunt-close-as-subsumed.md`)
found that `coding/hooks/directive.sh` (and sibling plugins) source
core's `role-directive.sh` with no local fallback and no guard on the
`.`, so with `CLAUDE_PLUGIN_ROOT_CORE` unset the SessionStart hook
silently emits nothing (exit 127, untested by this repo's suite). This
means core#204's rule reaching a session is an environment fact, not a
repo-guaranteed one — it doesn't change this issue's own conclusion but
is a real gap outside `docs/issue-82/**`. Recommend filing a follow-up
issue against `coding/hooks/directive.sh` (and siblings) rather than
widening this issue's write set.

## Out of scope

- Any edit to `coding/hooks/directive.sh` or
  `record-shape/hooks/directive.sh` — the survey found no residual gap
  to fix there.
- Any change to on-the-record's or tokenmaxxxer-core's gates or
  directives — out of this repo entirely.

## How you'll know it worked

`docs/issue-82/reports/implementation/survey.md` traces both of this
repo's record-shape-emitting files (`coding/hooks/directive.sh`,
`record-shape/hooks/directive.sh`), shows neither names a bare count nor
omits/contradicts the next-steps-for-non-terminal-loop_state rule, and
shows that rule is already live in-session via tokenmaxxxer-core's
directive. A reader can re-run the same greps this survey ran
(`grep -rn "template"`, `grep -n loop_state coding/hooks/directive.sh
record-shape/hooks/directive.sh`) and reach the same conclusion.
