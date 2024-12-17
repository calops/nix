import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import { idle } from "astal";
import Time from "./Time"
import Tray from "./Tray";
import Workspaces from "./Workspaces";
import { CenterBox } from "./core";
import Audio from "./Audio";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const centerbox = <centerbox vertical halign={Gtk.Align.START}>
		<CenterBox name="top" vertical valign={Gtk.Align.START}>
			<Tray />
		</CenterBox>

		<CenterBox name="middle" vertical valign={Gtk.Align.CENTER}>
			<Workspaces />
		</CenterBox>

		<CenterBox name="bottom" vertical valign={Gtk.Align.END}>
			<Audio />
			<Time />
		</CenterBox>
	</centerbox>

	return <window
		className="bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.IGNORE}
		keymode={Astal.Keymode.NONE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
		onRealize={self => idle(() => self.set_click_through(true))}
	>
		{centerbox}
	</window>
}
