---
name: self-review-branch
description: Reviews a full branch for correctness, idioms, comments, optimization balance, and testing — via parallel subagents per focus area. Use before requesting external review or merging.
---

# Self-Review Branch

Use before requesting external review or merging. Works on the current branch (assumes a diff target, e.g. `main` or the fork's base branch).

## Workflow

```
DIFF → EARLY EXIT → FAN OUT (subagents) → SYNTHESIZE → HANDOFF
```

### 0. Setup

Detect the base branch (merge target):

```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' \
  || git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||' \
  || echo "main")
```

If the diff is empty, exit early — nothing to review:

```bash
git diff "$BASE" --quiet && echo "No changes against $BASE — nothing to review." && exit 0
```

Get the diff once and make it available to all subagents. Detect relevant file extensions from the repo:

```bash
EXTS=$(git ls-files | awk -F. '{print $NF}' | sort -u | tr '\n' ' ')
rtk git diff "$BASE" -- *.$EXTS > /tmp/branch-diff.txt
```

`rtk` is optional token-saving shorthand — fall back to plain `git diff` if unavailable.

### 1. Fan-out: Subagents per Focus Area

Dispatch **one subagent per focus area**. Each subagent gets the diff file
and a focused task. All run in parallel — they share no mutable state.

| Agent task                    | What it checks                                                                                                                                                                                                                                                                                                                                                   |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Correctness & idioms**      | Semantic correctness, modern idioms, no outdated patterns, no `unsafe` or footguns without justification. YAGNI: does every abstraction earn its keep?                                                                                                                                                                                                           |
| **Comments & doc**            | Comments explain _why_ not _what_ (that's the code's job). No LLM boilerplate ("Here we iterate..."), no obsolete comments, no exposition of alternatives — that belongs in the commit message or ticket. Every comment justifies its existence.                                                                                                                 |
| **Optimization & pragmatism** | Cheap optimizations present, expensive ones absent or justified. Complexity has a documented rationale. Code doesn't paint into a corner but also doesn't future-proof against ghosts. Readability > cleverness unless measured.                                                                                                                                 |
| **Testing strategy**          | Tests cover _our_ logic, not frameworks/dependencies. No trivial-coverage tests (passthroughs, vendored error types). Lean toward unit tests with minimal mocks. If it's an integration or e2e test, the runtime dependency must earn its cost. No redundant or combinatorial test bloat — prefer one case with multiple asserts over 10 parameterized variants. |

**Example dispatch shape (adapt to available subagent tool):**

```
subagent review_diff_correctness: "Review /tmp/branch-diff.txt for correctness and idioms..."
subagent review_diff_comments: "Review /tmp/branch-diff.txt for comment quality..."
subagent review_diff_optimization: "Review /tmp/branch-diff.txt for optimization balance..."
subagent review_diff_testing: "Review /tmp/branch-diff.txt for testing strategy..."
```

Collect all outputs when they complete.

### 2. Synthesis

Merge the findings into a ranked report:

```
CRITICAL (must fix before merge)
├─ correctness issues
└─ bugs or semantic errors

MAJOR (fix or document rationale)
├─ idiom or style violations
├─ unjustified abstractions (YAGNI)
├─ testing over- or under-scope
└─ missing cheap optimizations

MINOR (would improve but won't block)
├─ comment hygiene
├─ readability polish
└─ test organization
```

Cross-check findings against the diff:

- **CRITICAL**: verify the exact diff hunk — don't trust blindly.
- **MAJOR**: spot-check for plausibility.
- **MINOR**: pass through — even if wrong, they're low-impact.

Add a final section to the report with unresolved questions or ambiguities
that need a human decision.

## Principles for the Report

- **One sentence per finding** — the diff line reference carries the detail.
- **Don't narrate the agent process** — skip "Agent X found that...". Findings stand on their own.
- **Explicit empty labels** — use `No issues found.` instead of leaving a section blank.
- **CRITICAL findings must include the diff hunk or file:line** — no ambiguous "there's an issue somewhere".

## Handoff

Present the full report to the user. If the report was saved to a file (e.g.
`/tmp/review-report.md`), mention the path. No further action — the report
replaces the manual self-review pass.

If all sections are clean, state clearly: **No issues found — branch is ready for merge.**
