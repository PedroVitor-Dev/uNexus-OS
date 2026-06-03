import QtQuick 2.15

Item {
    id: notificationCenter
    anchors.fill: parent
    z: 120

    property var notifications: []
    property int maxNotifications: 4

    function send(title, message, icon) {
        var n = {
            id: Date.now(),
            title: title,
            message: message,
            icon: icon || "🔔"
        }
        var list = notifications.slice()
        list.unshift(n)
        if (list.length > maxNotifications)
            list = list.slice(0, maxNotifications)
        notifications = list
    }

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
        anchors.rightMargin: 12
        spacing: 8

        Repeater {
            model: notificationCenter.notifications

            delegate: Rectangle {
                id: notifItem
                width: 300
                height: notifColumn.height + 20
                radius: 12
                color: "#0e1520"
                border.color: "#1e2d45"
                border.width: 1
                anchors.right: parent ? parent.right : undefined
                opacity: 0.0

                NumberAnimation on opacity {
                    from: 0.0
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutCubic
                    running: true
                }

                NumberAnimation on anchors.rightMargin {
                    from: -320
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                    running: true
                }

                Column {
                    id: notifColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    Row {
                        spacing: 8
                        width: parent.width

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.title
                            color: "#ffffff"
                            font.pixelSize: 13
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
                            color: closeMouse.containsMouse ? "#2a3a55" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#ffffff"
                                font.pixelSize: 10
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
                        color: "#aaaaaa"
                        font.pixelSize: 12
                        width: parent.width
                        wrapMode: Text.WordWrap
                        opacity: 0.8
                    }
                }

                // Auto dismiss depois de 4s
                Timer {
                    interval: 4000
                    running: true
                    onTriggered: notificationCenter.dismiss(index)
                }
            }
        }
    }
}