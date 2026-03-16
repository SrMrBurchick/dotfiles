import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:./Services/"
import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard/Media"

BaseText {
    property bool bHovered: false
    color: bHovered ? MediaStyle.colors.controlButtonHovered : MediaStyle.colors.controlButton
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            moduleClicked();
        }
        onEntered: {
            bHovered = true;
        }
        onExited: {
            bHovered = false;
        }
    }


    signal buttonClicked();
}
