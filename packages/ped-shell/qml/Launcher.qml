import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: launcher
    anchors.fill: parent
    visible: false
    opacity: 0.0

    property var allApps: [
        { icon: "🎮", name: "Steam",  category: "Gaming", command: "steam",  flatpakId: "com.valvesoftware.Steam", windowClasses: ["steam", "Steam"] },
        { icon: "🎮", name: "Lutris", category: "Gaming", command: "lutris", flatpakId: "net.lutris.Lutris", windowClasses: ["lutris", "Lutris"] },
        { icon: "🗂", name: "Files",    category: "System", command: "nautilus", args: [] },
        { icon: "⚙️", name: "Settings", category: "System", command: "gnome-control-center", args: [] },
        { icon: "🖥", name: "Terminal", category: "System", command: "gnome-terminal", args: [] },
        { icon: "🏪", name: "Store",    category: "System", command: "gnome-software", args: [] },
        { icon: "🌐", name: "Browser",  category: "Media", command: "firefox", args: [] },
        { icon: "🎵", name: "Music",    category: "Media", command: "rhythmbox", args: [] },
        { icon: "📷", name: "Camera",   category: "Media", command: "cheese", args: [] },
        { icon: "📝", name: "Notes",    category: "Media", command: "gedit", args: [] }
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

function launchApp(app) {
    var opened = false
    var isGamingApp = app.category === "Gaming"

    if (isGamingApp && gameMode.active) {
        if (!appLauncher.isMangoHudInstalled())
            notifCenter.send("MangoHud not found", "Launching without MangoHud overlay.", "⚠️")

        if (!appLauncher.isGameModeRunInstalled())
            notifCenter.send("GameMode not found", "Launching without gamemoderun.", "⚠️")

        opened = appLauncher.focusOrLaunchGame(
            app.windowClasses || [],
            app.command || "",
            app.args || [],
            app.flatpakId || "",
            true,
            true
        )
    } else if (app.windowClasses && app.windowClasses.length > 0) {
        opened = appLauncher.focusOrLaunch(
            app.windowClasses,
            app.command || "",
            app.args || [],
            app.flatpakId || ""
        )
    } else {
        if (app.command && app.command.length > 0)
            opened = appLauncher.launch(app.command, app.args || [])

        if (!opened && app.flatpakId && app.flatpakId.length > 0)
            opened = appLauncher.launch("flatpak", ["run", app.flatpakId])
    }

    if (!opened && notifCenter)
        notifCenter.send("App not found", app.name + " is not installed.", "⚠️")

    launcher.hide()
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

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
    }

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

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: statusText.width + 12
                        height: 18
                        radius: 6
                        color: {
                            if (modelData.category !== "Gaming") return "transparent"
                            var installed = appLauncher.isInstalled(modelData.command || "") ||
                                            appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                            return installed ? "#0d3020" : "#2a1010"
                        }

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: {
                                if (modelData.category !== "Gaming") return modelData.category
                                var installed = appLauncher.isInstalled(modelData.command || "") ||
                                                appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                                return installed ? "✓ installed" : "not installed"
                            }
                            color: {
                                if (modelData.category !== "Gaming") return "#4d9eff"
                                var installed = appLauncher.isInstalled(modelData.command || "") ||
                                                appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                                return installed ? "#00ff88" : "#ff4d4d"
                            }
                            font.pixelSize: 11
                            opacity: modelData.category !== "Gaming" ? 0.6 : 1.0
                        }
                    }

                    Rectangle {
                        visible: modelData.category === "Gaming"
                        z: 2
                        anchors.right: parent.right
                        anchors.rightMargin: statusText.width + 28
                        anchors.verticalCenter: parent.verticalCenter
                        width: copyOptsText.width + 16
                        height: 22
                        radius: 6
                        color: copyOptsMouse.containsMouse ? "#254160" : "#172233"
                        border.color: "#2d5f8f"
                        border.width: 1

                        Text {
                            id: copyOptsText
                            anchors.centerIn: parent
                            text: "Copy opts"
                            color: "#b7ddff"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: copyOptsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                appLauncher.copyToClipboard("mangohud gamemoderun %command%")
                                if (notifCenter)
                                    notifCenter.send("Launch options copied", "Paste into Steam game launch options.", "🎮")
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        z: 1
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: launchApp(modelData)
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: launcher.hide()
    }
}
