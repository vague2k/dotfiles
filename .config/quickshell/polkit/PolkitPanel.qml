import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import "../theme"

Scope {
    id: root

    readonly property var flow: agent.flow
    readonly property bool active: flow !== null && !flow.isCompleted
    readonly property string iconSource: flow && flow.iconName && Quickshell.hasThemeIcon(flow.iconName) ? Quickshell.iconPath(flow.iconName, true) : ""
    // show on the monitor the user is currently on
    readonly property var focusedScreen: {
        const monitor = Hyprland.focusedMonitor;
        if (!monitor)
            return null;
        return Quickshell.screens.find(screen => screen.name === monitor.name) ?? null;
    }
    // message shown under the request text: PAM output, processing, or failure
    readonly property string statusMessage: {
        if (!flow || flow.isCompleted || flow.isCancelled)
            return "";
        if (flow.supplementaryIsError)
            return flow.supplementaryMessage;
        if (!flow.isResponseRequired)
            return "Checking...";
        if (flow.failed)
            return "Authentication failed. Try again.";
        return flow.supplementaryMessage;
    }
    readonly property bool statusIsError: flow !== null && !flow.isCompleted && !flow.isCancelled && (flow.supplementaryIsError || (flow.failed && flow.isResponseRequired))

    PolkitAgent {
        id: agent
    }

    Connections {
        target: root.flow

        function onIsResponseRequiredChanged() {
            if (root.flow && root.flow.isResponseRequired)
                Qt.callLater(() => passwordInput.forceActiveFocus());
        }
    }

    function submit() {
        if (!root.active || !root.flow.isResponseRequired)
            return;
        root.flow.submit(passwordInput.text);
        passwordInput.text = "";
        Qt.callLater(() => passwordInput.forceActiveFocus());
    }

    function cancel() {
        if (root.active)
            root.flow.cancelAuthenticationRequest();
    }

    function selectIdentity(identity) {
        if (root.flow)
            root.flow.selectedIdentity = identity;
    }

    PanelWindow {
        id: panel
        visible: root.active
        screen: root.focusedScreen
        focusable: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "quickshell-polkit"
        exclusionMode: ExclusionMode.Ignore

        HyprlandFocusGrab {
            windows: [panel]
            active: panel.visible
            onCleared: root.cancel()
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onVisibleChanged: {
            if (visible)
                Qt.callLater(() => passwordInput.forceActiveFocus());
        }

        // swallow clicks outside the dialog so they don't reach windows below
        MouseArea {
            anchors.fill: parent
        }

        Shortcut {
            sequence: "Escape"
            enabled: root.active
            onActivated: root.cancel()
        }

        Rectangle {
            id: dialog
            width: 440
            implicitHeight: content.implicitHeight + Theme.panelPadding * 2
            anchors.centerIn: parent
            color: Theme.bgBase
            border.width: 1
            border.color: root.flow && root.flow.supplementaryIsError ? Theme.accentRed : Theme.bgBorder

            ColumnLayout {
                id: content
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Theme.panelPadding
                }
                spacing: Theme.sectionSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing

                    Item {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignTop

                        IconImage {
                            anchors.fill: parent
                            implicitSize: 32
                            source: root.iconSource
                            visible: root.iconSource !== ""
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.iconSource === ""
                            text: "󰌾"
                            color: Theme.accentPrimary
                            font.pixelSize: 26
                            font.family: Theme.fontFamily
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: "Authentication required"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.flow ? root.flow.message : ""
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            wrapMode: Text.Wrap
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.flow && root.flow.identities.length === 1 && root.flow.selectedIdentity !== null
                            text: root.flow && root.flow.selectedIdentity ? "Authenticating as " + (root.flow.selectedIdentity.displayName || root.flow.selectedIdentity.string) : ""
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                        }
                    }
                }

                // identity picker, only when there is something to pick
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: root.flow && root.flow.identities.length > 1

                    Repeater {
                        model: root.flow && root.flow.identities.length > 1 ? root.flow.identities : []

                        Rectangle {
                            id: identityButton
                            required property var modelData

                            readonly property bool selected: root.flow !== null && root.flow.selectedIdentity === modelData

                            Layout.fillWidth: true
                            implicitHeight: 26
                            activeFocusOnTab: true
                            color: identityHover.containsMouse || identityButton.activeFocus ? Theme.bgHover : selected ? Theme.bgSelected : Theme.bgSurface
                            border.width: 1
                            border.color: identityButton.activeFocus || selected ? Theme.accentPrimary : Theme.bgBorder

                            Accessible.role: Accessible.Button
                            Accessible.name: "Authenticate as " + (identityButton.modelData.displayName || identityButton.modelData.string)

                            Keys.onReturnPressed: root.selectIdentity(identityButton.modelData)
                            Keys.onEnterPressed: root.selectIdentity(identityButton.modelData)
                            Keys.onSpacePressed: root.selectIdentity(identityButton.modelData)

                            Text {
                                anchors.centerIn: parent
                                width: parent.width - 12
                                text: identityButton.modelData.displayName || identityButton.modelData.string
                                color: identityButton.selected ? Theme.accentPrimary : Theme.textPrimary
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MouseArea {
                                id: identityHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectIdentity(identityButton.modelData)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.statusMessage !== ""
                    text: root.statusMessage
                    color: root.statusIsError ? Theme.accentRed : Theme.textSecondary
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing
                    visible: root.flow && root.flow.isResponseRequired

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        visible: text !== ""
                        text: root.flow ? root.flow.inputPrompt : ""
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 26
                        color: Theme.bgSurfaceLow
                        border.width: 1
                        border.color: passwordInput.activeFocus ? Theme.accentPrimary : Theme.bgBorder

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.textPrimary
                            selectionColor: Theme.accentPrimary
                            selectedTextColor: Theme.bgBase
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                            echoMode: root.flow && root.flow.responseVisible ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "*"
                            activeFocusOnTab: true
                            selectByMouse: true
                            clip: true
                            readOnly: !(root.flow && root.flow.isResponseRequired)
                            opacity: root.flow && root.flow.isResponseRequired ? 1 : 0.6

                            onAccepted: root.submit()

                            Keys.onEscapePressed: root.cancel()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.sectionSpacing

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        id: cancelButton
                        implicitWidth: cancelLabel.width + 20
                        implicitHeight: 26
                        activeFocusOnTab: true
                        color: cancelHover.containsMouse || cancelButton.activeFocus ? Theme.bgSelected : Theme.bgInset
                        border.width: 1
                        border.color: cancelButton.activeFocus ? Theme.accentPrimary : Theme.bgBorder

                        Accessible.role: Accessible.Button
                        Accessible.name: "Cancel authentication"

                        Keys.onReturnPressed: root.cancel()
                        Keys.onEnterPressed: root.cancel()
                        Keys.onSpacePressed: root.cancel()

                        Text {
                            id: cancelLabel
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Theme.textSecondary
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                        }

                        MouseArea {
                            id: cancelHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.cancel()
                        }
                    }

                    Rectangle {
                        id: authButton
                        visible: root.active
                        opacity: root.flow && root.flow.isResponseRequired ? 1 : 0.5
                        implicitWidth: authLabel.width + 20
                        implicitHeight: 26
                        activeFocusOnTab: true
                        color: authHover.containsMouse || authButton.activeFocus ? Theme.bgSelected : Theme.bgInset
                        border.width: 1
                        border.color: Theme.accentPrimary

                        Accessible.role: Accessible.Button
                        Accessible.name: "Authenticate"

                        Keys.onReturnPressed: root.submit()
                        Keys.onEnterPressed: root.submit()
                        Keys.onSpacePressed: root.submit()

                        Text {
                            id: authLabel
                            anchors.centerIn: parent
                            text: "Authenticate"
                            color: Theme.accentPrimary
                            font.pixelSize: Theme.fontSize
                            font.family: Theme.fontFamily
                        }

                        MouseArea {
                            id: authHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submit()
                        }
                    }
                }
            }
        }
    }
}
