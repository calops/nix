import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import type { Component } from "@oh-my-pi/pi-tui";
import { Box, Text } from "@oh-my-pi/pi-tui";

import { extractInboundEnvelope } from "./protocol.ts";

/**
 * OMP-native inbound delivery for Herdr Link.
 *
 * `herdr agent prompt` is Herdr's only cross-agent transport, so a Herdr Link
 * message arrives at OMP as a user prompt carrying the self-describing inbound
 * wrapper (marker line, From/id metadata, a JSON envelope). Correct transport,
 * but wrong presentation.
 *
 * This module replaces that raw prompt with a structured custom message:
 *
 * - The `input` handler recognizes a valid wrapper, suppresses the raw text
 *   (`handled: true`), and emits a `herdr-link` custom message with the
 *   envelope fields as structured `details` and the body as `content`.
 *   `triggerTurn: true` starts a real agent turn (the model receives the body
 *   as a developer-role instruction; while streaming it steers instead).
 * - A registered message renderer draws the transcript entry as a deliberate
 *   card — icon + title header, a metadata line (route, time, message id),
 *   then the body — so neither the transcript nor the model ever sees the
 *   transport syntax or the envelope JSON.
 *
 * Additive glue: unrecognized input passes through untouched.
 */

export const HERDR_LINK_MESSAGE_TYPE = "herdr-link";

interface InboundDetails {
	from?: unknown;
	to?: unknown;
	id?: unknown;
}

function peerField(value: unknown): string | undefined {
	return typeof value === "string" && value.length > 0 ? value : undefined;
}
function renderInboundMessage(
	message: { content: unknown; details?: unknown; timestamp?: number },
	_options: { expanded: boolean },
	theme: {
		bold(text: string): string;
		fg(color: string, text: string): string;
		bg(color: string, text: string): string;
		icon: { package: string };
		boxRound: Record<string, string>;
	},
): Component | undefined {
	const details = (typeof message.details === "object" && message.details !== null ? message.details : {}) as InboundDetails;
	const from = peerField(details.from);
	if (!from) return undefined; // Not a rendered inbound delivery — default frame.

	const to = peerField(details.to);
	const id = peerField(details.id);
	const clock =
		typeof message.timestamp === "number" && Number.isFinite(message.timestamp)
			? new Date(message.timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
			: undefined;

	const card = new Box(1, 1, (text: string) => theme.bg("userMessageBg", text));
	card.setBorder({ chars: theme.boxRound, color: (text: string) => theme.fg("borderMuted", text) });
	card.addChild(new Text(theme.fg("customMessageLabel", theme.bold(`${theme.icon.package} Herdr Link`)), 0, 0));
	const meta = [to ? `${from} → ${to}` : from, clock, id].filter((part) => part).join("   ");
	card.addChild(new Text(theme.fg("dim", meta), 0, 0));
	const body = typeof message.content === "string" ? message.content : "";
	if (body) card.addChild(new Text(theme.fg("customMessageText", body), 0, 0));
	return card;
}

export function installOmpInboundHandler(pi: ExtensionAPI): void {
	pi.registerMessageRenderer(HERDR_LINK_MESSAGE_TYPE, renderInboundMessage);

	pi.on("input", event => {
		const envelope = extractInboundEnvelope(event.text);
		if (!envelope) return undefined;

		pi.sendMessage(
			{
				customType: HERDR_LINK_MESSAGE_TYPE,
				content: envelope.message,
				display: true,
				details: { from: envelope.from, to: envelope.to, id: envelope.id },
			},
			{ triggerTurn: true },
		);
		return { handled: true };
	});
}
