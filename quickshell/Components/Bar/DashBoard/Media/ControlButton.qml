import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:./Components/Base/"
import "root:./Configs"
import "root:./Services/"
import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard/Media"

Item {
    id: root

    property string text: ""
    property bool hovered: false
    property bool active: false

    signal buttonClicked()

    implicitWidth: 36
    implicitHeight: 36

    Rectangle {
        id: background

        anchors.fill: parent

        radius: width / 2

        color: root.hovered
            ? Config.colors.surfaceAlt
            : Config.colors.backgroundAlt

        border.width: 1

        border.color: root.hovered
            ? Config.colors.lavender
            : Config.colors.purpleDark

        scale: root.hovered ? 1.12 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: Config.anim.appearance.baseAnimationTime
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.anim.appearance.baseAnimationTime
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Config.anim.appearance.baseAnimationTime
            }
        }

        BaseText {
            anchors.centerIn: parent

            text: root.text

            font.pixelSize: 16
            font.bold: true

            color: root.hovered
                ? Config.colors.lavender
                : Config.colors.foreground

            Behavior on color {
                ColorAnimation {
                    duration: Config.anim.appearance.baseAnimationTime
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.buttonClicked()
    }
}
