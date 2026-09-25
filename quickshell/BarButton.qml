import QtQuick

Rectangle {
    id: root

    property string label: ""
    property int labelFontSize: Theme.fontSize
    property string glyph: ""
    property int glyphFontSize: 26
    property string icon: ""
    property int iconSize: 17

    property bool selected: false
    property bool boxed: false
    property bool highlightOnHover: true
    property real lineHeight: 1
    property bool alignLeft: false
    signal clicked()

    color: boxed ? (selected ? "#35465e" : mouse.containsMouse ? "#344052" : "#252c36") : (highlightOnHover && mouse.containsMouse ? "#344052" : "transparent")
    border.color: boxed ? (selected ? "#699fe0" : "#596575") : "transparent"
    border.width: boxed ? 1 : 0
    implicitWidth: labelText.implicitWidth + (iconImage.visible ? root.iconSize + 5 : 0) + (glyphText.visible ? glyphText.implicitWidth + 5 : 0) + 12
    implicitHeight: 25

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        x: root.alignLeft ? 6 : (root.width - implicitWidth) / 2
        spacing: 5

        Image {
            id: iconImage
            visible: root.icon !== ""
            source: root.icon
            width: root.iconSize
            height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: glyphText
            visible: root.glyph !== ""
            text: root.glyph
            color: "#e8edf5"
            font.family: Theme.fontFamily
            font.pixelSize: root.glyphFontSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: labelText
            width: root.alignLeft ? Math.max(0, root.width - 12 - (iconImage.visible ? root.iconSize + 5 : 0) - (glyphText.visible ? glyphText.implicitWidth + 5 : 0)) : implicitWidth
            text: root.label
            color: "#e8edf5"
            font.family: Theme.fontFamily
            font.pixelSize: root.labelFontSize
            lineHeight: root.lineHeight
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
        onClicked: root.clicked()
    }
}
