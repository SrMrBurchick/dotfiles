pragma Singleton

import QtQuick
import QtQuick.Controls

QtObject {
    id: root
    property list<Popup> popups: []

    function addRegion(region) {
        console.log("Opened popup: x = ", region.x, ", y = ", region.y, ", w = ", region.width, ", h = ", region.height);
        popups.push(region)
        regionAdded(region)
    }

    function removeRegion(region) {
        console.log("Region Removed!")
        regionRemoved(region)
        root.popups.splice(root.popups.indexOf(popups), 1);
    }

    signal regionRemoved(var region);
    signal regionAdded(var region);
}
