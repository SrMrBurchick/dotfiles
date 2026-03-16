import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "root:./Components/Base/"
import "root:./Components/Bar/Workspace"
import "root:./Configs/"

Item {
    Layout.fillHeight: true
    Layout.margins: Config.sizes.defaultMargin

    Row {
        anchors.fill: parent
        anchors.margins: Config.sizes.defaultMargin
        spacing: 10
        Repeater {
            model: Hyprland.workspaces
            WorkspaceButton {
                workspace: modelData
            }
        }
    }

    Timer {
        // 1000 milliseconds is 1 second
        interval: 1000

        // start the timer immediately
        running: true

        // run the timer again when it ends
        repeat: true

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: Hyprland.refreshWorkspaces()
    }
}

