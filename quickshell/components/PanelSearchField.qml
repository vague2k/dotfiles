import QtQuick
import QtQuick.Controls
import "../theme"

TextField {
    id: field

    implicitHeight: 26
    leftPadding: 8
    rightPadding: 8
    color: Theme.textPrimary
    placeholderTextColor: Theme.textSecondary
    selectionColor: Theme.accentPrimary
    selectedTextColor: Theme.bgBase
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    background: Rectangle {
        color: Theme.bgSurfaceLow
        border.width: 1
        border.color: field.activeFocus ? Theme.accentPrimary : Theme.bgBorder
    }
}
