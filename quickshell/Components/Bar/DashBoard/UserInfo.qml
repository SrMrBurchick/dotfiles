import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:./"
import "root:./Components/Base/"

Row {
    Layout.fillWidth: true
    spacing: 15
    readonly property string fetchScriptPath: "~/.config/quickshell/Scripts/system_fetch.py"
    ClippingRectangle {
        radius: 100
        height: 100
        width: height
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        Image {
            anchors.fill: parent
            source: "root:./Resources/avatar.jpg"
        }
    }

    BaseText {
        id: fetchInfo
        anchors.verticalCenter: parent.verticalCenter
    }

    onVisibleChanged: {
        if (visible) {
            fetchProc.running = true
        }
    }

    Process {
        id: fetchProc
        command: ["sh", "-c", fetchScriptPath]

        // run the command immediately
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let info = JSON.parse(this.text);
                fetchInfo.text = "󰣇: " + info.user;
                fetchInfo.text += "\n󰧨: " + info.desktop_env;
                fetchInfo.text += "\n󱤥: " + info.uptime;
            }
        }
    }
}
