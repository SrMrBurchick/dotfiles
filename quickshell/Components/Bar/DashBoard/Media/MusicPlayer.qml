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
import "root:./Configs"

ColumnLayout {
    id: root
    anchors.fill: parent
    anchors.margins: 10

    spacing: 10

    ScrollingText {
        id: title

        Layout.fillWidth: true

        text: (Players.active?.trackTitle ?? qsTr("No media"))
              || qsTr("Unknown title")

        color: Config.colors.foreground

        font.bold: true

        animationDuration: 5000
        pauseDuration: 1200
    }

    BaseText {
        Layout.fillWidth: true

        text: Players.active?.trackArtist ?? ""

        horizontalAlignment: Text.AlignHCenter

        color: Config.colors.textMuted

        elide: Text.ElideRight
    }

    Item {
        id: coverContainer

        Layout.fillWidth: true
        Layout.fillHeight: true

        property url currentArtUrl: ""

        function updateArt() {
            const url = Players.active?.trackArtUrl ?? ""

            if (url !== "")
                currentArtUrl = url
        }

        Connections {
            target: Players.active

            function onTrackArtUrlChanged() {
                coverContainer.updateArt()
            }
        }

        Component.onCompleted: {
            updateArt()
        }

        ClippingRectangle {
            anchors.centerIn: parent

            width: 140
            height: 140

            radius: 16
            color: Config.colors.surfaceAlt

            Image {
                id: cover

                anchors.fill: parent

                source: coverContainer.currentArtUrl
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                cache: true

                onStatusChanged: {
                    console.log(
                        "Cover status:",
                        status,
                        "source:",
                        source
                    )
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        spacing: 10

        ControlButton {
            text: ""

            onButtonClicked: {
                Players.active?.previous()
            }
        }

        ControlButton {
            text: Players.active?.isPlaying ? "" : ""

            onButtonClicked: {
                Players.active?.togglePlaying()
            }
        }

        ControlButton {
            text: ""

            onButtonClicked: {
                Players.active?.next()
            }
        }
    }

    Component.onCompleted: {
        coverContainer.updateArt()
    }
}
