import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: toastWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: 400
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            readonly property int maxDisplayCount: 20

            Item {
                id: offscreenAnchor
                x: -9999
                y: -9999
                width: 1
                height: 1
                visible: true
                opacity: 0.0
            }

            DynamicRegion {
                id: toastBlurRegion
                window: toastWindow
                offscreenAnchor: offscreenAnchor
                groupId: "toastScopeBlur"
            }

            BackgroundEffect.blurRegion: toastBlurRegion.region

            DynamicRegion {
                id: toastMaskRegion
                window: toastWindow
                offscreenAnchor: offscreenAnchor
                groupId: "toastScope"
            }

            mask: toastMaskRegion.region

            Component.onCompleted: syncToasts()

            Item {
                id: toastScope
                anchors.fill: parent
                property string blurGroupId: "toastScopeBlur"
                property string maskGroupId: "toastScope"

                Item {
                    id: toastContainer
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: Theme.iconWidth + 8
                    anchors.topMargin: 15
                    width: 320
                }
            }

            property var activeToasts: ({})

            readonly property int toastSpacing: 10

            Component {
                id: toastComponent
                ToastCard {
                    onExited: function(notificationId) {
                        var toasts = toastWindow.activeToasts
                        delete toasts[notificationId]
                        toastWindow.activeToasts = toasts
                        toastWindow.syncToasts()
                    }
                    onHeightChanged: toastWindow.repositionToasts()
                }
            }

            Connections {
                target: Notifications

                function onTransientCountChanged() {
                    toastWindow.syncToasts()
                }
            }

            function repositionToasts() {
                var yOffset = 0
                for (var i = 0; i < Notifications.model.count; i++) {
                    var entry = Notifications.model.get(i)
                    if (!entry.isTransient || entry.isDismissed)
                        continue
                    var card = activeToasts[entry.notificationId]
                    if (card && !card.isExiting) {
                        card.targetY = yOffset
                        yOffset += card.height + toastSpacing
                    }
                }
            }

            function syncToasts() {
                var entries = []
                for (var i = 0; i < Notifications.model.count; i++) {
                    var entry = Notifications.model.get(i)
                    if (entry.isTransient && !entry.isDismissed) {
                        entries.push(entry)
                    }
                }

                var displayed = entries.slice(0, maxDisplayCount)

                var displayedIds = {}
                for (var k = 0; k < displayed.length; k++) {
                    displayedIds[displayed[k].notificationId] = true
                }

                for (var m = 0; m < displayed.length; m++) {
                    Notifications.setDisplayShown(displayed[m].notificationId, true)
                }
                for (var n = maxDisplayCount; n < entries.length; n++) {
                    Notifications.setDisplayShown(entries[n].notificationId, false)
                }

                var activeIds = {}
                for (var id in activeToasts) {
                    activeIds[id] = false
                }

                for (var j = 0; j < displayed.length; j++) {
                    var e = displayed[j]
                    var nid = e.notificationId

                    if (!activeToasts[nid]) {
                        var card = toastComponent.createObject(toastContainer, {
                            entry: e
                        })
                        var toasts = activeToasts
                        toasts[nid] = card
                        activeToasts = toasts
                    }
                    activeIds[nid] = true
                }

                for (var oldId in activeIds) {
                    if (!activeIds[oldId] && activeToasts[oldId]) {
                        activeToasts[oldId].startExit()
                    }
                }

                repositionToasts()
            }
        }
    }
}
