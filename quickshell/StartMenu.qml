import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal closeRequested()
    width: 340
    height: 430

    function focusSearch() {
        search.text = "";
        search.forceActiveFocus();
    }

    onVisibleChanged: if (visible) Qt.callLater(focusSearch)

    function filteredApps() {
        const query = search.text.trim().toLowerCase();
        return DesktopEntries.applications.values.filter(app =>
            !query || (app.name + " " + app.genericName).toLowerCase().includes(query))
            .sort((a, b) => a.name.localeCompare(b.name));
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
            text: "Start"
            color: "#e8edf5"
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 20
        }

        TextField {
            id: search
            Layout.fillWidth: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            placeholderText: "Search applications"
            onAccepted: {
                if (root.filteredApps().length) {
                    root.filteredApps()[0].execute();
                    root.closeRequested();
                }
            }
        }

        ListView {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.filteredApps()
            spacing: 2

            delegate: BarButton {
                required property var modelData
                width: results.width
                label: modelData.name
                icon: Quickshell.iconPath(modelData.icon || "", true)
                alignLeft: true
                highlightOnHover: true
                onClicked: {
                    modelData.execute();
                    root.closeRequested();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            BarButton {
                label: "Lock"
                onClicked: { Quickshell.execDetached(["loginctl", "lock-session"]); root.closeRequested(); }
            }
            BarButton {
                label: "Log out"
                onClicked: { Quickshell.execDetached(["hyprctl", "dispatch", "exit"]); root.closeRequested(); }
            }
            BarButton {
                label: "Restart"
                onClicked: Quickshell.execDetached(["systemctl", "reboot"])
            }
            BarButton {
                label: "Shut down"
                onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
            }
        }
    }
}
