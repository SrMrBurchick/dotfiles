import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `burchick-${name}`
    color: "transparent"
}
