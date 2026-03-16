pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property Sizes sizes: Sizes {}
    property Colors colors: Colors {}

    component Colors: QtObject {
        readonly property color controlButton: "#18122B"
        readonly property color controlButtonHovered: "#393053"
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
