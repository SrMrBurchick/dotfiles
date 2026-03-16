import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    required property string name

    WlrLayershell.namespace: `burchick-${name}`
    color: "transparent"
}
