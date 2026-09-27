import QtQuick
import "../theme"

Rectangle {
    id: button

    property string label: ""
    property int labelFontSize: Theme.fontSize
    property string glyph: ""
    property int glyphFontSize: 20
    property string glyphFamily: "tabler-icons"
    property string icon: ""
    property int iconSize: 17
    property bool selected: false
    property bool boxed: false
    property bool alignLeft: false
    property real lineHeight: 1
    property real progress: -1
    signal clicked

    color: boxed ? (selected ? Theme.bgSelected : mouse.containsMouse ? Theme.bgHover : Theme.bgSurface) : "transparent"
    border.color: boxed ? (selected ? Theme.accentPrimary : Theme.bgBorder) : "transparent"
    border.width: boxed ? 1 : 0
    implicitWidth: labelText.implicitWidth + (iconImage.visible ? button.iconSize + Theme.spacing : 0) + (glyphText.visible ? glyphText.implicitWidth + Theme.spacing : 0) + (progressTrack.visible ? progressTrack.width + Theme.spacing : 0) + 12
    implicitHeight: 25

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        x: button.alignLeft ? 10 : (button.width - implicitWidth) / 2
        width: button.alignLeft ? button.width - 20 : implicitWidth
        spacing: Theme.spacing

        Image {
            id: iconImage
            visible: button.icon !== ""
            source: button.icon
            width: button.iconSize
            height: button.iconSize
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: glyphText
            visible: button.glyph !== ""
            text: button.glyph
            color: Theme.textPrimary
            font.family: button.glyphFamily
            font.pixelSize: button.glyphFontSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: progressTrack
            visible: button.progress >= 0
            width: 4
            height: 16
            color: Theme.bgBorder
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * Math.max(0, Math.min(1, button.progress))
                color: Theme.accentPrimary
            }
        }

        Text {
            id: labelText
            width: button.alignLeft ? parent.width - (iconImage.visible ? iconImage.width + parent.spacing : 0) : implicitWidth
            text: button.label
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: button.labelFontSize
            lineHeight: button.lineHeight
            lineHeightMode: Text.ProportionalHeight
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
