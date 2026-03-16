import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets

import "root:./Services/"
import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard/Media"


ColumnLayout {
    BaseText {
        id: title

        // anchors.top: cover.bottom
        // anchors.horizontalCenter: parent.horizontalCenter
        // anchors.topMargin: Appearance.spacing.normal

        // animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
        // color: Colours.palette.m3primary
        // font.pointSize: Appearance.font.size.normal

        // width: parent.implicitWidth - Appearance.padding.large * 2
        elide: Text.ElideRight
    }

    ClippingRectangle {
        radius: 100
        height: 130
        width: height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        Image {
            anchors.fill: parent
            source: Players.active?.trackArtUrl ?? ""
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        ControlButton {
            text: ""
        }
        ControlButton {
            text: ""
        }
        ControlButton {
            text: ""
        }
    }
}
