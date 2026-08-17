import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"
import "root:./Configs"

BaseText {
    property HyprlandWorkspace workspace
    property bool bIsFocused: workspace ? workspace.focused : false
    property bool bIsHovered: false
    text: bIsFocused || bIsHovered ? "" : ""
    scale: {
        if (bIsHovered)
            return 1.4

        if (bIsFocused)
            return 1.15

        return 1.0
    }
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    color: bIsHovered
        ? Config.colors.workspaceHover
        : bIsFocused
            ? Config.colors.workspaceActive
            : Config.colors.workspace

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

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
