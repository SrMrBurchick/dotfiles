import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import "root:./Configs"
import "root:./Widgets"
import "root:./Components/Render"
import "root:./Services"

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData
        property list<Popup> popups: []
        property list<QtObject> notifications: []

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
                id: rootRegion
                x: bar.implicitWidth
                y: Config.sizes.barHeight
                width: win.width - bar.implicitWidth - 10
                height: win.height
                intersection: Intersection.Xor
                regions: regions.instances
            }

            Variants {
                id: regions

                model: popups

                delegate: Region {
                    required property AppletWindow modelData

                    x: modelData.x
                    y: modelData.y

                    width: modelData.width
                    height: modelData.height

                    intersection: Intersection.Subtract
                }
            }
            Item {
                id: debugRegions

                Repeater {
                    model: popups
                    Rectangle {
                        x: modelData.x
                        y: modelData.y
                        width: modelData.width
                        height: modelData.height
                        color: "#33FF0000"
                        border.color: "#FF0000"
                        border.width: 2
                    }
                }
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

            Item {
                id: notificationArea

                width: 300
                height: children.length > 0 ? children.length * 70 : 0

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 60

                Repeater {
                    model: NotificationService.list

                    delegate: Item {
                        width: 300
                        height: 60

                        Rectangle {
                            anchors.fill: parent
                            color: "#CC1E1E1E"
                            radius: Config.sizes.moduleRadius
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Config.sizes.defaultPadding

                            Text {
                                text: modelData.summary
                                color: Config.colors.text
                                font.pixelSize: Config.font.size.normal
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }

                            Text {
                                text: "×"
                                color: Config.colors.text
                                font.pixelSize: Config.font.size.large

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: modelData.notification.dismiss()
                                }
                            }
                        }

                        Timer {
                            interval: 5000
                            running: true
                            onTriggered: modelData.notification.dismiss()
                        }
                    }
                }
            }

            Component.onCompleted: {
                notifications = NotificationService.list;
                RenderManager.regionRemoved.connect(function(region) {
                    console.log("Region removed event")
                    if (region.screen === scope.modelData)
                    {
                        console.log("Region removed")
                        scope.popups.splice(scope.popups.indexOf(region), 1);
                    }
                })
                RenderManager.regionAdded.connect(function(region) {
                    if (region.screen === scope.modelData)
                    {
                        scope.popups.push(region)
                        console.log("Exclusion: x:", region.x, " y:", region.y)
                        console.log("Region added")
                    }
                })
            }
        }
    }
}
