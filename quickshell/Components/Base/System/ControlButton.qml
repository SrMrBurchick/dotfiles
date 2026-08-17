import QtQuick
import QtQuick.Controls

import "root:./Components/Base/"
import "root:./Configs"

Item {
    id: root

    property string icon: ""
    property string tooltip: ""

    property color accentColor: Config.colors.lavender

    property bool hovered: false
    property bool requiresConfirmation: true
    property bool confirming: false

    property int confirmTimeout: 3000

    signal clicked()
    signal confirmed()

    implicitWidth: 40
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent

        radius: Config.sizes.moduleRadius

        color: root.confirming
            ? Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                0.18
            )
            : root.hovered
                ? Config.colors.surfaceAlt
                : Config.colors.surface

        border.width: 1

        border.color: root.confirming
            ? root.accentColor
            : root.hovered
                ? root.accentColor
                : Config.colors.purpleDark

        scale: root.hovered ? 1.08 : 1.0

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

            text: root.confirming
                ? "󰄬"
                : root.icon

            color: root.confirming
                ? root.accentColor
                : root.hovered
                    ? root.accentColor
                    : Config.colors.foreground

            font.pixelSize: 18

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

        onClicked: {
            if (!root.requiresConfirmation) {
                root.clicked()
                return
            }

            if (!root.confirming) {
                root.confirming = true
                confirmTimer.restart()
                return
            }

            confirmTimer.stop()
            root.confirming = false
            root.confirmed()
        }
    }

    Timer {
        id: confirmTimer

        interval: root.confirmTimeout
        repeat: false

        onTriggered: {
            root.confirming = false
        }
    }

    ToolTip {
        visible: root.hovered

        text: root.confirming
            ? "Click again to confirm"
            : root.tooltip

        delay: 350
    }
}
