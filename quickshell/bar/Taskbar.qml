import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../theme"

Row {
    id: root

    property var monitor
    property int maxWidth: 800
    readonly property var windows: Hyprland.toplevels.values.filter(window => window.monitor?.name === monitor?.name && window.workspace?.id > 0)
    readonly property int tabWidth: Math.min(220, Math.max(0, Math.floor((maxWidth - Math.max(0, windows.length - 1) * spacing) / Math.max(1, windows.length))))

    spacing: 1

    Repeater {
        model: root.windows

        Rectangle {
            id: taskButton
            required property var modelData
            readonly property var entry: DesktopEntries.heuristicLookup(modelData?.wayland?.appId || modelData?.lastIpcObject?.class || "")

            width: root.tabWidth
            implicitHeight: 28
            color: modelData.activated ? Theme.bgSelected : taskMouse.containsMouse ? Theme.bgHover : Theme.bgSurface
            border.color: modelData.activated ? Theme.accentPrimary : Theme.bgBorder
            border.width: 1

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 8
                width: taskButton.width - 20
                spacing: Theme.spacing

                Image {
                    id: taskIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 20
                    source: Quickshell.iconPath(taskButton.entry?.icon || "", true)
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width - (taskIcon.width + parent.spacing)
                    anchors.verticalCenter: parent.verticalCenter
                    text: taskButton.modelData.title ? taskButton.modelData.title : (taskButton.entry?.name || taskButton.modelData.wayland?.appId || taskButton.modelData.lastIpcObject?.class || "App")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: taskMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
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
}
