import Gio from "gi://Gio?version=2.0"
import Niri, { Window } from "./services/niri";
import { CenterBox } from "./core";
import { Widget, Gtk } from "astal/gtk3";
import { bind } from "astal"

export default function Workspaces() {
	const niri = new Niri()

	const workspaces = bind(niri, "workspaces").as((workspaces) => workspaces?.map((workspace) => {
		const windows = bind(niri, "windows").as((windows) => windows
			?.filter((window) => window.workspace_id == workspace.id)
			.map((window) => [window.title, getIcon(window)] as [string, Gio.Icon])
			.filter(([_title, icon]) => icon)
			.map(([title, icon]) => <icon gIcon={icon} className="window" tooltipMarkup={title} />))

		const revealer = <revealer>
			<box className="windows" vertical>{windows}</box>
		</revealer> as Widget.Revealer

		const label = <label
			label={workspace.name ? nameToSymbol(workspace.name) : String(workspace.id)}
			className={workspace.name ? "symbol" : ""}
		/> as Widget.Label

		const workspaceBox = <box vertical className="workspace-box">
			<button className={"workspace small"} onClick={() => niri.focusWorkspace(workspace.id)}>
				{label}
			</button>
			{revealer}
		</box> as Widget.Box

		const niriConnection = niri.connect("focus-changed", (_, focusedWorkspace: number) => {
			const isFocused = workspace.id === focusedWorkspace
			revealer.set_reveal_child(isFocused)
			workspaceBox.set_state_flags(isFocused ? Gtk.StateFlags.SELECTED : null, true)
		})

		workspaceBox.connect("destroy", () => niri.disconnect(niriConnection))

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

function getIcon(window: Window) {
	return Gio.AppInfo.get_all().find(a => {
		return a.get_name() === window.app_id ||
			a.get_id()?.replace(".desktop", "") === window.app_id
	})?.get_icon() as Gio.Icon
}
