import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter

    width: 310
    height: 380

    onVisibleChanged: {
        if (!visible && adapter) adapter.discovering = false;
    }

    Rectangle {
        anchors.fill: parent
        color: "#202630"
        border.color: "#74859b"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "Bluetooth"
            color: "#e8edf5"
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 18
        }

        RowLayout {
            BarButton {
                label: root.adapter?.enabled ? "On" : "Off"
                selected: root.adapter?.enabled ?? false
                onClicked: { if (root.adapter) root.adapter.enabled = !root.adapter.enabled; }
            }
            BarButton {
                label: root.adapter?.discovering ? "Stop scan" : "Scan"
                visible: root.adapter?.enabled ?? false
                onClicked: { if (root.adapter) root.adapter.discovering = !root.adapter.discovering; }
            }
        }

        Text {
            visible: !root.adapter
            text: "No Bluetooth adapter found"
            color: "#aeb6c2"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        ListView {
            id: devices
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            model: root.adapter?.devices.values || []

            delegate: Column {
                id: deviceRow
                required property var modelData
                width: devices.width
                spacing: 3

                Text {
                    text: deviceRow.modelData.name + (deviceRow.modelData.connected ? "  Connected" : "")
                    color: "#e8edf5"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    elide: Text.ElideRight
                    width: parent.width
                }
                Row {
                    spacing: 5
                    BarButton {
                        label: deviceRow.modelData.connected ? "Disconnect" : "Connect"
                        visible: deviceRow.modelData.paired || deviceRow.modelData.connected
                        onClicked: deviceRow.modelData.connected ? deviceRow.modelData.disconnect() : deviceRow.modelData.connect()
                    }
                    BarButton {
                        label: deviceRow.modelData.pairing ? "Cancel" : "Pair"
                        visible: !deviceRow.modelData.paired
                        onClicked: deviceRow.modelData.pairing ? deviceRow.modelData.cancelPair() : deviceRow.modelData.pair()
                    }
                    BarButton {
                        label: "Forget"
                        visible: deviceRow.modelData.paired
                        onClicked: deviceRow.modelData.forget()
                    }
                }
            }
        }
    }
}
