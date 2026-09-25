import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal closeRequested()

    property string directory: Theme.wallpaperDirectory
    property string currentWallpaper: ""
    property string selectedScheme: "m3-content"
    property var wallpapers: []
    property bool busy: false
    property string message: ""
    readonly property var schemes: [
        { label: "M3 Tonal Spot", value: "m3-tonal-spot" },
        { label: "M3 Content", value: "m3-content" },
        { label: "M3 Fruit Salad", value: "m3-fruit-salad" },
        { label: "M3 Rainbow", value: "m3-rainbow" },
        { label: "M3 Monochrome", value: "m3-monochrome" },
        { label: "Vibrant", value: "vibrant" },
        { label: "Faithful", value: "faithful" },
        { label: "Soft", value: "soft" },
        { label: "Dysfunctional", value: "dysfunctional" },
        { label: "Muted", value: "muted" }
    ]

    function focusSearch() {
        search.text = "";
        search.forceActiveFocus();
    }

    function refresh() {
        if (!scan.running) scan.running = true;
        if (!readWallpaper.running) readWallpaper.running = true;
        if (!readScheme.running) readScheme.running = true;
    }

    function applyWallpaper(path) {
        if (busy) return;
        busy = true;
        message = "Applying " + path.split("/").pop() + "...";
        setWallpaper.command = ["noctalia", "msg", "wallpaper-set", path];
        setWallpaper.running = true;
    }

    function applyScheme(scheme) {
        if (busy) return;
        busy = true;
        message = "Applying " + scheme + "...";
        setScheme.command = ["noctalia", "msg", "color-scheme-set", "wallpaper", scheme];
        setScheme.running = true;
    }

    onVisibleChanged: if (visible) {
        refresh();
        Qt.callLater(focusSearch);
    }

    Timer {
        interval: 4000
        repeat: true
        running: root.visible
        onTriggered: if (!scan.running) scan.running = true
    }

    Process {
        id: scan
        command: ["find", root.directory, "-maxdepth", "1", "-type", "f", "-iregex", ".*\\.\\(jpg\\|jpeg\\|png\\|webp\\|bmp\\|gif\\|avif\\)", "-print"]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(path => path !== "").sort((a, b) => a.localeCompare(b))
        }
        onExited: (code, status) => {
            if (code !== 0) root.message = "Could not read " + root.directory;
        }
    }

    Process {
        id: readWallpaper
        command: ["noctalia", "msg", "wallpaper-get"]
        stdout: StdioCollector {
            onStreamFinished: root.currentWallpaper = text.trim()
        }
    }

    Process {
        id: readScheme
        command: ["noctalia", "msg", "color-scheme-get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.trim().match(/^wallpaper\s+(\S+)/);
                if (match) root.selectedScheme = match[1];
            }
        }
    }

    Process {
        id: setWallpaper
        onExited: (code, status) => {
            root.busy = false;
            root.message = code === 0 ? "Wallpaper changed" : "Could not change wallpaper";
            if (code === 0) root.refresh();
        }
    }

    Process {
        id: setScheme
        onExited: (code, status) => {
            root.busy = false;
            root.message = code === 0 ? "Color scheme changed" : "Could not change color scheme";
            if (code === 0) root.refresh();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#202630"
        border.color: Theme.barBorder
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Wallpapers"
                color: "#e8edf5"
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 18
            }

            Item { Layout.fillWidth: true }

            BarButton {
                label: "Refresh"
                onClicked: root.refresh()
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.directory
            elide: Text.ElideMiddle
            color: "#aeb6c2"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        TextField {
            id: search
            Layout.fillWidth: true
            placeholderText: "Search wallpapers"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: Math.floor(width / 3)
            cellHeight: 108
            model: root.wallpapers.filter(path => path.split("/").pop().toLowerCase().includes(search.text.trim().toLowerCase()))

            delegate: Item {
                id: tile
                required property string modelData
                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    color: "#2a323e"
                    border.width: tile.modelData === root.currentWallpaper ? 2 : 1
                    border.color: tile.modelData === root.currentWallpaper ? "#73a5e2" : "#596575"

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
                        color: "#e8edf5"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideMiddle
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.applyWallpaper(tile.modelData)
                    }
                }
            }
        }

        Text {
            visible: grid.count === 0
            text: root.wallpapers.length ? "No matching wallpapers" : "No images found in " + root.directory
            color: "#aeb6c2"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Color scheme"
                color: "#e8edf5"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            ComboBox {
                id: schemePicker
                Layout.fillWidth: true
                model: root.schemes
                textRole: "label"
                valueRole: "value"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                currentIndex: Math.max(0, root.schemes.findIndex(scheme => scheme.value === root.selectedScheme))
                onActivated: index => root.applyScheme(root.schemes[index].value)
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.message
            visible: text !== ""
            color: "#aeb6c2"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
