import Quickshell // for PanelWindow
import QtQuick // for Text

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            property int margin: 5
            top: margin
            left: margin
            right: margin
        }

        implicitHeight: 25
        color: "#010101"

        Text {
            // center the bar in its parent component (the window)
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "hh:mm:ss")
            color: "#fefefefe"
            font {
                family: "Arial"
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
    }
}
