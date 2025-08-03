import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:"
import "root:./Components/Base/"

Text {
    font.pixelSize : Config.font.size.large
    font.family: Config.font.family.mono
    color: Config.colors.text
    font.bold: true
}
