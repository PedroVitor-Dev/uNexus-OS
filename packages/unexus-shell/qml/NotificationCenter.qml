import QtQuick 2.15

Item {
    id: notificationCenter
    anchors.fill: parent
    z: 120

    property var notifications: []
    property int maxNotifications: 4
    property bool notificationsEnabled: true

    function send(title, message, icon, actionLabel, actionCallback) {
        if (!notificationsEnabled)
            return
        var n = {
            id: Date.now(),
            title: title,
            message: message,
            actionLabel: actionLabel || "",
            actionCallback: actionCallback || null,
            icon: icon || "🔔"
        }
        var list = notifications.slice()
        list.unshift(n)
        if (list.length > maxNotifications)
            list = list.slice(0, maxNotifications)
        notifications = list
    }

    onNotificationsEnabledChanged: if (!notificationsEnabled) notifications = []

    function dismiss(index) {
        var list = notifications.slice()
        list.splice(index, 1)
        notifications = list
    }

    // Stack de notificações
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: root.spaceMd
        spacing: root.spaceSm

        Repeater {
            model: notificationCenter.notifications

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
                            font.pixelSize: root.textLg
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.title
                            color: root.textPrimary
                            font.pixelSize: root.textBody
                            font.bold: true
                            opacity: 0.95
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 60
                            elide: Text.ElideRight
                        }

                        // Botão fechar
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: closeMouse.containsMouse ? root.surfaceStrongHover : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: root.textPrimary
                                font.pixelSize: root.textTiny
                                opacity: 0.6
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: notificationCenter.dismiss(index)
                            }
                        }
                    }

                    Text {
                        text: modelData.message
                        color: root.textSecondary
                        font.pixelSize: root.textSmall
                        width: parent.width
                        wrapMode: Text.WordWrap
                        opacity: 0.8
                    }

                    Rectangle {
                        visible: modelData.actionLabel && modelData.actionLabel.length > 0
                        width: actionText.width + root.spaceLg
                        height: visible ? 26 : 0
                        radius: root.radiusSm
                        color: actionMouse.containsMouse ? root.surfaceHover : root.surfaceRaised
                        border.color: root.themeAccent
                        border.width: 1

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.actionLabel || ""
                            color: "#b7ddff"
                            font.pixelSize: root.textTiny
                            font.family: root.uiFont
                            font.bold: true
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var callback = modelData.actionCallback
                                notificationCenter.dismiss(index)
                                if (callback)
                                    callback()
                            }
                        }
                    }
                }

                // Auto dismiss depois de 4s
                Timer {
                    interval: modelData.actionLabel && modelData.actionLabel.length > 0 ? 7000 : 4000
                    running: true
                    onTriggered: notificationCenter.dismiss(index)
                }
            }
        }
    }
}
