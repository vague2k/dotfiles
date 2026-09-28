import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    property string title: ""
    property string ipcTarget: ""
    property bool open: false
    property real bodyWidth: 380
    property real bodyHeight: 500
    property int bodyBorderWidth: 1
    property bool headerKeyboardNavigable: false
    property bool closeOnEscape: true
    signal escapePressed

    property bool anchorLeft: false
    property bool anchorRight: false
    property bool anchorTop: false
    property bool anchorBottom: false
    property int marginLeft: 4
    property int marginRight: 4
    property int marginTop: 4
    property int marginBottom: 36

    default property alias content: contentColumn.data
    property alias popover: popoverSlot.data

    IpcHandler {
        target: root.ipcTarget

        function toggle(): void {
            root.open = !root.open;
        }
    }

    PanelWindow {
        id: panel
        visible: root.open
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-" + root.ipcTarget
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Rectangle {
            id: body

            readonly property real maxWidth: Math.max(0, panel.width - root.marginLeft - root.marginRight)
            readonly property real maxHeight: Math.max(0, panel.height - root.marginTop - root.marginBottom)

            width: Math.min(root.bodyWidth, maxWidth)
            height: Math.min(root.bodyHeight, maxHeight)
            x: root.anchorLeft ? root.marginLeft : root.anchorRight ? panel.width - width - root.marginRight : Math.round((panel.width - width) / 2)
            y: root.anchorTop ? root.marginTop : root.anchorBottom ? panel.height - height - root.marginBottom : Math.round((panel.height - height) / 2)

            focus: true
            color: Theme.bgSurfaceLow
            border.color: Theme.bgBorder
            border.width: root.bodyBorderWidth

            MouseArea {
                anchors.fill: parent
            }

            Keys.onEscapePressed: {
                if (root.closeOnEscape)
                    root.open = false;
                root.escapePressed();
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.panelPadding
                spacing: Theme.sectionSpacing

                PanelHeader {
                    Layout.fillWidth: true
                    visible: root.title !== ""
                    title: root.title
                    keyboardNavigable: root.headerKeyboardNavigable
                    onCloseRequested: root.open = false
                }

                ColumnLayout {
                    id: contentColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.sectionSpacing
                }
            }

            Item {
                id: popoverSlot
                anchors.fill: parent
            }
        }
    }
}
