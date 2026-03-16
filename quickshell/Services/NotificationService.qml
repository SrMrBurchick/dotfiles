pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    readonly property list<RawNotification> list: []
    readonly property list<RawNotification> popups: list.filter(n => n.popup)

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            root.list.push(notifComp.createObject(root, {
                popup: true,
                notification: notif
            }));
        }
    }

    component RawNotification: QtObject {
        id: notif

        property bool popup
        required property Notification notification
        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property int urgency: notification.urgency
        readonly property list<NotificationAction> actions: notification.actions

        readonly property Connections conn: Connections {
            target: notif.notification.Retainable

            function onDropped(): void {
                root.list.splice(root.list.indexOf(notif), 1);
            }

            function onAboutToDestroy(): void {
                notif.destroy();
            }
        }
    }

    Component {
        id: notifComp

        RawNotification {}
    }
}
