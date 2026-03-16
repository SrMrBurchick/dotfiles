import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import "root:./Configs"
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
                // height: 0
                intersection: Intersection.Xor

                // regions: regions.instances
                // regions: [Region {
                //     x: win.width / 2 - 100
                //     y: Config.sizes.barHeight
                //
                //     // width: modelData.width
                //     // height: modelData.height
                //     width: 200
                //     height: 200
                //     intersection: Intersection.Subtract
                // }]
            }


            // Variants {
            //     id: regions
            //
            //     model: RenderManager.popups
            //
            //     delegate: Region {
            //         required property AppletWindow modelData
            //
            //         x: modelData.x + bar.implicitWidth
            //         y: modelData.y + Config.sizes.barHeight
            //         // x: win.width / 2 - 100
            //         // y: Config.sizes.barHeight
            //
            //         width: modelData.width
            //         height: modelData.height
            //         // width: 200
            //         // height: 200
            //
            //         intersection: Intersection.Subtract
            //         Component.onCompleted: {
            //             console.log("Add new region[x = ", x, ",y = ", y, ",w =", width, "h = ", height)
            //         }
            //     }
            // }

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
