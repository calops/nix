import Quickshell
import Quickshell.Io
import "widgets"
import "services"

ShellRoot {
    id: root

    IpcService {}
    Bars {}
    OverviewBackdrop {}
    NotificationToasts {}

    readonly property var _anyrunService: AnyrunService
    readonly property var _cavaService: CavaService
    readonly property var _notificationsService: Notifications
}
