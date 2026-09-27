import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme

    readonly property var adapter: Bluetooth.defaultAdapter

    function buildDeviceSections() {
        const all = root.adapter?.devices.values ?? [];
        const known = [];
        const available = [];
        for (let i = 0; i < all.length; i++) {
            const device = all[i];
            if (device.connected || device.paired || device.bonded)
                known.push({
                    device: device,
                    section: "Known"
                });
            else if ((device.deviceName ?? "").length > 0)
                available.push({
                    device: device,
                    section: "Available"
                });
        }
        known.sort(function (a, b) {
            return (b.device.connected ? 1 : 0) - (a.device.connected ? 1 : 0) || a.device.name.localeCompare(b.device.name);
        });
        available.sort(function (a, b) {
            return a.device.name.localeCompare(b.device.name);
        });
        return known.concat(available);
    }

    ModalOverlay {
        id: overlay
        ipcTarget: "bluetooth"
        title: "Bluetooth"
        bodyWidth: 310
        bodyHeight: 380

        onOpenChanged: if (!open && root.adapter)
            root.adapter.discovering = false

        PanelCard {
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
                    PanelButton {
                        label: root.adapter?.discovering ? "Stop" : "Scan"
                        action: true
                        onClicked: if (root.adapter)
                            root.adapter.discovering = !root.adapter.discovering
                    }
                    PanelButton {
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
                    PanelButton {
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
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                model: root.buildDeviceSections()
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
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.theme.bgBorder
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: deviceScrollBar
                    policy: ScrollBar.AsNeeded
                    width: 6

                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: root.theme.bgBorderStrong
                        visible: deviceScrollBar.size < 1.0
                        opacity: deviceScrollBar.active ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    background: Rectangle {
                        color: "transparent"
                    }
                }

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
                            text: deviceRow.modelData.device.name + (deviceRow.modelData.device.connected ? "  Connected" : "")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        PanelButton {
                            label: deviceRow.modelData.device.connected ? "Disconnect" : deviceRow.modelData.device.paired ? "Connect" : deviceRow.modelData.device.pairing ? "Cancel" : "Pair"
                            action: true
                            labelFontSize: 11
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

                        PanelButton {
                            label: "×"
                            action: true
                            visible: deviceRow.modelData.device.paired
                            onClicked: deviceRow.modelData.device.forget()
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
    }
}
