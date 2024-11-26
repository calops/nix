import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"

const time = Variable("time").poll(1000, "date")

export default function Bar(gdkmonitor: Gdk.Monitor) {
	return <window
		className="Bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
	>
		<centerbox vertical>
			<button onClicked="echo hello" halign={Gtk.Align.FILL}>
				Welcome to AGS!
			</button>
			<box />
			<button onClick={() => print("hello")} halign={Gtk.Align.FILL}>
				<label label={time()} />
			</button>
		</centerbox>
	</window>
}
