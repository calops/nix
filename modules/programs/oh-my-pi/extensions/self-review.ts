import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { Container, Text } from "@oh-my-pi/pi-tui";

// ── Types ─────────────────────────────────────────────────────────────────

interface Issue {
  id: string;
  severity: "critical" | "major" | "minor";
  section: "correctness" | "comments" | "optimization" | "testing";
  file: string;
  line?: number;
  explanation: string;
  suggestion?: string;
  resolved: boolean;
  resolvedNote?: string;
}

interface ReviewPayload {
  issues: Issue[];
  summary: string;
  timestamp: number;
}

// ── Extension ─────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  const z = pi.zod;

  // In-memory review state — source of truth for incremental updates.
  const issues: Issue[] = [];
  let summary = "";

  // ── Helpers ─────────────────────────────────────────────────────────────

  function broadcast() {
    pi.sendMessage(
      {
        customType: "review-result",
        content: JSON.stringify({ issues, summary, timestamp: Date.now() } satisfies ReviewPayload),
        display: true,
        attribution: "agent",
      },
      { triggerTurn: false },
    );
  }

  function activeIssues() {
    return issues.filter((i) => !i.resolved);
  }

  function countSev(severity: Issue["severity"]) {
    return activeIssues().filter((i) => i.severity === severity).length;
  }

  function fmtIssue(i: Issue) {
    const loc = i.file + (i.line != null ? `:${i.line}` : "");
    let s = `[${i.severity}] [${i.section}] ${loc} — ${i.explanation}`;
    if (i.suggestion) s += `\n  → ${i.suggestion}`;
    return s;
  }

  // ── Tool: submit_review ────────────────────────────────────────────────
  // Called by the agent after synthesising subagent outputs.
  // Replaces any prior review state in this session.

  const IssueSchema = z.object({
    severity: z.enum(["critical", "major", "minor"]).describe(
      "critical = must fix before merge (bugs, security, data loss)\n" +
      "major = fix or document rationale (idiom violations, YAGNI, scope)\n" +
      "minor = would improve but won't block (comment hygiene, readability)",
    ),
    section: z.enum(["correctness", "comments", "optimization", "testing"]),
    file: z.string().describe("File path relative to repo root"),
    line: z.number().optional().describe("Line number"),
    explanation: z.string().describe("One-sentence description of the issue"),
    suggestion: z.string().optional().describe("Brief fix suggestion"),
  });

  pi.registerTool({
    name: "submit_review",
    label: "Submit Review",
    description:
      "Submit structured code-review results from a self-review pass. " +
      "Each issue gets an auto-assigned id so it can be resolved later via " +
      "resolve_review_item.  Replaces any prior review in this session.",
    parameters: z.object({
      issues: z.array(IssueSchema),
      summary: z.string().describe("One-line summary of the review results"),
    }),
    async execute(_id, params, _signal, _onUpdate) {
      const ts = Date.now();
      issues.length = 0;
      params.issues.forEach((raw, i) => {
        issues.push({
          ...raw,
          id: `review-${ts}-${i}`,
          resolved: false,
        });
      });
      summary = params.summary;

      broadcast();

      const c = countSev("critical");
      const m = countSev("major");
      const n = countSev("minor");
      const body =
        `Review submitted: ${issues.length} issue${issues.length === 1 ? "" : "s"}` +
        (c ? `, ${c} critical` : "") +
        (m ? `, ${m} major` : "") +
        (n && !c && !m ? `, ${n} minor` : "");

      return {
        content: [{ type: "text" as const, text: body + "\n" + issues.map(fmtIssue).join("\n") }],
        details: { count: issues.length },
      };
    },
  });

  // ── Tool: resolve_review_item ──────────────────────────────────────────

  pi.registerTool({
    name: "resolve_review_item",
    label: "Resolve Review Item",
    description:
      "Mark a review item as resolved (e.g. after pushing a fix). " +
      "The id comes from submit_review's output.",
    parameters: z.object({
      issueId: z.string().describe("The `id` field of the issue to resolve"),
      note: z.string().optional().describe("How it was resolved (commit message, etc.)"),
    }),
    async execute(_id, params, _signal, _onUpdate) {
      const issue = issues.find((i) => i.id === params.issueId);
      if (!issue) {
        return {
          content: [
            {
              type: "text" as const,
              text:
                `Unknown issue id "${params.issueId}". ` +
                `Active ids: ${activeIssues().map((i) => i.id).join(", ")}`,
            },
          ],
          isError: true,
        };
      }

      issue.resolved = true;
      issue.resolvedNote = params.note;
      broadcast();

      const rem = activeIssues().length;
      const loc = issue.file + (issue.line != null ? `:${issue.line}` : "");
      return {
        content: [
          {
            type: "text" as const,
            text:
              `Resolved: ${loc} — ${issue.explanation}` +
              (params.note ? `\n  note: ${params.note}` : "") +
              `\n${rem} issue${rem === 1 ? "" : "s"} remaining.`,
          },
        ],
      };
    },
  });

  // ── TUI renderer ───────────────────────────────────────────────────────
  // Collapsed: one-line severity badge + counts.
  // Expanded (Ctrl+O): grouped issue list (active first, then resolved).

  pi.registerMessageRenderer("review-result", (message, { expanded }, theme) => {
    const raw: ReviewPayload =
      typeof message.content === "string" ? JSON.parse(message.content) : message.content;
    const active = raw.issues.filter((i) => !i.resolved);
    const done = raw.issues.filter((i) => i.resolved);

    const c = active.filter((i) => i.severity === "critical").length;
    const m = active.filter((i) => i.severity === "major").length;
    const n = active.filter((i) => i.severity === "minor").length;
    const allDone = raw.issues.length > 0 && active.length === 0;

    // Badge
    const badgeColor = c > 0 ? "red" : m > 0 ? "yellow" : allDone ? "green" : "dim";
    let badge = `◆ Review`;
    if (raw.summary) badge += ` — ${raw.summary}`;
    badge += `  (${active.length}/${raw.issues.length} open`;
    if (c) badge += `, ${c} critical`;
    if (m) badge += `, ${m} major`;
    if (n && !c && !m) badge += `, ${n} minor`;
    badge += `)`;

    const ctr = new Container();
    ctr.addChild(new Text(theme.fg(badgeColor, badge), 1, 0));
    if (!expanded) return ctr;

    // Active issues (grouped by severity)
    if (active.length > 0) {
      ctr.addChild(new Text("", 0, 0));
      ctr.addChild(new Text(theme.fg("bold", "  Active Issues:"), 1, 0));

      for (const sev of ["critical", "major", "minor"] as const) {
        const group = active.filter((i) => i.severity === sev);
        if (group.length === 0) continue;

        const tagColor = sev === "critical" ? "red" : sev === "major" ? "yellow" : "dim";
        const tag = theme.fg(tagColor, sev === "critical" ? "  !" : sev === "major" ? "  ~" : "  ·");

        for (const issue of group) {
          const loc = issue.file + (issue.line != null ? `:${issue.line}` : "");
          ctr.addChild(new Text(`${tag} [${issue.section}] ${loc}`, 1, 0));
          ctr.addChild(new Text(`     ${issue.explanation}`, 1, 0));
          if (issue.suggestion) {
            ctr.addChild(new Text(`     ${theme.fg("dim", `→ ${issue.suggestion}`)}`, 1, 0));
          }
        }
      }
    }

    // Resolved items
    if (done.length > 0) {
      ctr.addChild(new Text("", 0, 0));
      ctr.addChild(new Text(theme.fg("green", "  Resolved:"), 1, 0));
      for (const issue of done) {
        const loc = issue.file + (issue.line != null ? `:${issue.line}` : "");
        ctr.addChild(new Text(theme.fg("dim", `  ✓ ${loc} — ${issue.explanation}`), 1, 0));
      }
    }

    // All clear
    if (active.length === 0 && raw.issues.length > 0) {
      ctr.addChild(new Text("", 0, 0));
      ctr.addChild(new Text(theme.fg("green", "  All issues resolved! The branch is ready."), 1, 0));
    }

    return ctr;
  });

  // ── Context filter: strip review cards from LLM context ────────────────
  // The renderer is for the human; the model shouldn't re-read its own output.

  pi.on("context", async (event) => {
    const filtered = event.messages.filter(
      (m) => !(m.role === "custom" && "customType" in m && m.customType === "review-result"),
    );
    if (filtered.length !== event.messages.length) {
      return { messages: filtered };
    }
  });

  // ── /review slash command ─────────────────────────────────────────────

  pi.registerCommand("review", {
    description:
      "Resend the current self-review state to the TUI. " +
      "The skill workflow is the primary entrypoint; this just re-shows the last snapshot.",
    handler: async (_args, ctx) => {
      if (issues.length === 0) {
        ctx.ui.notify("No review loaded yet — run self-review-branch first.", "warning");
        return;
      }
      broadcast();
      ctx.ui.notify(`Review re-shown (${activeIssues().length}/${issues.length} open)`, "info");
    },
  });
}
