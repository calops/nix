---
name: python-dev
description: Python guidelines. Use when writing, reviewing or specifying python code
---

# Be idiomatic

Put a special importance on being *idiomatic*, in particular *relative to the current python version used*.
Don't rely on old best practices and idioms, use modern constructs when relevant. For example:

- Don't use the "lambdas in dicts" dispatching pattern, use pattern matching instead when available.
- Don't use juxtaposition of strings for multiline strings, use triple quotes instead.

# Correctness

Always strive to be correct. That means using the standard, idiomatic constructs of the language and
frameworks you're using. Don't take shortcuts by disabling lints with #noqa.

# Comments

Every comment has to earn its place. Prefer deleting one over writing one that restates the code.

- Explain *why*, not *what*. If the code already says it, the comment shouldn't.
- Say it once. The same rationale spread across a constant, its docstring and its call site is three
  things to keep in sync; put it where the design lives and leave the rest bare.
- State the rule, not today's instances. "Strings for these, doubles for those" goes stale on the next
  addition; the rule that produced the list doesn't.
- Don't name things that get renamed underneath you: sibling constants, DB constraints, migrations,
  test names. State the fact they encode instead, so a rename can't silently falsify the comment.
- No bare measurements or version-specific defaults ("~6x faster", "8 by default"). They rot with
  nobody noticing. Numbers belong in the commit message, where they're dated and carry their setup.
- No predictions ("nothing will need to change once X lands") and no flourish.
- Fewest words that carry the information. Past three lines, ask what earns the length.

What does earn a comment: a non-obvious constraint, a counter-intuitive ordering, an opaque operator,
and "don't simplify this" where the simplification is plausible and expensive.
