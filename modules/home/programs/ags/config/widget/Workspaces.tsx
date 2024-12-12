import Gio from "gi://Gio?version=2.0"
import Niri from "./services/niri";
import { CenterBox } from "./core";
import { Widget } from "astal/gtk3";
import { bind } from "astal"

export default function Workspaces() {
	const niri = new Niri()

	const workspaces = bind(niri, "workspaces").as((workspaces) => workspaces?.map((workspace) => {
		// FIXME: a lot of icons are missed with this strategy
		const windows = bind(niri, "windows").as((windows) => windows
			?.filter((window) => window.workspace_id == workspace.id)
			.map((window) => [
				window.title,
				Gio.AppInfo.get_all().find(a => {
					return a.get_name() === window.app_id ||
						a.get_id()?.replace(".desktop", "") === window.app_id
				})?.get_icon()
			] as [string, Gio.Icon])
			.filter(([_title, icon]) => icon)
			.map(([title, icon]) => <icon gIcon={icon} className="window" tooltipMarkup={title} />))

		const revealer = <revealer>
			<box className="windows" vertical>{windows}</box>
		</revealer> as Widget.Revealer

		const label = workspace.name ? nameToSymbol(workspace.name) : String(workspace.id)

		const workspaceBox = <box vertical className="workspace-box">
			<button className={"workspace small"} onClick={() => niri.focusWorkspace(workspace.id)}>
				<label label={label} className={workspace.name ? "symbol" : ""} />
			</button>
			{revealer}
		</box> as Widget.Box

		niri.connect("focus-changed", (_, focusedWorkspace: number) => {
			const isFocused = workspace.id === focusedWorkspace
			revealer.set_reveal_child(isFocused)
			workspaceBox.set_class_name(isFocused ? "workspace-box active" : "workspace-box")
		})

		return workspaceBox;
	}))

	return <CenterBox className="workspaces" vertical>{workspaces}</CenterBox>
}

function nameToSymbol(name: string) {
	switch (name) {
		case "web": return "󰖟";
		case "dev": return "";
		case "work": return "";
		case "chat": return "󰭹";
		case "games": return "󰊗";
		case "misc": return "";
		default: return name;
	}
}
