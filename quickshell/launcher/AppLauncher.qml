import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Standalone app launcher overlay. Copy this folder on its own and it still
// works, falling back to DefaultTheme.
//
// Layout mirrors the classic Windows start menu: a wide "all apps" column on
// the left, a narrower places column on the right, and a search + session bar
// pinned along the bottom. Styling is unchanged: same theme, PanelSearchField
// and MenuRow as the rest of the shell.
Scope {
    id: root

    property var theme: DefaultTheme {}

    component PanelSearchField: TextField {
        id: field
        property var theme: DefaultTheme {}

        implicitHeight: 26
        leftPadding: 8
        rightPadding: 8
        color: theme.textPrimary
        placeholderTextColor: theme.textSecondary
        selectionColor: theme.accentPrimary
        selectedTextColor: theme.bgBase
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize

        background: Rectangle {
            color: field.theme.bgSurfaceLow
            border.width: 1
            border.color: field.activeFocus ? field.theme.accentPrimary : field.theme.bgBorder
        }
    }

    // One icon + label row, shared by the apps list, the places list and the
    // jump-list flyout. Matches the hover treatment used elsewhere in the shell.
    component MenuRow: Rectangle {
        id: row
        property var theme: DefaultTheme {}
        property string icon: ""
        property string label: ""
        property bool hasSubmenu: false
        property bool selected: false
        signal clicked
        signal submenuRequested

        implicitHeight: 24
        color: menuMouse.containsMouse || chevronMouse.containsMouse ? theme.bgHover : row.selected ? theme.bgSelected : "transparent"

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
                color: row.theme.textPrimary
                font.family: row.theme.fontFamily
                font.pixelSize: row.theme.fontSize
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                visible: row.hasSubmenu
                text: ">"
                color: row.theme.textSecondary
                font.family: row.theme.fontFamily
                font.pixelSize: row.theme.fontSize
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

    // Bottom-bar session control: power glyph, current user, and a right arrow
    // that opens the session overlay. Mirrors the action-button styling used
    // elsewhere in the shell.
    component SessionButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string glyph: ""
        property string name: ""
        signal clicked

        activeFocusOnTab: true
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        Keys.onSpacePressed: button.clicked()

        readonly property bool highlight: mouse.containsMouse || activeFocus

        color: highlight ? theme.accentPrimary : "transparent"
        border.color: activeFocus ? theme.accentPrimary : theme.bgBorderStrong
        border.width: 1
        implicitHeight: 26

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            Text {
                text: button.glyph
                color: button.highlight ? button.theme.bgBase : button.theme.accentPrimary
                font.family: button.theme.fontFamily
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                text: button.name
                color: button.highlight ? button.theme.bgBase : button.theme.accentPrimary
                font.family: button.theme.fontFamily
                font.pixelSize: button.theme.fontSize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: ">"
                color: button.highlight ? button.theme.bgBase : button.theme.textSecondary
                font.family: button.theme.fontFamily
                font.pixelSize: button.theme.fontSize
                Layout.alignment: Qt.AlignVCenter
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                button.forceActiveFocus();
                button.clicked();
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            panel.visible = !panel.visible;
            if (panel.visible)
                Qt.callLater(() => content.focusSearch());
        }
    }

    PanelWindow {
        id: panel
        visible: false
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-launcher"
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
            id: content
            width: 460
            height: 550
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            // Places column contents, filled in by the xdg user-dirs probe
            // below. Each entry is {label, icon, kind, target}.
            property var places: []
            // Shared column width, so the bottom bar lines up with the columns.
            readonly property int placesWidth: 140
            // Current user, shown on the session button.
            property string userName: Quickshell.env("USER") || "user"
            // App whose jump-list flyout is currently open, and its top y in
            // appsColumn coordinates.
            property var menuEntry: null
            property real menuY: 0

            function focusSearch() {
                search.text = "";
                closeMenu();
                results.currentIndex = 0;
                search.forceActiveFocus();
            }

            onVisibleChanged: {
                if (visible)
                    Qt.callLater(focusSearch);
                else
                    closeMenu();
            }

            function closeMenu() {
                menuEntry = null;
                menuY = 0;
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
                panel.visible = false;
            }

            function launchAction(action) {
                if (!action)
                    return;
                closeMenu();
                action.execute();
                panel.visible = false;
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
                panel.visible = false;
            }

            // Resolve the current user for the session button label.
            Process {
                id: whoamiProc
                running: true
                command: ["whoami"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const name = text.trim();
                        if (name.length > 0)
                            content.userName = name;
                    }
                }
            }

            // Probe the real XDG folders (skip any that don't exist), plus a
            // few system entries, so the places column works on any machine.
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
                    for s in systemsettings gnome-control-center cosmic-settings xfce4-settings-manager; do
                        if command -v "$s" >/dev/null 2>&1; then emit "Settings" "preferences-system" "exec" "$s"; break; fi
                    done
                `]
                stdout: StdioCollector {
                    onStreamFinished: {
                        content.places = text.split("\n").filter(line => line.length > 0).map(line => {
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

            Keys.onEscapePressed: {
                if (menuEntry)
                    closeMenu();
                else
                    panel.visible = false;
            }

            Rectangle {
                anchors.fill: parent
                color: root.theme.bgSurfaceLow
                border.color: root.theme.bgBorder
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.panelPadding
                spacing: root.theme.sectionSpacing

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: root.theme.sectionSpacing

                    // ----- all apps -----
                    Rectangle {
                        id: appsColumn
                        // Lift the whole column (and the jump-list flyout that
                        // overflows it) above the places column, which is a
                        // later sibling and would otherwise paint over it.
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
                            model: content.filteredApps()
                            spacing: 1
                            currentIndex: 0
                            keyNavigationWraps: true
                            activeFocusOnTab: true
                            highlightFollowsCurrentItem: true
                            onActiveFocusChanged: if (activeFocus)
                                positionViewAtIndex(currentIndex, ListView.Contain)
                            Keys.onReturnPressed: content.launchApp(results.currentItem?.modelData)
                            Keys.onEnterPressed: content.launchApp(results.currentItem?.modelData)
                            onMovementStarted: content.closeMenu()

                            delegate: MenuRow {
                                id: appRow
                                required property var modelData
                                required property int index
                                width: results.width
                                theme: root.theme
                                icon: Quickshell.iconPath(modelData.icon || "", true)
                                label: modelData.name
                                hasSubmenu: content.entryActions(modelData).length > 0
                                selected: ListView.isCurrentItem && results.activeFocus
                                onClicked: {
                                    results.currentIndex = index;
                                    content.launchApp(modelData);
                                }
                                onSubmenuRequested: content.openMenu(modelData, appRow.mapToItem(appsColumn, 0, 0).y)
                            }
                        }

                        // Jump-list flyout for the selected app, anchored to the
                        // right edge of the apps column and clamped inside it.
                        Rectangle {
                            id: actionsMenu
                            z: 20
                            visible: content.menuEntry !== null
                            x: appsColumn.width
                            y: Math.max(0, Math.min(content.menuY, appsColumn.height - height))
                            width: content.placesWidth
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
                                    text: content.menuEntry?.name || ""
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
                                    model: content.entryActions(content.menuEntry)

                                    delegate: MenuRow {
                                        required property var modelData
                                        width: menuColumn.width
                                        theme: root.theme
                                        icon: Quickshell.iconPath(modelData.icon || "", true)
                                        label: modelData.name
                                        onClicked: content.launchAction(modelData)
                                    }
                                }
                            }
                        }
                    }

                    // ----- places -----
                    Rectangle {
                        Layout.preferredWidth: content.placesWidth
                        Layout.fillHeight: true
                        color: root.theme.bgSurface
                        border.color: root.theme.bgBorder
                        border.width: 1

                        ListView {
                            id: places
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            model: content.places
                            spacing: 1
                            activeFocusOnTab: true

                            delegate: MenuRow {
                                required property var modelData
                                width: places.width
                                theme: root.theme
                                icon: Quickshell.iconPath(modelData.icon || "", true)
                                label: modelData.label
                                onClicked: content.launchPlace(modelData)
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

                    // Sits under the apps column: fillWidth plus a
                    // placesWidth-wide button and the same column spacing makes
                    // this exactly as wide as the app list above it.
                    PanelSearchField {
                        id: search
                        theme: root.theme
                        Layout.fillWidth: true
                        placeholderText: "Search applications"
                        KeyNavigation.tab: results
                        Keys.onDownPressed: {
                            if (results.count) {
                                results.currentIndex = 0;
                                results.forceActiveFocus();
                            }
                        }
                        onTextChanged: content.closeMenu()
                        onAccepted: content.launchApp(content.filteredApps()[0])
                    }

                    SessionButton {
                        theme: root.theme
                        glyph: "\uF011"
                        name: content.userName
                        Layout.preferredWidth: content.placesWidth
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            panel.visible = false;
                            Quickshell.execDetached(["qs", "ipc", "call", "session", "toggle"]);
                        }
                    }
                }
            }
        }
    }
}
