import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "PED OS Shell"
    color: "#0a0a0a"

    // Wallpaper gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0a0a0a" }
            GradientStop { position: 1.0; color: "#0d1117" }
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

        Text {
            anchors.centerIn: parent
            text: "PED OS"
            color: "#ffffff"
            font.pixelSize: 13
            font.letterSpacing: 4
            opacity: 0.7
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
        anchors.verticalCenterOffset: 20

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

        NumberAnimation on opacity {
            from: 0.0
            to: 1.0
            duration: 1000
            easing.type: Easing.OutCubic
            running: true
        }

        NumberAnimation on anchors.verticalCenterOffset {
            from: 20
            to: 0
            duration: 1000
            easing.type: Easing.OutCubic
            running: true
        }
    }

    // Dock
    Rectangle {
        id: dock
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 40
        width: dockRow.width + 24
        height: 56
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

                delegate: Rectangle {
                    width: 44
                    height: 44
                    radius: 10
                    color: dockItemMouse.containsMouse ? "#2a2a2a" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: 24
                    }

                    MouseArea {
                        id: dockItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}