import QtQuick 2.15

Item {
    id: bubble

    property string role: "assistant"
    property string text: ""
    property bool streaming: false

    readonly property bool isUser: role === "user"
    readonly property bool isSystem: role === "system"

    width: ListView.view ? ListView.view.width : 640
    height: content.height + 14

    Row {
        width: parent.width
        layoutDirection: bubble.isUser ? Qt.RightToLeft : Qt.LeftToRight

        Rectangle {
            id: content
            width: Math.min(messageText.implicitWidth + 28, bubble.width * 0.78)
            height: messageText.implicitHeight + 18
            radius: 10
            color: bubble.isSystem ? "#3a1f2a" : (bubble.isUser ? root.themeAccentDim : "#172233")
            border.color: bubble.isSystem ? "#7a3348" : (bubble.isUser ? root.themeAccent : "#26384d")
            border.width: 1

            Text {
                id: messageText
                anchors.fill: parent
                anchors.margins: 9
                text: bubble.text.length > 0 ? bubble.text : (bubble.streaming ? root.tr("Thinking locally...") : "")
                color: bubble.isSystem ? "#ffb4b4" : root.textPrimary
                font.pixelSize: 13
                font.family: root.uiFont
                wrapMode: Text.Wrap
            }

            Rectangle {
                visible: bubble.streaming
                width: 6
                height: 6
                radius: 3
                color: root.themeAccent
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 5

                SequentialAnimation on opacity {
                    running: bubble.streaming
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.2; duration: 520 }
                    NumberAnimation { from: 0.2; to: 1.0; duration: 520 }
                }
            }
        }
    }
}
