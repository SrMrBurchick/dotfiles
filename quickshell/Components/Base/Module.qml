import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:./Components/Base/"
import "root:./Configs"

Control {
    property bool isHovered: false
    property string bgColor: isHovered ? Config.colors.moduleHoveredBG : Config.colors.moduleUnHoveredBG

    Behavior on bgColor {
        ColorAnimation {
            duration: Config.anim.appearance.baseAnimationTime
        }
    }

    padding: Config.sizes.defaultPadding

    background: Rectangle {
        id: button
        color: bgColor
        opacity: Config.anim.appearance.baseOpacity
        radius: Config.sizes.moduleRadius
    }

    Layout.fillHeight: true
    Layout.margins: Config.sizes.defaultMargin

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            moduleClicked();
        }
        onEntered: {
            isHovered = true;
            moduleHovered(isHovered);
        }
        onExited: {
            isHovered = false;
            moduleHovered(isHovered);
        }
    }


    signal moduleClicked();
    signal moduleHovered(bool hovered);
}

