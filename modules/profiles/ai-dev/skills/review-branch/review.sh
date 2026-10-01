#!/usr/bin/env bash
# GitHub pull request review helper.
#
# Keeps inline comments in one pending review until the user explicitly submits it.

set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  review.sh diff [--pr PR] [--output FILE]
  review.sh open [--pr PR]
  review.sh status [--pr PR]
  review.sh comment [--pr PR] --path FILE --line LINE --body TEXT [--side RIGHT]
                    [--start-line LINE] [--start-side RIGHT]
  review.sh submit [--pr PR] [--event COMMENT|APPROVE|REQUEST_CHANGES] [--body TEXT]
  review.sh discard [--pr PR]

PR may be a pull request number, URL, or branch accepted by `gh pr view`.
EOF
}

die() {
	echo "Error: $*" >&2
	exit 1
}

require_value() {
	local option=$1
	local count=$2
	[ "$count" -ge 2 ] || die "$option requires a value"
}

command -v gh >/dev/null || die "gh is required"
command -v jq >/dev/null || die "jq is required"

GH_REPO=$(gh repo view --json owner,name -q '"\(.owner.login)/\(.name)"' 2>/dev/null || true)
[ -n "$GH_REPO" ] || die "not a GitHub repository"

PR_REF=""
PR_JSON=""
PR_NUMBER=""
PR_HEAD=""
PR_URL=""

load_pr() {
	if [ -n "$PR_JSON" ]; then
		return
	fi

	if [ -n "$PR_REF" ]; then
		PR_JSON=$(gh pr view "$PR_REF" --repo "$GH_REPO" --json number,headRefOid,url 2>/dev/null) \
			|| die "could not resolve pull request $PR_REF"
	else
		PR_JSON=$(gh pr view --repo "$GH_REPO" --json number,headRefOid,url 2>/dev/null) \
			|| die "could not find a pull request for the current branch; pass --pr"
	fi

	PR_NUMBER=$(jq -r '.number' <<<"$PR_JSON")
	PR_HEAD=$(jq -r '.headRefOid' <<<"$PR_JSON")
	PR_URL=$(jq -r '.url' <<<"$PR_JSON")
}

pending_review() {
	local login reviews count
	login=$(gh api user --jq '.login')
	reviews=$(
		gh api --paginate "repos/$GH_REPO/pulls/$PR_NUMBER/reviews?per_page=100" --slurp \
			| jq -c --arg login "$login" '[.[][] | select(.state == "PENDING" and .user.login == $login)]'
	)
	count=$(jq 'length' <<<"$reviews")
	[ "$count" -le 1 ] || die "found $count pending reviews for $PR_URL; refusing to choose one"
	jq -c 'first // empty' <<<"$reviews"
}

ensure_pending_review() {
	load_pr
	local review
	review=$(pending_review)
	if [ -n "$review" ]; then
		local commit_id
		commit_id=$(jq -r '.commit_id' <<<"$review")
		[ "$commit_id" = "$PR_HEAD" ] \
			|| die "pending review targets $commit_id but the PR head is $PR_HEAD; revalidate and re-anchor its comments first"
		jq -c '{id, node_id, state, commit_id, html_url, user: .user.login}' <<<"$review"
		return
	fi

	gh api --method POST "repos/$GH_REPO/pulls/$PR_NUMBER/reviews" -f commit_id="$PR_HEAD" \
		| jq -c '{id, node_id, state, commit_id, html_url, user: .user.login}'
}

parse_target_only() {
	while [ $# -gt 0 ]; do
		case "$1" in
		--pr)
			require_value "$1" "$#"
			PR_REF=$2
			shift 2
			;;
		*) die "unknown option: $1" ;;
		esac
	done
}

save_diff() {
	local output=""
	while [ $# -gt 0 ]; do
		case "$1" in
		--pr)
			require_value "$1" "$#"
			PR_REF=$2
			shift 2
			;;
		--output)
			require_value "$1" "$#"
			output=$2
			shift 2
			;;
		*) die "unknown option: $1" ;;
		esac
	done

	load_pr
	if [ -z "$output" ]; then
		output="/tmp/review-branch-$PR_NUMBER.diff"
	fi
	gh pr diff "$PR_NUMBER" --repo "$GH_REPO" >"$output"
	jq -n --arg path "$output" --arg url "$PR_URL" --argjson number "$PR_NUMBER" \
		--argjson bytes "$(wc -c <"$output")" \
		'{pullRequest: $number, url: $url, path: $path, bytes: $bytes}'
}

open_review() {
	parse_target_only "$@"
	ensure_pending_review
}

review_status() {
	parse_target_only "$@"
	load_pr
	local review comments
	review=$(pending_review)
	if [ -z "$review" ]; then
		jq -n --arg url "$PR_URL" --arg head "$PR_HEAD" --argjson number "$PR_NUMBER" \
			'{pullRequest: $number, url: $url, headCommit: $head, pendingReview: null, comments: []}'
		return
	fi

	comments=$(gh api "repos/$GH_REPO/pulls/$PR_NUMBER/reviews/$(jq -r '.id' <<<"$review")/comments?per_page=100")
	jq -n --arg url "$PR_URL" --arg head "$PR_HEAD" --argjson number "$PR_NUMBER" --argjson review "$review" \
		--argjson comments "$comments" '
		{
		  pullRequest: $number,
		  url: $url,
		  headCommit: $head,
		  pendingReview: ($review | {id, node_id, state, commit_id, html_url}
		    + {head_commit_id: $head, stale: (.commit_id != $head)}),
		  comments: ($comments | map({
		    id, node_id, path, line, original_line, start_line, original_start_line,
		    side, position, original_position, body, html_url, commit_id, original_commit_id, diff_hunk
		  }))
		}'
}

add_comment() {
	local path=""
	local line=""
	local body=""
	local side="RIGHT"
	local start_line=""
	local start_side="RIGHT"

	while [ $# -gt 0 ]; do
		case "$1" in
		--pr)
			require_value "$1" "$#"
			PR_REF=$2
			shift 2
			;;
		--path)
			require_value "$1" "$#"
			path=$2
			shift 2
			;;
		--line)
			require_value "$1" "$#"
			line=$2
			shift 2
			;;
		--body)
			require_value "$1" "$#"
			body=$2
			shift 2
			;;
		--side)
			require_value "$1" "$#"
			side=$2
			shift 2
			;;
		--start-line)
			require_value "$1" "$#"
			start_line=$2
			shift 2
			;;
		--start-side)
			require_value "$1" "$#"
			start_side=$2
			shift 2
			;;
		*) die "unknown option: $1" ;;
		esac
	done

	[ -n "$path" ] || die "--path is required"
	[[ "$line" =~ ^[0-9]+$ ]] || die "--line must be a positive integer"
	[ "$line" -gt 0 ] || die "--line must be a positive integer"
	[ -n "$body" ] || die "--body is required"
	[[ "$side" = "LEFT" || "$side" = "RIGHT" ]] || die "--side must be LEFT or RIGHT"
	if [ -n "$start_line" ]; then
		[[ "$start_line" =~ ^[0-9]+$ ]] || die "--start-line must be a positive integer"
		[ "$start_line" -gt 0 ] || die "--start-line must be a positive integer"
		[[ "$start_side" = "LEFT" || "$start_side" = "RIGHT" ]] || die "--start-side must be LEFT or RIGHT"
	fi

	local review review_id response
	review=$(ensure_pending_review)
	review_id=$(jq -r '.node_id' <<<"$review")

	if [ -n "$start_line" ]; then
		response=$(
			gh api graphql -f query='
			mutation($reviewId: ID!, $body: String!, $path: String!, $line: Int!, $side: DiffSide!, $startLine: Int!, $startSide: DiffSide!) {
			  addPullRequestReviewThread(input: {
			    pullRequestReviewId: $reviewId,
			    body: $body,
			    path: $path,
			    line: $line,
			    side: $side,
			    startLine: $startLine,
			    startSide: $startSide
			  }) {
			    thread { id comments(first: 1) { nodes { id url body path line } } }
			  }
			}' -F reviewId="$review_id" -f body="$body" -f path="$path" -F line="$line" -f side="$side" \
				-F startLine="$start_line" -f startSide="$start_side"
		)
	else
		response=$(
			gh api graphql -f query='
			mutation($reviewId: ID!, $body: String!, $path: String!, $line: Int!, $side: DiffSide!) {
			  addPullRequestReviewThread(input: {
			    pullRequestReviewId: $reviewId,
			    body: $body,
			    path: $path,
			    line: $line,
			    side: $side
			  }) {
			    thread { id comments(first: 1) { nodes { id url body path line } } }
			  }
			}' -F reviewId="$review_id" -f body="$body" -f path="$path" -F line="$line" -f side="$side"
		)
	fi
	if jq -e '.errors and (.errors | length > 0)' >/dev/null <<<"$response"; then
		die "GitHub rejected review comment: $(jq -c '.errors' <<<"$response")"
	fi
	jq -ce '.data.addPullRequestReviewThread.thread // error("GitHub returned no review thread")' <<<"$response"
}

submit_review() {
	local event="COMMENT"
	local body=""
	while [ $# -gt 0 ]; do
		case "$1" in
		--pr)
			require_value "$1" "$#"
			PR_REF=$2
			shift 2
			;;
		--event)
			require_value "$1" "$#"
			event=$2
			shift 2
			;;
		--body)
			require_value "$1" "$#"
			body=$2
			shift 2
			;;
		*) die "unknown option: $1" ;;
		esac
	done

	case "$event" in
	COMMENT | APPROVE | REQUEST_CHANGES) ;;
	*) die "--event must be COMMENT, APPROVE, or REQUEST_CHANGES" ;;
	esac

	load_pr
	local review review_id response submitted_id remaining
	review=$(pending_review)
	[ -n "$review" ] || die "no pending review for $PR_URL"
	review_id=$(jq -r '.node_id' <<<"$review")

	response=$(
		gh api graphql -f query='
		mutation($reviewId: ID!, $event: PullRequestReviewEvent!, $body: String!) {
		  submitPullRequestReview(input: {
		    pullRequestReviewId: $reviewId,
		    event: $event,
		    body: $body
		  }) {
		    pullRequestReview { id databaseId state body url commit { oid } }
		  }
		}' -F reviewId="$review_id" -f event="$event" -f body="$body" \
			--jq '.data.submitPullRequestReview.pullRequestReview'
	)
	submitted_id=$(jq -r '.id' <<<"$response")
	[ "$submitted_id" = "$review_id" ] \
		|| die "GitHub submitted review $submitted_id instead of pending review $review_id"
	remaining=$(pending_review)
	[ -z "$remaining" ] \
		|| die "review $review_id was submitted but pending review $(jq -r '.node_id' <<<"$remaining") remains"
	jq '{id: .databaseId, node_id: .id, state, body, commit_id: .commit.oid, html_url: .url}' <<<"$response"
}

discard_review() {
	parse_target_only "$@"
	load_pr
	local review review_id
	review=$(pending_review)
	[ -n "$review" ] || die "no pending review for $PR_URL"
	review_id=$(jq -r '.id' <<<"$review")
	gh api --method DELETE "repos/$GH_REPO/pulls/$PR_NUMBER/reviews/$review_id" >/dev/null
	jq -n --arg url "$PR_URL" --argjson id "$review_id" '{discardedReview: $id, url: $url}'
}

case "${1:-}" in
diff)
	shift
	save_diff "$@"
	;;
open)
	shift
	open_review "$@"
	;;
status)
	shift
	review_status "$@"
	;;
comment)
	shift
	add_comment "$@"
	;;
submit)
	shift
	submit_review "$@"
	;;
discard)
	shift
	discard_review "$@"
	;;
-h | --help | help | "") usage ;;
*)
	usage >&2
	die "unknown command: $1"
	;;
esac
