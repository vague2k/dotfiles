import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Standalone app launcher overlay. Copy this folder on its own and it still
// works, falling back to DefaultTheme.
Scope {
    id: root

    property var theme: DefaultTheme {}

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property string icon: ""
        property int iconSize: 17
        property bool selected: false
        property bool action: false
        property bool keyboardNavigable: false
        property bool highlightOnHover: true
        property bool alignLeft: false
        signal clicked

        activeFocusOnTab: keyboardNavigable
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        Keys.onSpacePressed: button.clicked()

        color: action ? (mouse.containsMouse || activeFocus ? theme.accentPrimary : "transparent") : highlightOnHover && (mouse.containsMouse || activeFocus) ? theme.bgSurface : "transparent"
        border.color: activeFocus ? theme.accentPrimary : action ? theme.bgBorderStrong : "transparent"
        border.width: activeFocus || action ? 1 : 0
        implicitWidth: labelText.implicitWidth + (iconImage.visible ? button.iconSize + theme.spacing : 0) + (action ? 16 : 12)
        implicitHeight: 25

        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: button.alignLeft ? (button.action ? 8 : 6) : (button.width - implicitWidth) / 2
            spacing: button.theme.spacing

            Image {
                id: iconImage
                visible: button.icon !== ""
                source: button.icon
                width: button.iconSize
                height: button.iconSize
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: labelText
                width: button.alignLeft ? Math.max(0, button.width - (button.action ? 16 : 12) - (iconImage.visible ? button.iconSize + button.theme.spacing : 0)) : implicitWidth
                text: button.label
                color: button.action ? (mouse.containsMouse || button.activeFocus ? button.theme.bgBase : button.theme.accentPrimary) : button.theme.textPrimary
                font.family: button.theme.fontFamily
                font.pixelSize: button.labelFontSize
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
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

    component PanelSearchField: TextField {
        id: field
        property var theme: DefaultTheme {}

        implicitHeight: 30
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
            height: 430
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            Keys.onEscapePressed: panel.visible = false

            property string category: "All"

            function focusSearch() {
                search.text = "";
                category = "All";
                results.currentIndex = 0;
                search.forceActiveFocus();
            }

            onVisibleChanged: if (visible)
                Qt.callLater(focusSearch)

            function filteredApps() {
                const query = search.text.trim().toLowerCase();
                return DesktopEntries.applications.values.filter(app => (content.category === "All" || (app.categories || []).includes(content.category)) && (!query || (app.name + " " + app.genericName).toLowerCase().includes(query))).sort((a, b) => a.name.localeCompare(b.name));
            }

            function activateSelected(index) {
                const app = filteredApps()[index];
                if (!app)
                    return;
                app.execute();
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
                spacing: root.theme.spacing

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
                    onAccepted: content.activateSelected(0)
                }

                ListView {
                    id: results
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: content.filteredApps()
                    spacing: 1
                    currentIndex: 0
                    keyNavigationWraps: true
                    activeFocusOnTab: true
                    highlightFollowsCurrentItem: true
                    onActiveFocusChanged: if (activeFocus)
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    Keys.onReturnPressed: content.activateSelected(results.currentIndex)
                    Keys.onEnterPressed: content.activateSelected(results.currentIndex)

                    delegate: BarButton {
                        id: appRow
                        theme: root.theme
                        required property var modelData
                        required property int index
                        width: results.width
                        height: 44
                        label: ""
                        icon: Quickshell.iconPath(modelData.icon || "", true)
                        iconSize: 26
                        alignLeft: true
                        highlightOnHover: true
                        selected: ListView.isCurrentItem && results.activeFocus
                        Column {
                            x: 42
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - x - 8
                            Text {
                                text: appRow.modelData.name
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            Text {
                                text: appRow.modelData.genericName || appRow.modelData.comment || ""
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                        onClicked: {
                            results.currentIndex = index;
                            content.activateSelected(index);
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: root.theme.bgBorder
                }

                BarButton {
                    theme: root.theme
                    Layout.fillWidth: true
                    label: "Session..."
                    action: true
                    keyboardNavigable: true
                    alignLeft: true
                    onClicked: {
                        panel.visible = false;
                        Quickshell.execDetached(["qs", "ipc", "call", "session", "toggle"]);
                    }
                }
            }
        }
    }
}
