---
name: process-review-comments
description: Process PR review comments iteratively, one by one. Use whenever asked to address incoming review feedback on a pull request.
---

# Process Review Comments

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

For each review comment:

```
PRESENT → ANALYZE → USER → ADDRESS → REVIEW → SUBMIT → CONFIRM → CONTINUE
```

### PRESENT

Show the comment verbatim — quote `body`, note the `path` and `line` from the list output.

### ANALYZE

Assess honestly. Agree or disagree with technical reasoning. If multiple viable approaches exist, list trade-offs. Challenge when the reviewer is wrong or missing context.

_"The reviewer is right about the shadowing, but `res` conflicts with the HTTP-response convention here. Options: A) `result` (preferred) — clear intent; B) `parsed` — more specific; C) `res` as suggested — against local convention."_

_"The reviewer suggests error handling here, but this function is intentionally fallible — the caller handles errors. Swallowing would hide failures."_

### USER

State your recommendation and wait. _"I'd go with option A. Which approach?"_

### ADDRESS

Implement the fix based on the user's choice. Draft the commit message and/or reply text.

Explicitly stage the changes you want committed:

```bash
git add <files>
```

### REVIEW

Show the user what will be submitted **before** running anything:

- **Commit message** (if any): `fix: ...`
- **Reply text** (if any): the inline response you plan to post
- **Operations**: commit / push / reply / resolve — which flags `solve` will use

Ask for approval: _"Here's what I'll submit. Review the commit message and reply?"_

Wait for the user to confirm or suggest edits before proceeding.

### SUBMIT

Once the user has approved, run `solve` with all flags in one shot:

```bash
${SKILL_DIR}/review-comments.sh solve <commentId> -m "fix: ..." -p -r "Done" -R
```

Or for reply-only (no code change):

```bash
${SKILL_DIR}/review-comments.sh solve <commentId> -r "Explanation here." -R
```

The script runs steps in order: commit → push → reply → resolve.

### CONFIRM

Confirm the action was taken and show progress: _"Comment 2/5 handled. 3 remaining."_

### CONTINUE

Move to the next comment using the cached `list` output — the script fetches all comments at once, so there is no need to re-list between iterations. When all are done: _"All 6 addressed. Summary: 3 resolved, 2 replied, 1 replied without change. What's next?"_

## Edge Cases

- **Unclear** — don't guess. Ask the user what the reviewer means before implementing.
- **Trivial** — fix directly. _"Typo — fixing."_ Then `-r "Fixed" -R` or just `-R` depending on whether a reply adds value.
- **Scope creep** — flag it. _"This suggests unrelated work. Separate issue or handle here?"_

## GitHub Reply Convention

Post replies inline, not as top-level PR comments. The `solve` command handles this correctly — replies go to the comment thread via the API. Never use `gh pr comment` for review follow-ups.
