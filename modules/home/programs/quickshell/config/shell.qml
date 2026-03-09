import Quickshell
import "widgets"
import "services"

ShellRoot {
    IpcService {}
    Bars {}

    readonly property var _anyrunService: AnyrunService
}
