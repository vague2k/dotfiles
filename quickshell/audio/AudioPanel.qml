import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    readonly property var inputs: Pipewire.nodes.values.filter(node => node.audio && !node.isSink && !node.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(node => node.audio && node.isStream && node.isSink)

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.streams)
    }

    ModalOverlay {
        id: overlay
        ipcTarget: "audio"
        title: "Audio"
        bodyWidth: 380
        bodyHeight: 500
        anchorRight: true
        anchorBottom: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.theme.sectionSpacing

            Repeater {
                model: 2

                PanelCard {
                    id: deviceCard
                    required property int index
                    readonly property bool output: index === 0
                    readonly property var device: output ? root.sink : root.source
                    readonly property var devices: output ? root.outputs : root.inputs
                    Layout.fillWidth: true
                    Layout.preferredHeight: 84

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: root.theme.spacing

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.theme.spacing

                            Text {
                                text: deviceCard.output ? "Output" : "Input"
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSize
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            PanelSelect {
                                Layout.fillWidth: true
                                model: deviceCard.devices
                                textRole: "description"
                                font.pixelSize: 11
                                currentIndex: deviceCard.devices.findIndex(node => node.id === deviceCard.device?.id)
                                onActivated: index => {
                                    if (deviceCard.output)
                                        Pipewire.preferredDefaultAudioSink = deviceCard.devices[index];
                                    else
                                        Pipewire.preferredDefaultAudioSource = deviceCard.devices[index];
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: root.theme.spacing

                            PanelSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1
                                value: deviceCard.device?.audio?.volume || 0
                                onMoved: if (deviceCard.device?.audio)
                                    deviceCard.device.audio.volume = value
                            }

                            Text {
                                text: Math.round((deviceCard.device?.audio?.volume || 0) * 100) + "%"
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                            }

                            PanelButton {
                                action: true
                                label: deviceCard.device?.audio?.muted ? "×" : deviceCard.output ? "󰕾" : "󰍬"
                                labelFontSize: 12
                                onClicked: if (deviceCard.device?.audio)
                                    deviceCard.device.audio.muted = !deviceCard.device.audio.muted
                            }
                        }
                    }
                }
            }
        }

        PanelCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: root.theme.sectionSpacing

                Text {
                    text: "Application Volumes"
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize
                    font.bold: true
                }

                ListView {
                    id: applications
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.streams
                    spacing: root.theme.spacing

                    delegate: Rectangle {
                        id: streamRow
                        required property var modelData
                        width: applications.width
                        height: 40
                        color: root.theme.bgInset

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
                            spacing: root.theme.spacing

                            Image {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                source: AppLookup.iconPath(streamRow.entry?.icon || streamRow.properties["application.icon-name"])
                                fillMode: Image.PreserveAspectFit
                            }

                            PanelSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1
                                value: streamRow.modelData?.audio?.volume || 0
                                onMoved: if (streamRow.modelData?.audio)
                                    streamRow.modelData.audio.volume = value
                            }

                            Text {
                                text: Math.round((streamRow.modelData?.audio?.volume || 0) * 100) + "%"
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    visible: root.streams.length === 0
                    color: root.theme.bgInset

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text {
                            text: "No Application Audio"
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            text: "No application playback streams are currently available."
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }
                }
            }
        }
    }
}
