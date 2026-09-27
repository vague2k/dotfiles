pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var wallpapers: []
    property string currentWallpaper: ""
    property string error: ""

    readonly property string directory: Quickshell.env("HOME") + "/Pictures"

    function rescan() {
        wallpapers = [];
        if (!scanner.running)
            scanner.running = true;
    }

    function setWallpaper(path) {
        if (!path)
            return;
        root.currentWallpaper = path;
        apply.exec(["awww", "img", path, "--transition-type", "fade", "--transition-pos", "center", "--transition-duration", "1"]);
    }

    Process {
        id: apply
        running: false
        stderr: StdioCollector {
            onStreamFinished: if (text.trim())
                root.error = text.trim()
        }
    }

    Process {
        id: scanner
        command: ["find", root.directory, "-maxdepth", "1", "-type", "f", "-iregex", ".*\\.\\(jpg\\|jpeg\\|png\\|webp\\|bmp\\|gif\\|avif\\)", "-print"]
        stdout: StdioCollector {
            onStreamFinished: root.wallpapers = text.split("\n").filter(path => path !== "").sort((a, b) => a.localeCompare(b))
        }
        onExited: (code, status) => {
            if (code !== 0)
                root.error = "Could not read " + root.directory;
        }
    }
}
