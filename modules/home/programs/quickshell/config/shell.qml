import Quickshell
import Quickshell.Io
import "widgets"
import "services"

ShellRoot {
    id: root

    IpcService {}
    Bars {}
    NotificationPopups {}
    OverviewBackdrop {}

    readonly property var _anyrunService: AnyrunService
    readonly property var _cavaService: CavaService
}
