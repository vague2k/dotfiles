import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Standalone MRU window switcher. Driven by Hyprland keybinds that call the
// `switcher` IPC target on Alt+Tab (repeat) and on Alt release (commit), so the
// overlay itself never holds keyboard focus. Hovering a tile moves the selection;
// releasing Alt focuses it.
Scope {
    id: root

    property var theme: DefaultTheme {}
    property string font: theme.fontFamily

    property bool shown: false
    property int index: 0
    property var order: []

    function rebuild() {
        const all = Hyprland.toplevels.values.filter(window => window.workspace?.id > 0);
        const active = Hyprland.activeToplevel;
        const rest = all.filter(window => window !== active);
        root.order = active ? [active].concat(rest) : all;
    }

    function open(dir) {
        if (!shown) {
            rebuild();
            if (root.order.length === 0)
                return;
            shown = true;
            const count = root.order.length;
            index = dir < 0 ? count - 1 : (count > 1 ? 1 : 0);
        } else {
            const count = root.order.length;
            if (count)
                index = (index + dir + count) % count;
        }
    }

    function focusSelected() {
        if (shown && root.order[index]) {
            const window = root.order[index];
            if (window.wayland)
                window.wayland.activate();
            else
                Hyprland.dispatch("focuswindow address:" + window.address);
        }
        shown = false;
    }

    IpcHandler {
        target: "switcher"

        function next(): void {
            root.open(1);
        }

        function prev(): void {
            root.open(-1);
        }

        function commit(): void {
            root.focusSelected();
        }

        function cancel(): void {
            root.shown = false;
        }
    }

    PanelWindow {
        id: panel
        visible: root.shown
        focusable: false
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell-switcher"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        mask: Region {
            item: card
        }

        Rectangle {
            id: card
            anchors.centerIn: parent

            readonly property int columns: Math.min(Math.max(root.order.length, 1), 5)
            readonly property int rows: Math.max(1, Math.ceil(root.order.length / columns))
            readonly property int tileWidth: 132
            readonly property int tileHeight: 104
            readonly property int gap: 8

            width: columns * tileWidth + (columns - 1) * gap + 16
            height: rows * tileHeight + (rows - 1) * gap + 16
            color: root.theme.bgSurfaceLow
            border.color: root.theme.bgBorder
            border.width: 1
            clip: true

            Flow {
                anchors.fill: parent
                anchors.margins: 8
                spacing: card.gap

                Repeater {
                    model: root.order

                    Rectangle {
                        id: tile
                        required property var modelData
                        required property int index

                        readonly property string appId: modelData.wayland?.appId || modelData.lastIpcObject?.class || ""
                        readonly property var entry: DesktopEntries.heuristicLookup(appId)
                        readonly property bool selected: index === root.index

                        width: card.tileWidth
                        height: card.tileHeight
                        color: selected ? root.theme.accentPrimary : "transparent"
                        border.width: 1
                        border.color: selected ? root.theme.accentPrimary : root.theme.bgBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                source: Quickshell.iconPath(tile.entry?.icon || "", true)
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                Layout.fillWidth: true
                                text: tile.entry?.name || tile.appId || "Window"
                                color: tile.selected ? root.theme.bgBase : root.theme.textPrimary
                                font.family: root.font
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: tile.modelData.title || ""
                                color: tile.selected ? root.theme.bgBase : root.theme.textMuted
                                font.family: root.font
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.index = tile.index
                            onClicked: {
                                root.index = tile.index;
                                root.focusSelected();
                            }
                        }
                    }
                }
            }
        }
    }
}
