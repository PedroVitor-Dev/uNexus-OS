import QtQuick 2.15

Item {
    id: notificationCenter
    anchors.fill: parent
    z: 120

    property var notifications: []
    property int maxVisibleNotifications: 4
    property int timeoutMs: 7000
    property bool notificationsEnabled: true
    property double silencedUntil: 0
    property bool queueExpanded: false
    property int clockTick: 0
    readonly property bool silenced: clockTick >= 0 && Date.now() < silencedUntil
    readonly property int queuedCount: Math.max(0, notifications.length - maxVisibleNotifications)
    readonly property int visibleCount: queueExpanded ? notifications.length : Math.min(notifications.length, maxVisibleNotifications)

    onNotificationsEnabledChanged: if (!notificationsEnabled) clearAll()
    onSilencedUntilChanged: userSettings.notificationSilencedUntil = silencedUntil

    Component.onCompleted: silencedUntil = userSettings.notificationSilencedUntil

    function nextId() {
        return Date.now() + Math.floor(Math.random() * 100000)
    }

    function send(title, message, icon, actionLabel, actionCallback) {
        if (!notificationsEnabled || silenced)
            return false

        var n = {
            id: nextId(),
            title: title,
            message: message,
            actionLabel: actionLabel || root.tr("Open"),
            actionCallback: actionCallback || null,
            hasAction: actionCallback !== undefined && actionCallback !== null,
            icon: icon || "INFO",
            timeoutMs: Math.max(3000, timeoutMs)
        }

        var list = notifications.slice()
        list.unshift(n)
        notifications = list
        return true
    }

    function dismissById(id) {
        var list = notifications.slice()
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list.splice(i, 1)
                notifications = list
                if (notifications.length <= maxVisibleNotifications)
                    queueExpanded = false
                return
            }
        }
    }

    function clearAll() {
        notifications = []
        queueExpanded = false
    }

    function openNotification(notification) {
        dismissById(notification.id)
        if (notification.actionCallback)
            notification.actionCallback()
    }

    function silenceForOneHour() {
        silencedUntil = Date.now() + 60 * 60 * 1000
        clearAll()
    }

    function unsilence() {
        silencedUntil = 0
    }

    function silenceRemainingLabel() {
        var remainingMs = Math.max(0, silencedUntil - Date.now())
        var minutes = Math.ceil(remainingMs / 60000)
        return root.tr("Notifications silenced") + " - " + minutes + "m"
    }

    function visibleNotifications() {
        return notifications.slice(0, visibleCount)
    }

    Timer {
        interval: 1000
        repeat: true
        running: notificationCenter.silenced
        onTriggered: notificationCenter.clockTick++
    }

    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: root.spaceMd
        spacing: root.spaceSm

        LiquidGlass {
            width: 300
            height: visible ? queueHeaderColumn.height + root.spaceMd : 0
            radius: root.radiusMd
            tintColor: root.surfaceBase
            accentColor: root.themeAccent
            borderColor: root.borderSubtle
            materialOpacity: 0.72
            borderOpacity: 0.48
            highlightOpacity: 0.12
            depth: 0.28
            visible: notificationCenter.notifications.length > 0 || notificationCenter.silenced
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: root.motionQuick; easing.type: Easing.OutCubic } }

            Column {
                id: queueHeaderColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: root.spaceSm
                spacing: 2

                Row {
                    width: parent.width
                    spacing: root.spaceSm

                    Text {
                        text: root.tr("Notification queue")
                        color: root.textPrimary
                        font.pixelSize: root.textSmall
                        font.family: root.uiFont
                        font.bold: true
                        width: parent.width - queueCountBadge.width - root.spaceSm
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: queueCountBadge
                        width: queueCountText.width + root.spaceSm
                        height: 20
                        radius: root.radiusSm
                        color: root.surfaceRaised
                        border.color: root.themeAccent
                        border.width: 1

                        Text {
                            id: queueCountText
                            anchors.centerIn: parent
                            text: notificationCenter.silenced ? root.tr("Silenced") : notificationCenter.notifications.length
                            color: root.themeAccent
                            font.pixelSize: root.textTiny
                            font.family: root.uiFont
                            font.bold: true
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: notificationCenter.silenced ? notificationCenter.silenceRemainingLabel() :
                          (notificationCenter.queuedCount > 0 ? ("+" + notificationCenter.queuedCount + " " + root.tr("queued") + " - " + root.tr("Click to expand")) :
                           root.tr("Open, dismiss or silence alerts."))
                    color: root.textMuted
                    font.pixelSize: root.textTiny
                    font.family: root.uiFont
                    elide: Text.ElideRight
                }

                Row {
                    width: parent.width
                    spacing: root.spaceXs
                    visible: notificationCenter.notifications.length > 0 || notificationCenter.silenced
                    height: visible ? 26 : 0

                    NotificationActionButton {
                        width: Math.floor((parent.width - root.spaceXs) / 2)
                        label: notificationCenter.queueExpanded ? root.tr("Collapse") : root.tr("Show queue")
                        muted: notificationCenter.notifications.length <= notificationCenter.maxVisibleNotifications
                        onClicked: notificationCenter.queueExpanded = !notificationCenter.queueExpanded
                    }

                    NotificationActionButton {
                        width: parent.width - Math.floor((parent.width - root.spaceXs) / 2) - root.spaceXs
                        label: notificationCenter.silenced ? root.tr("Unsilence") : root.tr("Clear")
                        accent: notificationCenter.silenced
                        muted: !notificationCenter.silenced && notificationCenter.notifications.length === 0
                        onClicked: notificationCenter.silenced ? notificationCenter.unsilence() : notificationCenter.clearAll()
                    }
                }

            }
        }

        Repeater {
            model: notificationCenter.visibleNotifications()

            delegate: LiquidGlass {
                id: notifItem
                width: 300
                height: notifColumn.height + root.spaceXl
                radius: root.radiusLg
                tintColor: root.surfaceBase
                accentColor: root.themeAccent
                borderColor: root.borderSubtle
                materialOpacity: 0.80
                borderOpacity: 0.52
                highlightOpacity: 0.16
                depth: 0.42
                anchors.right: parent ? parent.right : undefined
                opacity: 0.0

                NumberAnimation on opacity {
                    from: 0.0
                    to: 1.0
                    duration: root.motionEntrance
                    easing.type: Easing.OutCubic
                    running: true
                }

                NumberAnimation on anchors.rightMargin {
                    from: -320
                    to: 0
                    duration: root.motionEntrance
                    easing.type: Easing.OutCubic
                    running: true
                }

                Column {
                    id: notifColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.spaceMd
                    spacing: root.spaceXs

                    Row {
                        spacing: root.spaceSm
                        width: parent.width

                        Text {
                            text: modelData.icon
                            color: root.themeAccent
                            font.pixelSize: root.textLg
                            font.family: root.uiFont
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.title
                            color: root.textPrimary
                            font.pixelSize: root.textBody
                            font.family: root.uiFont
                            font.bold: true
                            opacity: 0.95
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 60
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: modelData.message
                        color: root.textSecondary
                        font.pixelSize: root.textSmall
                        font.family: root.uiFont
                        width: parent.width
                        wrapMode: Text.WordWrap
                        opacity: 0.8
                    }

                    Row {
                        width: parent.width
                        spacing: root.spaceXs

                        NotificationActionButton {
                            width: Math.floor((parent.width - root.spaceXs * 2) / 3)
                            label: root.tr("Open")
                            muted: !modelData.hasAction
                            onClicked: notificationCenter.openNotification(modelData)
                        }

                        NotificationActionButton {
                            width: Math.floor((parent.width - root.spaceXs * 2) / 3)
                            label: root.tr("Dismiss")
                            onClicked: notificationCenter.dismissById(modelData.id)
                        }

                        NotificationActionButton {
                            width: parent.width - Math.floor((parent.width - root.spaceXs * 2) / 3) * 2 - root.spaceXs * 2
                            label: root.tr("Silence 1h")
                            accent: true
                            onClicked: notificationCenter.silenceForOneHour()
                        }
                    }
                }

                Timer {
                    interval: modelData.timeoutMs
                    running: modelData.timeoutMs > 0
                    onTriggered: notificationCenter.dismissById(modelData.id)
                }
            }
        }
    }

    component NotificationActionButton: Rectangle {
        id: actionButton
        property string label: ""
        property bool accent: false
        property bool muted: false
        signal clicked()

        height: 26
        radius: root.radiusSm
        opacity: muted ? 0.45 : 1.0
        color: actionMouse.containsMouse && !muted ? root.surfaceHover : root.surfaceRaised
        border.color: accent ? root.themeAccent : root.borderMuted
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: actionButton.label
            color: actionButton.accent ? root.themeAccent : root.textPrimary
            font.pixelSize: root.textTiny
            font.family: root.uiFont
            font.bold: true
            elide: Text.ElideRight
            width: parent.width - root.spaceXs
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            enabled: !actionButton.muted
            hoverEnabled: enabled
            onClicked: actionButton.clicked()
        }
    }
}
