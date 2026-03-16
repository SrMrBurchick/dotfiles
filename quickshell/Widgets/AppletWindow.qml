import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Quickshell

import "root:./Components/Render"

Popup {
    required property ShellScreen screen
    id: root
    focus: true
    modal: true
    x: Math.round((parent.width - width) / 2)
    y: parent.height

    property Item region: {
        width: root.width
    }

    onOpened: {
        RenderManager.addRegion(this);
    }

    onClosed: {
        RenderManager.removeRegion();
    }

    Component.onCompleted: {

    }
}

