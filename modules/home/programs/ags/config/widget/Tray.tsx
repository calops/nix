import { bind } from "astal"
import AstalTray from "gi://AstalTray"
import { CenterBox } from "./core"

export default function Tray() {
	const tray = AstalTray.get_default()

	return <CenterBox vertical className="SysTray">
		{bind(tray, "items").as(items => items.map(item => (
			<CenterBox className="small">
				<menubutton
					tooltipMarkup={bind(item, "tooltipMarkup")}
					usePopover={false}
					actionGroup={bind(item, "action-group").as(ag => ["dbusmenu", ag])}
					menuModel={bind(item, "menu-model")}>
					<icon gicon={bind(item, "gicon")} />
				</menubutton>
			</CenterBox>
		)))}
	</CenterBox>
}
