import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "PED OS Shell"
    color: "#0a0a0a"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0a0a0a" }
            GradientStop { position: 1.0; color: "#0d1117" }
        }
    }

    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32
        color: "#111111"
        opacity: 0.0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "PED OS"
            color: "#ffffff"
            font.pixelSize: 12
            font.letterSpacing: 4
            opacity: 0.7
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: "#ffffff"
            font.pixelSize: 13
            opacity: 0.8

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }

            Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }

        Text {
            id: dateText
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 12
            opacity: 0.5

            Timer {
                interval: 60000
                running: true
                repeat: true
                onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
            }

            Component.onCompleted: text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
        }

        NumberAnimation on opacity {
            from: 0.0
            to: 0.9
            duration: 800
            easing.type: Easing.OutCubic
            running: true
        }
    }

    Column {
        id: centerLogo
        anchors.centerIn: parent
        spacing: 12
        opacity: 0.0

        SequentialAnimation on opacity {
            running: true
            NumberAnimation { from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PED OS"
            color: "#ffffff"
            font.pixelSize: 48
            font.letterSpacing: 8
            opacity: 0.9
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "the OS should disappear."
            color: "#4d9eff"
            font.pixelSize: 14
            font.letterSpacing: 2
            opacity: 0.7
        }
    }

    Rectangle {
        id: dock
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 40
        width: dockRow.width + 24
        height: 60
        radius: 16
        color: "#1a1a1a"
        opacity: 0.0

        SequentialAnimation on opacity {
            running: true
            PauseAnimation { duration: 400 }
            NumberAnimation { from: 0.0; to: 0.85; duration: 1000; easing.type: Easing.OutCubic }
        }

        SequentialAnimation on anchors.bottomMargin {
            running: true
            PauseAnimation { duration: 400 }
            NumberAnimation { from: 40; to: 12; duration: 1000; easing.type: Easing.OutCubic }
        }

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: [
                    { icon: "🗂", label: "Files" },
                    { icon: "🌐", label: "Browser" },
                    { icon: "⚙️", label: "Settings" },
                    { icon: "🖥", label: "Terminal" },
                    { icon: "🏪", label: "Store" }
                ]

                delegate: Item {
                    width: 52
                    height: 60
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

                    Rectangle {
                        id: dockItem
                        width: dockItemMouse.containsMouse ? 52 : 44
                        height: dockItemMouse.containsMouse ? 52 : 44
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: tooltip.top
                        anchors.bottomMargin: 4
                        radius: 12
                        color: dockItemMouse.containsMouse ? "#2a2a2a" : "transparent"

                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                        Behavior on height {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: dockItemMouse.containsMouse ? 28 : 24

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            id: dockItemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }

                    Rectangle {
                        id: tooltip
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        height: 68
                        width: tooltipText.width + 12
                        radius: 6
                        color: "#222222"
                        opacity: dockItemMouse.containsMouse ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: "#ffffff"
                            font.pixelSize: 11
                            opacity: 0.8
                        }
                    }
                }
            }
        }
    }
}