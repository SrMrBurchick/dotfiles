import QtQuick

import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Widgets"
import "root:./Services"

Module {
    contentItem: BaseText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: HyprlandSocket.currentKbLayout
    }
}

