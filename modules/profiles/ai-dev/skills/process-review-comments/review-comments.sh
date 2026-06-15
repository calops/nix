#!/usr/bin/env bash
# Unified tool for PR review comment workflows.
#
# Usage:
#   ./review-comments.sh list
#     → JSON array of unresolved comments, sorted by createdAt
#       [{ id, threadId, body, path, line, author, createdAt }]
#
#   ./review-comments.sh solve <comment-id> [-m "msg"] [-p] [-r "reply"] [-R]
#     → Execute any combination of: commit, push, reply, resolve
#       All flags are independent and executed in this order.
#     -m "msg"    git commit -m "msg" (stage changes with `git add` before calling this)
#     -p          git push (implies -m — requires a message to push)
#     -r "text"   post reply to the comment
#     -R          resolve the review thread
#
# Examples:
#   ./review-comments.sh list | jq '.[].body'
#   ./review-comments.sh solve 123456789 -m "fix: address review feedback" -p -r "Done" -R

set -euo pipefail

GH_REPO=$(gh repo view --json owner,name -q '"\(.owner.login)/\(.name)"' 2>/dev/null || true)
if [ -z "$GH_REPO" ]; then
	echo "Not a GitHub repository" >&2
	exit 1
fi

GH_OWNER=${GH_REPO%/*}
GH_REPO_NAME=${GH_REPO#*/}

list_comments() {
	pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || true)
	if [ -z "$pr_number" ]; then
		echo '[]'
		exit 0
	fi

	gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 10) {
            nodes {
              id
              body
              path
              line
              author { login }
              createdAt
            }
          }
        }
      }
    }
  }
}' -F owner="$GH_OWNER" -F repo="$GH_REPO_NAME" -F pr="$pr_number" \
		--jq '.data.repository.pullRequest.reviewThreads.nodes[] |
    select(.isResolved == false) |
    { threadId: .id, isResolved, isOutdated, comments: .comments.nodes[] } |
    { threadId, commentId: .comments.id, body: .comments.body, path: .comments.path,
      line: .comments.line, author: .comments.author.login, createdAt: .comments.createdAt }
  ' 2>/dev/null | jq -s 'sort_by(.createdAt)'
}

solve_comment() {
	local comment_id=$1
	shift

	local commit_msg=""
	local do_push=false
	local reply_text=""
	local do_resolve=false

	while [ $# -gt 0 ]; do
		case "$1" in
		-m)
			commit_msg="$2"
			shift 2
			;;
		-p)
			do_push=true
			shift
			;;
		-r)
			reply_text="$2"
			shift 2
			;;
		-R)
			do_resolve=true
			shift
			;;
		*)
			echo "Unknown flag: $1" >&2
			exit 1
			;;
		esac
	done

	# Commit
	if [ -n "$commit_msg" ]; then
		git commit -m "$commit_msg"
		echo "  ✓ committed"
	fi

	# Push
	if [ "$do_push" = true ]; then
		if [ -z "$commit_msg" ]; then
			echo "Error: -p requires -m (need a commit message)" >&2
			exit 1
		fi
		git push
		echo "  ✓ pushed"
	fi

	# Resolve/reply needs the thread ID. GitHub's PullRequestReviewComment node no
	# longer exposes pullRequestReviewThread directly, so find the containing
	# review thread by scanning the current PR's unresolved review threads.
	local thread_id=""
	if [ -n "$reply_text" ] || [ "$do_resolve" = true ]; then
		local pr_number
		pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || true)
		if [ -z "$pr_number" ]; then
			echo "Error: could not find current PR" >&2
			exit 1
		fi

		thread_id=$(gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          id
          comments(first: 100) {
            nodes { id }
          }
        }
      }
    }
  }
}' -F owner="$GH_OWNER" -F repo="$GH_REPO_NAME" -F pr="$pr_number" \
			| jq -r --arg commentId "$comment_id" '
.data.repository.pullRequest.reviewThreads.nodes[]
| select(any(.comments.nodes[]; .id == $commentId))
| .id
' | head -n 1)
	fi

	if [ -z "$thread_id" ] && { [ -n "$reply_text" ] || [ "$do_resolve" = true ]; }; then
		echo "Error: could not find thread for comment $comment_id" >&2
		exit 1
	fi

	# Reply (must happen before resolve — needs the thread to still exist as-is)
	if [ -n "$reply_text" ]; then
		gh api graphql -f query='
    mutation($threadId: ID!, $body: String!) {
      addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
        comment { id }
      }
    }' -F threadId="$thread_id" -f body="$reply_text" >/dev/null
		echo "  ✓ replied"
	fi

	# Resolve
	if [ "$do_resolve" = true ]; then
		gh api graphql -f query='
    mutation($threadId: ID!) {
      resolveReviewThread(input: {threadId: $threadId}) { thread { id } }
    }' -F threadId="$thread_id" >/dev/null
		echo "  ✓ resolved"
	fi
}

case "${1:-}" in
list) list_comments ;;
solve)
	if [ $# -lt 2 ]; then
		echo "Usage: $0 solve <comment-id> [-m msg] [-p] [-r reply] [-R]" >&2
		exit 1
	fi
	solve_comment "${@:2}"
	;;
*)
	echo "Usage: $0 list | solve <comment-id> [-m msg] [-p] [-r reply] [-R]" >&2
	exit 1
	;;
esac
