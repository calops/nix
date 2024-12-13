import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk3"

import Time from "./Time"
import Tray from "./Tray";
import Workspaces from "./Workspaces";
import { CenterBox } from "./core";

export default function Bar(gdkmonitor: Gdk.Monitor) {
	return <window
		className="bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.IGNORE}
		anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
		application={App}
		clickThrough={true}
	>
		<centerbox vertical halign={Gtk.Align.START} clickThrough={true}>
			<CenterBox name="top" vertical valign={Gtk.Align.START} clickThrough={true}>
				<Tray />
			</CenterBox>

			<CenterBox name="middle" vertical valign={Gtk.Align.CENTER} clickThrough={true}>
				<Workspaces />
			</CenterBox>

			<CenterBox name="bottom" vertical valign={Gtk.Align.END}>
				<Time />
			</CenterBox>
		</centerbox>
	</window> as Widget.Window
}
