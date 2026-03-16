pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQml

Singleton {
    id: root
    property string currentKbLayout: "English (US)"

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name.startsWith("activelayout"))
            {
                const parts = event.data.split(",")
                root.currentKbLayout = parts[1]
            }
        }
    }
}
