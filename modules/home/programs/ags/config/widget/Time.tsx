import { idle, Variable, GLib } from "astal"
import { Gtk, Widget } from "astal/gtk3";
import { CenterBox } from "./core";

export default function Time() {
	const time = Variable<string[]>([]).poll(1000, () => {
		return GLib.DateTime.new_now_local().format("%H:%M:%Y:%m:%d")!.split(":")
	});

	const date = <revealer>
		<CenterBox name="date">
			<label label={time(([_, __, year, month, day]) => `${year}\n${month}\n${day}`)} justify={Gtk.Justification.CENTER} />
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
				label={time(([hour, minute]) => { return `${hour}\n${minute}`; })}
			/>
		</button>
	</box>

	return box;
}
