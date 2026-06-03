import QtQuick 2.15

Item {
    id: sideDock

    property string side: "left"
    property string title: ""
    property var apps: []
    property color accentColor: "#4d9eff"
    property color panelColor: "#111111"
    property string fontFamily: "Exo 2"
    property int dockStateVersion: 0
    property var appStates: ({})
    property bool actionMenuVisible: false
    property string actionMenuSide: ""
    property bool expanded: false
    property bool leftSide: side === "left"
    property bool menuOwnsDock: actionMenuVisible && actionMenuSide === sideDock.side
    property bool shouldExpand: dockMouse.containsMouse || edgeMouse.containsMouse || menuOwnsDock

    signal launchRequested(var app)
    signal actionMenuRequested(var app, var point, string side)

    function stateFor(app) {
        if (app && app.internalAction && appStates[app.internalAction])
            return appStates[app.internalAction]

        return ""
    }

    width: 72
    height: dockPanel.height
    y: Math.max(56, ((parent ? parent.height : 720) - height) / 2)
    x: leftSide
       ? (expanded ? 12 : -60)
       : (expanded ? (parent ? parent.width : 1280) - width - 12 : (parent ? parent.width : 1280) - 12)

    onShouldExpandChanged: {
        if (shouldExpand) {
            hideTimer.stop()
            expanded = true
        } else {
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 420
        repeat: false
        onTriggered: sideDock.expanded = false
    }

    Behavior on x {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    MouseArea {
        id: edgeMouse
        x: sideDock.leftSide ? sideDock.width - 12 : 0
        y: 0
        width: 16
        height: sideDock.height
        hoverEnabled: true
    }

    Rectangle {
        id: dockPanel
        width: sideDock.width
        height: dockColumn.height + 18
        radius: 16
        color: sideDock.panelColor
        opacity: sideDock.expanded ? 0.92 : 0.78
        border.color: sideDock.accentColor
        border.width: 1

        Behavior on opacity { NumberAnimation { duration: 160 } }

        Column {
            id: dockColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 9
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: sideDock.title
                color: sideDock.accentColor
                font.pixelSize: 9
                font.family: sideDock.fontFamily
                font.bold: true
                opacity: 0.85
            }

            Repeater {
                model: sideDock.apps

                delegate: DockButton {
                    id: dockButtonDelegate

                    app: modelData
                    leftSide: sideDock.leftSide
                    dockSide: sideDock.side
                    accentColor: sideDock.accentColor
                    fontFamily: sideDock.fontFamily
                    dockStateVersion: sideDock.dockStateVersion
                    appStateOverride: sideDock.stateFor(modelData)
                    onLaunchRequested: function(app) {
                        sideDock.launchRequested(app)
                    }
                    onActionMenuRequested: function(app, point, side) {
                        sideDock.actionMenuRequested(app, dockButtonDelegate.mapToItem(sideDock.parent, point.x, point.y), side)
                    }
                }
            }
        }
    }

    MouseArea {
        id: dockMouse
        anchors.fill: dockPanel
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
