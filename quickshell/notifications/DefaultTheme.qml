import QtQuick

// Static fallback so a module keeps working when instantiated without a
// ThemeProvider. shell.qml injects the live provider as `theme`.
// Keep the property names in sync with Theme.qml.
QtObject {
    readonly property string fontFamily: "Iosevka Nerd Font Mono"
    readonly property int fontSize: 13

    readonly property color bgBase: "#1c222b"
    readonly property color bgSurface: "#272e39"
    readonly property color bgSurfaceLow: "#202630"
    readonly property color bgInset: "#1c222b"
    readonly property color bgHover: "#344052"
    readonly property color bgSelected: "#35465e"
    readonly property color bgBorder: "#596575"
    readonly property color bgBorderStrong: "#6f9fd7"
    readonly property color bgOverlay: "#88000000"
    readonly property color textPrimary: "#e8edf5"
    readonly property color textSecondary: "#aeb6c2"
    readonly property color textMuted: "#596575"
    readonly property color accentPrimary: "#73a5e2"
    readonly property color accentCyan: "#7dcfff"
    readonly property color accentGreen: "#9ece6a"
    readonly property color accentOrange: "#ff9e64"
    readonly property color accentRed: "#f7768e"
    readonly property color urgencyLow: textMuted
    readonly property color urgencyNormal: accentPrimary
    readonly property color urgencyCritical: accentRed

    readonly property int spacing: 4
    readonly property int sectionSpacing: 8
    readonly property int panelPadding: 12
    readonly property int barInset: 2

    // Theme provider API fallbacks (no-ops when used standalone).
    readonly property var schemes: []
    readonly property string scheme: ""
    readonly property string wallpaper: ""
    readonly property bool busy: false
    readonly property string error: ""
    readonly property bool ready: false
    readonly property string themedCavaConfig: ""

    function applyWallpaper(path) {
    }
    function setScheme(value) {
    }
    function retry() {
    }
}
