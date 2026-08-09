# Shared test-env resolution helper (issue #79, docs/specs/test-env-resolution.md,
# on-the-record issue #551). Sourced by this repo's gate-test scripts in
# place of each one's own ad hoc CLAUDE_PLUGIN_ROOT_CORE resolution block.
#
# Requires the sourcing script to have already set REPO_ROOT to this repo's
# root (absolute path). On success, exports CLAUDE_PLUGIN_ROOT_CORE and
# returns 0. On the convention's SKIP outcome, prints the SKIP message to
# stderr and returns 75 — the caller should `exit 75` in response so the
# whole test run reports as skipped, not failed.
if [ -z "${CLAUDE_PLUGIN_ROOT_CORE:-}" ]; then
  _resolved="$(python3 "$REPO_ROOT/gates/test_env_resolve.py" \
    "$HOME/tokenmaxxxer/tokenmaxxxer-core/core" "$REPO_ROOT/../core" 2>&1)"
  _rc=$?
  if [ "$_rc" -eq 75 ]; then
    printf '%s\n' "$_resolved" >&2
    return 75
  elif [ "$_rc" -ne 0 ]; then
    printf '%s\n' "$_resolved" >&2
    return "$_rc"
  fi
  export CLAUDE_PLUGIN_ROOT_CORE="$_resolved"
fi
unset _resolved _rc
