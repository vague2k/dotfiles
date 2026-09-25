import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)

    width: 315
    height: 280

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Rectangle {
        anchors.fill: parent
        color: "#202630"
        border.color: "#74859b"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            text: "Audio"
            color: "#e8edf5"
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 18
        }

        Text { text: "Output  " + Math.round((root.sink?.audio?.volume || 0) * 100) + "%"; color: "#e8edf5"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
        Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            value: root.sink?.audio?.volume || 0
            onMoved: { if (root.sink?.audio) root.sink.audio.volume = value; }
        }
        BarButton {
            label: root.sink?.audio?.muted ? "Unmute output" : "Mute output"
            onClicked: { if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted; }
        }

        Text { text: "Input  " + Math.round((root.source?.audio?.volume || 0) * 100) + "%"; color: "#e8edf5"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
        Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            value: root.source?.audio?.volume || 0
            onMoved: { if (root.source?.audio) root.source.audio.volume = value; }
        }
        BarButton {
            label: root.source?.audio?.muted ? "Unmute input" : "Mute input"
            onClicked: { if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted; }
        }

        Text { text: "Output device"; color: "#aeb6c2"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
        ComboBox {
            Layout.fillWidth: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            model: root.outputs
            textRole: "description"
            currentIndex: root.outputs.findIndex(node => node.id === root.sink?.id)
            onActivated: index => Pipewire.preferredDefaultAudioSink = root.outputs[index]
        }
    }
}
