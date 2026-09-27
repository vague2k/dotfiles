import QtQuick
import "../theme"

Rectangle {
    id: button

    property string label: ""
    property int labelFontSize: Theme.fontSize
    property bool action: false
    property bool selected: false
    property bool keyboardNavigable: false
    property bool alignLeft: false
    signal clicked

    activeFocusOnTab: keyboardNavigable
    Keys.onReturnPressed: button.clicked()
    Keys.onEnterPressed: button.clicked()
    Keys.onSpacePressed: button.clicked()

    color: action ? (mouse.containsMouse || activeFocus ? Theme.accentPrimary : selected ? Theme.bgSelected : "transparent") : selected ? Theme.bgSelected : "transparent"
    border.color: activeFocus ? Theme.accentPrimary : action ? Theme.bgBorderStrong : "transparent"
    border.width: activeFocus || action ? 1 : 0
    implicitWidth: labelText.implicitWidth + (action ? 16 : 12)
    implicitHeight: 25

    Text {
        id: labelText
        x: button.alignLeft ? 8 : (button.width - implicitWidth) / 2
        text: button.label
        color: button.action ? (mouse.containsMouse || button.activeFocus ? Theme.bgBase : Theme.accentPrimary) : Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: button.labelFontSize
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (button.keyboardNavigable)
                button.forceActiveFocus();
            button.clicked();
        }
    }
}
