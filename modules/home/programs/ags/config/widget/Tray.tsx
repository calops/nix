import { bind } from "astal"
import { App, Gdk } from "astal/gtk3"
import AstalTray from "gi://AstalTray"

export default function Tray() {
	const tray = AstalTray.get_default()

	return <box vertical>
		{bind(tray, "items").as((items: AstalTray.TrayItem[]) => items
			.filter(item => item.id)
			.map((item: AstalTray.TrayItem) => {
				if (item.iconThemePath) {
					App.add_icons(item.iconThemePath);
				}

				const menu = item.create_menu()
				return <button
					tooltipMarkup={bind(item, "tooltipMarkup")}
					onDestroy={() => menu?.destroy()}
					onClickRelease={self => {
						menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null)
					}}>
					<icon gIcon={bind(item, "gicon")} />
				</button>
			}))}
	</box>
}
