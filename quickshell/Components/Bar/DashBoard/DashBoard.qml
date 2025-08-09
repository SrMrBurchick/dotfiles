import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Components/Bar/DashBoard/Calendar"

GridLayout {
    anchors.fill: parent
    // Calendar {
    //
    // }
    //
    Module {
        contentItem: UserInfo {

        }
    }
}

