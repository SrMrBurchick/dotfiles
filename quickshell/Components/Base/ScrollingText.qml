import QtQuick

import "root:./Components/Base/"
import "root:./Configs"

Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font

    property int animationDuration: 4500
    property int pauseDuration: 1000

    readonly property bool shouldScroll: label.implicitWidth > width
    readonly property real overflow: Math.max(0, label.implicitWidth - width)

    implicitHeight: label.implicitHeight

    clip: true

    BaseText {
        id: label

        anchors.verticalCenter: parent.verticalCenter

        x: root.shouldScroll ? 0 : (root.width - width) / 2

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on x {
            enabled: false
        }
    }

    SequentialAnimation {
        id: scrollAnimation

        running: root.shouldScroll
        loops: Animation.Infinite

        PauseAnimation {
            duration: root.pauseDuration
        }

        NumberAnimation {
            target: label
            property: "x"

            from: 0
            to: -root.overflow

            duration: root.animationDuration
            easing.type: Easing.InOutSine
        }

        PauseAnimation {
            duration: root.pauseDuration
        }

        NumberAnimation {
            target: label
            property: "x"

            from: -root.overflow
            to: 0

            duration: root.animationDuration
            easing.type: Easing.InOutSine
        }
    }

    onShouldScrollChanged: {
        if (!shouldScroll) {
            scrollAnimation.stop()
            label.x = (width - label.width) / 2
        }
    }
}
