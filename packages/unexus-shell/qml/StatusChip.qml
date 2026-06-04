import QtQuick 2.15

Rectangle {
    id: chip

    property string status: "installed"
    property string label: ""
    property string fontFamily: ""
    property color accentColor: "#4d9eff"
    property int motionDuration: 90

    readonly property bool isRunning: status === "running"
    readonly property bool isInstalled: status === "installed" || status === "ready"
    readonly property bool isMissing: status === "missing"
    readonly property bool needsRestart: status === "needs-restart"
    readonly property color stateColor: {
        if (isRunning)
            return "#4d9eff"
        if (isInstalled)
            return "#00ff88"
        if (needsRestart)
            return "#ffcc66"
        if (isMissing)
            return "#ff6b6b"
        return accentColor
    }

    width: Math.max(statusLabel.implicitWidth + 16, 42)
    height: 22
    radius: 7
    color: Qt.rgba(stateColor.r, stateColor.g, stateColor.b, 0.13)
    border.color: Qt.rgba(stateColor.r, stateColor.g, stateColor.b, 0.46)
    border.width: 1

    Behavior on color { ColorAnimation { duration: chip.motionDuration } }
    Behavior on border.color { ColorAnimation { duration: chip.motionDuration } }

    Text {
        id: statusLabel
        anchors.centerIn: parent
        text: chip.label.length > 0 ? chip.label : chip.status
        color: chip.stateColor
        font.pixelSize: 10
        font.family: chip.fontFamily
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
