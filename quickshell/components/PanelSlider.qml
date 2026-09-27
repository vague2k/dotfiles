import QtQuick
import QtQuick.Controls
import "../theme"

Slider {
    id: slider

    implicitHeight: 24
    hoverEnabled: true
    activeFocusOnTab: false

    background: Rectangle {
        x: slider.leftPadding
        y: (slider.height - height) / 2
        width: slider.availableWidth
        height: 4
        color: Theme.bgBorder

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: Theme.accentPrimary
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: (slider.height - height) / 2
        width: 6
        height: 16
        color: slider.pressed || slider.hovered || slider.activeFocus ? Theme.textPrimary : Theme.accentPrimary
    }
}
