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
    property int appStateVersion: 0
    property int localeVersion: 0
    property var appStateProvider: null
    property bool actionMenuVisible: false
    property string actionMenuSide: ""
    property bool expanded: false
    property bool leftSide: side === "left"
    property bool menuOwnsDock: actionMenuVisible && actionMenuSide === sideDock.side
    property bool shouldExpand: dockMouse.containsMouse || edgeMouse.containsMouse || menuOwnsDock
    property int edgeMargin: root.multiMonitorEdgeMargin || root.spaceMd
    property int topSafeMargin: root.multiMonitorTopMargin || 56

    signal launchRequested(var app)
    signal actionMenuRequested(var app, var point, string side)

    function stateFor(app, stateVersion, dockVersion) {
        stateVersion
        dockVersion

        if (appStateProvider)
            return appStateProvider(app, stateVersion)

        return ""
    }

    width: 72
    height: dockPanel.height
    y: Math.max(topSafeMargin, Math.min((parent ? parent.height : 720) - height - root.spaceLg, ((parent ? parent.height : 720) - height) / 2))
    x: leftSide
       ? (expanded ? edgeMargin : -60)
       : (expanded ? (parent ? parent.width : 1280) - width - edgeMargin : (parent ? parent.width : 1280) - edgeMargin)

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
        NumberAnimation { duration: root.motionExpressive; easing.type: Easing.OutCubic }
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
        height: dockColumn.height + root.spaceXl
        radius: root.radiusDock
        color: sideDock.panelColor
        opacity: sideDock.expanded ? 0.92 : 0.78
        border.color: sideDock.accentColor
        border.width: root.borderHairline

        Behavior on opacity { NumberAnimation { duration: root.motionBase } }

        Column {
            id: dockColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.spaceSm + 1
            spacing: root.spaceSm

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: sideDock.title
                color: sideDock.accentColor
                font.pixelSize: root.textMicro
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
                    localeVersion: sideDock.localeVersion
                    dockExpanded: sideDock.expanded
                    appStateOverride: sideDock.stateFor(modelData, sideDock.appStateVersion, sideDock.dockStateVersion)
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
