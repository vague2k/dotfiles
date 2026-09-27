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
    property real bodyInset: 0
    property int bodyBorderWidth: 1
    property bool headerKeyboardNavigable: false
    property bool closeOnEscape: true
    signal escapePressed

    default property alias content: contentColumn.data

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

        Rectangle {
            anchors.fill: parent
            color: Theme.bgOverlay

            MouseArea {
                anchors.fill: parent
                onClicked: root.open = false
            }
        }

        Rectangle {
            id: body
            width: Math.min(root.bodyWidth, panel.width - root.bodyInset)
            height: Math.min(root.bodyHeight, panel.height - root.bodyInset)
            anchors.centerIn: parent
            visible: root.open
            focus: true
            color: Theme.bgSurfaceLow
            border.color: Theme.bgBorder
            border.width: root.bodyBorderWidth

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
        }
    }
}
