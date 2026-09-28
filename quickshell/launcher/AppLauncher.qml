import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme

    property var places: []
    readonly property int placesWidth: 140
    property var menuEntry: null
    property real menuY: 0

    function focusSearch() {
        search.text = "";
        closeMenu();
        results.currentIndex = 0;
        search.forceActiveFocus();
    }

    function closeMenu() {
        menuEntry = null;
        menuY = 0;
    }

    function runSession(action) {
        overlay.open = false;
        if (action === "logout")
            Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]);
        else if (action === "restart")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else
            Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function entryActions(entry) {
        const actions = entry ? entry.actions : null;
        return actions && actions.length ? actions : [];
    }

    function filteredApps() {
        const query = search.text.trim().toLowerCase();
        return DesktopEntries.applications.values.filter(app => !query || (app.name + " " + app.genericName).toLowerCase().includes(query)).sort((a, b) => a.name.localeCompare(b.name));
    }

    function launchApp(app) {
        if (!app)
            return;
        closeMenu();
        app.execute();
        overlay.open = false;
    }

    function launchAction(action) {
        if (!action)
            return;
        closeMenu();
        action.execute();
        overlay.open = false;
    }

    function openMenu(entry, y) {
        if (!entryActions(entry).length) {
            closeMenu();
            return;
        }
        menuEntry = entry;
        menuY = y;
    }

    function launchPlace(place) {
        if (!place)
            return;
        closeMenu();
        if (place.kind === "exec")
            Quickshell.execDetached([place.target]);
        else
            Quickshell.execDetached(["xdg-open", place.target]);
        overlay.open = false;
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

    component MenuRow: Rectangle {
        id: row
        property string icon: ""
        property string label: ""
        property bool hasSubmenu: false
        property bool selected: false
        signal clicked
        signal submenuRequested

        implicitHeight: 24
        color: menuMouse.containsMouse || chevronMouse.containsMouse ? root.theme.bgHover : row.selected ? root.theme.bgSelected : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 6
            spacing: 8

            Image {
                id: rowIcon
                visible: row.icon !== ""
                source: row.icon
                sourceSize.width: 18
                sourceSize.height: 18
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                text: row.label
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                visible: row.hasSubmenu
                text: ">"
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: chevronMouse.containsMouse ? 0 : 4
            }
        }

        MouseArea {
            id: menuMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }

        MouseArea {
            id: chevronMouse
            visible: row.hasSubmenu
            width: 22
            height: parent.height
            anchors.right: parent.right
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.submenuRequested()
        }
    }

    ModalOverlay {
        id: overlay
        ipcTarget: "launcher"
        bodyWidth: 460
        bodyHeight: 550
        anchorLeft: true
        anchorBottom: true
        closeOnEscape: false

        onOpenChanged: {
            if (open)
                Qt.callLater(root.focusSearch);
            else
                root.closeMenu();
        }

        onEscapePressed: {
            if (root.menuEntry)
                root.closeMenu();
            else
                overlay.open = false;
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.theme.sectionSpacing

            Rectangle {
                id: appsColumn
                z: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.theme.bgSurface
                border.color: root.theme.bgBorder
                border.width: 1

                ListView {
                    id: results
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true
                    model: root.filteredApps()
                    spacing: 1
                    currentIndex: 0
                    keyNavigationWraps: true
                    activeFocusOnTab: true
                    highlightFollowsCurrentItem: true
                    onActiveFocusChanged: if (activeFocus)
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    Keys.onReturnPressed: root.launchApp(results.currentItem?.modelData)
                    Keys.onEnterPressed: root.launchApp(results.currentItem?.modelData)
                    onMovementStarted: root.closeMenu()

                    delegate: MenuRow {
                        id: appRow
                        required property var modelData
                        required property int index
                        width: results.width
                        icon: Quickshell.iconPath(modelData.icon || "", true)
                        label: modelData.name
                        hasSubmenu: root.entryActions(modelData).length > 0
                        selected: ListView.isCurrentItem && results.activeFocus
                        onClicked: {
                            results.currentIndex = index;
                            root.launchApp(modelData);
                        }
                        onSubmenuRequested: root.openMenu(modelData, appRow.mapToItem(appsColumn, 0, 0).y)
                    }
                }

                Rectangle {
                    id: actionsMenu
                    z: 20
                    visible: root.menuEntry !== null
                    x: appsColumn.width
                    y: Math.max(0, Math.min(root.menuY, appsColumn.height - height))
                    width: root.placesWidth
                    height: menuColumn.implicitHeight + 8
                    color: root.theme.bgSurfaceLow
                    border.color: root.theme.bgBorder
                    border.width: 1

                    Column {
                        id: menuColumn
                        width: parent.width - 8
                        x: 4
                        y: 4
                        spacing: 1

                        Text {
                            width: parent.width
                            height: 20
                            text: root.menuEntry?.name || ""
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.theme.bgBorder
                        }

                        Repeater {
                            model: root.entryActions(root.menuEntry)

                            delegate: MenuRow {
                                required property var modelData
                                width: menuColumn.width
                                icon: Quickshell.iconPath(modelData.icon || "", true)
                                label: modelData.name
                                onClicked: root.launchAction(modelData)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: root.placesWidth
                Layout.fillHeight: true
                color: root.theme.bgSurface
                border.color: root.theme.bgBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 1

                    ListView {
                        id: places
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: root.places
                        spacing: 1
                        activeFocusOnTab: true

                        delegate: MenuRow {
                            required property var modelData
                            width: places.width
                            icon: Quickshell.iconPath(modelData.icon || "", true)
                            label: modelData.label
                            onClicked: root.launchPlace(modelData)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: root.theme.bgBorder
                    }

                    MenuRow {
                        Layout.fillWidth: true
                        icon: Quickshell.iconPath("system-log-out", true)
                        label: "Log out"
                        onClicked: root.runSession("logout")
                    }

                    MenuRow {
                        Layout.fillWidth: true
                        icon: Quickshell.iconPath("system-reboot", true)
                        label: "Restart"
                        onClicked: root.runSession("restart")
                    }

                    MenuRow {
                        Layout.fillWidth: true
                        icon: Quickshell.iconPath("system-shutdown", true)
                        label: "Shut down"
                        onClicked: root.runSession("shutdown")
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: root.theme.bgBorder
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.sectionSpacing

            PanelSearchField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search applications"
                KeyNavigation.tab: results
                Keys.onDownPressed: {
                    if (results.count) {
                        results.currentIndex = 0;
                        results.forceActiveFocus();
                    }
                }
                onTextChanged: root.closeMenu()
                onAccepted: root.launchApp(root.filteredApps()[0])
            }
        }
    }
}
