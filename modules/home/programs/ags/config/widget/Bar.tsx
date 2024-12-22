import Audio from "./Audio";
import Cairo from "gi://cairo";
import Time from "./Time"
import Tray from "./Tray";
import Workspaces from "./Workspaces";
import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { CenterBox } from "./core";
import { idle } from "astal";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const top = <CenterBox name="top" vertical valign={Gtk.Align.START}>
		<Tray />
	</CenterBox>

	const middle = <CenterBox name="middle" vertical valign={Gtk.Align.CENTER}>
		<Workspaces />
	</CenterBox>

	const bottom = <CenterBox name="bottom" vertical valign={Gtk.Align.END}>
		<Audio />
		<Time />
	</CenterBox>

	const centerbox = <centerbox vertical halign={Gtk.Align.START}>
		{top}
		{middle}
		{bottom}
	</centerbox>

	const bar = <box className="bar" orientation={Gtk.Orientation.HORIZONTAL} hexpand={false}>
		{centerbox}
	</box>

	const window = <window
		className="window"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.IGNORE}
		keymode={Astal.Keymode.NONE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.RIGHT}
		application={App}
	>
		<box>
			{bar}
			<box className="rest" hexpand />
		</box>
	</window>

	const setInputShape = () => idle(() => {
		const region = new Cairo.Region();
		const input_areas = [top, middle, bottom];

		input_areas.forEach((area) => {
			// @ts-ignore
			region.unionRectangle(area.get_allocation());
		});

		window.input_shape_combine_region(region);
	});

	top.connect("size-allocate", setInputShape);
	middle.connect("size-allocate", setInputShape);
	bottom.connect("size-allocate", setInputShape);
	window.connect("realize", setInputShape);

	return bar;
}
