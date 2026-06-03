import QtQuick 2.15

Rectangle {
    id: dockButton

    property var app
    property bool leftSide: true
    property string dockSide: "left"
    property color accentColor: "#4d9eff"
    property string fontFamily: "Exo 2"
    property int dockStateVersion: 0
    property string appStateOverride: ""
    property string resolvedIcon: app.iconNames ? appLauncher.findIcon(app.iconNames) : ""
    property string appState: {
        dockStateVersion

        if (appStateOverride.length > 0)
            return appStateOverride

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

    signal launchRequested(var app)
    signal actionMenuRequested(var app, var point, string side)

    width: dockMouseArea.containsMouse ? 56 : 48
    height: dockMouseArea.containsMouse ? 56 : 48
    radius: 14
    color: dockMouseArea.containsMouse ? "#2a2a2a" : "transparent"

    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    transform: Translate { id: dockBounce; y: 0 }

    onActiveChanged: {
        if (!active)
            scale = 1.0
    }

    onMinimizedChanged: {
        if (!minimized)
            minimizedPill.scale = 1.0
    }

    SequentialAnimation on scale {
        running: dockButton.active
        loops: Animation.Infinite
        NumberAnimation { to: 1.035; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
    }

    SequentialAnimation {
        id: dockBounceAnim
        NumberAnimation { target: dockBounce; property: "y"; to: -10; duration: 95; easing.type: Easing.OutCubic }
        NumberAnimation { target: dockBounce; property: "y"; to: 0; duration: 110; easing.type: Easing.InBounce }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: dockButton.accentColor
        opacity: dockButton.active ? 0.08 : 0.0

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    Image {
        id: appIcon
        anchors.centerIn: parent
        width: dockMouseArea.containsMouse ? 34 : 30
        height: width
        source: dockButton.resolvedIcon
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: status === Image.Ready
    }

    Text {
        anchors.centerIn: parent
        text: app.icon || "?"
        color: "#ffffff"
        font.pixelSize: dockMouseArea.containsMouse ? 18 : 15
        font.family: dockButton.fontFamily
        font.bold: true
        visible: appIcon.status !== Image.Ready
    }

    Rectangle {
        width: 4
        height: dockButton.active ? 18 : (dockButton.minimized ? 6 : 0)
        radius: 2
        color: dockButton.accentColor
        opacity: dockButton.minimized ? 0.75 : 1.0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dockButton.leftSide ? parent.left : undefined
        anchors.right: dockButton.leftSide ? undefined : parent.right
        anchors.leftMargin: 2
        anchors.rightMargin: 2

        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: minimizedPill
        width: dockButton.minimized ? 14 : 0
        height: 3
        radius: 2
        color: dockButton.accentColor
        opacity: dockButton.minimized ? 0.9 : 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4

        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        SequentialAnimation on scale {
            running: dockButton.minimized
            loops: Animation.Infinite
            NumberAnimation { to: 0.55; duration: 650; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 650; easing.type: Easing.InOutSine }
        }
    }

    Rectangle {
        id: dockLabel
        width: dockLabelText.width + 16
        height: 24
        radius: 8
        color: "#1e1e1e"
        opacity: dockMouseArea.containsMouse ? 1.0 : 0.0
        visible: opacity > 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dockButton.leftSide ? parent.right : undefined
        anchors.right: dockButton.leftSide ? undefined : parent.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Behavior on opacity { NumberAnimation { duration: 120 } }

        Text {
            id: dockLabelText
            anchors.centerIn: parent
            text: dockButton.minimized ? dockButton.app.label + " - minimized" : dockButton.app.label
            color: dockButton.minimized ? "#ffbd7a" : "#ffffff"
            font.pixelSize: 12
            font.family: dockButton.fontFamily
        }
    }

    MouseArea {
        id: dockMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            mouse.accepted = true

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
