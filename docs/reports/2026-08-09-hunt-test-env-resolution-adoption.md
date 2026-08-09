---
proposal: docs/issue-79/proposals/2026-08-09-test-env-resolution-adoption.md
---

# Hunt record — test-env-resolution-adoption

## after-proposal — stance 0: assume the gate just touched is bypassable — find the bypass

Verdict: NO FINDING
Seed: docs/issue-79/proposals/2026-08-09-test-env-resolution-adoption.md, docs/issue-79/reports/implementation/survey.md (docs-only diff, no gates/test_env_resolve.py or tests/lib/resolve-core-env.sh exist in the repo yet)
cap_seconds: 60
tier: default
diff_stat_lines: 2 files added (proposal + survey), no code
started_at: 2026-08-09T00:40:58Z
ended_at: 2026-08-09T00:41:20Z

Checked repo for any pre-existing implementation to probe (`grep -rn "exit 75\|SKIP"`, searches for `gates/`, `tests/lib/`, `core-resolution`, `CORE_ENV`, `resolve-core-env`) — none exist. The proposed gates/test_env_resolve.py, tests/lib/resolve-core-env.sh, and the 8 gate-test-script call sites that would source it are all future work; nothing is built to run or bypass. Cannot produce a reproduction against code that does not exist. No finding.

## before-landing — stance 4: assume the write set cannot carry this work — find a path the build needed that the frozen proposal write set does not list

Verdict: NO FINDING
Seed: uncommitted working-tree diff implementing docs/issue-79/proposals/2026-08-09-test-env-resolution-adoption.md (gates/test_env_resolve.py, tests/lib/resolve-core-env.sh, and edits to the eight listed test scripts + docs/handbooks/gate-tests.md)
cap_seconds: 120
tier: before-landing
diff_stat_lines: ~140 (git diff on the 8 modified test scripts) + 2 new files (gates/test_env_resolve.py, tests/lib/resolve-core-env.sh)
started_at: 2026-08-09T01:37:29Z
ended_at: 2026-08-09T01:41:00Z

Checked whether the vendored module needed an untracked sibling path (e.g.
`gates/__init__.py` for `import gates.test_env_resolve` / `python3 -m
gates.test_env_resolve`, per the module's own docstring and
docs/issue-79/reports/implementation.md's claim of unit-testing it that way).
Python 3 namespace packages make this unnecessary — confirmed both
`python3 -c "from gates.test_env_resolve import resolve_core; ..."` and
`python3 -m gates.test_env_resolve <bogus> <bogus>` run correctly from repo
root with no `__init__.py` present.

Also checked whether `docs/specs/test-env-resolution.md`, referenced by
comment in all 8 edited scripts plus resolve-core-env.sh and gate-tests.md,
was a dangling local reference the write set forgot to add — it is not:
docs/handbooks/gate-tests.md and the survey explicitly document it as an
external, unvendored doc living in the `on-the-record` repo (issue #551),
consistent with the "referenced, never vendored" convention already used for
gate-lib.sh/gate-lib.py elsewhere in this repo.

Ran the actual SKIP branch end-to-end (the implementation report says this
was blocked by sandbox approval and only unit-tested) by unsetting
CLAUDE_PLUGIN_ROOT_CORE and pointing HOME at a nonexistent dir, then running
`bash tests/run-gate-tests.sh`: prints `SKIP: core plugin unreachable —
unverifiable outside spawn env` to stderr and exits 75 as documented — the
`|| exit 75` wiring around `source .../resolve-core-env.sh` works correctly
even though `return 75` happens inside a sourced file rather than a function.

`coding/hooks/tests/hunt-guard-tests.sh` and `hunt-state-tests.sh` do fail in
this checkout (exit-127, `hunt-guard.sh: No such file or directory`), but
`git diff` confirms this is pre-existing on unmodified HEAD (hunt-guard.sh
was deleted in an unrelated prior commit, b1a6b88, "canon rollout: remove
remaining vendored canon files"), not something this change's write set
introduced or should have listed — the implementation report notes the same
via git stash. No path this build actually needs is missing from the frozen
write set.
