import QtQuick 2.15

Rectangle {
    id: button

    property string label: ""
    property string variant: "subtle"
    property string fontFamily: ""
    property color accentColor: "#4d9eff"
    property int motionDuration: 90

    signal clicked()

    readonly property bool danger: variant === "danger"
    readonly property bool primary: variant === "primary"
    readonly property color toneColor: danger ? "#ff8a8a" : (primary ? accentColor : "#b7ddff")

    width: Math.max(buttonLabel.implicitWidth + 18, 72)
    height: 34
    radius: 7
    color: !enabled ? "#111820" : (buttonMouse.containsMouse ? (danger ? "#3a1f2a" : "#254160") : (primary ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.18) : "#172233"))
    border.color: enabled ? (danger ? "#7a3348" : accentColor) : "#253140"
    border.width: 1
    opacity: enabled ? 1.0 : 0.55

    Behavior on color { ColorAnimation { duration: button.motionDuration } }
    Behavior on opacity { NumberAnimation { duration: button.motionDuration } }

    Text {
        id: buttonLabel
        anchors.centerIn: parent
        text: button.label
        color: button.toneColor
        font.pixelSize: 12
        font.family: button.fontFamily
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
        width: parent.width - 14
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        enabled: button.enabled
        hoverEnabled: enabled
        onClicked: button.clicked()
    }
}
