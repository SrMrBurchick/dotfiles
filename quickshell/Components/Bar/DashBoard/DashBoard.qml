import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Components/Bar/DashBoard/Calendar"
import "root:./Components/Bar/DashBoard/Media"

GridLayout {
    id: root
    anchors.fill: parent
    Module {
        contentItem: UserInfo {
        }
    }

    Module {
        contentItem: MusicPlayer {

        }
    }

    Module {
        contentItem: Calendar {

        }
    }

    Component.onCompleted: {
        console.log("Craeted DashBoard: w = ", root.widht, " h = ", root.height)
    }
}

