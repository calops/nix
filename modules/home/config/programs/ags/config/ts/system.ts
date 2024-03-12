import { pillBox } from "./utils";

const cpu = Variable(0, {
	poll: [
		2000,
		"top -b -n 1",
		(out) => {
			const usage = out
				.split("\n")
				.find((line) => line.includes("Cpu(s)"))
				?.split(/\s+/)[1]
				.replace(",", ".");

			if (usage === undefined) throw new Error("Failed to retrieve CPU info");

			return +usage / 100;
		},
	],
});

const ram = Variable(0, {
	poll: [
		2000,
		"free",
		(out) => {
			const [free, total] = out
				.split("\n")
				.find((line) => line.includes("Mem:"))
				?.split(/\s+/)
				?.splice(1, 2) ?? [undefined, undefined];

			if (free === undefined || total === undefined) throw new Error("Failed to retrieve memory info");

			return +free / +total;
		},
	],
});

const cpuProgress = Widget.CircularProgress({
	value: cpu.bind(),
});

const ramProgress = Widget.CircularProgress({
	value: ram.bind(),
});

export default {
	widget: pillBox([cpuProgress, ramProgress]),
};
