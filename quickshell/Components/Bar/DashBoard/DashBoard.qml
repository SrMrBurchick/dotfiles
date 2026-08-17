import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Components/Bar/DashBoard/Calendar"
import "root:./Components/Bar/DashBoard/Media"
import "root:./Configs"

RowLayout {
    id: root

    spacing: 8

    // Dynamically computed from the actual content instead of a hardcoded
    // constant, so the Popup (AppletWindow) always gets a correct hit-region
    // matching what's rendered, regardless of how the content grows/shrinks.
    //implicitWidth: userInfo.implicitWidth + middle.implicitWidth + left.implicitWidth + spacing * 2 + 12
    //implicitHeight: Math.max(userInfo.implicitHeight, middle.implicitHeight, left.implicitHeight) + 12
    //implicitWidth: 900
    //implicitHeight: 900

    Module {
        id: userInfo

        Layout.fillWidth: true
        Layout.fillHeight: true

        contentItem: UserInfo {}
    }

    ColumnLayout {
        id: middle
        Layout.fillWidth: true
        Layout.fillHeight: true

        Module {
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            contentItem: Calendar {}
        }

        Module {
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            contentItem: SystemControll {}
        }

    }

    ColumnLayout {
        id: left
        Layout.fillWidth: true
        Layout.fillHeight: true


        Module {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            contentItem: MusicPlayer {}
        }
    }

    Component.onCompleted: {
        console.log(
            "Created Dashboard: w =",
            root.width,
            "h =",
            root.height
        )
    }
}
