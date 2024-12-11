import GObject, { register, property } from "astal/gobject"
import { execAsync, subprocess } from "astal/process"

function msg(...args: string[]) {
	return execAsync(["niri", "msg", ...args])
}

@register({ GTypeName: "Niri" })
export default class Niri extends GObject.Object {
	private _focusedWorkspace: number = 0

	@property(Number)
	declare focusedWindow: number

	@property(Number)
	get focusedWorkspace() { return this._focusedWorkspace; }
	set focusedWorkspace(value: number) {
		this._focusedWorkspace = value
		msg("action", "focus-workspace", String(value)).then(() => this.notify("focused-workspace"))
	}

	@property(Object)
	declare windows: any[]

	@property(Object)
	declare workspaces: any[]

	constructor() {
		super()
		subprocess(
			["niri", "msg", "--json", "event-stream"],
			(event) => this.handleEvent(JSON.parse(event)),
			(err) => console.error(err),
		)
	}

	handleEvent(event: any) {
		for (const key in event) {
			const value = event[key]
			switch (key) {
				case "WorkspacesChanged":
					this.onWorkspacesChanged(value.workspaces)
					break;

				case "WindowsChanged":
					this.onWindowsChanged(value.windows)
					break;

				case "WindowFocusChanged":
					this.focusedWindow = value.id
					break;

				case "WorkspaceActivated":
					this.focusedWorkspace = value.id
					break;
			}
		}
	}

	onWorkspacesChanged(workspaces: any[]) {
		this.workspaces = workspaces.sort((a, b) => a.id - b.id)
		this.focusedWorkspace = this.workspaces.find((workspace) => workspace.is_focused)?.id
	}

	onWindowsChanged(windows: any[]) {
		this.windows = windows.sort((a, b) => a.id - b.id)
		this.focusedWindow = this.windows.find((window) => window.is_focused)?.id
	}
}
