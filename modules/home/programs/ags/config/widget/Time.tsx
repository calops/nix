import { Variable, GLib } from "astal"

export default function Time() {
	const time = Variable<string>("").poll(1000, () => GLib.DateTime.new_now_local().format("%H:%M:%Y:%m")!);

	return <button name="time">
		<box>
			<label
				className="big"
				label={time((value) => {
					const [hour, minute, _year, _month] = value.split(":");
					return `${hour}\n${minute}`;
				})}
				onDestroy={() => time.drop()}
			/>
			<revealer>
			</revealer>
		</box>
	</button>
}
