import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root

    property var theme: DefaultTheme {}
    property var monitor
    property int maxWidth: 800
    readonly property var windows: Hyprland.toplevels.values.filter(window => window.monitor?.name === monitor?.name && window.workspace?.id > 0)
    readonly property int tabWidth: Math.min(210, Math.max(0, Math.floor((maxWidth - Math.max(0, windows.length - 1) * spacing) / Math.max(1, windows.length))))

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property string icon: ""
        property int iconSize: 17
        property bool selected: false
        property bool boxed: false
        property bool alignLeft: false
        signal clicked

        color: boxed ? (selected ? theme.bgSelected : mouse.containsMouse ? theme.bgHover : theme.bgSurface) : "transparent"
        border.color: boxed ? (selected ? theme.accentPrimary : theme.bgBorder) : "transparent"
        border.width: boxed ? 1 : 0
        implicitWidth: labelText.implicitWidth + (iconImage.visible ? button.iconSize + theme.spacing : 0) + 12
        implicitHeight: 25

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: button.theme.spacing

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
                id: labelText
                width: parent.width - (iconImage.visible ? iconImage.width + parent.spacing : 0)
                text: button.label
                color: button.theme.textPrimary
                font.family: button.theme.fontFamily
                font.pixelSize: button.labelFontSize
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

    spacing: 1

    Repeater {
        model: root.windows

        BarButton {
            theme: root.theme
            required property var modelData
            readonly property var entry: DesktopEntries.heuristicLookup(modelData.wayland?.appId || modelData.lastIpcObject?.class || "")

            width: root.tabWidth
            label: (entry?.name || modelData.wayland?.appId || modelData.lastIpcObject?.class || "App") + (modelData.title ? " - " + modelData.title : "")
            icon: Quickshell.iconPath(entry?.icon || "", true)
            selected: modelData.activated
            boxed: true
            alignLeft: true

            onClicked: {
                if (modelData.activated && modelData.wayland)
                    modelData.wayland.minimized = true;
                else if (modelData.wayland)
                    modelData.wayland.activate();
                else
                    Hyprland.dispatch("focuswindow address:" + modelData.address);
            }
        }
    }
}
