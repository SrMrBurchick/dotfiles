import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:"
import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Widgets"

Module {
    SystemClock {
        id: clock
    }

    contentItem: BaseText {
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDateTime(clock.date, "ddd dd MMM yyyy hh:mm:ss")
    }

    AppletWindow {
        id: dashboard
        contentItem: Calendar {

        }
    }

    onModuleClicked: {
        if (dashboard.opened) {
            dashboard.close()
        } else {
            dashboard.open()
        }
    }
}

