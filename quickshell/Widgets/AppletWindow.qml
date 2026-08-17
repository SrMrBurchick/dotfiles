import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

import "root:./Components/Render"
import "root:./Configs"

Popup {
    id: root

    required property ShellScreen screen

    focus: true
    modal: true

    parent: Overlay.overlay

    // Size the popup to fit whatever contentItem is assigned, so the
    // Popup's real geometry (used for CloseOnPressOutside and the
    // click-through mask in MainRender) always matches what's rendered.
    //implicitWidth: contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0
    //implicitHeight: contentItem ? contentItem.implicitHeight + topPadding + bottomPadding : 0

    x: Math.round((parent.width - width) / 2)
    y: Config.sizes.barHeight

    background: Rectangle {
        color: Config.colors.backgroundAlt
        radius: Config.sizes.moduleRadius + 4

        border.width: 1
        border.color: Config.colors.purpleDark
    }

    onOpened: {
        RenderManager.addRegion(this)
    }

    onClosed: {
        console.log("Applet closed")
        RenderManager.removeRegion(this)
    }

    Component.onCompleted: {
        console.log("Popup created")
    }
}
