import Quickshell
import Quickshell.Io
import "widgets"
import "services"

ShellRoot {
    id: root



    IpcService {}
    Bars {}
    OverviewBackdrop { id: backdrop }

    readonly property var _anyrunService: AnyrunService
}
