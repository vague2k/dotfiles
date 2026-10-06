pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string wallpaper: ""
    property string scheme: "m3-content"
    property bool busy: false
    property string error: ""
    property var palette: ({})

    readonly property bool ready: palette.bgBase !== undefined
    readonly property string themedCavaConfig: stateDirectory + "/cava.conf"

    readonly property string stateDirectory: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme"
    readonly property string themeScript: stateDirectory + "/set.sh"

    readonly property var schemes: [
        {
            label: "M3 Tonal Spot",
            value: "m3-tonal-spot"
        },
        {
            label: "M3 Content",
            value: "m3-content"
        },
        {
            label: "M3 Fruit Salad",
            value: "m3-fruit-salad"
        },
        {
            label: "M3 Rainbow",
            value: "m3-rainbow"
        },
        {
            label: "M3 Monochrome",
            value: "m3-monochrome"
        }
    ]

    function applyWallpaper(path) {
        apply(path, scheme);
    }

    function setScheme(value) {
        apply(wallpaper, value);
    }

    function apply(path, value) {
        if (!path || !schemes.some(item => item.value === value)) {
            error = "Select a wallpaper and a supported M3 scheme";
            return;
        }
        if (busy)
            return;
        busy = true;
        error = "";
        generate.exec(["sh", root.themeScript, path, value]);
    }

    Process {
        id: checkGenerator
        running: true
        command: ["sh", "-c", "command -v matugen"]
        onExited: (code, status) => {
            if (code !== 0)
                root.error = "Install matugen to enable wallpaper themes";
        }
    }

    FileView {
        id: settingsFile
        path: root.stateDirectory + "/wallpaper.json"
        printErrors: false
        onLoaded: {
            try {
                const settings = JSON.parse(text());
                if (settings.wallpaper && root.schemes.some(item => item.value === settings.scheme)) {
                    root.wallpaper = settings.wallpaper;
                    root.scheme = settings.scheme;
                }
            } catch (e) {
                root.error = "Invalid wallpaper settings";
            }
        }
    }

    FileView {
        id: paletteFile
        path: root.stateDirectory + "/wallpaper-theme.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const tokens = JSON.parse(text());
                if (tokens.bgBase && tokens.textPrimary && tokens.accentPrimary)
                    root.palette = tokens;
            } catch (e) {
                root.error = "Invalid wallpaper palette";
            }
        }
    }

    Process {
        id: generate
        stderr: StdioCollector {
            onStreamFinished: if (text.trim())
                root.error = text.trim()
        }
        onExited: (code, status) => {
            root.busy = false;
            if (code !== 0) {
                if (!root.error)
                    root.error = "Could not apply wallpaper theme";
                return;
            }
            settingsFile.reload();
            paletteFile.reload();
        }
    }

    readonly property string fontFamily: "Iosevka Nerd Font Mono"
    readonly property int fontSize: 14
    readonly property int iconSize: 20
    readonly property color bgBase: palette.bgBase || "#1c222b"
    readonly property color bgSurface: palette.bgSurface || "#272e39"
    readonly property color bgSurfaceLow: palette.bgSurfaceLow || "#202630"
    readonly property color bgInset: palette.bgInset || "#1c222b"
    readonly property color bgHover: palette.bgHover || "#344052"
    readonly property color bgSelected: palette.bgSelected || "#35465e"
    readonly property color bgBorder: palette.bgBorder || "#596575"
    readonly property color bgBorderStrong: palette.bgBorderStrong || "#6f9fd7"
    readonly property color textPrimary: palette.textPrimary || "#e8edf5"
    readonly property color textSecondary: palette.textSecondary || "#aeb6c2"
    readonly property color textMuted: palette.textMuted || "#596575"
    readonly property color accentPrimary: palette.accentPrimary || "#73a5e2"
    readonly property color accentRed: palette.accentRed || "#f7768e"
    readonly property color urgencyLow: textMuted
    readonly property color urgencyNormal: accentPrimary
    readonly property color urgencyCritical: accentRed
    readonly property int spacing: 4
    readonly property int sectionSpacing: 8
    readonly property int panelPadding: 12
    readonly property int barInset: 2
}
