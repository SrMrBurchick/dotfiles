pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Controls

import "root:./Components/Notification"

Singleton {
    id: root

    readonly property list<RawNotification> list: []
    readonly property list<RawNotification> popups: list.filter(n => n.popup)

    property var activeScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            console.log("Notification received:", notif.appName, notif.summary);
            notif.tracked = true;

            const rawNotif = notifComp.createObject(root, {
                popup: true,
                notification: notif
            });
            root.list.push(rawNotif);
        }
    }

    Connections {
        target: Hyprland

        function onFocusedMonitorChanged(): void {
            const mon = Hyprland.focusedMonitor;
            if (mon) {
                root.activeScreen = Quickshell.screens.filter(s => s.name === mon.name)[0] || null;
            }
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

    Component {
        id: popupComp

        NotificationPopup {
        }
    }
}
