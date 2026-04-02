pragma Singleton
import QtQuick

QtObject {
    id: root

    property var groupRegistries: ({})
    // Dummy property to force bindings to update
    property int updateTrigger: 0

    function registerItem(groupId, item) {
        if (!groupId || !item) {
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
        }
    }

    function unregisterItem(groupId, item) {
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
            }
        }
    }

    function getItemsForGroup(groupId) {
        var t = updateTrigger;
        var r = groupRegistries[groupId] || [];
        return r.slice();
    }
}
