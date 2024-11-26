import Gio from "gi://Gio?version=2.0";
import { App } from "astal/gtk3";
import Bar from "./widget/Bar";
import * as fileUtils from "astal/file";
import * as processUtils from "astal/process";

const scss_file = `./style.scss`;
const css_file = `/tmp/ags/style.css`;

function reloadCss() {
	processUtils.exec(`sassc ${scss_file} ${css_file}`);
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
		App.get_monitors().map(Bar);
	},
});
