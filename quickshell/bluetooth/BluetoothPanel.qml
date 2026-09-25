import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Standalone bluetooth overlay.
Scope {
    id: root

    property var theme: DefaultTheme {}

    readonly property var adapter: Bluetooth.defaultAdapter

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property bool action: false
        property bool selected: false
        property bool keyboardNavigable: false
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
            text: button.label
            color: button.action ? (mouse.containsMouse || button.activeFocus ? button.theme.bgBase : button.theme.accentPrimary) : button.theme.textPrimary
            font.family: button.theme.fontFamily
            font.pixelSize: button.labelFontSize
            anchors.centerIn: parent
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

    component PanelCard: Rectangle {
        property var theme: DefaultTheme {}
        color: theme.bgSurface
        border.color: theme.bgBorder
        border.width: 1
    }

    component PanelHeader: Item {
        id: header
        property var theme: DefaultTheme {}
        property string title: ""
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
            onClicked: header.closeRequested()
        }
    }

    IpcHandler {
        target: "bluetooth"

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
        WlrLayershell.namespace: "quickshell-bluetooth"
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
            width: 310
            height: 380
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            Keys.onEscapePressed: panel.visible = false

            onVisibleChanged: if (!visible && root.adapter)
                root.adapter.discovering = false

            Rectangle {
                anchors.fill: parent
                color: root.theme.bgSurfaceLow
                border.color: root.theme.bgBorder
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.panelPadding
                spacing: root.theme.sectionSpacing

                PanelHeader {
                    theme: root.theme
                    Layout.fillWidth: true
                    title: "Bluetooth"
                    onCloseRequested: panel.visible = false
                }

                PanelCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: root.theme.spacing

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Bluetooth"
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            BarButton {
                                theme: root.theme
                                label: root.adapter?.discovering ? "Stop" : "Scan"
                                action: true
                                onClicked: if (root.adapter)
                                    root.adapter.discovering = !root.adapter.discovering
                            }
                            BarButton {
                                theme: root.theme
                                label: root.adapter?.enabled ? "On" : "Off"
                                action: true
                                selected: root.adapter?.enabled ?? false
                                onClicked: if (root.adapter)
                                    root.adapter.enabled = !root.adapter.enabled
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Discoverable by nearby devices"
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            BarButton {
                                theme: root.theme
                                label: root.adapter?.discoverable ? "On" : "Off"
                                action: true
                                selected: root.adapter?.discoverable ?? false
                                onClicked: if (root.adapter)
                                    root.adapter.discoverable = !root.adapter.discoverable
                            }
                        }
                    }
                }

                PanelCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(94, devices.contentHeight + 46)
                    visible: root.adapter?.enabled ?? false

                    Text {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 8
                        text: "Devices"
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize
                        font.bold: true
                    }

                    ListView {
                        id: devices
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 34
                        anchors.bottomMargin: 8
                        clip: true
                        spacing: root.theme.spacing
                        model: root.adapter?.devices.values || []
                        keyNavigationWraps: true

                        delegate: Rectangle {
                            id: deviceRow
                            required property var modelData
                            width: devices.width
                            height: 36
                            color: root.theme.bgInset

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: root.theme.spacing

                                Text {
                                    Layout.fillWidth: true
                                    text: deviceRow.modelData.name + (deviceRow.modelData.connected ? "  Connected" : "")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }

                                BarButton {
                                    theme: root.theme
                                    label: deviceRow.modelData.connected ? "Disconnect" : deviceRow.modelData.paired ? "Connect" : deviceRow.modelData.pairing ? "Cancel" : "Pair"
                                    action: true
                                    labelFontSize: 11
                                    onClicked: {
                                        if (deviceRow.modelData.connected)
                                            deviceRow.modelData.disconnect();
                                        else if (deviceRow.modelData.paired)
                                            deviceRow.modelData.connect();
                                        else if (deviceRow.modelData.pairing)
                                            deviceRow.modelData.cancelPair();
                                        else
                                            deviceRow.modelData.pair();
                                    }
                                }

                                BarButton {
                                    theme: root.theme
                                    label: "×"
                                    action: true
                                    visible: deviceRow.modelData.paired
                                    onClicked: deviceRow.modelData.forget()
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: !root.adapter
                    text: "No Bluetooth adapter found"
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
