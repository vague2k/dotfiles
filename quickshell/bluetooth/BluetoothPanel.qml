import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    property bool open: false
    onOpenChanged: if (!open && root.adapter)
        root.adapter.discovering = false

    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property var knownDevices: (root.adapter?.devices.values ?? []).filter(device => device.connected || device.paired || device.bonded).map(device => ({
                device: device,
                section: "Known"
            })).sort((a, b) => (b.device.connected ? 1 : 0) - (a.device.connected ? 1 : 0) || a.device.name.localeCompare(b.device.name))

    readonly property var availableDevices: (root.adapter?.devices.values ?? []).filter(device => !device.connected && !device.paired && !device.bonded && (device.deviceName ?? "").length > 0).map(device => ({
                device: device,
                section: "Available"
            })).sort((a, b) => a.device.name.localeCompare(b.device.name))

    readonly property var deviceSections: knownDevices.concat(availableDevices)

    IpcHandler {
        target: "bluetooth"

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
        WlrLayershell.namespace: "quickshell-bluetooth"
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
            width: Math.min(310, panel.width - 8)
            height: Math.min(380, panel.height - 40)
            color: Theme.bgSurfaceLow
            border.color: Theme.bgBorder
            border.width: 1
            focus: true

            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: 4
                bottomMargin: 36
            }

            MouseArea {
                anchors.fill: parent
            }

            Keys.onEscapePressed: root.open = false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.panelPadding
                spacing: Theme.sectionSpacing

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 22

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Bluetooth"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 26
                        height: 22
                        color: bluetoothCloseMouse.containsMouse ? Theme.accentPrimary : "transparent"
                        border.color: Theme.bgBorderStrong
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: bluetoothCloseMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            id: bluetoothCloseMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.open = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: Theme.bgSurface
                    border.color: Theme.bgBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: Theme.spacing

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Bluetooth"
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                implicitWidth: scanText.implicitWidth + 16
                                implicitHeight: 22
                                color: scanMouse.containsMouse ? Theme.accentPrimary : "transparent"
                                border.color: Theme.bgBorderStrong
                                border.width: 1

                                Text {
                                    id: scanText
                                    anchors.centerIn: parent
                                    text: root.adapter?.discovering ? "Stop" : "Scan"
                                    color: scanMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                }

                                MouseArea {
                                    id: scanMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.adapter)
                                        root.adapter.discovering = !root.adapter.discovering
                                }
                            }

                            Rectangle {
                                implicitWidth: enabledText.implicitWidth + 16
                                implicitHeight: 22
                                color: enabledMouse.containsMouse ? Theme.accentPrimary : (root.adapter?.enabled ?? false) ? Theme.bgSelected : "transparent"
                                border.color: Theme.bgBorderStrong
                                border.width: 1

                                Text {
                                    id: enabledText
                                    anchors.centerIn: parent
                                    text: root.adapter?.enabled ? "On" : "Off"
                                    color: enabledMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                }

                                MouseArea {
                                    id: enabledMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.adapter)
                                        root.adapter.enabled = !root.adapter.enabled
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.adapter?.enabled ?? false
                    color: Theme.bgSurface
                    border.color: Theme.bgBorder
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 8
                        text: "Devices"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
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
                        spacing: Theme.spacing
                        model: root.deviceSections
                        keyNavigationWraps: true

                        section.property: "section"
                        section.delegate: Item {
                            width: devices.width
                            height: 20

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: section
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: Theme.bgBorder
                            }
                        }

                        delegate: Rectangle {
                            id: deviceRow
                            required property var modelData
                            width: devices.width
                            height: 36
                            color: Theme.bgInset

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: Theme.spacing

                                Text {
                                    Layout.fillWidth: true
                                    text: deviceRow.modelData.device.name + (deviceRow.modelData.device.connected ? "  Connected" : "")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    implicitWidth: pairText.implicitWidth + 16
                                    implicitHeight: 22
                                    color: pairMouse.containsMouse ? Theme.accentPrimary : "transparent"
                                    border.color: Theme.bgBorderStrong
                                    border.width: 1

                                    Text {
                                        id: pairText
                                        anchors.centerIn: parent
                                        text: deviceRow.modelData.device.connected ? "Disconnect" : deviceRow.modelData.device.paired ? "Connect" : deviceRow.modelData.device.pairing ? "Cancel" : "Pair"
                                        color: pairMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: pairMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const d = deviceRow.modelData.device;
                                            if (d.connected)
                                                d.disconnect();
                                            else if (d.paired)
                                                d.connect();
                                            else if (d.pairing)
                                                d.cancelPair();
                                            else
                                                d.pair();
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: deviceRow.modelData.device.paired
                                    implicitWidth: forgetText.implicitWidth + 16
                                    implicitHeight: 22
                                    color: forgetMouse.containsMouse ? Theme.accentPrimary : "transparent"
                                    border.color: Theme.bgBorderStrong
                                    border.width: 1

                                    Text {
                                        id: forgetText
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: forgetMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                    }

                                    MouseArea {
                                        id: forgetMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: deviceRow.modelData.device.forget()
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: !root.adapter
                    text: "No Bluetooth adapter found"
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                }
            }
        }
    }
}
