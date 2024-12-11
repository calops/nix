import Gio from "gi://Gio?version=2.0"
import Niri from "./services/niri";
import { CenterBox } from "./core";
import { Widget } from "astal/gtk3";
import { bind } from "astal"

export default function Workspaces() {
	const niri = new Niri()

	return <CenterBox className="workspaces" vertical>
		{bind(niri, "focusedWorkspace").as((_) => niri.workspaces?.map((workspace: any) => {
			const label = workspace.name ? nameToSymbol(workspace.name) : String(workspace.id)
			const isActive = workspace.id === niri.focusedWorkspace

			// FIXME: a lot of icons are missed with this strategy
			const windows =
				bind(niri, "windows").as((windows: any[]) => windows
					?.filter((window) => window.workspace_id == workspace.id)
					.map((window) => Gio.AppInfo.get_all().find(a => a.get_name() == window.app_id)?.get_icon())
					.filter((icon) => icon)
					.flatMap((icon) => <button className="window"><icon gIcon={icon!} /></button>))

			const revealer = <revealer><box vertical>{windows}</box></revealer> as Widget.Revealer

			if (isActive) revealer.set_reveal_child(true)

			return <box vertical className={"workspace-box" + (isActive ? " active" : "")}>
				<button
					className={"workspace small" + (isActive ? " active" : "")}
					onClick={() => niri.focusedWorkspace = workspace.id}
					onHover={() => revealer.set_reveal_child(true)}
					onHoverLost={() => revealer.set_reveal_child(isActive)}
				>
					<label label={label} className={workspace.name ? "symbol" : ""} />
				</button>
				{revealer}
			</box>
		}))}
	</CenterBox>
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
