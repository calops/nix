import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import Time from "./Time"

export default function Bar(gdkmonitor: Gdk.Monitor) {
	return <window
		className="Bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
	>
		<centerbox vertical>
			<box name="top" vertical valign={Gtk.Align.START}>
			</box>

			<box name="middle" vertical valign={Gtk.Align.CENTER}>
			</box>

			<box name="bottom" vertical valign={Gtk.Align.END}>
				<Time />
			</box>
		</centerbox>
	</window>
}
