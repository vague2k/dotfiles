import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    property bool open: false
    onOpenChanged: if (open) {
        WallpaperService.rescan();
        Qt.callLater(root.focusSearch);
    }

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

    function select(path) {
        WallpaperService.setWallpaper(path);
        Theme.applyWallpaper(path);
    }

    Component.onCompleted: if (Theme.wallpaper)
        WallpaperService.setWallpaper(Theme.wallpaper)

    Connections {
        target: Theme

        function onWallpaperChanged() {
            if (Theme.wallpaper && Theme.wallpaper !== WallpaperService.currentWallpaper)
                WallpaperService.setWallpaper(Theme.wallpaper);
        }
    }

    IpcHandler {
        target: "wallpaper"

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
        WlrLayershell.namespace: "quickshell-wallpaper"
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
            width: Math.min(600, panel.width - 8)
            height: Math.min(520, panel.height - 40)
            color: Theme.bgSurfaceLow
            border.color: Theme.bgBorder
            border.width: 1
            focus: true

            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 4
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
                        text: "Wallpapers"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Rectangle {
                        id: wallpaperCloseButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 26
                        height: 22
                        activeFocusOnTab: true
                        color: wallpaperCloseMouse.containsMouse || activeFocus ? Theme.accentPrimary : "transparent"
                        border.color: activeFocus ? Theme.accentPrimary : Theme.bgBorderStrong
                        border.width: 1

                        Keys.onReturnPressed: root.open = false
                        Keys.onEnterPressed: root.open = false
                        Keys.onSpacePressed: root.open = false

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: wallpaperCloseMouse.containsMouse || wallpaperCloseButton.activeFocus ? Theme.bgBase : Theme.accentPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            id: wallpaperCloseMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.open = false
                        }
                    }
                }

                Timer {
                    interval: 4000
                    repeat: true
                    running: root.open
                    onTriggered: WallpaperService.rescan()
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.bgBorder
                }

                Text {
                    Layout.fillWidth: true
                    text: WallpaperService.directory
                    elide: Text.ElideMiddle
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing

                    TextField {
                        id: search
                        implicitHeight: 22
                        Layout.fillWidth: true
                        leftPadding: 8
                        rightPadding: 8
                        placeholderText: "Search wallpapers"
                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textSecondary
                        selectionColor: Theme.accentPrimary
                        selectedTextColor: Theme.bgBase
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize

                        background: Rectangle {
                            color: Theme.bgSurfaceLow
                            border.width: 1
                            border.color: search.activeFocus ? Theme.accentPrimary : Theme.bgBorder
                        }

                        KeyNavigation.tab: schemePicker
                        Keys.onDownPressed: {
                            if (grid.count)
                                root.focusGrid(0);
                        }
                        onAccepted: if (grid.count)
                            root.select(grid.model[0])
                    }

                    ComboBox {
                        id: schemePicker
                        Layout.preferredWidth: 190
                        activeFocusOnTab: true
                        KeyNavigation.tab: refreshButton
                        KeyNavigation.backtab: search
                        model: Theme.schemes
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: Math.max(0, Theme.schemes.findIndex(scheme => scheme.value === Theme.scheme))
                        onActivated: index => Theme.setScheme(Theme.schemes[index].value)

                        implicitHeight: 22
                        leftPadding: 8
                        rightPadding: 26
                        spacing: 0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        hoverEnabled: true

                        background: Rectangle {
                            color: schemePicker.hovered ? Theme.bgSurface : Theme.bgSurfaceLow
                            border.width: 1
                            border.color: schemePicker.activeFocus || schemePicker.popup.visible ? Theme.accentPrimary : Theme.bgBorder
                        }

                        contentItem: Text {
                            leftPadding: schemePicker.leftPadding
                            rightPadding: schemePicker.rightPadding
                            text: schemePicker.displayText
                            color: Theme.textPrimary
                            font: schemePicker.font
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        indicator: Text {
                            x: schemePicker.width - width - 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "⌄"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        delegate: ItemDelegate {
                            required property int index
                            width: schemePicker.popup.width
                            height: 22

                            contentItem: Text {
                                leftPadding: 8
                                rightPadding: 8
                                text: schemePicker.textAt(index)
                                color: schemePicker.highlightedIndex === index ? Theme.bgBase : Theme.textPrimary
                                font: schemePicker.font
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                color: schemePicker.highlightedIndex === index ? Theme.accentPrimary : Theme.bgInset
                            }
                        }

                        popup: Popup {
                            y: schemePicker.height
                            width: schemePicker.width
                            implicitHeight: Math.min(contentItem.implicitHeight + 2, 240)
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: schemePicker.popup.visible ? schemePicker.delegateModel : null
                                currentIndex: schemePicker.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator {
                                }
                            }

                            background: Rectangle {
                                color: Theme.bgInset
                                border.width: 1
                                border.color: Theme.bgBorder
                            }
                        }
                    }

                    Rectangle {
                        id: refreshButton
                        implicitWidth: refreshText.implicitWidth + 16
                        implicitHeight: 22
                        activeFocusOnTab: true
                        color: refreshMouse.containsMouse || activeFocus ? Theme.accentPrimary : "transparent"
                        border.color: activeFocus ? Theme.accentPrimary : Theme.bgBorderStrong
                        border.width: 1

                        Keys.onReturnPressed: WallpaperService.rescan()
                        Keys.onEnterPressed: WallpaperService.rescan()
                        Keys.onSpacePressed: WallpaperService.rescan()
                        Keys.onTabPressed: root.focusGrid(0)
                        Keys.onBacktabPressed: schemePicker.forceActiveFocus()

                        Text {
                            id: refreshText
                            anchors.centerIn: parent
                            text: "Refresh"
                            color: refreshMouse.containsMouse || refreshButton.activeFocus ? Theme.bgBase : Theme.accentPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                refreshButton.forceActiveFocus();
                                WallpaperService.rescan();
                            }
                        }
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
                            root.focusGrid(currentIndex + 1);
                        else
                            search.forceActiveFocus();
                    }
                    Keys.onBacktabPressed: {
                        if (currentIndex > 0)
                            root.focusGrid(currentIndex - 1);
                        else
                            refreshButton.forceActiveFocus();
                    }
                    Keys.onReturnPressed: if (currentItem)
                        root.select(currentItem.modelData)
                    Keys.onEnterPressed: if (currentItem)
                        root.select(currentItem.modelData)
                    Keys.onSpacePressed: if (currentItem)
                        root.select(currentItem.modelData)

                    delegate: Item {
                        id: tile
                        required property string modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing
                            color: Theme.bgSurface
                            border.width: tile.modelData === Theme.wallpaper ? 2 : 1
                            border.color: tile.GridView.isCurrentItem && grid.activeFocus || tile.modelData === Theme.wallpaper ? Theme.accentPrimary : Theme.bgBorder

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
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                elide: Text.ElideMiddle
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    grid.currentIndex = tile.index;
                                    root.select(tile.modelData);
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.bgBorder
                }

                Text {
                    visible: grid.count === 0
                    text: WallpaperService.wallpapers.length ? "No matching wallpapers" : "No images found in " + WallpaperService.directory
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: Theme.error || (Theme.busy ? "Applying wallpaper theme..." : "")
                    visible: text !== ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}
