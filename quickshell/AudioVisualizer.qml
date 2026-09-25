import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth: 100
    implicitHeight: 23
    readonly property int bandCount: 15
    property var targets: Array(bandCount).fill(0)

    // Cava captures the default PipeWire output and writes 15 ASCII bands per frame.
    Process {
        id: capture
        running: true
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        stdout: SplitParser {
            onRead: line => {
                const bands = line.trim().replace(/;$/, "").split(";");
                if (bands.length === root.bandCount && bands.every(value => value !== "" && Number.isFinite(Number(value))))
                    root.targets = bands.map(value => Math.max(0, Math.min(1, Number(value) / 1000)));
            }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: root.bandCount * 6 - 1
        height: 20
        Repeater {
            model: root.bandCount
            Rectangle {
                required property int index
                property real level: root.targets[index]
                x: index * 6
                width: 5
                height: Math.max(2, level * 20)
                color: "#73a5e2"
                anchors.bottom: parent.bottom

                // Approximate Noctalia's 60ms smoothing as new frames arrive.
                Behavior on height {
                    NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
