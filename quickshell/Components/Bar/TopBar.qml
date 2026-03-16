import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:./Components/Bar/"
import "root:./Components/Bar/Workspace/"
import "root:./Components/Bar/KbLayout/"
import "root:./Components/Bar/Network/"
import "root:./Components/Base/"
import "root:./Configs/"

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Config.sizes.barHeight
        Workspaces {
            Layout.alignment: Qt.AlignLeft
        }

        Clock {
            screen: root.screen
            anchors.centerIn: parent
        }

        KbLayout {
            Layout.alignment: Qt.AlignRight
        }
    }
}
