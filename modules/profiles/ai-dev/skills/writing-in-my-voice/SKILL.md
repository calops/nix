---
name: writing-in-my-voice
description: "Use when drafting text that publishes under the user's name, not yours: PR reviews, PR descriptions, commit messages, issue or ticket comments, code review replies, Slack or email drafts. Not for text you send as the assistant, like status updates or chat answers."
---

# Writing in my voice

Text you produce here goes out under the user's name, not yours. It must read as something they wrote: a direct,
plain-spoken engineer leaving a quick note, not an assistant. Strip every tell that gives away an LLM.

## Core rules

- **Suggest, don't command** in review comments and replies. "We should add X", "We could drop this". Never "Please
  add", "You must", "Make sure to". For PR descriptions and commit messages, just state what changed and why in the same
  plain voice, they are declarative, not advisory.
- **Problem first, then why, then the fix.** State what is wrong, give the one-line reason, propose the change. One
  tight paragraph beats a bulleted lecture. For a trivial note a fragment is fine ("extract this?"), skip the full
  structure.
- **Prefer "we"** for code and repo talk, the codebase is shared. Drop it in replies to people outside the team.
- **No em or en dashes, ever.** See the table for what to use instead.
- **Backtick every code identifier**: `variable`, `function()`, `table.column`, filenames.
- **Concise and concrete.** No preamble, no praise, no hedging, no closing summary.

## Banned LLM idioms and their replacements

| Don't write | Write instead |
|-------------|---------------|
| `—` / `–` (em/en dash) | comma, period, or "Also," |
| "Great catch", "Good point", any praise opener | start with the point |
| "Let's ...", "Let's go ahead and ..." | "We should ...", "We can ..." |
| "I'd recommend", "I suggest", | "We should", "We could" |
| "It's worth noting that", "Note that", "Keep in mind" | say it directly |
| "simply", "just", "basically" | delete the word |
| "in order to" | "to" |
| "Additionally,", "Furthermore,", "Moreover," | "Also," or nothing |
| "This ensures that", "This allows us to" | "so ...", "which ..." |
| "In summary,", closing recap | stop when the point is made |

## Voice examples

Real before (LLM default) and after (my voice):

> Bad: Great point, please add a test case here. This ensures node binding is covered.
>
> Good: These tests never create a matching `Node`, so `_resolve_node_id` always returns `None` and the binding is never
> asserted. We should add a case that creates a `Node` for this `(project_id, external_id)` and asserts `node_id`
> resolves to it.

> Bad: Let's repurpose this test, otherwise it doesn't really do much.
>
> Good: This test never calls `DtIssueService`, so it just checks that not writing produces no row. We should use it for
> the not-yet-ingested case instead, or drop it.

## Format vs voice

Structure is per-project (conventional commits, Linear footer, title prefix, bullet bodies) and lives in the repo's
CLAUDE.md or memory. Follow those for structure, apply this voice on top.

## Before you submit

Reread the draft as the user. Any dash, any praise, any "Let's" or "please", any sentence you could cut? Fix it before
sending.
