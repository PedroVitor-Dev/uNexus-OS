import QtQuick 2.15

Item {
    id: contextMenu
    visible: false
    z: 150

    property int menuX: 0
    property int menuY: 0

    function show(x, y) {
        menuX = x
        menuY = y

        // Ajusta pra não sair da tela
        if (menuX + menuRect.width > parent.width)
            menuX = parent.width - menuRect.width - 8
        if (menuY + menuRect.height > parent.height)
            menuY = parent.height - menuRect.height - 8

        visible = true
        showAnim.start()
    }

    function hide() {
        hideAnim.start()
    }

    NumberAnimation {
        id: showAnim
        target: menuRect
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 150
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: menuRect
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 100
        }
        ScriptAction { script: contextMenu.visible = false }
    }

    Rectangle {
        id: menuRect
        x: contextMenu.menuX
        y: contextMenu.menuY
        width: 200
        height: menuColumn.height + 16
        radius: 10
        color: "#0e1520"
        border.color: "#1e2d45"
        border.width: 1
        opacity: 0.0

        Column {
            id: menuColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8
            spacing: 2
            padding: 6

            Repeater {
                model: [
                    { icon: "🖼", label: "Change Wallpaper" },
                    { icon: "⚙️", label: "Settings" },
                    { icon: "📋", label: "Paste" },
                    { icon: "🔄", label: "Refresh" },
                    { icon: "🖥", label: "Open Terminal" }
                ]

                delegate: Rectangle {
                    width: menuColumn.width - 12
                    height: 36
                    radius: 6
                    color: itemMouse.containsMouse ? "#1e2d45" : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 10

                        Text {
                            text: modelData.icon
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.label
                            color: "#ffffff"
                            font.pixelSize: 13
                            opacity: 0.85
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: contextMenu.hide()
                    }
                }
            }
        }
    }

    // Fechar ao clicar fora
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: contextMenu.hide()
    }
}