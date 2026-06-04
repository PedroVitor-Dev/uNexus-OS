import QtQuick 2.15

Rectangle {
    id: control

    property var values: []
    property string currentValue: ""
    property string fontFamily: ""
    property color accentColor: "#4d9eff"
    property int motionDuration: 90
    property var labelProvider: function(value) { return value }

    signal selected(string value)

    height: 32
    radius: 8
    color: "#101927"
    border.color: "#223247"
    border.width: 1

    function labelFor(value) {
        return labelProvider ? labelProvider(value) : value
    }

    Row {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: control.values

            delegate: Rectangle {
                id: segment
                width: Math.max(segmentText.implicitWidth + 20, 64)
                height: parent.height
                radius: 6
                color: control.currentValue === modelData ? control.accentColor : (segmentMouse.containsMouse ? "#1e2d45" : "transparent")

                Behavior on color { ColorAnimation { duration: control.motionDuration } }

                Text {
                    id: segmentText
                    anchors.centerIn: parent
                    text: control.labelFor(modelData)
                    color: control.currentValue === modelData ? "#ffffff" : "#8ea4bd"
                    font.pixelSize: 12
                    font.family: control.fontFamily
                    font.bold: control.currentValue === modelData
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    width: parent.width - 10
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: segmentMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: control.selected(modelData)
                }
            }
        }
    }
}
