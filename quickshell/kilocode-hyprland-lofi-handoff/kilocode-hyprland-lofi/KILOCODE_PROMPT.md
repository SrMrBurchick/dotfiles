# KiloCode CLI Prompt — Hyprland + Quickshell Lofi Rice

You are working on my existing Arch Linux + Hyprland desktop configuration.

## Goal

Help me continue building a cohesive **lofi-themed Hyprland desktop** using **Quickshell (QML)**.

The visual direction is:

- dark charcoal/navy base
- muted lavender / dusty purple
- warm dusty pink / coral
- cream highlights
- muted sage green accents
- soft, cozy lofi atmosphere
- rounded UI
- subtle blur/transparency where appropriate
- smooth, short animations
- minimal visual noise
- avoid overusing bright pink/purple; accents should remain restrained

I want the whole desktop to eventually feel visually consistent:
Hyprland, Quickshell bar, workspace indicators, launcher, notifications, terminal, etc.

## Color palette

Use these colors as the canonical palette:

```qml
// Base
background      = "#11111B"
backgroundAlt   = "#181825"
surface         = "#1E1E2E"
surfaceAlt      = "#29263A"

// Text
foreground      = "#CDD6F4"
text            = "#CDD6F4"
textMuted       = "#8C8AA3"
textDark        = "#181825"

// Purple / Lavender
lavender        = "#A89BB9"
purple          = "#817A9B"
purpleDark      = "#514B68"

// Pink / Coral
pink            = "#C77D91"
coral           = "#D58A86"
rose            = "#B86F82"

// Warm tones
cream           = "#D8C3A5"
peach           = "#D6A27A"

// Green
sage            = "#819B8B"
sageDark        = "#596F65"
```

Semantic mapping:

```qml
button                = purple
buttonHover           = lavender
buttonActive          = pink

border                = purpleDark
borderInactive        = surfaceAlt
borderActive          = pink

selection             = purple
selectionHover        = lavender

notification          = surface
notificationForeground = foreground
notificationHighlight = pink

success               = sage
warning               = peach
error                 = rose

workspace             = textMuted
workspaceHover        = lavender
workspaceActive       = pink

tooltip               = surfaceAlt
tooltipText           = foreground
```

## Current Config.qml direction

My Quickshell config uses a singleton with semantic colors.

Keep semantic names centralized in `Config.qml`; do not scatter literal hex values throughout components unless there is a strong reason.

Current intended structure:

```qml
pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property Sizes sizes: Sizes {}
    property Colors colors: Colors {}

    component Colors: QtObject {
        readonly property color background: "#11111B"
        readonly property color backgroundAlt: "#181825"
        readonly property color surface: "#1E1E2E"
        readonly property color surfaceAlt: "#29263A"

        readonly property color foreground: "#CDD6F4"
        readonly property color text: "#CDD6F4"
        readonly property color textMuted: "#8C8AA3"
        readonly property color textDark: "#181825"

        readonly property color lavender: "#A89BB9"
        readonly property color purple: "#817A9B"
        readonly property color purpleDark: "#514B68"

        readonly property color pink: "#C77D91"
        readonly property color coral: "#D58A86"
        readonly property color rose: "#B86F82"

        readonly property color cream: "#D8C3A5"
        readonly property color peach: "#D6A27A"

        readonly property color sage: "#819B8B"
        readonly property color sageDark: "#596F65"

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

        // Legacy/current aliases kept for compatibility
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
    }
}
```

## Workspace component

My current workspace indicator component is based on `BaseText`.

It currently uses empty/filled Nerd Font circle glyphs:

- inactive: ``
- focused or hovered: ``

Current component:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:./Components/Base/"

BaseText {
    property HyprlandWorkspace workspace
    property bool bIsFocused: workspace ? workspace.focused : false
    property bool bIsHovered: false

    text: bIsFocused || bIsHovered ? "" : ""

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (workspace) {
                workspace.activate()
            }
        }

        onEntered: {
            bIsHovered = true
        }

        onExited: {
            bIsHovered = false
        }
    }
}
```

Desired workspace behavior:

- smooth hover scale animation
- hover scale around `1.35–1.4`
- focused workspace may remain slightly enlarged around `1.10–1.15`
- animation duration around `120–180 ms`
- use `Easing.OutCubic` or similarly soft easing
- smoothly animate color
- inactive workspace: `Config.colors.workspace`
- focused workspace: `Config.colors.workspaceActive`
- hovered workspace: `Config.colors.workspaceHover`
- preserve click-to-activate behavior
- keep layout stable; avoid hover causing surrounding items to jump
- avoid excessive animation

A suitable implementation direction is:

```qml
scale: {
    if (bIsHovered)
        return 1.4
    if (bIsFocused)
        return 1.15
    return 1.0
}

color: bIsHovered
    ? Config.colors.workspaceHover
    : bIsFocused
        ? Config.colors.workspaceActive
        : Config.colors.workspace

Behavior on scale {
    NumberAnimation {
        duration: 150
        easing.type: Easing.OutCubic
    }
}

Behavior on color {
    ColorAnimation {
        duration: 150
    }
}
```

## Coding preferences

When editing the project:

1. Inspect the existing project structure and reuse existing base components.
2. Prefer small, incremental changes.
3. Do not rewrite working components unnecessarily.
4. Keep visual constants in the central config singleton.
5. Reuse semantic colors instead of raw hex values in UI components.
6. Keep QML readable and relatively simple.
7. Preserve existing naming conventions unless there is a clear improvement.
8. Explain any architectural change before making a broad refactor.
9. Avoid adding dependencies unless actually necessary.
10. When possible, show me the exact files changed and summarize why.

## First task

Start by inspecting the current Quickshell configuration and workspace component.

Then:

1. Update the workspace indicator to have polished hover/focus scale and color animations.
2. Check whether its parent layout reserves enough space so scaling does not clip.
3. If clipping or layout jitter is possible, fix it cleanly without changing the overall bar height unnecessarily.
4. Keep the result subtle and consistent with the lofi palette.
5. Show the final diff or exact changed files.

After that, suggest the next 2–3 small UI improvements that would give the biggest visual payoff while keeping the same aesthetic.