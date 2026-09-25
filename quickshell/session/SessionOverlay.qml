import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Standalone session overlay.
Scope {
    id: root

    property var theme: DefaultTheme {}

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property bool action: false
        property bool selected: false
        property bool keyboardNavigable: false
        property bool alignLeft: false
        signal clicked

        activeFocusOnTab: keyboardNavigable
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        Keys.onSpacePressed: button.clicked()

        color: action ? (mouse.containsMouse || activeFocus ? theme.accentPrimary : selected ? theme.bgSelected : "transparent") : selected ? theme.bgSelected : "transparent"
        border.color: activeFocus ? theme.accentPrimary : action ? theme.bgBorderStrong : "transparent"
        border.width: activeFocus || action ? 1 : 0
        implicitWidth: labelText.implicitWidth + (action ? 16 : 12)
        implicitHeight: 25

        Text {
            id: labelText
            x: button.alignLeft ? 8 : (button.width - implicitWidth) / 2
            text: button.label
            color: button.action ? (mouse.containsMouse || button.activeFocus ? button.theme.bgBase : button.theme.accentPrimary) : button.theme.textPrimary
            font.family: button.theme.fontFamily
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

    component PanelHeader: Item {
        id: header
        property var theme: DefaultTheme {}
        property string title: ""
        property bool keyboardNavigable: false
        signal closeRequested

        implicitHeight: 26

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: header.title
            color: header.theme.textPrimary
            font.family: header.theme.fontFamily
            font.pixelSize: header.theme.fontSize
            font.bold: true
        }

        BarButton {
            theme: header.theme
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

    IpcHandler {
        target: "session"

        function toggle(): void {
            panel.visible = !panel.visible;
        }
    }

    PanelWindow {
        id: panel
        visible: false
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-session"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors.fill: parent
            color: root.theme.bgOverlay

            MouseArea {
                anchors.fill: parent
                onClicked: panel.visible = false
            }
        }

        Item {
            id: body
            width: 320
            height: 150
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            Keys.onEscapePressed: panel.visible = false

            function focusFirstAction() {
                lockButton.forceActiveFocus();
            }

            Rectangle {
                anchors.fill: parent
                color: root.theme.bgSurfaceLow
                border.color: root.theme.bgBorder
                border.width: 1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.panelPadding
                spacing: root.theme.sectionSpacing

                PanelHeader {
                    theme: root.theme
                    Layout.fillWidth: true
                    title: "Session"
                    keyboardNavigable: true
                    onCloseRequested: panel.visible = false
                }

                BarButton {
                    id: logoutButton
                    theme: root.theme
                    Layout.fillWidth: true
                    label: "Log out"
                    action: true
                    keyboardNavigable: true
                    KeyNavigation.up: lockButton
                    KeyNavigation.down: restartButton
                    onClicked: {
                        panel.visible = false;
                        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]);
                    }
                }

                BarButton {
                    id: restartButton
                    theme: root.theme
                    Layout.fillWidth: true
                    label: "Restart"
                    action: true
                    keyboardNavigable: true
                    KeyNavigation.up: logoutButton
                    KeyNavigation.down: shutdownButton
                    onClicked: {
                        panel.visible = false;
                        Quickshell.execDetached(["systemctl", "reboot"]);
                    }
                }

                BarButton {
                    id: shutdownButton
                    theme: root.theme
                    Layout.fillWidth: true
                    label: "Shut down"
                    action: true
                    keyboardNavigable: true
                    KeyNavigation.up: restartButton
                    KeyNavigation.down: lockButton
                    onClicked: {
                        panel.visible = false;
                        Quickshell.execDetached(["systemctl", "poweroff"]);
                    }
                }
            }
        }

        onVisibleChanged: if (visible)
            Qt.callLater(() => body.focusFirstAction())
    }
}
