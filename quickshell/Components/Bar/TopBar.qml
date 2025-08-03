import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:./"
import "root:./Components/Bar/"
import "root:./Components/Bar/Workspace/"
import "root:./Components/Base/"

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

        Rectangle {
            color: "transparent"
            anchors.centerIn: parent
            width: Config.sizes.barHeight
            height: Config.sizes.barHeight
            RowLayout {
                anchors.fill: parent
                Clock {
                }
            }
        }

    }

}
