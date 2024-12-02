import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import Time from "./Time"
import Tray from "./Tray";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const window = <window
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
			</box>

			<box name="bottom" vertical valign={Gtk.Align.END}>
				<Time />
			</box>
		</centerbox>
	</window>

	return window;
}
