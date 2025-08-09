pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property Sizes sizes: Sizes {}
    property Colors colors: Colors {}

    component Colors: QtObject {
        readonly property color dayBG: "#9290C3"
        readonly property color todayDayBG: "#EDE4FF"
        readonly property color text: "white"
        readonly property color moduleUnHoveredBG: "#18122B"
        readonly property color moduleHoveredBG: "#393053"
    }

    component Sizes: QtObject {
        readonly property int buttonBorderSize: 2
        readonly property int buttonFontSize: 24
        readonly property int buttonRadiusSize: 10
        readonly property int barHeight: 40
        readonly property int moduleRadius: 10

        readonly property int defaultMargin: 5
        readonly property int defaultPadding: 5

        readonly property int baseSpacing: 5

    }
}
