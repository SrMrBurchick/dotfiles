import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:./Configs"

Window {
    id: popupRoot

    required property var notification
    required property var screen

    width: 300
    height: 70

    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopWindow

    Timer {
        id: closeTimer
        interval: 5000
        running: true
        onTriggered: popupRoot.close()
    }

    Rectangle {
        anchors.fill: parent
        color: "#CC1E1E1E"
        radius: Config.sizes.moduleRadius
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.sizes.defaultPadding
        spacing: Config.sizes.defaultPadding

        Image {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: {
                const icon = popupRoot.notification.appIcon;
                if (!icon) return "";
                if (icon.startsWith("/")) return "file://" + icon;
                return "image://desktop/" + icon;
            }
            visible: popupRoot.notification.appIcon !== ""
        }

        Text {
            text: popupRoot.notification.summary
            color: Config.colors.text
            font.pixelSize: Config.font.size.normal
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }

        Text {
            text: "×"
            color: Config.colors.text
            font.pixelSize: Config.font.size.large

            MouseArea {
                anchors.fill: parent
                onClicked: popupRoot.close()
            }
        }
    }

    Component.onCompleted: {
        x = popupRoot.screen.x + 20;
        y = popupRoot.screen.y + 60;
    }

    function close() {
        closeTimer.stop();
        destroy();
    }
}
