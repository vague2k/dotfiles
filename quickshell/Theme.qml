pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property string fontFamily: "Iosevka Nerd Font Mono"
    readonly property int fontSize: 13
    readonly property color barBackground: "#1c222b"
    readonly property color barBorder: "#596575"
    readonly property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures"
}
