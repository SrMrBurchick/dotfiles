import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

import "root:./"
import "root:./Widgets"
import "root:./Components/Render"

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusion {
            screen: scope.modelData
            bar: bar
        }

        BaseWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            mask: Region {
                x: bar.implicitWidth
                y: Config.sizes.barHeight
                width: win.width - bar.implicitWidth - 10
                height: win.height
                intersection: Intersection.Xor

                regions: regions.instances
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            BarRender {
                id: bar

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom


                screen: scope.modelData
                visibilities: visibilities
            }
        }
    }
}
