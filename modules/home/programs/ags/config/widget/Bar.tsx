import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import Time from "./Time"
import Tray from "./Tray";
import Workspaces from "./Workspaces";
import { CenterBox } from "./core";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	return <window
		name="bar"
		className="bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.IGNORE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
	>
		<centerbox vertical halign={Gtk.Align.START}>
			<CenterBox name="top" vertical valign={Gtk.Align.START}>
				<Tray />
			</CenterBox>

			<CenterBox name="middle" vertical valign={Gtk.Align.CENTER}>
				<Workspaces />
			</CenterBox>

			<CenterBox name="bottom" vertical valign={Gtk.Align.END}>
				<Time />
			</CenterBox>
		</centerbox>
	</window>
}
