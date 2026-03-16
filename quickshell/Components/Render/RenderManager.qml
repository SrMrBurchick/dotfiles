pragma Singleton

import QtQuick
import QtQuick.Controls

QtObject {
    property list<Popup> popups: []

    function addRegion(region) {
        console.log("Opened popup: x = ", region.x, ", y = ", region.y, ", w = ", region.width, ", h = ", region.height);
        popups.push(region)
    }

    function removeRegion() {
        popups.clear()
    }

}
