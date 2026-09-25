//@ pragma IconTheme hicolor
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick

ShellRoot {
    SystemStats { id: stats }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            property string openMenu: ""

            screen: modelData
            implicitHeight: 30
            color: Theme.barBackground

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Theme.barBorder
                border.width: 1
            }

            anchors {
                bottom: true
                left: true
                right: true
            }

            function toggleMenu(menu) {
                openMenu = openMenu === menu ? "" : menu;
            }

            Row {
                id: leftSide
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3


                BarButton {
                    id: startButton
                    boxed: true
                    label: "START"
                    selected: bar.openMenu === "start"
                    onClicked: bar.toggleMenu("start")
                }

                BarButton {
                    id: wallpaperButton
                    glyph: ""
                    glyphFontSize: 28
                    selected: bar.openMenu === "wallpaper"
                    onClicked: bar.toggleMenu("wallpaper")
                }

                Rectangle { width: 1; height: 18; color: "#596575"; anchors.verticalCenter: parent.verticalCenter }

                Row {
                    spacing: 2
                    Repeater {
                        model: ["brave-browser", "steam", "com.mitchellh.ghostty"]
                        BarButton {
                            required property string modelData
                            readonly property var app: DesktopEntries.byId(modelData)
                            width: 24
                            label: ""
                            icon: Quickshell.iconPath(({"brave-browser": "brave-desktop", "steam": "steam", "com.mitchellh.ghostty": "com.mitchellh.ghostty"})[modelData])
                            onClicked: { if (app) app.execute(); }
                        }
                    }
                }

                Rectangle { width: 1; height: 18; color: "#596575"; anchors.verticalCenter: parent.verticalCenter }

                Taskbar {
                    monitor: Hyprland.monitorFor(bar.screen)
                    maxWidth: Math.max(0, bar.width - x - rightSide.width - 30)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                id: rightSide
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                BarButton { glyph: "󰍛"; label: stats.cpu; }
                BarButton { glyph: ""; label: stats.ram }
                BarButton { glyph: ""; label: stats.disk }

                BarButton {
                    id: visualizerButton
                    width: 108
                    selected: bar.openMenu === "audio"
                    onClicked: bar.toggleMenu("audio")
                    AudioVisualizer {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                    }
                }

                BarButton {
                    id: soundButton
                    glyph: Pipewire.defaultAudioSink?.audio?.muted ? "󰝟" : "󰕾"
                    label: Math.round((Pipewire.defaultAudioSink?.audio?.volume || 0) * 100) + "%"
                    selected: bar.openMenu === "audio"
                    onClicked: bar.toggleMenu("audio")
                }

                BarButton {
                    id: bluetoothButton
                    glyph: "󰂯"
                    glyphFontSize: 17
                    width: 26
                    selected: bar.openMenu === "bluetooth"
                    onClicked: bar.toggleMenu("bluetooth")
                }

                BarButton {
                    label: Qt.formatDateTime(clock.date, "MMM dd, yyyy\nhh:mm:ss AP")
                    labelFontSize: 12
                    lineHeight: 0.9
                }
            }

            HyprlandFocusGrab {
                windows: [bar, bluetoothPopup, audioPopup]
                active: bar.openMenu === "bluetooth" || bar.openMenu === "audio"
                onCleared: bar.openMenu = ""
            }

            PopupWindow {
                id: startPopup
                grabFocus: true
                anchor.window: bar
                anchor.rect.x: startButton.x + leftSide.x
                anchor.rect.y: -height
                implicitWidth: 340
                implicitHeight: 430
                visible: bar.openMenu === "start"
                onVisibleChanged: if (!visible && bar.openMenu === "start") bar.openMenu = ""
                StartMenu {
                    anchors.fill: parent
                    visible: startPopup.visible
                    onCloseRequested: bar.openMenu = ""
                }
            }

            PopupWindow {
                id: wallpaperPopup
                grabFocus: true
                anchor.window: bar
                anchor.rect.x: wallpaperButton.x + leftSide.x
                anchor.rect.y: -height
                implicitWidth: Math.min(600, bar.width - 16)
                implicitHeight: Math.min(520, bar.screen.height - bar.height - 16)
                visible: bar.openMenu === "wallpaper"
                onVisibleChanged: if (!visible && bar.openMenu === "wallpaper") bar.openMenu = ""
                WallpaperPicker {
                    anchors.fill: parent
                    visible: bar.openMenu === "wallpaper"
                    onCloseRequested: bar.openMenu = ""
                }
            }

            PopupWindow {
                id: bluetoothPopup
                anchor.window: bar
                anchor.rect.x: Math.max(0, bar.width - width - 140)
                anchor.rect.y: -height
                implicitWidth: 310
                implicitHeight: 380
                visible: bar.openMenu === "bluetooth"
                BluetoothMenu {
                    anchors.fill: parent
                    visible: bar.openMenu === "bluetooth"
                }
            }

            PopupWindow {
                id: audioPopup
                anchor.window: bar
                anchor.rect.x: Math.max(0, bar.width - width - 190)
                anchor.rect.y: -height
                implicitWidth: 315
                implicitHeight: 280
                visible: bar.openMenu === "audio"
                AudioMenu { anchors.fill: parent }
            }
        }
    }
}
