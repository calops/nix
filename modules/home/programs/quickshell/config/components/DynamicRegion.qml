import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"

Item {
    id: root

    property var window: null
    property var offscreenAnchor: null
    property string groupId: ""

    // Output region - assign to BackgroundEffect.blurRegion or window.mask
    property var region: null

    // Store items for access in generated QML
    property var _items: []

    // Watch RegionRegistry.updateTrigger for changes
    Connections {
        target: RegionRegistry
        function onUpdateTriggerChanged() {
            _rebuildRegion();
        }
    }

    onGroupIdChanged: _rebuildRegion()

    function _rebuildRegion() {
        root._items = RegionRegistry.getItemsForGroup(root.groupId) || [];
        var items = root._items;
        console.log("[DynamicRegion] _rebuildRegion for groupId='" + root.groupId + "' items.length=" + items.length);

        var qmlStr = "import Quickshell; import Quickshell.Wayland; Region {\n";

        if (items.length === 0) {
            qmlStr += "    Region { item: root.offscreenAnchor }\n";
        } else {
            for (var i = 0; i < items.length; i++) {
                qmlStr += "    property var item" + i + ": root._items[" + i + "];\n";
                qmlStr += "    Region { item: item" + i + " || root.offscreenAnchor; radius: typeof item" + i + " !== 'undefined' && item" + i + " ? (item" + i + ".radius || 0) : 0 }\n";
            }
        }

        qmlStr += "}";

        if (region) region.destroy();
        region = Qt.createQmlObject(qmlStr, root, "dynamicRegion");
    }

    Component.onDestruction: {
        if (region) region.destroy();
    }
}
