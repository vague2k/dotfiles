import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Standalone audio mixer overlay.
Scope {
    id: root

    property var theme: DefaultTheme {}

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(node => node.audio && node.isStream && node.isSink)

    component BarButton: Rectangle {
        id: button
        property var theme: DefaultTheme {}
        property string label: ""
        property int labelFontSize: theme.fontSize
        property bool action: false
        property bool selected: false
        property bool keyboardNavigable: false
        signal clicked

        activeFocusOnTab: keyboardNavigable
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        Keys.onSpacePressed: button.clicked()

        color: action ? (mouse.containsMouse || activeFocus ? theme.accentPrimary : selected ? theme.bgSelected : "transparent") : selected ? theme.bgSelected : "transparent"
        border.color: activeFocus ? theme.accentPrimary : action ? theme.bgBorderStrong : "transparent"
        border.width: activeFocus || action ? 1 : 0
        implicitWidth: labelText.implicitWidth + (action ? 16 : 12)
        implicitHeight: 25

        Text {
            id: labelText
            text: button.label
            color: button.action ? (mouse.containsMouse || button.activeFocus ? button.theme.bgBase : button.theme.accentPrimary) : button.theme.textPrimary
            font.family: button.theme.fontFamily
            font.pixelSize: button.labelFontSize
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (button.keyboardNavigable)
                    button.forceActiveFocus();
                button.clicked();
            }
        }
    }

    component PanelCard: Rectangle {
        property var theme: DefaultTheme {}
        color: theme.bgSurface
        border.color: theme.bgBorder
        border.width: 1
    }

    component PanelHeader: Item {
        id: header
        property var theme: DefaultTheme {}
        property string title: ""
        signal closeRequested

        implicitHeight: 26

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: header.title
            color: header.theme.textPrimary
            font.family: header.theme.fontFamily
            font.pixelSize: header.theme.fontSize
            font.bold: true
        }

        BarButton {
            theme: header.theme
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 24
            label: "×"
            action: true
            onClicked: header.closeRequested()
        }
    }

    component PanelSlider: Slider {
        id: slider
        property var theme: DefaultTheme {}

        implicitHeight: 24
        hoverEnabled: true
        activeFocusOnTab: false

        background: Rectangle {
            x: slider.leftPadding
            y: (slider.height - height) / 2
            width: slider.availableWidth
            height: 4
            color: slider.theme.bgBorder

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: slider.theme.accentPrimary
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: (slider.height - height) / 2
            width: 6
            height: 16
            color: slider.pressed || slider.hovered || slider.activeFocus ? slider.theme.textPrimary : slider.theme.accentPrimary
        }
    }

    component PanelSelect: ComboBox {
        id: select
        property var theme: DefaultTheme {}

        implicitHeight: 30
        leftPadding: 8
        rightPadding: 26
        spacing: 0
        font.family: select.theme.fontFamily
        font.pixelSize: select.theme.fontSize
        hoverEnabled: true
        activeFocusOnTab: false

        background: Rectangle {
            color: select.hovered ? select.theme.bgSurface : select.theme.bgSurfaceLow
            border.width: 1
            border.color: select.activeFocus || select.popup.visible ? select.theme.accentPrimary : select.theme.bgBorder
        }

        contentItem: Text {
            leftPadding: select.leftPadding
            rightPadding: select.rightPadding
            text: select.displayText
            color: select.theme.textPrimary
            font: select.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: select.width - width - 8
            anchors.verticalCenter: parent.verticalCenter
            text: "⌄"
            color: select.theme.textSecondary
            font.family: select.theme.fontFamily
            font.pixelSize: select.theme.fontSize
        }

        delegate: ItemDelegate {
            required property int index
            width: select.popup.width
            height: 28

            contentItem: Text {
                leftPadding: 8
                rightPadding: 8
                text: select.textAt(index)
                color: select.highlightedIndex === index ? select.theme.bgBase : select.theme.textPrimary
                font: select.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: select.highlightedIndex === index ? select.theme.accentPrimary : select.theme.bgInset
            }
        }

        popup: Popup {
            y: select.height
            width: select.width
            implicitHeight: Math.min(contentItem.implicitHeight + 2, 240)
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: select.popup.visible ? select.delegateModel : null
                currentIndex: select.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator {}
            }

            background: Rectangle {
                color: select.theme.bgInset
                border.width: 1
                border.color: select.theme.bgBorder
            }
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.streams)
    }

    IpcHandler {
        target: "audio"

        function toggle(): void {
            panel.visible = !panel.visible;
        }
    }

    PanelWindow {
        id: panel
        visible: false
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

        Rectangle {
            anchors.fill: parent
            color: root.theme.bgOverlay

            MouseArea {
                anchors.fill: parent
                onClicked: panel.visible = false
            }
        }

        Item {
            id: body
            width: 380
            height: 500
            focus: true
            anchors.centerIn: parent
            visible: panel.visible

            Keys.onEscapePressed: panel.visible = false

            Rectangle {
                anchors.fill: parent
                color: root.theme.bgSurfaceLow
                border.color: root.theme.bgBorder
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.panelPadding
                spacing: root.theme.sectionSpacing

                PanelHeader {
                    theme: root.theme
                    Layout.fillWidth: true
                    title: "Audio"
                    onCloseRequested: panel.visible = false
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: root.theme.sectionSpacing

                    Repeater {
                        model: 2

                        PanelCard {
                            id: deviceCard
                            theme: root.theme
                            required property int index
                            readonly property bool output: index === 0
                            readonly property var device: output ? root.sink : root.source
                            Layout.fillWidth: true
                            Layout.preferredHeight: 96

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: root.theme.spacing

                                Text {
                                    text: deviceCard.output ? "Output" : "Input"
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSize
                                    font.bold: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: deviceCard.device?.description || "No device"
                                    color: root.theme.textSecondary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacing

                                    PanelSlider {
                                        theme: root.theme
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

                                    BarButton {
                                        theme: root.theme
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
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: root.theme.spacing

                        Text {
                            text: "Output device"
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: 11
                        }

                        PanelSelect {
                            id: outputSelect
                            theme: root.theme
                            Layout.fillWidth: true
                            model: root.outputs
                            textRole: "description"
                            font.pixelSize: 11
                            currentIndex: root.outputs.findIndex(node => node.id === root.sink?.id)
                            onActivated: index => Pipewire.preferredDefaultAudioSink = root.outputs[index]
                        }
                    }
                }

                PanelCard {
                    theme: root.theme
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
                                readonly property string iconSource: {
                                    const icon = entry?.icon || properties["application.icon-name"] || "";
                                    return icon ? Quickshell.iconPath(icon, true) : "";
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: root.theme.spacing

                                    Image {
                                        Layout.preferredWidth: 22
                                        Layout.preferredHeight: 22
                                        source: streamRow.iconSource
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    PanelSlider {
                                        theme: root.theme
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
    }
}
