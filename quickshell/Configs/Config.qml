pragma Singleton

import QtQuick
import Quickshell.Io
pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property Sizes sizes: Sizes {}
    property Colors colors: Colors {}
    property Font font: Font {}
    property Anim anim: Anim {}

    component Colors: QtObject {
        // ─────────────────────────────────────────────
        // Base
        // ─────────────────────────────────────────────

        readonly property color background: "#11111B"
        readonly property color backgroundAlt: "#181825"

        readonly property color surface: "#1E1E2E"
        readonly property color surfaceAlt: "#29263A"

        // ─────────────────────────────────────────────
        // Text
        // ─────────────────────────────────────────────

        readonly property color foreground: "#CDD6F4"
        readonly property color text: "#CDD6F4"
        readonly property color textMuted: "#8C8AA3"
        readonly property color textDark: "#181825"

        // ─────────────────────────────────────────────
        // Purple / Lavender
        // ─────────────────────────────────────────────

        readonly property color lavender: "#A89BB9"
        readonly property color purple: "#817A9B"
        readonly property color purpleDark: "#514B68"

        // ─────────────────────────────────────────────
        // Pink / Coral
        // ─────────────────────────────────────────────

        readonly property color pink: "#C77D91"
        readonly property color coral: "#D58A86"
        readonly property color rose: "#B86F82"

        // ─────────────────────────────────────────────
        // Warm tones
        // ─────────────────────────────────────────────

        readonly property color cream: "#D8C3A5"
        readonly property color peach: "#D6A27A"

        // ─────────────────────────────────────────────
        // Green
        // ─────────────────────────────────────────────

        readonly property color sage: "#819B8B"
        readonly property color sageDark: "#596F65"

        // ─────────────────────────────────────────────
        // Semantic UI colors
        // ─────────────────────────────────────────────

        readonly property color button: purple
        readonly property color buttonHover: lavender
        readonly property color buttonActive: pink

        readonly property color border: purpleDark
        readonly property color borderInactive: surfaceAlt
        readonly property color borderActive: pink

        readonly property color selection: purple
        readonly property color selectionHover: lavender

        readonly property color notification: surface
        readonly property color notificationForeground: foreground
        readonly property color notificationHighlight: pink

        readonly property color success: sage
        readonly property color warning: peach
        readonly property color error: rose

        readonly property color workspace: textMuted
        readonly property color workspaceHover: lavender
        readonly property color workspaceActive: pink

        readonly property color tooltip: surfaceAlt
        readonly property color tooltipText: foreground

        // ─────────────────────────────────────────────
        // Existing Quickshell names
        // Keep these for compatibility with current UI
        // ─────────────────────────────────────────────

        readonly property color dayBG: surface
        readonly property color todayDayBG: surfaceAlt

        readonly property color moduleUnHoveredBG: backgroundAlt
        readonly property color moduleHoveredBG: purpleDark
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
        readonly property int baseExclusion: 10

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
