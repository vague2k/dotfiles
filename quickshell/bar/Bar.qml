import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import "../theme"

Scope {
    id: root

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
            implicitHeight: 32
            visible: root.barVisible
            color: Theme.bgBase

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Theme.bgBorder
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
                anchors.leftMargin: Theme.barInset
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: startText.implicitWidth + 12
                    implicitHeight: 28
                    color: startMouse.containsMouse ? Theme.bgHover : Theme.bgSurface
                    border.color: Theme.bgBorder
                    border.width: 1

                    Text {
                        id: startText
                        anchors.centerIn: parent
                        text: "START"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        id: startMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: wallpaperGlyph.implicitWidth + 12
                    implicitHeight: 28
                    color: "transparent"

                    Text {
                        id: wallpaperGlyph
                        anchors.centerIn: parent
                        text: ""
                        color: Theme.textPrimary
                        font.family: tablerIcons.name
                        font.pixelSize: Theme.iconSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "wallpaper", "toggle"])
                    }
                }

                Rectangle {
                    width: 1
                    height: 20
                    color: Theme.bgBorder
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: [
                            {
                                id: "brave-browser",
                                icon: "brave-desktop"
                            },
                            {
                                id: "steam",
                                icon: "steam"
                            },
                            {
                                id: "com.mitchellh.ghostty",
                                icon: "com.mitchellh.ghostty"
                            }
                        ]

                        Rectangle {
                            required property var modelData
                            readonly property var app: DesktopEntries.byId(modelData.id)
                            width: 24
                            implicitHeight: 28
                            color: "transparent"

                            Image {
                                anchors.centerIn: parent
                                width: Theme.iconSize
                                height: Theme.iconSize
                                source: Quickshell.iconPath(modelData.icon)
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (app)
                                        app.execute();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 20
                    color: Theme.bgBorder
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
                anchors.rightMargin: Theme.barInset
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Repeater {
                    model: [
                        {
                            glyph: "勺",
                            label: stats.cpu,
                            progress: stats.cpuUsage
                        },
                        {
                            glyph: "",
                            label: stats.gpu,
                            progress: stats.gpuUsage
                        },
                        {
                            glyph: "",
                            label: stats.ram,
                            progress: stats.ramUsage
                        },
                        {
                            glyph: "",
                            label: stats.disk,
                            progress: stats.diskUsage
                        }
                    ]

                    Rectangle {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: statContent.implicitWidth + 12
                        implicitHeight: 22
                        color: "transparent"

                        Row {
                            id: statContent
                            anchors.centerIn: parent
                            spacing: Theme.spacing

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.glyph
                                color: Theme.textPrimary
                                font.family: tablerIcons.name
                                font.pixelSize: Theme.iconSize
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 4
                                height: 16
                                color: Theme.bgBorder

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * Math.max(0, Math.min(1, modelData.progress))
                                    color: Theme.accentPrimary
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 108
                    implicitHeight: 22
                    color: "transparent"

                    AudioVisualizer {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: soundContent.implicitWidth + 12
                    implicitHeight: 22
                    color: "transparent"

                    Row {
                        id: soundContent
                        anchors.centerIn: parent
                        spacing: Theme.spacing

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Pipewire.defaultAudioSink?.audio?.muted ? "" : ""
                            color: Theme.textPrimary
                            font.family: tablerIcons.name
                            font.pixelSize: Theme.iconSize
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.round((Pipewire.defaultAudioSink?.audio?.volume || 0) * 100) + "%"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "audio", "toggle"])
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 26
                    implicitHeight: 22
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Theme.textPrimary
                        font.family: tablerIcons.name
                        font.pixelSize: Theme.iconSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "bluetooth", "toggle"])
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: clockText.implicitWidth + 12
                    implicitHeight: 22
                    color: "transparent"

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(clock.date, "MMM dd, yyyy\nhh:mm:ss AP")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        lineHeight: 0.8
                    }
                }
            }
        }
    }
}
