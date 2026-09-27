import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme
    property bool barVisible: true

    FontLoader {
        id: tablerIcons
        source: "file:///usr/share/fonts/TTF/tabler-icons.ttf"
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
                    anchors.verticalCenter: parent.verticalCenter
                    boxed: true
                    label: "START"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
                }

                BarButton {
                    id: wallpaperButton
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
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "勺"
                    glyphFamily: tablerIcons.name
                    label: stats.cpu
                    progress: stats.cpuUsage
                }
                BarButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    label: stats.gpu
                    progress: stats.gpuUsage
                }
                BarButton {
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    label: stats.ram
                    progress: stats.ramUsage
                    anchors.verticalCenter: parent.verticalCenter
                }
                BarButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    label: stats.disk
                    progress: stats.diskUsage
                }

                BarButton {
                    id: visualizerButton
                    anchors.verticalCenter: parent.verticalCenter
                    width: 108
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                    AudioVisualizer {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                    }
                }

                BarButton {
                    id: soundButton
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Pipewire.defaultAudioSink?.audio?.muted ? "" : ""
                    glyphFamily: tablerIcons.name
                    label: Math.round((Pipewire.defaultAudioSink?.audio?.volume || 0) * 100) + "%"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                }

                BarButton {
                    id: bluetoothButton
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: ""
                    glyphFamily: tablerIcons.name
                    glyphFontSize: 22
                    width: 26
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "bluetooth", "toggle"])
                }

                BarButton {
                    anchors.verticalCenter: parent.verticalCenter
                    label: Qt.formatDateTime(clock.date, "MMM dd, yyyy\nhh:mm:ss AP")
                    labelFontSize: 12
                    lineHeight: 0.9
                }
            }
        }
    }
}
