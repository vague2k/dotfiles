import Quickshell
import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme

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

    Component.onCompleted: if (root.theme.wallpaper)
        WallpaperService.setWallpaper(root.theme.wallpaper)

    Connections {
        target: root.theme

        function onWallpaperChanged() {
            if (root.theme.wallpaper && root.theme.wallpaper !== WallpaperService.currentWallpaper)
                WallpaperService.setWallpaper(root.theme.wallpaper);
        }
    }

    ModalOverlay {
        id: overlay
        ipcTarget: "wallpaper"
        title: "Wallpapers"
        bodyWidth: 600
        bodyHeight: 520
        bodyInset: 16
        headerKeyboardNavigable: true

        onOpenChanged: if (open) {
            root.refresh();
            Qt.callLater(root.focusSearch);
        }

        Timer {
            interval: 4000
            repeat: true
            running: overlay.open
            onTriggered: WallpaperService.rescan()
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
                implicitHeight: 30
                Layout.fillWidth: true
                placeholderText: "Search wallpapers"
                KeyNavigation.tab: schemePicker
                Keys.onDownPressed: {
                    if (grid.count)
                        root.focusGrid(0);
                }
                onAccepted: if (grid.count)
                    root.select(grid.model[0])
            }

            PanelSelect {
                id: schemePicker
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

            PanelButton {
                id: refreshButton
                label: "Refresh"
                action: true
                keyboardNavigable: true
                Keys.onTabPressed: root.focusGrid(0)
                Keys.onBacktabPressed: schemePicker.forceActiveFocus()
                onClicked: root.refresh()
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
                            root.select(tile.modelData);
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
