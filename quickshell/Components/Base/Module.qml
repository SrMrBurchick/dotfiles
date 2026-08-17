import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:./Components/Base/"
import "root:./Configs"

Control {
    id: root

    property bool isHovered: false

    property color bgColor: isHovered
        ? Config.colors.moduleHoveredBG
        : Config.colors.moduleUnHoveredBG

    property color borderColor: isHovered
        ? Config.colors.lavender
        : Config.colors.purpleDark

    leftPadding: Config.sizes.defaultPadding + 3
    rightPadding: Config.sizes.defaultPadding + 3

    topPadding: Config.sizes.defaultPadding
    bottomPadding: Config.sizes.defaultPadding
    //padding: Config.sizes.defaultPadding

    scale: isHovered ? 1.035 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: Config.anim.appearance.baseAnimationTime
            easing.type: Easing.OutCubic
        }
    }

    Behavior on bgColor {
        ColorAnimation {
            duration: Config.anim.appearance.baseAnimationTime
        }
    }

    Behavior on borderColor {
        ColorAnimation {
            duration: Config.anim.appearance.baseAnimationTime
        }
    }

    background: Rectangle {
        color: root.bgColor

        opacity: Config.anim.appearance.baseOpacity

        radius: Config.sizes.moduleRadius

        border.width: 1
        border.color: root.borderColor
    }

    Layout.fillHeight: true
    Layout.margins: Config.sizes.defaultMargin

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.moduleClicked()
        }

        onEntered: {
            root.isHovered = true
            root.moduleHovered(true)
        }

        onExited: {
            root.isHovered = false
            root.moduleHovered(false)
        }
    }

    signal moduleClicked()
    signal moduleHovered(bool hovered)
}
