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

	const bar = <window
		className="bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.IGNORE}
		keymode={Astal.Keymode.NONE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
	>
		{centerbox}
	</window>

	const setInputShape = () => idle(() => {
		const region = new Cairo.Region();

		// @ts-ignore
		region.unionRectangle(top.get_allocation());
		// @ts-ignore
		region.unionRectangle(middle.get_allocation());
		// @ts-ignore
		region.unionRectangle(bottom.get_allocation());

		bar.input_shape_combine_region(region);
	});

	top.connect("size-allocate", setInputShape);
	middle.connect("size-allocate", setInputShape);
	bottom.connect("size-allocate", setInputShape);
	bar.connect("realize", setInputShape);

	return bar;
}
