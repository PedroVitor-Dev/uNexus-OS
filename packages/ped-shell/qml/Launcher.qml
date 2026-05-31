import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: launcher
    anchors.fill: parent
    visible: false
    opacity: 0.0

property var allApps: [
    { icon: "🎮", name: "Steam",    category: "Gaming" },
    { icon: "🎮", name: "Lutris",   category: "Gaming" },

    { icon: "🗂", name: "Files",    category: "System" },
    { icon: "⚙️", name: "Settings", category: "System" },
    { icon: "🖥", name: "Terminal", category: "System" },
    { icon: "🏪", name: "Store",    category: "System" },

    { icon: "🌐", name: "Browser",  category: "Media" },
    { icon: "🎵", name: "Music",    category: "Media" },
    { icon: "📷", name: "Camera",   category: "Media" },
    { icon: "📝", name: "Notes",    category: "Media" }
]

    property string searchText: ""
    property string activeCategory: "All"

    function filteredApps() {
        return allApps.filter(function(a) {
            var matchCategory = activeCategory === "All" || a.category === activeCategory
            var matchSearch = searchText.length === 0 ||
                              a.name.toLowerCase().indexOf(searchText.toLowerCase()) !== -1
            return matchCategory && matchSearch
        })
    }

    function show() {
        launcher.visible = true
        searchInput.text = ""
        searchText = ""
        activeCategory = "All"
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
        anchors.topMargin: 100
        height: categoryRow.height + searchBox.height + resultsList.height + 56
        radius: 16
        color: "#0e1520"
        border.color: "#4d9eff"
        border.width: 1

        // Glow azul na borda
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.color: "#4d9eff"
            border.width: 1
            opacity: 0.15
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.color: "#4d9eff"
            border.width: 1
            opacity: 0.07
        }

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

        // Categorias
        Row {
            id: categoryRow
            anchors.top: searchBox.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 8
            spacing: 8

            Repeater {
                model: ["All", "Gaming", "System", "Media"]

                delegate: Rectangle {
                    width: catText.width + 20
                    height: 28
                    radius: 8
                    color: launcher.activeCategory === modelData ? "#4d9eff" : "#1a2030"

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Text {
                        id: catText
                        anchors.centerIn: parent
                        text: modelData
                        color: launcher.activeCategory === modelData ? "#ffffff" : "#aaaaaa"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: launcher.activeCategory = modelData
                    }
                }
            }
        }

        // Lista de resultados
        Column {
            id: resultsList
            anchors.top: categoryRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8
            padding: 8
            spacing: 2

            Repeater {
                model: launcher.filteredApps()

                delegate: Rectangle {
                    width: resultsList.width - 16
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

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.category
                        color: "#4d9eff"
                        font.pixelSize: 11
                        opacity: 0.6
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