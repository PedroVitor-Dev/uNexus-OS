import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "PED OS Shell"
    color: "#0a0a0a"

    // Wallpaper
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#050810" }
            GradientStop { position: 0.5; color: "#0a0f1e" }
            GradientStop { position: 1.0; color: "#060d18" }
        }

        Rectangle {
            width: 600
            height: 600
            radius: 300
            x: -150
            y: 80
            color: "transparent"
            border.color: "#0d2a4a"
            border.width: 1
            opacity: 0.4
        }

        Rectangle {
            width: 400
            height: 400
            radius: 200
            x: parent.width - 250
            y: parent.height - 300
            color: "transparent"
            border.color: "#0d2a4a"
            border.width: 1
            opacity: 0.3
        }

        Rectangle {
            width: 300
            height: 300
            radius: 150
            x: -80
            y: 200
            color: "#051428"
            opacity: 0.6
        }

        Rectangle {
            width: 250
            height: 250
            radius: 125
            x: parent.width - 180
            y: 100
            color: "#04111f"
            opacity: 0.5
        }

        Rectangle {
            width: parent.width
            height: 1
            y: parent.height * 0.6
            color: "#4d9eff"
            opacity: 0.04
        }

        Rectangle {
            width: parent.width
            height: 1
            y: parent.height * 0.4
            color: "#4d9eff"
            opacity: 0.03
        }
    }

    // Top bar
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32
        color: "#111111"
        opacity: 0.0

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: logoText.width + 16
            height: 22
            radius: 6
            color: logoMouse.containsMouse ? "#1e2d45" : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                id: logoText
                anchors.centerIn: parent
                text: "PED OS"
                color: "#ffffff"
                font.pixelSize: 12
                font.letterSpacing: 4
                opacity: 0.7
            }

            MouseArea {
                id: logoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (pedLauncher.visible) {
                        pedLauncher.hide()
                    } else {
                        pedLauncher.show()
                    }
                }
            }
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

    // Center logo
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

    // Dock container
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: dockRow.width + 24
        height: 90

        Rectangle {
            id: globalTooltip
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: dockBg.top
            anchors.bottomMargin: 8
            height: 22
            width: globalTooltipText.width + 16
            radius: 8
            color: "#1e1e1e"
            opacity: 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Text {
                id: globalTooltipText
                anchors.centerIn: parent
                text: ""
                color: "#ffffff"
                font.pixelSize: 12
                opacity: 0.9
            }
        }

        Rectangle {
            id: dockBg
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 60
            radius: 16
            color: "#1a1a1a"
            opacity: 0.0

            SequentialAnimation on opacity {
                running: true
                PauseAnimation { duration: 400 }
                NumberAnimation { from: 0.0; to: 0.85; duration: 1000; easing.type: Easing.OutCubic }
            }
        }

        Row {
            id: dockRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: [
                    { icon: "🗂", label: "Files" },
                    { icon: "🌐", label: "Browser" },
                    { icon: "⚙️", label: "Settings" },
                    { icon: "🖥", label: "Terminal" },
                    { icon: "🏪", label: "Store" }
                ]

                delegate: Rectangle {
                    id: dockItem
                    width: dockItemMouse.containsMouse ? 52 : 44
                    height: dockItemMouse.containsMouse ? 52 : 44
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    radius: 12
                    color: dockItemMouse.containsMouse ? "#2a2a2a" : "transparent"

                    property bool active: false

                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    transform: Translate {
                        id: bounceTranslate
                        y: 0
                    }

                    SequentialAnimation {
                        id: bounceAnim
                        NumberAnimation { target: bounceTranslate; property: "y"; to: -16; duration: 120; easing.type: Easing.OutCubic }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: 0;   duration: 120; easing.type: Easing.InBounce }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: -8;  duration: 80;  easing.type: Easing.OutCubic }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: 0;   duration: 80;  easing.type: Easing.InBounce }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: dockItemMouse.containsMouse ? 28 : 24

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    Rectangle {
                        width: dockItem.active ? 6 : 0
                        height: 3
                        radius: 2
                        color: "#4d9eff"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        id: dockItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton

                        onClicked: {
                            dockItem.active = !dockItem.active
                            bounceAnim.start()
                        }

                        onContainsMouseChanged: {
                            if (containsMouse) {
                                globalTooltipText.text = modelData.label
                                globalTooltip.opacity = 1.0
                            } else {
                                globalTooltip.opacity = 0.0
                            }
                        }
                    }
                }
            }
        }
    }

    // Launcher
    Launcher {
        id: pedLauncher
        anchors.fill: parent
        z: 100
    }
    LoginScreen {
        id: loginScreen
        anchors.fill: parent
        z: 200
        onLoginSuccess: loginScreen.destroy()
    }
    ContextMenu {
        id: contextMenu
        anchors.fill: parent
        z: 150
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: 1
        onClicked: {
            if (mouse.button === Qt.RightButton)
                contextMenu.show(mouse.x, mouse.y)
        }
    }
    NotificationCenter {
        id: notifCenter
        anchors.fill: parent
        z: 120
    }

    // Teste — notificação ao fazer login
    Connections {
        target: loginScreen
        function onLoginSuccess() {
            notifCenter.send("Welcome back!", "PED OS is ready.", "👋")
        }
    }
}