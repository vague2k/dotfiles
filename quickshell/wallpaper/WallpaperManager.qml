import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Standalone wallpaper overlay, plus the per-screen background renderer.
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

    component PanelSelect: ComboBox {
        id: select
        property var theme: DefaultTheme {}

        implicitHeight: 30
        leftPadding: 8
        rightPadding: 26
        spacing: 0
        font.family: select.theme.fontFamily
        font.pixelSize: select.theme.fontSize
        hoverEnabled: true
        activeFocusOnTab: false

        background: Rectangle {
            color: select.hovered ? select.theme.bgSurface : select.theme.bgSurfaceLow
            border.width: 1
            border.color: select.activeFocus || select.popup.visible ? select.theme.accentPrimary : select.theme.bgBorder
        }

        contentItem: Text {
            leftPadding: select.leftPadding
            rightPadding: select.rightPadding
            text: select.displayText
            color: select.theme.textPrimary
            font: select.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: select.width - width - 8
            anchors.verticalCenter: parent.verticalCenter
            text: "⌄"
            color: select.theme.textSecondary
            font.family: select.theme.fontFamily
            font.pixelSize: select.theme.fontSize
        }

        delegate: ItemDelegate {
            required property int index
            width: select.popup.width
            height: 28

            contentItem: Text {
                leftPadding: 8
                rightPadding: 8
                text: select.textAt(index)
                color: select.highlightedIndex === index ? select.theme.bgBase : select.theme.textPrimary
                font: select.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: select.highlightedIndex === index ? select.theme.accentPrimary : select.theme.bgInset
            }
        }

        popup: Popup {
            y: select.height
            width: select.width
            implicitHeight: Math.min(contentItem.implicitHeight + 2, 240)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: select.popup.visible ? select.delegateModel : null
                currentIndex: select.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator {}
            }

            background: Rectangle {
                color: select.theme.bgInset
                border.width: 1
                border.color: select.theme.bgBorder
            }
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            panel.visible = !panel.visible;
            if (panel.visible)
                WallpaperService.rescan();
        }
    }

    Component.onCompleted: if (root.theme.wallpaper)
        WallpaperService.setWallpaper(root.theme.wallpaper)

    Connections {
        target: root.theme

        function onWallpaperChanged() {
            if (root.theme.wallpaper && root.theme.wallpaper !== WallpaperService.currentWallpaper)
                WallpaperService.setWallpaper(root.theme.wallpaper);
        }
    }

    PanelWindow {
        id: panel
        visible: false
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-wallpaper"
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
            width: Math.min(600, panel.width - 16)
            height: Math.min(520, panel.height - 16)
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            Keys.onEscapePressed: panel.visible = false

            function focusSearch() {
                search.text = "";
                grid.currentIndex = 0;
                search.forceActiveFocus();
            }

            function focusGrid(index) {
                grid.currentIndex = index;
                grid.positionViewAtIndex(index, GridView.Contain);
                grid.forceActiveFocus();
            }

            function refresh() {
                WallpaperService.rescan();
            }

            function select(path) {
                WallpaperService.setWallpaper(path);
                root.theme.applyWallpaper(path);
            }

            onVisibleChanged: if (visible) {
                refresh();
                Qt.callLater(focusSearch);
            }

            Timer {
                interval: 4000
                repeat: true
                running: body.visible
                onTriggered: WallpaperService.rescan()
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

                PanelHeader {
                    theme: root.theme
                    Layout.fillWidth: true
                    title: "Wallpapers"
                    keyboardNavigable: true
                    onCloseRequested: panel.visible = false
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: root.theme.bgBorder
                }

                Text {
                    Layout.fillWidth: true
                    text: WallpaperService.directory
                    elide: Text.ElideMiddle
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.theme.sectionSpacing

                    PanelSearchField {
                        id: search
                        theme: root.theme
                        Layout.fillWidth: true
                        placeholderText: "Search wallpapers"
                        KeyNavigation.tab: schemePicker
                        Keys.onDownPressed: {
                            if (grid.count)
                                body.focusGrid(0);
                        }
                        onAccepted: if (grid.count)
                            body.select(grid.model[0])
                    }

                    PanelSelect {
                        id: schemePicker
                        theme: root.theme
                        Layout.preferredWidth: 190
                        activeFocusOnTab: true
                        KeyNavigation.tab: refreshButton
                        KeyNavigation.backtab: search
                        model: root.theme.schemes
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: Math.max(0, root.theme.schemes.findIndex(scheme => scheme.value === root.theme.scheme))
                        onActivated: index => root.theme.setScheme(root.theme.schemes[index].value)
                    }

                    BarButton {
                        id: refreshButton
                        theme: root.theme
                        label: "Refresh"
                        action: true
                        keyboardNavigable: true
                        Keys.onTabPressed: body.focusGrid(0)
                        Keys.onBacktabPressed: schemePicker.forceActiveFocus()
                        onClicked: body.refresh()
                    }
                }

                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: Math.floor(width / 3)
                    cellHeight: 112
                    model: WallpaperService.wallpapers.filter(path => path.split("/").pop().toLowerCase().includes(search.text.trim().toLowerCase()))
                    currentIndex: 0
                    keyNavigationWraps: true
                    activeFocusOnTab: true
                    onCurrentIndexChanged: if (activeFocus && currentIndex >= 0)
                        positionViewAtIndex(currentIndex, GridView.Contain)
                    Keys.onTabPressed: {
                        if (currentIndex < count - 1)
                            body.focusGrid(currentIndex + 1);
                        else
                            search.forceActiveFocus();
                    }
                    Keys.onBacktabPressed: {
                        if (currentIndex > 0)
                            body.focusGrid(currentIndex - 1);
                        else
                            refreshButton.forceActiveFocus();
                    }
                    Keys.onReturnPressed: if (currentItem)
                        body.select(currentItem.modelData)
                    Keys.onEnterPressed: if (currentItem)
                        body.select(currentItem.modelData)
                    Keys.onSpacePressed: if (currentItem)
                        body.select(currentItem.modelData)

                    delegate: Item {
                        id: tile
                        required property string modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: root.theme.spacing
                            color: root.theme.bgSurface
                            border.width: tile.modelData === root.theme.wallpaper ? 2 : 1
                            border.color: tile.GridView.isCurrentItem && grid.activeFocus || tile.modelData === root.theme.wallpaper ? root.theme.accentPrimary : root.theme.bgBorder

                            Image {
                                anchors.fill: parent
                                anchors.margins: 3
                                anchors.bottomMargin: 23
                                source: "file://" + encodeURI(tile.modelData)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize.width: 240
                                sourceSize.height: 160
                                clip: true
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 4
                                text: tile.modelData.split("/").pop()
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 12
                                elide: Text.ElideMiddle
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    grid.currentIndex = tile.index;
                                    body.select(tile.modelData);
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: root.theme.bgBorder
                }

                Text {
                    visible: grid.count === 0
                    text: WallpaperService.wallpapers.length ? "No matching wallpapers" : "No images found in " + WallpaperService.directory
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: root.theme.error || (root.theme.busy ? "Applying wallpaper theme..." : "")
                    visible: text !== ""
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                }
            }
        }
    }
}
