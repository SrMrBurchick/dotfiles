import Quickshell
import QtQuick

import "root:./Components/Bar/"
import "root:./Components/Base/"

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities

    property bool isHovered

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        sourceComponent: TopBar {
            screen: root.screen
            visibilities: root.visibilities
        }
    }
}
