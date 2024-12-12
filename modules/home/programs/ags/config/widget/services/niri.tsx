import GObject, { register, property, signal } from "astal/gobject"
import { execAsync, subprocess } from "astal/process"

function action(...args: string[]) {
	return execAsync(["niri", "msg", "action", ...args])
}

export type Workspace = {
	id: number
	name: string
	is_focused: boolean
}

export type Window = {
	id: number
	title: string
	app_id: string
	workspace_id: number
	is_focused: boolean
}

@register({ GTypeName: "Niri" })
export default class Niri extends GObject.Object {
	private _focusedWorkspace: number = 0

	@property(Number)
	declare focusedWindow: number

	@property(Object)
	declare windows: Window[]

	@property(Object)
	declare workspaces: Workspace[]

	@signal(Number)
	declare focusChanged: (id: number) => void

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

				case "WindowOpenedOrChanged":
					this.onWindowChanged(value.window)
					break;

				case "WindowClosed":
					this.onWindowClosed(value.id)
					break;

				case "WindowFocusChanged":
					this.focusedWindow = value.id
					break;

				case "WorkspaceActivated":
					this.onWorkspaceFocused(value.id)
					break;
			}
		}
	}

	onWorkspacesChanged(workspaces: Workspace[]) {
		this.workspaces = workspaces.sort((a, b) => a.id - b.id)
		const focusedWorkspace = this.workspaces.find((workspace) => workspace.is_focused)?.id!
		this._focusedWorkspace = focusedWorkspace
		this.focusChanged(this._focusedWorkspace)
	}

	onWindowsChanged(windows: Window[]) {
		this.windows = windows
		this.focusedWindow = this.windows.find((window) => window.is_focused)?.id!
	}

	onWindowChanged(window: Window) {
		const index = this.windows.findIndex((w) => w.id === window.id)
		if (index === -1) {
			this.windows.push(window)
		} else {
			this.windows[index] = window
		}
		this.notify("windows")
	}

	onWindowClosed(id: number) {
		this.windows.splice(this.windows.findIndex((w) => w.id === id), 1)
		this.notify("windows")
	}

	onWorkspaceFocused(workspaceId: number) {
		this.workspaces.find((workspace) => workspace.id === this._focusedWorkspace)!.is_focused = false
		this.workspaces.find((workspace) => workspace.id === workspaceId)!.is_focused = true
		this._focusedWorkspace = workspaceId
		this.focusChanged(workspaceId)
	}

	focusWorkspace(id: number) {
		action("focus-workspace", String(id)).then(() => { })
	}
}
