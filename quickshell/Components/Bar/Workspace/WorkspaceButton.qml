import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"

BaseText {
    property HyprlandWorkspace workspace
    property bool bIsFocused: workspace ? workspace.focused : false
    property bool bIsHovered: false
    text: bIsFocused || bIsHovered ? "" : ""

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (workspace) {
                workspace.activate()
            }
        }

        onEntered: {
            bIsHovered = true;
        }
        onExited: {
            bIsHovered = false;
        }

    }
}
