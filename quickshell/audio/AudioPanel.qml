import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    property bool open: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    readonly property var inputs: Pipewire.nodes.values.filter(node => node.audio && !node.isSink && !node.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(node => node.audio && node.isStream && node.isSink)

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.streams)
    }

    IpcHandler {
        target: "audio"

        function toggle(): void {
            root.open = !root.open;
        }
    }

    PanelWindow {
        id: panel
        visible: root.open
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell-audio"
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Rectangle {
            id: body
            width: 400
            height: 500
            color: Theme.bgSurfaceLow
            border.color: Theme.bgBorder
            border.width: 1
            focus: true

            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: 4
                bottomMargin: 36
            }

            MouseArea {
                anchors.fill: parent
            }

            Keys.onEscapePressed: root.open = false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.panelPadding
                spacing: Theme.sectionSpacing

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 22

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Audio"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        color: audioCloseMouse.containsMouse ? Theme.accentPrimary : "transparent"
                        border.color: Theme.bgBorderStrong
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: audioCloseMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            id: audioCloseMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.open = false
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing

                    Repeater {
                        model: [
                            {
                                output: true
                            },
                            {
                                output: false
                            }
                        ]

                        Rectangle {
                            id: deviceCard
                            required property var modelData
                            readonly property bool output: modelData.output
                            readonly property var device: output ? root.sink : root.source
                            readonly property var devices: output ? root.outputs : root.inputs
                            Layout.fillWidth: true
                            Layout.preferredHeight: 84
                            color: Theme.bgSurface
                            border.color: Theme.bgBorder
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: Theme.spacing

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.spacing

                                    Text {
                                        text: deviceCard.output ? "Output" : "Input"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        font.bold: true
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    ComboBox {
                                        id: deviceSelect
                                        Layout.fillWidth: true
                                        model: deviceCard.devices
                                        textRole: "description"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        currentIndex: deviceCard.devices.findIndex(node => node.id === deviceCard.device?.id)
                                        onActivated: index => {
                                            if (deviceCard.output)
                                                Pipewire.preferredDefaultAudioSink = deviceCard.devices[index];
                                            else
                                                Pipewire.preferredDefaultAudioSource = deviceCard.devices[index];
                                        }

                                        implicitHeight: 22
                                        leftPadding: 4
                                        rightPadding: 26
                                        spacing: 0
                                        hoverEnabled: true
                                        activeFocusOnTab: false

                                        background: Rectangle {
                                            color: deviceSelect.hovered ? Theme.bgSurface : Theme.bgSurfaceLow
                                            border.width: 1
                                            border.color: deviceSelect.activeFocus || deviceSelect.popup.visible ? Theme.accentPrimary : Theme.bgBorder
                                        }

                                        contentItem: Text {
                                            leftPadding: deviceSelect.leftPadding
                                            rightPadding: deviceSelect.rightPadding
                                            text: deviceSelect.displayText
                                            color: Theme.textPrimary
                                            font: deviceSelect.font
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        indicator: Text {
                                            x: deviceSelect.width - width - 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: ""
                                            color: Theme.textSecondary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                        }

                                        delegate: ItemDelegate {
                                            required property int index
                                            width: deviceSelect.popup.width
                                            height: 22

                                            contentItem: Text {
                                                leftPadding: 8
                                                rightPadding: 8
                                                text: deviceSelect.textAt(index)
                                                color: deviceSelect.highlightedIndex === index ? Theme.bgBase : Theme.textPrimary
                                                font: deviceSelect.font
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                            }

                                            background: Rectangle {
                                                color: deviceSelect.highlightedIndex === index ? Theme.accentPrimary : Theme.bgInset
                                            }
                                        }

                                        popup: Popup {
                                            y: deviceSelect.height
                                            width: deviceSelect.width
                                            implicitHeight: Math.min(contentItem.implicitHeight + 2, 240)
                                            padding: 1

                                            contentItem: ListView {
                                                clip: true
                                                implicitHeight: contentHeight
                                                model: deviceSelect.popup.visible ? deviceSelect.delegateModel : null
                                                currentIndex: deviceSelect.highlightedIndex
                                                ScrollIndicator.vertical: ScrollIndicator {}
                                            }

                                            background: Rectangle {
                                                color: Theme.bgInset
                                                border.width: 1
                                                border.color: Theme.bgBorder
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.spacing

                                    Slider {
                                        id: deviceVolume
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 1
                                        value: deviceCard.device?.audio?.volume || 0
                                        onMoved: if (deviceCard.device?.audio)
                                            deviceCard.device.audio.volume = value

                                        implicitHeight: 24
                                        hoverEnabled: true
                                        activeFocusOnTab: false

                                        background: Rectangle {
                                            x: deviceVolume.leftPadding
                                            y: (deviceVolume.height - height) / 2
                                            width: deviceVolume.availableWidth
                                            height: 4
                                            color: Theme.bgBorder

                                            Rectangle {
                                                width: deviceVolume.visualPosition * parent.width
                                                height: parent.height
                                                color: Theme.accentPrimary
                                            }
                                        }

                                        handle: Rectangle {
                                            x: deviceVolume.leftPadding + deviceVolume.visualPosition * (deviceVolume.availableWidth - width)
                                            y: (deviceVolume.height - height) / 2
                                            width: 8
                                            height: 20
                                            color: deviceVolume.pressed || deviceVolume.hovered || deviceVolume.activeFocus ? Theme.textPrimary : Theme.accentPrimary
                                        }
                                    }

                                    Text {
                                        text: Math.round((deviceCard.device?.audio?.volume || 0) * 100) + "%"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                    }

                                    Rectangle {
                                        implicitWidth: 24
                                        implicitHeight: 24
                                        color: muteMouse.containsMouse ? Theme.accentPrimary : "transparent"
                                        border.color: Theme.bgBorderStrong
                                        border.width: 1

                                        Text {
                                            id: muteText
                                            anchors.centerIn: parent
                                            text: deviceCard.device?.audio?.muted ? "×" : deviceCard.output ? "󰕾" : "󰍬"
                                            color: muteMouse.containsMouse ? Theme.bgBase : Theme.accentPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.iconSize
                                        }

                                        MouseArea {
                                            id: muteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (deviceCard.device?.audio)
                                                deviceCard.device.audio.muted = !deviceCard.device.audio.muted
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.bgSurface
                    border.color: Theme.bgBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: Theme.sectionSpacing

                        Text {
                            text: "Application Volumes"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                        }

                        ListView {
                            id: applications
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: root.streams
                            spacing: Theme.spacing

                            delegate: Rectangle {
                                id: streamRow
                                required property var modelData
                                width: applications.width
                                height: 40
                                color: Theme.bgInset

                                readonly property var properties: modelData?.properties || ({})
                                readonly property string appName: properties["application.name"] || modelData?.name || modelData?.description || ""
                                readonly property var entry: {
                                    const keys = [appName, properties["application.process.binary"], properties["application.icon-name"]];
                                    for (const key of keys) {
                                        if (!key)
                                            continue;
                                        const found = DesktopEntries.heuristicLookup(key);
                                        if (found)
                                            return found;
                                    }
                                    return null;
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: Theme.spacing

                                    IconImage {
                                        Layout.preferredWidth: Theme.iconSize
                                        Layout.preferredHeight: Theme.iconSize
                                        source: Quickshell.iconPath(streamRow.entry?.icon || streamRow.properties["application.icon-name"], true)
                                    }

                                    Slider {
                                        id: streamVolume
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 1
                                        value: streamRow.modelData?.audio?.volume || 0
                                        onMoved: if (streamRow.modelData?.audio)
                                            streamRow.modelData.audio.volume = value

                                        implicitHeight: 22
                                        hoverEnabled: true
                                        activeFocusOnTab: false

                                        background: Rectangle {
                                            x: streamVolume.leftPadding
                                            y: (streamVolume.height - height) / 2
                                            width: streamVolume.availableWidth
                                            height: 4
                                            color: Theme.bgBorder

                                            Rectangle {
                                                width: streamVolume.visualPosition * parent.width
                                                height: parent.height
                                                color: Theme.accentPrimary
                                            }
                                        }

                                        handle: Rectangle {
                                            x: streamVolume.leftPadding + streamVolume.visualPosition * (streamVolume.availableWidth - width)
                                            y: (streamVolume.height - height) / 2
                                            width: 6
                                            height: 16
                                            color: streamVolume.pressed || streamVolume.hovered || streamVolume.activeFocus ? Theme.textPrimary : Theme.accentPrimary
                                        }
                                    }

                                    Text {
                                        text: Math.round((streamRow.modelData?.audio?.volume || 0) * 100) + "%"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                width: applications.width - 24
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: applications.count === 0
                                text: "No application playback streams are currently available."
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                }
            }
        }
    }
}
