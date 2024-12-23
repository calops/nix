import { Variable, GLib } from "astal"
import { Widget } from "astal/gtk3";
import { CenterBox } from "./core";

export default function Time() {
	const time = Variable<GLib.DateTime>(GLib.DateTime.new_now_local()).poll(1000, () => {
		return GLib.DateTime.new_now_local()
	});

	const date = <revealer>
		<CenterBox name="date">
			<label
				label={time(date => date.format("%Y-%m-%d")!)}
				angle={90}
			/>
		</CenterBox >
	</revealer> as Widget.Revealer;

	const box = <box name="datetime" vertical>
		{date}
		<button
			name="time"
			onHover={() => date.set_reveal_child(true)}
			onHoverLost={() => date.set_reveal_child(false)}
			onDestroy={() => time.drop()}
		>
			<label
				className="big"
				label={time((date) => date.format("%H\n%M")!)}
			/>
		</button>
	</box>

	return box;
}
