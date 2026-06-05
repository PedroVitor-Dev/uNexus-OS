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
        { icon: "🎮", name: "Heroic", category: "Gaming", command: "heroic", flatpakId: "com.heroicgameslauncher.hgl", windowClasses: ["heroic", "Heroic", "com.heroicgameslauncher.hgl"] },
        { icon: "🎮", name: "Bottles", category: "Gaming", command: "bottles", flatpakId: "com.usebottles.bottles", windowClasses: ["bottles", "Bottles", "com.usebottles.bottles"] },
        { icon: "🎮", name: "Game Settings", category: "Gaming", internalAction: "gameSettings" },
        { icon: "🗂", name: "uNexus Files", category: "System", internalAction: "files" },
        { icon: "⚙️", name: "Settings", category: "System", internalAction: "settings" },
        { icon: "🖥", name: "Terminal", category: "System", command: "gnome-terminal", args: [] },
        { icon: "🏪", name: "Store",    category: "System", command: "gnome-software", args: [] },
        { icon: "🌐", name: "Browser",  category: "Media", command: "brave", args: [], windowClasses: ["brave-browser", "Brave-browser", "brave", "Brave"] },
        { icon: "🎵", name: "Music",    category: "Media", command: "rhythmbox", args: [] },
        { icon: "📷", name: "Camera",   category: "Media", command: "cheese", args: [] },
        { icon: "📝", name: "Notes",    category: "Media", command: "gedit", args: [] }
    ]

    property string searchText: ""
    property string activeCategory: "All"
    property var settingsPanel: null
    property var gameSettingsPanel: null
    property var filesPanel: null
    property bool loading: false
    property string errorMessage: ""
    property string unavailableMessage: ""

    function filteredApps() {
        return allApps.filter(function(a) {
            var matchCategory = activeCategory === "All" || a.category === activeCategory
            var matchSearch = searchText.length === 0 ||
                              a.name.toLowerCase().indexOf(searchText.toLowerCase()) !== -1
            return matchCategory && matchSearch
        })
    }

    function appInstalled(app) {
        if (app.internalAction)
            return true
        return appLauncher.isInstalled(app.command || "") ||
               appLauncher.isFlatpakInstalled(app.flatpakId || "")
    }

    function appRunning(app) {
        if (!app.windowClasses || app.windowClasses.length === 0)
            return false
        return appLauncher.isWindowOpen(app.windowClasses) ||
               appLauncher.isProcessRunning(app.windowClasses)
    }

    function appStatus(app) {
        if (app.internalAction)
            return "panel"
        if (appRunning(app))
            return "running"
        return appInstalled(app) ? "installed" : "missing"
    }

    function appStatusLabel(app) {
        if (app.internalAction)
            return root.tr("panel")
        if (appRunning(app))
            return root.tr("running")
        if (app.category !== "Gaming")
            return appInstalled(app) ? root.tr(app.category) : root.tr("missing")
        return appInstalled(app) ? root.tr("installed") : root.tr("missing")
    }

function launchApp(app) {
    if (app.internalAction === "settings") {
        launcher.hide()
        if (settingsPanel)
            settingsPanel.show()
        return
    }

    if (app.internalAction === "files") {
        launcher.hide()
        if (filesPanel)
            filesPanel.show()
        return
    }

    if (app.internalAction === "gameSettings") {
        launcher.hide()
        if (gameSettingsPanel)
            gameSettingsPanel.show()
        return
    }

    var opened = false
    var isGamingApp = app.category === "Gaming"

    if (isGamingApp && gameMode.active) {
        if (!appLauncher.isMangoHudInstalled())
            notifCenter.send(root.tr("MangoHud not found"), root.tr("Launching without MangoHud overlay."), "⚠️", root.tr("Open Game Settings"), function() {
                if (gameSettingsPanel)
                    gameSettingsPanel.show()
            })

        if (!appLauncher.isGameModeRunInstalled())
            notifCenter.send(root.tr("GameMode not found"), root.tr("Launching without gamemoderun."), "⚠️", root.tr("Open Game Settings"), function() {
                if (gameSettingsPanel)
                    gameSettingsPanel.show()
            })

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
        notifCenter.send(root.tr("App not found"), root.trAppMessage("{app} is not installed.", app.name), "⚠️", root.tr("Open Game Settings"), function() {
            if (gameSettingsPanel)
                gameSettingsPanel.show()
        })

    launcher.hide()
}

    function show() {
        hideAnim.stop()
        launcher.visible = true
        launcher.opacity = 0.0
        panel.scale = 0.98
        panelSlide.y = -12
        searchInput.text = ""
        searchText = ""
        activeCategory = "All"
        searchInput.forceActiveFocus()
        showAnim.start()
    }

    function hide() {
        if (!launcher.visible)
            return
        showAnim.stop()
        hideAnim.start()
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: launcher; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        SpringAnimation { target: panel; property: "scale"; to: 1.0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
        SpringAnimation { target: panelSlide; property: "y"; to: 0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: launcher; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            SpringAnimation { target: panel; property: "scale"; to: 0.98; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
            SpringAnimation { target: panelSlide; property: "y"; to: -8; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
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
        width: Math.min(root.compactLayout ? 360 : 420, parent.width - root.panelMargin * 2)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.min(root.panelTopMargin, Math.max(56, parent.height * 0.12))
        height: Math.min(root.compactLayout ? 420 : 460, parent.height - anchors.topMargin - root.panelMargin)
        radius: root.radiusDock
        color: "#0e1520"
        border.color: "#4d9eff"
        border.width: 1
        transform: Translate { id: panelSlide; y: 0 }

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
            anchors.margins: root.panelPadding
            height: 40
            radius: 10
            color: "#1a2030"
            border.color: "#2a3a55"
            border.width: 1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "🔍"
                font.pixelSize: 14
            }

            TextInput {
                id: searchInput
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 14
                selectionColor: "#4d9eff"

                onTextChanged: launcher.searchText = text
                Keys.onEscapePressed: launcher.hide()
            }

            Text {
                anchors.left: searchInput.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.tr("Search apps...")
                color: "#ffffff"
                font.pixelSize: 14
                opacity: 0.3
                visible: searchInput.text.length === 0
            }
        }

        SegmentedControl {
            id: categoryRow
            anchors.top: searchBox.bottom
            anchors.left: parent.left
            anchors.leftMargin: root.panelPadding
            anchors.topMargin: root.spaceSm
            width: Math.min(300, parent.width - root.panelPadding * 2)
            values: ["All", "Gaming", "System", "Media"]
            currentValue: launcher.activeCategory
            fontFamily: root.uiFont
            accentColor: root.themeAccent
            motionDuration: root.motionQuick
            labelProvider: function(value) { return root.tr(value) }
            onSelected: function(value) { launcher.activeCategory = value }
        }

        Rectangle {
            id: resultsList
            anchors.top: categoryRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: root.panelPadding
            anchors.topMargin: root.spaceSm
            radius: 10
            color: "#111a28"
            border.color: "#223247"
            border.width: 1
            clip: true

            PanelStateView {
                anchors.fill: parent
                anchors.margins: root.spaceSm
                visible: launcher.loading || launcher.errorMessage.length > 0 ||
                         launcher.unavailableMessage.length > 0 || launcher.filteredApps().length === 0
                state: launcher.loading ? "loading" : (launcher.errorMessage.length > 0 ? "error" : (launcher.unavailableMessage.length > 0 ? "unavailable" : "empty"))
                title: launcher.loading ? root.tr("Loading apps") : (launcher.errorMessage.length > 0 ? root.tr("Launcher error") : (launcher.unavailableMessage.length > 0 ? root.tr("Launcher unavailable") : root.tr("No apps found")))
                message: launcher.loading ? root.tr("Checking available apps and launchers.") :
                         (launcher.errorMessage.length > 0 ? launcher.errorMessage :
                         (launcher.unavailableMessage.length > 0 ? launcher.unavailableMessage : root.tr("Try another search or category.")))
                actionLabel: root.tr("Reset search")
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                primaryTextColor: root.textPrimary
                secondaryTextColor: root.textMuted
                onActionRequested: {
                    launcher.searchText = ""
                    searchInput.text = ""
                    launcher.activeCategory = "All"
                    searchInput.forceActiveFocus()
                }
            }

            ListView {
                id: appsList
                anchors.fill: parent
                anchors.margins: root.spaceSm
                visible: !launcher.loading && launcher.errorMessage.length === 0 &&
                         launcher.unavailableMessage.length === 0 && launcher.filteredApps().length > 0
                clip: true
                spacing: 2
                model: launcher.filteredApps()

                delegate: Rectangle {
                    width: appsList.width
                    height: 40
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
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.tr(modelData.name)
                            color: "#ffffff"
                            font.pixelSize: 13
                            opacity: 0.9
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StatusChip {
                        id: appStatusChip
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        status: launcher.appStatus(modelData)
                        label: launcher.appStatusLabel(modelData)
                        fontFamily: root.uiFont
                        accentColor: root.themeAccent
                    }

                    Rectangle {
                        visible: false
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: statusText.width + 12
                        height: 18
                        radius: 6
                        color: {
                            if (modelData.category !== "Gaming" || modelData.internalAction) return "transparent"
                            var installed = appLauncher.isInstalled(modelData.command || "") ||
                                            appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                            return installed ? "#0d3020" : "#2a1010"
                        }

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: {
                                if (modelData.internalAction) return root.tr("panel")
                                if (modelData.category !== "Gaming") return root.tr(modelData.category)
                                var installed = appLauncher.isInstalled(modelData.command || "") ||
                                                appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                                return installed ? "✓ " + root.tr("installed") : root.tr("not installed")
                            }
                            color: {
                                if (modelData.internalAction) return "#4d9eff"
                                if (modelData.category !== "Gaming") return "#4d9eff"
                                var installed = appLauncher.isInstalled(modelData.command || "") ||
                                                appLauncher.isFlatpakInstalled(modelData.flatpakId || "")
                                return installed ? "#00ff88" : "#ff4d4d"
                            }
                            font.pixelSize: 11
                            opacity: modelData.category !== "Gaming" ? 0.6 : 1.0
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
