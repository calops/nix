import Quickshell
import QtQuick
import "../services"
import "../widgets"

StyledText {
    id: workspaces
    text: Niri.focusedWorkspace?.icon
}
