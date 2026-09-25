import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Standalone bar module: one bar window per screen, toggled via IPC `bar toggle`.
Scope {
    id: root

    property var theme: DefaultTheme {}
    property bool barVisible: true

    FontLoader {
        id: tablerIcons
        source: "file:///usr/share/fonts/TTF/tabler-icons.ttf"
    }

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property string glyph: ""
        property int glyphFontSize: 20
        property string glyphFamily: "tabler-icons"
        property string icon: ""
        property int iconSize: 17
        property bool selected: false
        property bool boxed: false
        property real lineHeight: 1
        property real progress: -1
        signal clicked

        color: boxed ? (selected ? theme.bgSelected : mouse.containsMouse ? theme.bgHover : theme.bgSurface) : "transparent"
        border.color: boxed ? (selected ? theme.accentPrimary : theme.bgBorder) : "transparent"
        border.width: boxed ? 1 : 0
        implicitWidth: labelText.implicitWidth + (iconImage.visible ? button.iconSize + theme.spacing : 0) + (glyphText.visible ? glyphText.implicitWidth + theme.spacing : 0) + (progressTrack.visible ? progressTrack.width + theme.spacing : 0) + 12
        implicitHeight: 25

        Row {
            id: content
            anchors.verticalCenter: parent.verticalCenter
            x: (button.width - implicitWidth) / 2
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
                id: glyphText
                visible: button.glyph !== ""
                text: button.glyph
                color: button.theme.textPrimary
                font.family: button.glyphFamily
                font.pixelSize: button.glyphFontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: progressTrack
                visible: button.progress >= 0
                width: 4
                height: 16
                color: button.theme.bgBorder
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * Math.max(0, Math.min(1, button.progress))
                    color: button.theme.accentPrimary
                }
            }

            Text {
                id: labelText
                text: button.label
                color: button.theme.textPrimary
                font.family: button.theme.fontFamily
                font.pixelSize: button.labelFontSize
                lineHeight: button.lineHeight
                lineHeightMode: Text.ProportionalHeight
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    IpcHandler {
        target: "bar"

        function toggle(): void {
            root.barVisible = !root.barVisible;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            SystemStats {
                id: stats
            }

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            screen: modelData
            implicitHeight: 30
            visible: root.barVisible
            color: root.theme.bgBase

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: root.theme.bgBorder
                border.width: 1
            }

            anchors {
                bottom: true
                left: true
                right: true
            }

            Row {
                id: leftSide
                anchors.left: parent.left
                anchors.leftMargin: root.theme.barInset
                anchors.verticalCenter: parent.verticalCenter
                spacing: root.theme.spacing

                BarButton {
                    id: startButton
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    boxed: true
                    label: "START"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
                }

                BarButton {
                    id: wallpaperButton
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    glyphFontSize: 20
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "wallpaper", "toggle"])
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: root.theme.bgBorder
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: ["brave-browser", "steam", "com.mitchellh.ghostty"]
                        BarButton {
                            theme: root.theme
                            required property string modelData
                            readonly property var app: DesktopEntries.byId(modelData)
                            width: 24
                            label: ""
                            icon: Quickshell.iconPath(({
                                    "brave-browser": "brave-desktop",
                                    "steam": "steam",
                                    "com.mitchellh.ghostty": "com.mitchellh.ghostty"
                                })[modelData])
                            onClicked: {
                                if (app)
                                    app.execute();
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: root.theme.bgBorder
                    anchors.verticalCenter: parent.verticalCenter
                }

                Taskbar {
                    theme: root.theme
                    monitor: Hyprland.monitorFor(bar.screen)
                    maxWidth: Math.max(0, bar.width - x - rightSide.width - 30)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                id: rightSide
                anchors.right: parent.right
                anchors.rightMargin: root.theme.barInset
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                BarButton {
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "勺"
                    glyphFamily: tablerIcons.name
                    label: stats.cpu
                    progress: stats.cpuUsage
                }
                BarButton {
                    theme: root.theme
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    label: stats.ram
                    progress: stats.ramUsage
                    anchors.verticalCenter: parent.verticalCenter
                }
                BarButton {
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    label: stats.disk
                    progress: stats.diskUsage
                }

                BarButton {
                    id: visualizerButton
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    width: 108
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                    AudioVisualizer {
                        theme: root.theme
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                    }
                }

                BarButton {
                    id: soundButton
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Pipewire.defaultAudioSink?.audio?.muted ? "" : ""
                    glyphFamily: tablerIcons.name
                    label: Math.round((Pipewire.defaultAudioSink?.audio?.volume || 0) * 100) + "%"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                }

                BarButton {
                    id: bluetoothButton
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    glyphFontSize: 22
                    width: 26
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "bluetooth", "toggle"])
                }

                BarButton {
                    theme: root.theme
                    anchors.verticalCenter: parent.verticalCenter
                    label: Qt.formatDateTime(clock.date, "MMM dd, yyyy\nhh:mm:ss AP")
                    labelFontSize: 12
                    lineHeight: 0.9
                }
            }
        }
    }
}
