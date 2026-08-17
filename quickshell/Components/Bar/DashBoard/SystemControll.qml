import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:./Components/Base/"
import "root:./Components/Base/System/"
import "root:./Configs"


RowLayout {
    id: root
    anchors.fill: parent
    anchors.margins: 5

    spacing: 5

    ControlButton {
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        icon: "󰐥"
        tooltip: "Power Off"
        accentColor: Config.colors.error

        onConfirmed: {
            powerOff.running = true
        }
    }

    ControlButton {
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        icon: "󰜉"
        tooltip: "Reboot"
        accentColor: Config.colors.warning

        onConfirmed: {
            reboot.running = true
        }
    }

    ControlButton {
        Layout.preferredWidth: 40
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        icon: "󰍃"
        tooltip: "Log Out"
        accentColor: Config.colors.lavender

        onConfirmed: {
            logout.running = true
        }
    }

    Process {
        id: powerOff
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: reboot
        command: ["systemctl", "reboot"]
    }

    Process {
        id: logout
        command: ["hyprctl", "dispatch", "exit"]
    }
}
