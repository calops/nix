pragma Singleton
import QtQuick

QtObject {
    id: root

    property var groupRegistries: ({})
    // Dummy property to force bindings to update
    property int updateTrigger: 0

    function registerItem(groupId, item) {
        console.log("[RegionRegistry] registerItem: groupId='" + groupId + "' item=" + item);
        if (!groupId || !item) {
            console.log("[RegionRegistry] registerItem: FAILED - groupId=" + groupId + " item=" + item);
            return;
        }
        var r = groupRegistries;
        if (!r[groupId]) {
            r[groupId] = [];
        }
        if (r[groupId].indexOf(item) === -1) {
            r[groupId].push(item);
            groupRegistries = r;
            updateTrigger++;
            console.log("[RegionRegistry] registerItem: SUCCESS - group '" + groupId + "' now has " + r[groupId].length + " items");
        } else {
            console.log("[RegionRegistry] registerItem: SKIPPED - item already in group '" + groupId + "'");
        }
    }

    function unregisterItem(groupId, item) {
        console.log("[RegionRegistry] unregisterItem: groupId='" + groupId + "' item=" + item);
        if (!groupId || !item) {
            return;
        }
        var r = groupRegistries;
        if (r[groupId]) {
            var idx = r[groupId].indexOf(item);
            if (idx !== -1) {
                r[groupId].splice(idx, 1);
                groupRegistries = r;
                updateTrigger++;
                console.log("[RegionRegistry] unregisterItem: SUCCESS - group '" + groupId + "' now has " + r[groupId].length + " items");
            } else {
                console.log("[RegionRegistry] unregisterItem: SKIPPED - item not found in group '" + groupId + "'");
            }
        } else {
            console.log("[RegionRegistry] unregisterItem: SKIPPED - group '" + groupId + "' does not exist");
        }
    }

    function getItemsForGroup(groupId) {
        var t = updateTrigger;
        var r = groupRegistries[groupId] || [];
        console.log("[RegionRegistry] getItemsForGroup: groupId='" + groupId + "' returning " + r.length + " items");
        return r.slice();
    }
}
