import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Scope {
    id: root

    property int selectedIndex: 0
    property var places: []

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcherPanel.visible = !launcherPanel.visible;
            if (launcherPanel.visible) {
                searchInput.text = "";
                selectedIndex = -1;
                searchInput.forceActiveFocus();
            }
        }
    }

    ScriptModel {
        id: filteredApps
        objectProp: "id"
        values: {
            const query = searchInput.text.trim().toLowerCase();
            return DesktopEntries.applications.values.filter(app => !query || (app.name + " " + app.genericName).toLowerCase().includes(query)).sort((a, b) => a.name.localeCompare(b.name));
        }
    }

    function launchApp(entry) {
        entry.execute();
        launcherPanel.visible = false;
    }

    function launchPlace(place) {
        if (!place)
            return;
        if (place.kind === "exec")
            Quickshell.execDetached([place.target]);
        else
            Quickshell.execDetached(["xdg-open", place.target]);
        launcherPanel.visible = false;
    }

    function runSession(action) {
        launcherPanel.visible = false;
        if (action === "logout")
            Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]);
        else if (action === "restart")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else
            Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    Process {
        id: placesProbe
        running: true
        command: ["sh", "-c", `
            h="$HOME"
            emit() { printf '%s\\t%s\\t%s\\t%s\\n' "$1" "$2" "$3" "$4"; }
            emit "Home" "user-home" "dir" "$h"
            [ -d "$h/Documents" ] && emit "Documents" "folder-documents" "dir" "$h/Documents"
            [ -d "$h/Pictures" ] && emit "Pictures" "folder-pictures" "dir" "$h/Pictures"
            [ -d "$h/Downloads" ] && emit "Downloads" "folder-download" "dir" "$h/Downloads"
            [ -d "$h/Music" ] && emit "Music" "folder-music" "dir" "$h/Music"
            [ -d "$h/Videos" ] && emit "Videos" "folder-videos" "dir" "$h/Videos"
            [ -d "$h/Desktop" ] && emit "Desktop" "user-desktop" "dir" "$h/Desktop"
            emit "This PC" "computer" "dir" "/"
            command -v ghostty >/dev/null 2>&1 && emit "Terminal" "utilities-terminal" "exec" "ghostty"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                root.places = text.split("\n").filter(line => line.length > 0).map(line => {
                    const fields = line.split("\t");
                    return {
                        label: fields[0],
                        icon: fields[1],
                        kind: fields[2],
                        target: fields[3]
                    };
                });
            }
        }
    }

    PanelWindow {
        id: launcherPanel
        visible: false
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "quickshell-launcher"
        exclusionMode: ExclusionMode.Ignore

        HyprlandFocusGrab {
            id: grab
            windows: [launcherPanel]
            active: launcherPanel.visible
            onCleared: launcherPanel.visible = false
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // transparent overlay
        MouseArea {
            anchors.fill: parent
            onClicked: launcherPanel.visible = false
        }

        // launcher box
        Rectangle {
            id: launcherBox
            width: 460
            height: 550
            color: Theme.bgBase
            border.color: Theme.bgBorder
            border.width: 1

            anchors {
                bottom: parent.bottom
                left: parent.left
                bottomMargin: 36
                leftMargin: 4
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.panelPadding
                spacing: Theme.sectionSpacing

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.sectionSpacing

                    // App column
                    Rectangle {
                        id: appsColumn
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.bgSurface
                        border.color: Theme.bgBorder
                        border.width: 1

                        ListView {
                            id: resultsList
                            anchors.fill: parent
                            anchors.margins: 4
                            model: filteredApps
                            clip: true
                            focus: true
                            currentIndex: root.selectedIndex
                            highlightMoveDuration: 0

                            highlight: Rectangle {
                                color: Theme.bgSelected
                                visible: root.selectedIndex >= 0
                            }

                            delegate: Rectangle {
                                id: delegateRoot
                                required property var modelData
                                required property int index

                                Accessible.role: Accessible.Button
                                Accessible.name: (modelData.name ?? "Application") + (modelData.genericName ? " - " + modelData.genericName : "")

                                width: resultsList.width
                                height: 22
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: Theme.sectionSpacing

                                    // App icon
                                    IconImage {
                                        Layout.preferredWidth: Theme.iconSize
                                        Layout.preferredHeight: Theme.iconSize
                                        Layout.alignment: Qt.AlignVCenter
                                        source: Quickshell.iconPath(delegateRoot.modelData.icon ?? "", true)
                                        visible: (delegateRoot.modelData.icon ?? "") !== ""
                                    }

                                    // App name
                                    Text {
                                        text: delegateRoot.modelData.name ?? ""
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.fontSize
                                        font.family: Theme.fontFamily
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.launchApp(delegateRoot.modelData)
                                    onPositionChanged: root.selectedIndex = delegateRoot.index
                                }
                            }

                            // Empty state
                            Text {
                                anchors.centerIn: parent
                                text: "  No applications found"
                                color: Theme.textMuted
                                font.pixelSize: 14
                                font.family: Theme.fontFamily
                                visible: resultsList.count === 0 && searchInput.text !== ""
                            }
                        }
                    }

                    // Places column
                    Rectangle {
                        id: placesColumn
                        Layout.preferredWidth: 140
                        Layout.fillHeight: true
                        color: Theme.bgSurface
                        border.color: Theme.bgBorder
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 0

                            ListView {
                                id: placesList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                model: root.places
                                clip: true

                                delegate: Rectangle {
                                    id: placeDelegate
                                    required property var modelData

                                    width: placesList.width
                                    height: 22
                                    color: placeMouse.containsMouse ? Theme.bgHover : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: Theme.sectionSpacing

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: placeDelegate.modelData.label ?? ""
                                            color: Theme.textPrimary
                                            font.pixelSize: Theme.fontSize
                                            font.family: Theme.fontFamily
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: placeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.launchPlace(placeDelegate.modelData)
                                    }
                                }
                            }

                            // separator
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: Theme.bgBorder
                            }

                            Repeater {
                                model: [
                                    {
                                        label: "Log out",
                                        action: "logout"
                                    },
                                    {
                                        label: "Restart",
                                        action: "restart"
                                    },
                                    {
                                        label: "Shut down",
                                        action: "shutdown"
                                    }
                                ]

                                delegate: Rectangle {
                                    id: sessionDelegate
                                    required property var modelData

                                    Layout.fillWidth: placesList.width
                                    Layout.preferredHeight: 22
                                    color: sessionMouse.containsMouse ? Theme.bgHover : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: Theme.sectionSpacing

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: sessionDelegate.modelData.label ?? ""
                                            color: Theme.textPrimary
                                            font.pixelSize: Theme.fontSize
                                            font.family: Theme.fontFamily
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: sessionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.runSession(modelData.action)
                                    }
                                }
                            }
                        }
                    }
                }

                // separator
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.bgBorder
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing

                    TextField {
                        id: searchInput
                        implicitHeight: 22
                        Layout.fillWidth: true
                        leftPadding: 8
                        rightPadding: 8
                        placeholderText: "Search applications"
                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textSecondary
                        selectionColor: Theme.accentPrimary
                        selectedTextColor: Theme.bgBase
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        background: Rectangle {
                            color: Theme.bgSurfaceLow
                            border.width: 1
                            border.color: searchInput.activeFocus ? Theme.accentPrimary : Theme.bgBorder
                        }

                        onTextChanged: root.selectedIndex = text === "" ? -1 : 0

                        Keys.onEscapePressed: launcherPanel.visible = false

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                event.accepted = true;
                                root.selectedIndex = Math.min(root.selectedIndex + 1, resultsList.count - 1);
                                resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            } else if (event.key === Qt.Key_Up) {
                                event.accepted = true;
                                root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                                resultsList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                event.accepted = true;
                                if (root.selectedIndex >= 0) {
                                    const entry = filteredApps.values[root.selectedIndex];
                                    if (entry)
                                        root.launchApp(entry);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
