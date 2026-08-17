import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:./Components/Base/"
import "root:./Components/Bar/Dashboard/Calendar"
import "root:./Configs"

ColumnLayout {
    id: root

    spacing: Config.sizes.baseSpacing

    SystemClock {
        id: clock
    }

    DayOfWeekRow {
        id: weekRow

        locale: grid.locale
        Layout.fillWidth: true

        delegate: BaseText {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: model.shortName

            color: Config.colors.textMuted
            font.family: Config.font.family.sans
            font.weight: 500
        }
    }

    MonthGrid {
        id: grid

        month: clock.date.getMonth()
        year: clock.date.getFullYear()

        locale: Qt.locale("en_US")

        Layout.fillWidth: true

        delegate: Item {
            id: day

            required property var model

            property bool isHovered: false
            property bool isCurrentMonth: model.month === grid.month

            implicitWidth: 34
            implicitHeight: 34

            Rectangle {
                id: dayBackground

                anchors.centerIn: parent

                width: 30
                height: 30

                radius: width / 2

                color: {
                    if (day.model.today)
                        return Config.colors.workspaceActive

                    if (day.isHovered)
                        return Config.colors.workspaceHover

                    return Config.colors.dayBG
                }

                scale: day.isHovered ? 1.12 : 1.0

                Behavior on color {
                    ColorAnimation {
                        duration: Config.anim.appearance.baseAnimationTime
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Config.anim.appearance.baseAnimationTime
                        easing.type: Easing.OutCubic
                    }
                }

                BaseText {
                    id: text

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: Qt.formatDate(day.model.date, "d")

                    color: {
                        if (day.model.today)
                            return Config.colors.textDark

                        if (!day.isCurrentMonth)
                            return Config.colors.textMuted

                        return Config.colors.text
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.anim.appearance.baseAnimationTime
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    day.isHovered = true
                }

                onExited: {
                    day.isHovered = false
                }
            }
        }
    }
}
