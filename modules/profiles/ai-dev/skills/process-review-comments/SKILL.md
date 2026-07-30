---
name: process-review-comments
description: Process PR review comments iteratively, one by one. Use whenever asked to address incoming review feedback on a pull request.
---

# Process Review Comments

## CRITICAL — One Comment at a Time

- **NEVER dump all comments at once.** Present them one by one, iteratively.
- **NEVER implement a fix before the user approves.** The workflow is always: present → propose → WAIT for user → implement → resolve → next.
- **NEVER batch-resolve.** Each comment gets its own `solve` call. No exceptions.

If you present two comments before the first is resolved, you have violated this contract.

## Progress Tracking

Before starting, create a temporary untracked file at the repo root to track progress:

```bash
echo "# Review Comments Progress" > /tmp/review-comments-progress.md
```

After each comment is handled, append to it:

```bash
echo "- [x] <comment-id>: <one-line summary>" >> /tmp/review-comments-progress.md
```

This file is **never committed** — it's a scratchpad for you and the user. Share its contents as needed when summarizing progress. Delete it when all comments are done.

## Grouping Related Comments

If two or more comments touch the same file/line/topic (e.g., a reviewer left multiple comments on one function), you MAY:
- **Analyze them together** — present them as a group, propose one solution that addresses all.
- **Implement them together** — one commit that fixes both, with a reply on each thread.

But you MUST still:
- Present the group before implementing.
- Resolve each comment individually with `solve` (one call per thread).

**NEVER group unrelated comments.** Different files, different concerns, different reviewers → separate passes.

A companion script at `${SKILL_DIR}/review-comments.sh` handles GitHub operations in one shot — never chain multiple gh commands yourself.

## Commands

### `${SKILL_DIR}/review-comments.sh list`

Fetch all unresolved inline review comments on the current PR. Outputs a JSON array sorted by creation time.

Empty array (`[]`) = no comments or no open PR. Output fits in one short context turn.

### `${SKILL_DIR}/review-comments.sh solve <comment-id> [flags]`

Handle one comment. All flags are independent — use any subset:

| Flag        | Action  | Details                                                                                |
| ----------- | ------- | -------------------------------------------------------------------------------------- |
| `-m "msg"`  | Commit  | `git commit -m "msg"` (stage changes explicitly with `git add` before calling `solve`) |
| `-p`        | Push    | `git push` (requires `-m`)                                                             |
| `-r "text"` | Reply   | Post reply to comment inline                                                           |
| `-R`        | Resolve | Mark the review thread as resolved                                                     |

**Examples:**

```bash
# Just reply + resolve (no code change needed)
${SKILL_DIR}/review-comments.sh solve PRR_kwD... -r "Good catch, fixed." -R

# Commit, push, reply, resolve (full close-out)
${SKILL_DIR}/review-comments.sh solve PRR_kwD... \
	-m "fix: address naming conflict in profile" -p -r "Done" -R
```

The script runs steps in order: commit → push → reply → resolve. Errors early if a step fails.

## Workflow Per Comment

For each review comment (or group of related comments):

```
PRESENT → ANALYZE → WAIT FOR USER → ADDRESS → REVIEW → WAIT FOR USER → SUBMIT → CONFIRM → NEXT
```

The two WAIT gates are non-negotiable. Never proceed past them without explicit user approval.

### 1. PRESENT

Show the comment verbatim — quote `body`, note the `path` and `line` from the list output. ONE comment at a time.

### 2. ANALYZE

Assess honestly. Agree or disagree with technical reasoning. If multiple viable approaches exist, list trade-offs. Challenge when the reviewer is wrong or missing context.

End with an explicit recommendation and question — never just an analysis.

_"The reviewer is right about the shadowing, but `res` conflicts with the HTTP-response convention here. Options: A) `result` (preferred) — clear intent; B) `parsed` — more specific. I'd go with A. Which approach?"_

_"The reviewer suggests error handling here, but this function is intentionally fallible — the caller handles errors. I'd push back with an explanation. OK?"_

### 3. WAIT FOR USER

**STOP here.** Do NOT implement, do NOT edit files, do NOT stage changes. Wait for the user to approve the proposal or pick an option. This gate cannot be skipped, even for trivial fixes.

### 4. ADDRESS

Implement the fix based on the user's choice. Draft the commit message and/or reply text.

Explicitly stage the changes you want committed:

```bash
git add <files>
```

### 5. REVIEW

Show the user what will be submitted **before** running anything:

- **Commit message** (if any): `fix: ...`
- **Reply text** (if any): the inline response you plan to post
- **Operations**: commit / push / reply / resolve — which flags `solve` will use

Ask for approval: _"Here's what I'll submit. Review the commit message and reply?"_

### 6. WAIT FOR USER

**STOP again.** Wait for the user to confirm or suggest edits.

### 7. SUBMIT

Once the user has approved, run `solve` with all flags in one shot:

```bash
${SKILL_DIR}/review-comments.sh solve <commentId> -m "fix: ..." -p -r "Done" -R
```

Or for reply-only (no code change):

```bash
${SKILL_DIR}/review-comments.sh solve <commentId> -r "Explanation here." -R
```

The script runs steps in order: commit → push → reply → resolve.

### 8. CONFIRM

Confirm the action was taken, update the progress file, and show progress:

```bash
echo "- [x] <commentId>: <summary>" >> /tmp/review-comments-progress.md
```

_"Comment 2/5 handled. 3 remaining."_

### 9. NEXT

Move to the next unhandled comment. Re-list is not needed — the cached `list` output already has all comments. When all are done: _"All 6 addressed. Summary: 3 resolved, 2 replied, 1 replied without change. What's next?"_

## Edge Cases

- **Unclear** — don't guess. Ask the user what the reviewer means before analyzing.
- **Trivial** (typo, whitespace, obvious one-liner) — you still MUST present it and get approval before implementing. The PRESENT→WAIT gate is never skipped. The only shortcut: you can present and immediately say "This is a trivial typo fix — I'll commit `fix: typo in …` unless you object."
- **Disagree** — explain why the reviewer is wrong, propose a reply pushing back. Get the user's buy-in before replying.
- **Scope creep** — flag it. _"This suggests unrelated work. Separate issue or handle here?"_

## GitHub Reply Convention

Post replies inline, not as top-level PR comments. The `solve` command handles this correctly — replies go to the comment thread via the API. Never use `gh pr comment` for review follow-ups.
