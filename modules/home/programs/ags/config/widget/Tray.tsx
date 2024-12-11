import { bind } from "astal"
import { Gdk } from "astal/gtk3"
import AstalTray from "gi://AstalTray"
import { CenterBox } from "./core"

export default function Tray() {
	const tray = AstalTray.get_default()

	return <CenterBox vertical>
		{bind(tray, "items").as((items: AstalTray.TrayItem[]) => items
			.filter(item => item.gicon)
			.map((item: AstalTray.TrayItem) => {
				const menu = item.create_menu()
				return <CenterBox className="small">
					<button
						tooltipMarkup={bind(item, "tooltipMarkup")}
						onDestroy={() => menu?.destroy()}
						onClickRelease={self => {
							menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null)
						}}>
						<icon gIcon={bind(item, "gicon")} />
					</button>
				</CenterBox>
			}))}
	</CenterBox>
}
