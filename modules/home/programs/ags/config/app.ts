import Gio from "gi://Gio?version=2.0";
import GLib from "gi://GLib?version=2.0";
import { App, Gdk, Gtk } from "astal/gtk3";
import * as fileUtils from "astal/file";
import * as processUtils from "astal/process";
import Bar from "./widget/Bar";

const palette_file = `${GLib.getenv("XDG_CONFIG_HOME")}/colors/palette.scss`;
const scss_file = `./style.scss`;
const css_file = `/tmp/ags/style.css`;

function reloadCss() {
	const cmd = `cat ${palette_file} ${scss_file} | sassc -s ${css_file}`;
	processUtils.exec(`bash -c "${cmd}"`);

	App.reset_css();
	App.apply_css(css_file);

	console.log("CSS loaded");
}

fileUtils.monitorFile(scss_file, (_, event) => {
	if (event == Gio.FileMonitorEvent.CHANGED) {
		reloadCss();
	}
});

App.start({
	main() {
		reloadCss();
		const bars = new Map<Gdk.Monitor, Gtk.Widget>()

		// initialize
		for (const gdkmonitor of App.get_monitors()) {
			bars.set(gdkmonitor, Bar(gdkmonitor))
		}

		App.connect("monitor-added", (_, gdkmonitor) => {
			bars.set(gdkmonitor, Bar(gdkmonitor))
		})

		App.connect("monitor-removed", (_, gdkmonitor) => {
			bars.get(gdkmonitor)?.destroy()
			bars.delete(gdkmonitor)
		})
	},
});
