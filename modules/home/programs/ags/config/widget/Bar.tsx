import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import Time from "./Time"
import Tray from "./Tray";
import Workspaces from "./Workspaces";

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
			<box name="top" vertical valign={Gtk.Align.START}>
				<Tray />
			</box>

			<box name="middle" vertical valign={Gtk.Align.CENTER}>
				<Workspaces />
			</box>

			<box name="bottom" vertical valign={Gtk.Align.END}>
				<Time />
			</box>
		</centerbox>
	</window>
}
