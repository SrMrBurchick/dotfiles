import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:./Components/Base/"
import "root:./Components/Bar/DashBoard"
import "root:./Widgets"
import "root:./Configs"

Module {
    id: root

    required property ShellScreen screen

    SystemClock {
        id: clock
    }

    contentItem: Item {
        implicitWidth: content.implicitWidth
        implicitHeight: content.implicitHeight

        RowLayout {
            id: content

            anchors.centerIn: parent
            spacing: 8

            BaseText {
                text: Qt.formatDateTime(clock.date, "dddd dd MMM")
                color: Config.colors.textMuted

                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                Layout.alignment: Qt.AlignVCenter

                radius: 1
                color: Config.colors.purpleDark
            }

            BaseText {
                text: Qt.formatDateTime(clock.date, "hh:mm:ss")
                color: Config.colors.foreground

                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    AppletWindow {
        id: dashboard
        screen: root.screen

        contentItem: DashBoard {}
    }

    onModuleClicked: {
        if (dashboard.opened)
            dashboard.close()
        else
            dashboard.open()
    }
}
