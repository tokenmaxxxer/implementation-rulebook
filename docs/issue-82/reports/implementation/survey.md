# Survey: does this rulebook's record TEMPLATE still name a bare count or a non-terminal loop_state without next-steps, after on-the-record#730 and tokenmaxxxer-core#204?

## Scope

Issue #82's root complaint is that implementation role sessions' phase-2
board records repeatedly trip on-the-record's `record-claim-guard` (bare
counts need a code fence or `derived:` citation) and `record-fields-gate`
(non-terminal `loop_state` needs `next-steps` + an open-finding
resolution path). Both gates live in the external `on-the-record` repo
and check the record *content* a role session produces, not this repo.
This repo (`tokenmaxxxer`) is the source of the *guidance* — the
directive text and template description a role session models its
record on before writing it.

Per the issue: on-the-record#730 already makes on-the-record proactively
inject the claim-citation shape to every role, and tokenmaxxxer-core#204
adds the shared record-shape rules generically. Both are landed upstream
of this session (confirmed live in this very session's injected system
reminders — see below). The task is to find what, if anything, is left
in *this* rulebook's own record-shape guidance that would still produce
a bare count or a non-terminal loop_state lacking next-steps, on top of
what #730/#204 already cover.

## What this rulebook actually emits as record guidance

Two sources in this repo describe the phase-2 record shape to an
implementation-role session:

1. `coding/hooks/directive.sh:14` (`HAND_OFF`) — SessionStart directive,
   injected once per session. Text: "RECORD REQUIREMENT... your record
   lives at docs/issue-<n>/reports/implementation.md... Its frontmatter
   carries implementation.spec.json's four deliverable fields —
   commit_sha (realized here as code_under_review:), type, breaking,
   verdict — plus loop_state, whose vocabulary is coding,
   commit-unreachable, committing, landed, scope-undeclared (terminal:
   landed)."
2. `record-shape/hooks/directive.sh:24-58` — UserPromptSubmit directive,
   injected every turn. Text covers the same four frontmatter fields
   plus `## What did not work` (present-even-when-empty) and the
   conditional `## Rationale for deviations` section.

Neither file contains a literal filled-in record example — no sample
`code_under_review:` block, no sample count, no sample `loop_state:`
value populated with placeholder prose. Both are abstract field/heading
requirements (`grep -n template` over the repo returns zero hits: no
`docs/**/*template*`, no vendored record skeleton with example content).
So there is no template body in this repo that could itself violate
record-claim-guard by naming a bare count, because no template body
names any count at all.

## Coverage check against the two gates named in the issue

- **record-claim-guard** (bare count needs a code fence or `derived:`
  citation): neither `coding/hooks/directive.sh` nor
  `record-shape/hooks/directive.sh` instructs or models writing a count
  claim in any form — bare or cited. The claim-citation shape itself
  (what a cited claim looks like) is what on-the-record#730 now injects
  directly; this repo does not duplicate or contradict it anywhere.
- **record-fields-gate** (non-terminal `loop_state` needs `next-steps` +
  resolution path): this repo's own two directives state the
  `loop_state` vocabulary and its terminal value (`landed`) but do not
  themselves state the next-steps/resolution-path requirement for
  non-terminal states — that requirement is absent from both
  `coding/hooks/directive.sh` and `record-shape/hooks/directive.sh`.
  Confirmed live: this session's own injected system reminders (from the
  `core` plugin, external to this repo) already carry that exact
  requirement verbatim — "Whenever loop_state is non-terminal for your
  record's kind, also state next steps... and an open-finding resolution
  path" — i.e. tokenmaxxxer-core#204's shared record-shape rule is
  active in this repo's own sessions right now, sourced from core, not
  duplicated here.

## Residual gap found

None. This rulebook's directives never assert a bare count and never
omit the non-terminal-loop_state-needs-next-steps rule in a way that
contradicts or duplicates core's now-landed shared rule — that rule
already reaches implementation-role sessions via core's own injected
directive (`docs/issue-52/proposals/2026-07-31-implementation-domain-norms.md`
established the frontmatter/heading shape this repo's directives carry;
`record-shape-gate.sh` mechanically enforces frontmatter + headings only,
never count-citation or next-steps content — that content-level
enforcement was never this repo's job, it is on-the-record's, and #730
now handles the citation half proactively).

## Caveat found by hunt (after-proposal, stance 3)

`docs/issue-82/reports/implementation/2026-08-11-hunt-close-as-subsumed.md`
found that this survey's "confirmed live in this session's own injected
reminders" evidence rests on an unmaintained invariant, not a repo
guarantee: `coding/hooks/directive.sh` (and sibling plugins' equivalents)
source core's `role-directive.sh` with no local fallback and no error
guard on the `.` (unlike this repo's gate scripts, which do
`|| { echo ...; exit 2; }`). With `CLAUDE_PLUGIN_ROOT_CORE` unset and no
vendored `core/` directory, the SessionStart hook exits 127 and silently
emits no directive text — untested by this repo's own suite
(`tests/methodology-plugins-tests.sh` only runs `bash -n` on
`directive.sh`, never executes it). So core#204's rule reaching this
session is a fact about this session's environment, not a fact this repo
mechanically guarantees for every session.

This does not change the survey's conclusion about issue #82's actual
scope (this rulebook's own directive text still never asserts a bare
count, and does not duplicate the next-steps rule) — but it is a real,
separate silent-failure risk in the plugin wiring, out of this issue's
frozen write set (`docs/issue-82/**`) to fix. Flagged here as an open
finding for a follow-up issue against `coding/hooks/directive.sh` (and
sibling `directive.sh` files) to add a guarded source / fallback, not
fixed in this phase-1-only, docs-only issue.

## Skip-condition note

No design decision is open: the survey's own finding is "nothing to
build." Per the issue's own instruction — "If the survey finds the
residual is fully covered by #730/#204, say so and propose closing as
subsumed rather than inventing work" — the proposal that follows
recommends closing #82 as subsumed rather than proposing a code change.
