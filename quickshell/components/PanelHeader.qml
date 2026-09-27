import QtQuick
import "../theme"

Item {
    id: header

    property string title: ""
    property bool keyboardNavigable: false
    signal closeRequested

    implicitHeight: 26

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: header.title
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }

    PanelButton {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 24
        label: "×"
        action: true
        keyboardNavigable: header.keyboardNavigable
        onClicked: header.closeRequested()
    }
}
