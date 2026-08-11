---
proposal: docs/issue-82/proposals/2026-08-11-close-as-subsumed.md
---

# Hunt record — close-as-subsumed

## after-proposal — stance 3: assume the rule as written cannot hold — find the state nothing maintains

Verdict: FINDING — the survey's "confirmed live in this session's own injected reminders" claim depends on an unmaintained invariant: this repo's own SessionStart directive scripts (e.g. coding/hooks/directive.sh) have no vendored/local core/ fallback and no unguarded-source error handling, so with CLAUDE_PLUGIN_ROOT_CORE unset the directive silently produces no output while still touching a fatal error path — and no test in this repo exercises that path for directive.sh (only bash -n syntax checks).
Kind: silent-failure
Seed: docs/issue-82/proposals/2026-08-11-close-as-subsumed.md, docs/issue-82/reports/implementation/survey.md
cap_seconds: 120
tier: default
diff_stat_lines: ~140 (2 new doc files)
started_at: 2026-08-11T00:00:00Z
ended_at: 2026-08-11T00:05:00Z

### Reproduce
```
cd /home/jwjung/.tokenmaxxxer/work/implementation-rulebook-issue-82-implementation
env -u CLAUDE_PLUGIN_ROOT_CORE bash coding/hooks/directive.sh < /dev/null >/tmp/out.txt 2>/tmp/err.txt
echo "exit=$?"; cat /tmp/out.txt; echo ---; cat /tmp/err.txt

grep -n "directive.sh" -A3 -B3 tests/methodology-plugins-tests.sh
```

### Observed
`directive.sh` exits 127 with empty stdout (the SessionStart hook injects nothing) once `CLAUDE_PLUGIN_ROOT_CORE`
is unset and this repo has no local `core/` directory to fall back to (`cd coding/hooks/../../core` fails: no
such directory). The `.` on line 6 of `coding/hooks/directive.sh` is unguarded (no `||` handler, unlike the
gate scripts which do `|| { echo ...; exit 2; }`), so the script silently falls through to calling the now-undefined
`core_role_directive` function. The only test referencing `directive.sh` (`tests/methodology-plugins-tests.sh`)
only runs `bash -n` (syntax check) — it never executes the script, so this missing-core / no-reminder path is
completely unverified by this repo's own test suite. The survey's claim that the non-terminal-loop_state rule is
"confirmed live in this session's own injected reminders" is therefore an artifact of this one session having
`CLAUDE_PLUGIN_ROOT_CORE` correctly pre-set by the marketplace installer, not a fact this repo's own state
guarantees or checks.

### Expected
Either the repo vendors/checks-in a real `core/` fallback so the directive is self-sufficient, or `directive.sh`
guards its `source`/exit path the same way the gate scripts do (loud, non-zero, visible failure) and the test
suite exercises the missing-core case for every plugin's `directive.sh`, not just its gate script — so the
survey's "already covered / confirmed live" claim rests on something this repo actually maintains rather than
one session's ambient environment.
