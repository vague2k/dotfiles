import Quickshell
import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Scope {
    id: root

    property var theme: Theme

    function focusFirstAction() {
        logoutButton.forceActiveFocus();
    }

    ModalOverlay {
        id: overlay
        ipcTarget: "session"
        title: "Session"
        bodyWidth: 320
        bodyHeight: 150
        headerKeyboardNavigable: true

        onOpenChanged: if (open)
            Qt.callLater(root.focusFirstAction)

        PanelButton {
            id: logoutButton
            Layout.fillWidth: true
            label: "Log out"
            action: true
            keyboardNavigable: true
            KeyNavigation.up: shutdownButton
            KeyNavigation.down: restartButton
            onClicked: {
                overlay.open = false;
                Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]);
            }
        }

        PanelButton {
            id: restartButton
            Layout.fillWidth: true
            label: "Restart"
            action: true
            keyboardNavigable: true
            KeyNavigation.up: logoutButton
            KeyNavigation.down: shutdownButton
            onClicked: {
                overlay.open = false;
                Quickshell.execDetached(["systemctl", "reboot"]);
            }
        }

        PanelButton {
            id: shutdownButton
            Layout.fillWidth: true
            label: "Shut down"
            action: true
            keyboardNavigable: true
            KeyNavigation.up: restartButton
            KeyNavigation.down: logoutButton
            onClicked: {
                overlay.open = false;
                Quickshell.execDetached(["systemctl", "poweroff"]);
            }
        }
    }
}
