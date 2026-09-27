import Quickshell.Hyprland
import QtQuick
import "../components"

Row {
    id: root

    property var monitor
    property int maxWidth: 800
    readonly property var windows: Hyprland.toplevels.values.filter(window => window.monitor?.name === monitor?.name && window.workspace?.id > 0)
    readonly property int tabWidth: Math.min(210, Math.max(0, Math.floor((maxWidth - Math.max(0, windows.length - 1) * spacing) / Math.max(1, windows.length))))

    spacing: 1

    Repeater {
        model: root.windows

        BarButton {
            required property var modelData
            readonly property var entry: AppLookup.resolveWindow(modelData)

            width: root.tabWidth
            label: modelData.title ? modelData.title : (entry?.name || modelData.wayland?.appId || modelData.lastIpcObject?.class || "App")
            icon: AppLookup.icon(entry)
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
