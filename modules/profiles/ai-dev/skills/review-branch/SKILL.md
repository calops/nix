---
name: review-branch
description: Review a pull request or branch for correctness, maintainability, comments, optimization balance, and testing, then prepare approved inline feedback in a pending GitHub review.
---

# Review Branch

Review a pull request or branch as an external reviewer. The default deliverable is feedback, not edits to the reviewed branch.

## Workflow

```
TARGET → DIFF → FAN OUT → SYNTHESIZE → REPORT → ITERATE → PENDING REVIEW → SUBMIT
```

## 0. Resolve the target

An explicit PR URL or number wins over the current branch. Read the PR metadata, base, head, existing reviews, and existing inline comments so the review uses the right comparison and does not repeat resolved feedback.

For a GitHub PR, use the companion helper to save the complete diff once:

```bash
${SKILL_DIR}/review.sh diff --pr <number-or-url>
```

The command prints JSON containing the diff path. Give that same file to every review subagent.

For a local branch without a PR, detect the merge target:

```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' \
  || git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||' \
  || echo "main")
```

Save `git diff "$BASE"...HEAD` once. If the diff is empty, exit before fan-out with `No changes against $BASE, nothing to review.`

## 1. Fan out by focus area

Dispatch one parallel subagent per focus area. They share the saved diff and no mutable state.

| Focus | Checks |
| --- | --- |
| Correctness and idioms | Semantic correctness, current language and framework idioms, unsafe behavior, footguns, and abstractions that do not earn their cost. |
| Comments and documentation | Comments explain why, not what; no repeated rationale, stale enumerations, rename-sensitive references, bare measurements, version-specific defaults, or generated exposition. Load the relevant language skill for its full criteria. |
| Optimization and pragmatism | Avoidable allocation, copying, computation, query cost, concurrency, asymptotic behavior, unjustified complexity, and speculative future-proofing. |
| Testing strategy | Consumer-visible invariants and plausible regressions; no framework tests, mock echoes, combinatorial bloat, or expensive integration coverage where a unit test proves the behavior. |

Each subagent returns only evidence-backed findings introduced by the diff. Require severity, category, repository-relative file, right-side diff line when available, one-sentence defect, evidence, and a concise fix direction. Existing review comments are context, not findings to repeat.

## 2. Synthesize and verify

Merge duplicate findings and rank them:

```
CRITICAL: must fix before merge; correctness, security, data loss, or behavior that cannot meet the stated contract
MAJOR: should fix or document; maintainability, unjustified design, test scope, or material performance problems
MINOR: useful but non-blocking; comment hygiene, readability, and focused test improvements
```

Cross-check every critical finding against the exact diff and surrounding code. Spot-check every major finding. Run a focused reproduction when another command can prove or disprove a claim. Do not trust subagent severity or suggested fixes blindly.

Keep generic engine concerns separate from schema-specific configuration. A product-specific name in configuration is not an engine leak; product-specific behavior in reusable engine code is.

## 3. Present the complete report first

Before creating a GitHub review, show all findings to the user:

- Number findings globally and sort by severity.
- Include an explicit `No issues found.` under empty severity sections.
- Keep one sentence per finding where possible.
- Include file and right-side line references.
- End with unresolved decisions that need a human choice, or say there are none.
- Do not use review cards as a substitute for the report.

If every section is clean, state `No issues found, the branch is ready for review.` and stop.

## 4. Iterate one finding at a time

After the complete report, process findings individually in report order.

For every item:

1. Show its severity and progress as `MAJOR (2/7)`.
2. Restate the finding and explain the concrete failing case.
3. Load `writing-in-my-voice` and draft a concise inline comment.
4. Wait for the user to approve, rewrite, or skip it.
5. Add it to the pending review only when the user explicitly says to send it.
6. Confirm the pending comment URL, then move to the next item.

Normal review comments are one to three sentences. State the problem first, then suggest the fix. Do not include the visible file and line in the prose. A skipped finding gets no GitHub comment and still advances the progress count.

Use the helper for approved comments:

```bash
${SKILL_DIR}/review.sh open --pr <number-or-url>
${SKILL_DIR}/review.sh comment --pr <number-or-url> \
  --path path/to/file.py --line 42 --body "Approved comment text"
```

`open` is idempotent. `comment` creates or reuses the current user's pending review. Never create a standalone inline comment when a pending review is intended.

## 5. Review and submit the pending review

Keep the review pending while iterating. Never submit because the last finding was handled.

Inspect the accumulated review:

```bash
${SKILL_DIR}/review.sh status --pr <number-or-url>
```

If `pendingReview.stale` is `true`, stop adding comments. Fetch the new diff and revalidate every existing comment because GitHub marks comments added to an old pending review as outdated too. Get explicit approval before discarding the stale review, opening a new one, and reposting the approved comments at current lines.

Show the user:

- Every pending inline comment.
- The proposed review event: `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`.
- The proposed top-level review body, if any.

Wait for explicit approval. Then submit once:

```bash
${SKILL_DIR}/review.sh submit --pr <number-or-url> --event COMMENT --body "Review body"
```

Use `discard` only with explicit approval:

```bash
${SKILL_DIR}/review.sh discard --pr <number-or-url>
```

## Helper commands

```text
review.sh diff     Save the complete PR diff and print its path.
review.sh open     Create or return the current user's pending review.
review.sh status   Show the pending review and all comments in it.
review.sh comment  Add one line or multiline comment to the pending review.
review.sh submit   Submit the pending review with COMMENT, APPROVE, or REQUEST_CHANGES.
review.sh discard  Delete the pending review without publishing it.
```

Every command accepts `--pr <number-or-url>`. Without it, the helper resolves the PR for the current branch.