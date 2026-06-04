import QtQuick 2.15

Item {
    id: contextMenu
    visible: false
    z: 150

    property int menuX: 0
    property int menuY: 0

    signal openFilesRequested()
    signal openSettingsRequested()
    signal openGameSettingsRequested()
    signal openTerminalRequested()
    signal copyGameOptionsRequested()
    signal refreshShellRequested()

    function show(x, y) {
        hideAnim.stop()
        menuX = x
        menuY = y

        if (menuX + menuRect.width > parent.width)
            menuX = parent.width - menuRect.width - root.spaceSm
        if (menuY + menuRect.height > parent.height)
            menuY = parent.height - menuRect.height - root.spaceSm

        menuRect.opacity = 0.0
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
        duration: root.motionBase
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: menuRect
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: root.motionQuick
        }
        ScriptAction { script: contextMenu.visible = false }
    }

    Rectangle {
        id: menuShadow
        x: menuRect.x + root.spaceXs
        y: menuRect.y + root.spaceSm
        width: menuRect.width
        height: menuRect.height
        radius: menuRect.radius
        color: root.shadowSoft
        opacity: menuRect.opacity * 0.35
        visible: menuRect.visible
    }

    Rectangle {
        id: menuRect
        x: contextMenu.menuX
        y: contextMenu.menuY
        width: 210
        height: menuColumn.height + root.spaceLg
        radius: root.radiusLg
        color: root.surfaceBase
        border.color: root.borderSubtle
        border.width: root.borderHairline
        opacity: 0.0

        Column {
            id: menuColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: root.spaceSm
            spacing: 2
            padding: root.radiusSm

            Repeater {
                model: [
                    { action: "terminal", label: "Open Terminal" },
                    { action: "files", label: "Open Files" },
                    { action: "settings", label: "Settings" },
                    { action: "game-settings", label: "Game Settings" },
                    { action: "copy-game-options", label: "Copy Game Options" },
                    { action: "refresh", label: "Refresh Shell" }
                ]

                delegate: Rectangle {
                    width: menuColumn.width - root.spaceMd
                    height: 36
                    radius: root.radiusSm
                    color: itemMouse.containsMouse ? root.surfaceHover : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: root.motionQuick }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: root.spaceMd
                        anchors.right: parent.right
                        anchors.rightMargin: root.spaceMd
                        spacing: root.spaceMd

                        MenuIcon {
                            width: 18
                            height: 18
                            action: modelData.action
                            accentColor: root.themeAccent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width: parent.width - 18 - root.spaceMd
                            text: root.tr(modelData.label)
                            color: root.textPrimary
                            font.pixelSize: root.textBody
                            font.family: root.uiFont
                            opacity: 0.85
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "terminal")
                                contextMenu.openTerminalRequested()
                            else if (modelData.action === "files")
                                contextMenu.openFilesRequested()
                            else if (modelData.action === "settings")
                                contextMenu.openSettingsRequested()
                            else if (modelData.action === "game-settings")
                                contextMenu.openGameSettingsRequested()
                            else if (modelData.action === "copy-game-options")
                                contextMenu.copyGameOptionsRequested()
                            else if (modelData.action === "refresh")
                                contextMenu.refreshShellRequested()

                            contextMenu.hide()
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: contextMenu.hide()
    }

    component MenuIcon: Canvas {
        id: menuIcon
        property string action: ""
        property color accentColor: "#4d9eff"

        onActionChanged: requestPaint()
        onAccentColorChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.lineWidth = 1.6
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.strokeStyle = accentColor
            ctx.fillStyle = "transparent"

            if (action === "terminal") {
                ctx.strokeRect(2.5, 4, 13, 10)
                ctx.beginPath()
                ctx.moveTo(5, 7)
                ctx.lineTo(7.5, 9)
                ctx.lineTo(5, 11)
                ctx.moveTo(9, 11.5)
                ctx.lineTo(13, 11.5)
                ctx.stroke()
            } else if (action === "files") {
                ctx.beginPath()
                ctx.moveTo(2.5, 6)
                ctx.lineTo(7, 6)
                ctx.lineTo(8.5, 8)
                ctx.lineTo(15.5, 8)
                ctx.lineTo(15.5, 14)
                ctx.lineTo(2.5, 14)
                ctx.closePath()
                ctx.stroke()
            } else if (action === "settings") {
                ctx.beginPath()
                ctx.arc(9, 9, 3, 0, Math.PI * 2)
                ctx.stroke()
                for (var i = 0; i < 6; i++) {
                    var angle = i * Math.PI / 3
                    ctx.beginPath()
                    ctx.moveTo(9 + Math.cos(angle) * 5, 9 + Math.sin(angle) * 5)
                    ctx.lineTo(9 + Math.cos(angle) * 7, 9 + Math.sin(angle) * 7)
                    ctx.stroke()
                }
            } else if (action === "game-settings") {
                ctx.strokeRect(3, 6, 12, 8)
                ctx.beginPath()
                ctx.moveTo(6, 10)
                ctx.lineTo(9, 10)
                ctx.moveTo(7.5, 8.5)
                ctx.lineTo(7.5, 11.5)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(12, 9, 0.8, 0, Math.PI * 2)
                ctx.arc(13.5, 11.5, 0.8, 0, Math.PI * 2)
                ctx.stroke()
            } else if (action === "copy-game-options") {
                ctx.strokeRect(5, 4, 8, 10)
                ctx.strokeRect(3, 6, 8, 10)
            } else if (action === "refresh") {
                ctx.beginPath()
                ctx.arc(9, 9, 5, 0.4, Math.PI * 1.7)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(13.4, 5.5)
                ctx.lineTo(14.5, 2.8)
                ctx.lineTo(16, 5.2)
                ctx.stroke()
            }
        }
    }
}
