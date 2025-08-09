import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:./Components/Base/"
import "root:./Components/Bar/Dashboard/Calendar"

ColumnLayout {
    SystemClock {
        id: clock
    }

    DayOfWeekRow {
        locale: grid.locale
        Layout.fillWidth: true

        delegate: BaseText {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            color: "black"
            text: model.shortName
            font.family: Config.font.family.sans
            font.weight: 500
        }
    }

    MonthGrid {
        id: grid
        month: Qt.formatDateTime(clock.date, "MMMM")
        year: Qt.formatDateTime(clock.date, "yyyy")
        locale: Qt.locale("en_US")
        Layout.fillWidth: true
        delegate: Item {
            id: day

            required property var model

            implicitWidth: implicitHeight
            // implicitHeight: text.implicitHeight + Appearance.padding.small * 2
            implicitHeight: text.implicitHeight

            Rectangle {
                anchors.centerIn: parent

                implicitWidth: parent.implicitHeight
                implicitHeight: parent.implicitHeight

                radius: 20
                color: model.today ? CalendarStyle.colors.todayDayBG : CalendarStyle.colors.dayBG

                BaseText {
                    id: text

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(day.model.date, "d")

                    color: "black"
                    // color: day.model.today ? Colours.palette.m3onPrimary : day.model.month === grid.month ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outline
                }
            }
        }
    }
}
