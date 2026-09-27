import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: notificationData

    property Notification notification: null
    property bool closed: false
    property bool hovered: false
    property string seqId: ""

    readonly property int defaultTimeout: 5000

    readonly property string notifId: String(notification?.id ?? "")
    readonly property string summary: notification?.summary || ""
    readonly property string body: notification?.body || ""
    readonly property string appIcon: notification?.appIcon || ""
    readonly property string appName: notification?.appName || ""
    readonly property string image: notification?.image || ""
    readonly property int urgency: notification?.urgency ?? NotificationUrgency.Normal
    readonly property real expireTimeout: notification?.expireTimeout > 0 ? notification.expireTimeout : defaultTimeout
    readonly property var actions: (notification?.actions ?? []).map(action => ({
                identifier: action.identifier,
                text: action.text
            }))

    readonly property Connections _conn: Connections {
        target: notificationData.notification

        function onClosed(): void {
            if (notificationData.closed)
                return;
            notificationData.closed = true;
            NotificationService._remove(notificationData);
            notificationData.destroy();
        }
    }

    readonly property Timer _timer: Timer {
        running: !notificationData.closed && !notificationData.hovered && notificationData.urgency !== NotificationUrgency.Critical
        interval: notificationData.expireTimeout
        onTriggered: notificationData.dismiss()
    }

    function dismiss(): void {
        if (closed)
            return;
        closed = true;
        NotificationService._remove(notificationData);
        if (notification)
            try {
                notification.dismiss();
            } catch (e) {}
        destroy();
    }

    function invokeAction(identifier): void {
        if (!identifier || closed)
            return;
        closed = true;
        NotificationService._remove(notificationData);
        if (notification) {
            const action = notification.actions.find(function (a) {
                return a.identifier === identifier;
            });
            if (action)
                try {
                    action.invoke();
                } catch (e) {}
        }
        destroy();
    }
}
