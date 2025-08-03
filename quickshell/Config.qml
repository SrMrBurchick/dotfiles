pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property Sizes sizes: Sizes {}
    property Colors colors: Colors {}
    property Font font: Font {}
    property Anim anim: Anim {}

    component Colors: QtObject {
        readonly property color barBG: "transparent"
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

    component FontFamily: QtObject {
        readonly property string sans: "IBM Plex Sans"
        readonly property string mono: "JetBrains Mono NF"
        readonly property string material: "Material Symbols Rounded"
    }

    component FontSize: QtObject {
        readonly property int small: 11
        readonly property int smaller: 12
        readonly property int normal: 13
        readonly property int larger: 15
        readonly property int large: 18
        readonly property int extraLarge: 28
    }

    component Font: QtObject {
        readonly property FontFamily family: FontFamily {}
        readonly property FontSize size: FontSize {}
    }

    component Appearance: QtObject {
        readonly property real baseAnimationTime: 200.0
        readonly property real baseOpacity: 0.8
    }

    component Anim: QtObject {
        readonly property Appearance appearance: Appearance {}
    }
}
