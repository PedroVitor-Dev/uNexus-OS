import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: stateView

    property string state: "empty"
    property string title: ""
    property string message: ""
    property string actionLabel: ""
    property string fontFamily: "Exo 2"
    property color accentColor: "#4d9eff"
    property color primaryTextColor: "#ffffff"
    property color secondaryTextColor: "#8ea4bd"
    property color surfaceColor: "#111a28"
    property color borderColor: "#223247"

    signal actionRequested()

    width: parent ? parent.width : 320
    height: 132

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: stateView.surfaceColor
        border.color: stateView.borderColor
        border.width: 1
        opacity: 0.96
    }

    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width - 28, 360)
        spacing: 6

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 24
            height: visible ? 24 : 0
            running: stateView.state === "loading"
            visible: running
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: stateView.state !== "loading"
            height: visible ? implicitHeight : 0
            text: stateView.state === "error" ? "!" : (stateView.state === "unavailable" ? "-" : "0")
            color: stateView.accentColor
            font.pixelSize: 18
            font.family: stateView.fontFamily
            font.bold: true
            opacity: 0.9
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: stateView.title
            color: stateView.primaryTextColor
            font.pixelSize: 13
            font.family: stateView.fontFamily
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: stateView.message
            color: stateView.secondaryTextColor
            font.pixelSize: 11
            font.family: stateView.fontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: stateView.actionLabel.length > 0
            width: actionText.width + 18
            height: visible ? 26 : 0
            radius: 7
            color: actionMouse.containsMouse ? "#254160" : "#172233"
            border.color: stateView.accentColor
            border.width: 1

            Text {
                id: actionText
                anchors.centerIn: parent
                text: stateView.actionLabel
                color: "#b7ddff"
                font.pixelSize: 11
                font.family: stateView.fontFamily
                font.bold: true
            }

            MouseArea {
                id: actionMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: stateView.actionRequested()
            }
        }
    }
}
