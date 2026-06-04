import QtQuick 2.15

Rectangle {
    id: dockButton

    property var app
    property bool leftSide: true
    property string dockSide: "left"
    property color accentColor: "#4d9eff"
    property string fontFamily: "Exo 2"
    property int dockStateVersion: 0
    property int localeVersion: 0
    property bool dockExpanded: true
    property bool hovered: false
    property string appStateOverride: ""
    property string resolvedIcon: app.iconNames ? appLauncher.findIcon(app.iconNames) : ""
    property string fallbackIcon: app.fallbackIcon || app.icon || "app"
    property string appState: {
        dockStateVersion
        var override = appStateOverride

        // App interno: estado vem inteiramente do painel, nunca consulta processo/janela
        if (app.internalAction && app.internalAction.length > 0)
            return override.length > 0 ? override : "closed"

        // App externo com override explícito
        if (override === "active" || override === "minimized" || override === "running")
            return override

        var hasWindowClasses = app.windowClasses && app.windowClasses.length > 0
        var hasProcessNames = app.processNames && app.processNames.length > 0

        if (hasWindowClasses && appLauncher.isWindowHidden(app.windowClasses))
            return "minimized"

        if (hasWindowClasses && appLauncher.isWindowOpen(app.windowClasses))
            return "active"

        if (hasProcessNames && appLauncher.isProcessRunning(app.processNames))
            return "running"

        return "closed"
    }
    property bool active: appState === "active" || appState === "running"
    property bool minimized: appState === "minimized"
    property bool closed: appState === "closed"

    signal launchRequested(var app)
    signal actionMenuRequested(var app, var point, string side)

    width: hovered ? 56 : 48
    height: hovered ? 56 : 48
    radius: root.radiusXl
    color: hovered ? root.surfaceHover : "transparent"
    scale: hovered ? 1.025 : 1.0

    Behavior on width { NumberAnimation { duration: root.motionBase; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: root.motionBase; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: root.motionQuick; easing.type: Easing.OutCubic } }

    transform: Translate { id: dockBounce; y: 0 }

    onMinimizedChanged: {
        if (!minimized)
            minimizedPill.scale = 1.0
    }

    onClosedChanged: {
        if (closed) {
            hovered = false
            minimizedPill.scale = 1.0
        }
    }

    onDockExpandedChanged: {
        if (!dockExpanded)
            hovered = false
    }

    SequentialAnimation {
        id: dockBounceAnim
        NumberAnimation { target: dockBounce; property: "y"; to: -10; duration: root.motionQuick; easing.type: Easing.OutCubic }
        NumberAnimation { target: dockBounce; property: "y"; to: 0; duration: root.motionQuick; easing.type: Easing.InBounce }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: dockButton.accentColor
        opacity: dockButton.active && !dockButton.closed ? 0.08 : 0.0

        Behavior on opacity { NumberAnimation { duration: root.motionExpressive } }
    }

    Image {
        id: appIcon
        anchors.centerIn: parent
        width: dockButton.hovered ? 34 : 30
        height: width
        source: dockButton.resolvedIcon
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: status === Image.Ready
    }

    Item {
        id: fallbackArtwork
        anchors.centerIn: parent
        width: dockButton.hovered ? 34 : 30
        height: width
        visible: appIcon.status !== Image.Ready

        Rectangle {
            visible: dockButton.fallbackIcon === "steam"
            anchors.centerIn: parent
            width: parent.width * 0.84
            height: width
            radius: width / 2
            color: "transparent"
            border.color: "#ffffff"
            border.width: 2
            opacity: 0.92

            Rectangle {
                width: parent.width * 0.26
                height: width
                radius: width / 2
                color: "#ffffff"
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.16
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.16
            }

            Rectangle {
                width: parent.width * 0.38
                height: 2
                rotation: -28
                color: "#ffffff"
                anchors.centerIn: parent
            }

            Rectangle {
                width: parent.width * 0.3
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#ffffff"
                border.width: 2
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.1
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.12
            }
        }

        Canvas {
            id: lineIcon
            anchors.fill: parent
            visible: dockButton.fallbackIcon !== "steam"
            opacity: 0.94

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#ffffff"
                ctx.fillStyle = "#ffffff"
                ctx.lineWidth = Math.max(2, width * 0.075)
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                if (dockButton.fallbackIcon === "lutris") {
                    ctx.beginPath()
                    ctx.arc(width * 0.5, height * 0.5, width * 0.32, 0, Math.PI * 2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width * 0.32, height * 0.38)
                    ctx.lineTo(width * 0.68, height * 0.62)
                    ctx.moveTo(width * 0.68, height * 0.38)
                    ctx.lineTo(width * 0.32, height * 0.62)
                    ctx.stroke()
                } else if (dockButton.fallbackIcon === "heroic") {
                    ctx.beginPath()
                    ctx.moveTo(width * 0.5, height * 0.12)
                    ctx.lineTo(width * 0.78, height * 0.38)
                    ctx.lineTo(width * 0.62, height * 0.82)
                    ctx.lineTo(width * 0.38, height * 0.82)
                    ctx.lineTo(width * 0.22, height * 0.38)
                    ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width * 0.38, height * 0.45)
                    ctx.lineTo(width * 0.62, height * 0.45)
                    ctx.moveTo(width * 0.5, height * 0.25)
                    ctx.lineTo(width * 0.5, height * 0.72)
                    ctx.stroke()
                } else if (dockButton.fallbackIcon === "bottles") {
                    ctx.beginPath()
                    ctx.moveTo(width * 0.42, height * 0.12)
                    ctx.lineTo(width * 0.58, height * 0.12)
                    ctx.lineTo(width * 0.58, height * 0.34)
                    ctx.quadraticCurveTo(width * 0.74, height * 0.46, width * 0.72, height * 0.76)
                    ctx.quadraticCurveTo(width * 0.72, height * 0.9, width * 0.5, height * 0.9)
                    ctx.quadraticCurveTo(width * 0.28, height * 0.9, width * 0.28, height * 0.76)
                    ctx.quadraticCurveTo(width * 0.26, height * 0.46, width * 0.42, height * 0.34)
                    ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width * 0.35, height * 0.62)
                    ctx.lineTo(width * 0.65, height * 0.62)
                    ctx.stroke()
                } else if (dockButton.fallbackIcon === "game-settings") {
                    var x = width * 0.16
                    var y = height * 0.32
                    var w = width * 0.68
                    var h = height * 0.38
                    var r = width * 0.14
                    ctx.beginPath()
                    ctx.moveTo(x + r, y)
                    ctx.lineTo(x + w - r, y)
                    ctx.quadraticCurveTo(x + w, y, x + w, y + r)
                    ctx.lineTo(x + w, y + h - r)
                    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
                    ctx.lineTo(x + r, y + h)
                    ctx.quadraticCurveTo(x, y + h, x, y + h - r)
                    ctx.lineTo(x, y + r)
                    ctx.quadraticCurveTo(x, y, x + r, y)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width * 0.32, height * 0.51)
                    ctx.lineTo(width * 0.46, height * 0.51)
                    ctx.moveTo(width * 0.39, height * 0.44)
                    ctx.lineTo(width * 0.39, height * 0.58)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(width * 0.62, height * 0.49, width * 0.035, 0, Math.PI * 2)
                    ctx.arc(width * 0.72, height * 0.55, width * 0.035, 0, Math.PI * 2)
                    ctx.fill()
                } else if (dockButton.fallbackIcon === "files") {
                    ctx.beginPath()
                    ctx.moveTo(width * 0.16, height * 0.28)
                    ctx.lineTo(width * 0.38, height * 0.28)
                    ctx.lineTo(width * 0.46, height * 0.38)
                    ctx.lineTo(width * 0.84, height * 0.38)
                    ctx.lineTo(width * 0.84, height * 0.78)
                    ctx.lineTo(width * 0.16, height * 0.78)
                    ctx.closePath()
                    ctx.stroke()
                } else if (dockButton.fallbackIcon === "settings") {
                    ctx.beginPath()
                    ctx.arc(width * 0.5, height * 0.5, width * 0.25, 0, Math.PI * 2)
                    ctx.stroke()
                    for (var i = 0; i < 8; i++) {
                        var a = i * Math.PI / 4
                        ctx.beginPath()
                        ctx.moveTo(width * 0.5 + Math.cos(a) * width * 0.32, height * 0.5 + Math.sin(a) * width * 0.32)
                        ctx.lineTo(width * 0.5 + Math.cos(a) * width * 0.43, height * 0.5 + Math.sin(a) * width * 0.43)
                        ctx.stroke()
                    }
                } else if (dockButton.fallbackIcon === "terminal") {
                    ctx.beginPath()
                    ctx.moveTo(width * 0.2, height * 0.3)
                    ctx.lineTo(width * 0.4, height * 0.5)
                    ctx.lineTo(width * 0.2, height * 0.7)
                    ctx.moveTo(width * 0.48, height * 0.7)
                    ctx.lineTo(width * 0.78, height * 0.7)
                    ctx.stroke()
                } else {
                    ctx.beginPath()
                    ctx.arc(width * 0.5, height * 0.5, width * 0.3, 0, Math.PI * 2)
                    ctx.stroke()
                }
            }

            Connections {
                target: dockButton
                function onFallbackIconChanged() { lineIcon.requestPaint() }
                function onHoveredChanged() { lineIcon.requestPaint() }
            }
        }
    }

    Rectangle {
        width: 4
        height: dockButton.closed ? 0 : (dockButton.active ? 18 : (dockButton.minimized ? 6 : 0))
        radius: 2
        color: dockButton.accentColor
        opacity: dockButton.closed ? 0.0 : (dockButton.minimized ? 0.75 : 1.0)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dockButton.leftSide ? parent.left : undefined
        anchors.right: dockButton.leftSide ? undefined : parent.right
        anchors.leftMargin: 2
        anchors.rightMargin: 2

        Behavior on height { NumberAnimation { duration: root.motionExpressive; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: minimizedPill
        width: dockButton.minimized && !dockButton.closed ? 14 : 0
        height: 3
        radius: 2
        color: dockButton.accentColor
        opacity: dockButton.minimized && !dockButton.closed ? 0.9 : 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4

        Behavior on width { NumberAnimation { duration: root.motionExpressive; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: root.motionExpressive } }
    }

    Rectangle {
        id: dockLabel
        width: dockLabelText.width + root.spaceLg
        height: 24
        radius: root.radiusMd
        color: root.surfaceBase
        opacity: dockButton.hovered ? 1.0 : 0.0
        visible: opacity > 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dockButton.leftSide ? parent.right : undefined
        anchors.right: dockButton.leftSide ? undefined : parent.left
        anchors.leftMargin: root.spaceMd
        anchors.rightMargin: root.spaceMd

        Behavior on opacity { NumberAnimation { duration: root.motionQuick } }

        onVisibleChanged: {
            if (!visible) opacity = 0
        }

        Text {
                id: dockLabelText
                anchors.centerIn: parent
                text: dockButton.minimized
                      ? root.tr(dockButton.app.label) + " - " + root.tr("minimized")
                      : root.tr(dockButton.app.label)
                color: dockButton.minimized ? "#ffbd7a" : root.textPrimary
            font.pixelSize: root.textSmall
            font.family: dockButton.fontFamily
        }
    }

    MouseArea {
        id: dockMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: dockButton.hovered = true
        onExited: dockButton.hovered = false
        onCanceled: dockButton.hovered = false

        onClicked: function(mouse) {
            mouse.accepted = true
            dockButton.hovered = false

            if (mouse.button === Qt.RightButton) {
                dockButton.actionMenuRequested(
                    dockButton.app,
                    Qt.point(dockButton.width / 2, dockButton.height / 2),
                    dockButton.dockSide
                )
                return
            }

            dockBounceAnim.start()
            dockButton.launchRequested(dockButton.app)
        }
    }
}
