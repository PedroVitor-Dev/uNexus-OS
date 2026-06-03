import QtQuick 2.15

Rectangle {
    id: dockButton

    property var app
    property bool leftSide: true
    property string dockSide: "left"
    property color accentColor: "#4d9eff"
    property string fontFamily: "Exo 2"
    property int dockStateVersion: 0
    property string resolvedIcon: app.iconNames ? appLauncher.findIcon(app.iconNames) : ""
    property bool active: {
        dockStateVersion

        var hasWindowClasses = app.windowClasses && app.windowClasses.length > 0
        var hasProcessNames = app.processNames && app.processNames.length > 0

        if (hasWindowClasses && appLauncher.isWindowOpen(app.windowClasses))
            return true

        if (hasProcessNames && appLauncher.isProcessRunning(app.processNames))
            return true

        return false
    }

    signal launchRequested(var app)
    signal actionMenuRequested(var app, var point, string side)

    width: dockMouseArea.containsMouse ? 56 : 48
    height: dockMouseArea.containsMouse ? 56 : 48
    radius: 14
    color: dockMouseArea.containsMouse ? "#2a2a2a" : "transparent"

    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    transform: Translate { id: dockBounce; y: 0 }

    SequentialAnimation {
        id: dockBounceAnim
        NumberAnimation { target: dockBounce; property: "y"; to: -10; duration: 95; easing.type: Easing.OutCubic }
        NumberAnimation { target: dockBounce; property: "y"; to: 0; duration: 110; easing.type: Easing.InBounce }
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
        height: dockButton.active ? 18 : 0
        radius: 2
        color: dockButton.accentColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dockButton.leftSide ? parent.left : undefined
        anchors.right: dockButton.leftSide ? undefined : parent.right
        anchors.leftMargin: 2
        anchors.rightMargin: 2

        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
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
            text: dockButton.app.label
            color: "#ffffff"
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
