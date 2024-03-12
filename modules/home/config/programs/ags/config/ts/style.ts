import Gio from "types/@girs/gio-2.0/gio-2.0"

const scss_file = `${App.configDir}/style.scss`
const css_file = `/tmp/ags/style.css`

function reloadCss() {
	Utils.exec(`sassc ${scss_file} ${css_file}`)
	App.resetCss()
	App.applyCss(css_file)
	console.log('CSS loaded')
}
reloadCss()
Utils.monitorFile(scss_file, (_, event) => {
	if (event == Gio.FileMonitorEvent.CHANGED) {
		reloadCss()
	}
})
