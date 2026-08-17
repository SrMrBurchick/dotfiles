import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:./Components/Base/"
import "root:./Configs"

RowLayout {
    id: root

    spacing: 14

    readonly property string fetchScriptPath:
        "~/.config/quickshell/Scripts/system_fetch.py"

    ClippingRectangle {
        Layout.preferredWidth: 82
        Layout.preferredHeight: 82
        Layout.alignment: Qt.AlignVCenter

        radius: width / 2

        color: Config.colors.surfaceAlt

        Image {
            anchors.fill: parent
            source: "root:./Resources/avatar.jpg"

            fillMode: Image.PreserveAspectCrop
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 6

        BaseText {
            id: userName

            color: Config.colors.foreground
            font.bold: true
        }

        BaseText {
            id: desktop

            color: Config.colors.textMuted
        }

        BaseText {
            id: uptime

            color: Config.colors.textMuted
        }
    }

    onVisibleChanged: {
        if (visible)
            fetchProc.running = true
    }

    Process {
        id: fetchProc

        command: ["sh", "-c", root.fetchScriptPath]

        stdout: StdioCollector {
            onStreamFinished: {
                const info = JSON.parse(this.text)

                userName.text = "󰣇  " + info.user
                desktop.text = "󰧨  " + info.desktop_env
                uptime.text = "󱤥  " + info.uptime
            }
        }
    }
}
