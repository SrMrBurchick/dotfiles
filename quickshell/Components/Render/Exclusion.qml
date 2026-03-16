import Quickshell
import QtQuick

import "root:./Widgets"
import "root:./Configs"

Scope {
    id: root

    required property ShellScreen screen
    required property Item bar

    ExclusionZone {
        anchors.left: true
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: Config.sizes.barHeight
    }

    ExclusionZone {
        anchors.right: true
    }

    ExclusionZone {
        anchors.bottom: true
    }

    component ExclusionZone: BaseWindow {
        screen: root.screen
        name: "border-exclusion"
        mask: Region {}
        exclusiveZone: Config.sizes.baseExclusion
        // Rectangle {
        //     anchors.fill: parent
        //     color: "grey"
        //     opacity: 0.4
        //     width: parent.exclusiveZone
        //     height: parent.exclusiveZone
        // }
    }
}
