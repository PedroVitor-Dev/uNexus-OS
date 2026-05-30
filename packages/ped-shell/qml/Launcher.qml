import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: launcher
    anchors.fill: parent
    visible: false
    opacity: 0.0

    property var apps: [
        { icon: "🗂", name: "Files" },
        { icon: "🌐", name: "Browser" },
        { icon: "⚙️", name: "Settings" },
        { icon: "🖥", name: "Terminal" },
        { icon: "🏪", name: "Store" },
        { icon: "🎵", name: "Music" },
        { icon: "📷", name: "Camera" },
        { icon: "📝", name: "Notes" }
    ]

    property string searchText: ""

    function show() {
        launcher.visible = true
        searchInput.text = ""
        searchText = ""
        searchInput.forceActiveFocus()
        showAnim.start()
    }

    function hide() {
        hideAnim.start()
    }

    NumberAnimation {
        id: showAnim
        target: launcher
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 200
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: launcher
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 150
            easing.type: Easing.InCubic
        }
        ScriptAction { script: launcher.visible = false }
    }

    // Overlay escuro
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
    }

    // Painel central
    Rectangle {
        id: panel
        width: 600
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 120
        height: filteredColumn.height + searchBox.height + 48
        radius: 16
        color: "#111520"
        border.color: "#1e2d45"
        border.width: 1

        // Campo de busca
        Rectangle {
            id: searchBox
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            height: 48
            radius: 10
            color: "#1a2030"
            border.color: "#2a3a55"
            border.width: 1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "🔍"
                font.pixelSize: 16
            }

            TextInput {
                id: searchInput
                anchors.left: parent.left
                anchors.leftMargin: 44
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 16
                selectionColor: "#4d9eff"

                onTextChanged: launcher.searchText = text

                Keys.onEscapePressed: launcher.hide()
            }

            Text {
                anchors.left: searchInput.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Search apps..."
                color: "#ffffff"
                font.pixelSize: 16
                opacity: 0.3
                visible: searchInput.text.length === 0
            }
        }

        // Lista de resultados
        Column {
            id: filteredColumn
            anchors.top: searchBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.bottomMargin: 16
            spacing: 2
            padding: 8

            Repeater {
                model: launcher.apps.filter(function(a) {
                    return launcher.searchText.length === 0 ||
                           a.name.toLowerCase().indexOf(launcher.searchText.toLowerCase()) !== -1
                })

                delegate: Rectangle {
                    width: filteredColumn.width - 16
                    height: 48
                    radius: 8
                    color: itemMouse.containsMouse ? "#1e2d45" : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 22
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.name
                            color: "#ffffff"
                            font.pixelSize: 15
                            opacity: 0.9
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: launcher.hide()
                    }
                }
            }
        }
    }

    // Fechar ao clicar fora
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: launcher.hide()
    }
}