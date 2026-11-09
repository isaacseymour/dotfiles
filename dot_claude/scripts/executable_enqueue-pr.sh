#!/usr/bin/env bash
# Add an incident-io/core PR to the merge queue, but only one Isaac has approved and whose
# CI is green. Claude may run this without asking (see settings.json); it can't merge an
# unreviewed PR because the checks below refuse first.
#
# Usage: enqueue-pr.sh <pr-number>
set -euo pipefail

pr="${1:?usage: enqueue-pr.sh <pr-number>}"
[[ "$pr" =~ ^[0-9]+$ ]] || { echo "not a PR number: $pr" >&2; exit 2; }
repo="incident-io/core"

# /approve and /bypass-approve approve through these bots. github-actions is the
# automatic AI reviewer and doesn't count.
approvers='["incident-io-auto-approver","incident-io-core-approver"]'

pr_json=$(gh pr view "$pr" --repo "$repo" --json id,state,isDraft,reviewDecision,mergeStateStatus,reviews,statusCheckRollup)

state=$(jq -r .state <<<"$pr_json")
[ "$state" = OPEN ] || { echo "#$pr is $state" >&2; exit 1; }
[ "$(jq -r .isDraft <<<"$pr_json")" = false ] || { echo "#$pr is a draft" >&2; exit 1; }
[ "$(jq -r .reviewDecision <<<"$pr_json")" = APPROVED ] || { echo "#$pr is not approved" >&2; exit 1; }

approved_by_isaac=$(jq --argjson ok "$approvers" \
  '[.reviews[] | select(.state == "APPROVED") | .author.login | select(IN($ok[]))] | length > 0' <<<"$pr_json")
[ "$approved_by_isaac" = true ] || { echo "#$pr has no approval from Isaac" >&2; exit 1; }

failed=$(jq -r '[.statusCheckRollup[] | select((.conclusion // .state) | test("FAILURE|ERROR"))
  | (.name // .context) | select(. != "migrations")] | join(", ")' <<<"$pr_json")
[ -z "$failed" ] || { echo "#$pr has failing checks: $failed" >&2; exit 1; }

merge_state=$(jq -r .mergeStateStatus <<<"$pr_json")
[[ "$merge_state" =~ ^(CLEAN|UNSTABLE|HAS_HOOKS)$ ]] || { echo "#$pr is not ready to merge: $merge_state" >&2; exit 1; }

gh api graphql \
  -f query='mutation($id:ID!){enqueuePullRequest(input:{pullRequestId:$id}){mergeQueueEntry{position state}}}' \
  -f id="$(jq -r .id <<<"$pr_json")" \
  --jq ".data.enqueuePullRequest.mergeQueueEntry | \"#$pr queued: \(.state) position \(.position)\""
