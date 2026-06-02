import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "PED OS Shell"
    color: "#0a0a0a"

    property string pedFont: "Exo 2"
    property int themeIndex: 0
    property string themeName: "Neon Blue"
    property color themeBgTop: "#04050d"
    property color themeBgMid: "#080b18"
    property color themeBgBottom: "#050810"
    property color themeAccent: "#4d9eff"
    property color themeAccentDim: "#0d3060"
    property color themeGlow: "#4d9eff"

    function applyTheme(index, persist) {
        themeIndex = index

        if (index === 1) {
            themeName = "Cyber Violet"
            themeBgTop = "#0b0414"
            themeBgMid = "#150a2a"
            themeBgBottom = "#06040d"
            themeAccent = "#b86cff"
            themeAccentDim = "#3a1a66"
            themeGlow = "#ff4df0"
        } else if (index === 2) {
            themeName = "Toxic Green"
            themeBgTop = "#03100b"
            themeBgMid = "#071b12"
            themeBgBottom = "#020807"
            themeAccent = "#00ff88"
            themeAccentDim = "#0b4a31"
            themeGlow = "#9dff00"
        } else if (index === 3) {
            themeName = "Ember Core"
            themeBgTop = "#120606"
            themeBgMid = "#24100a"
            themeBgBottom = "#090404"
            themeAccent = "#ff6a2a"
            themeAccentDim = "#5a2413"
            themeGlow = "#ffcc33"
        } else {
            themeName = "Neon Blue"
            themeBgTop = "#04050d"
            themeBgMid = "#080b18"
            themeBgBottom = "#050810"
            themeAccent = "#4d9eff"
            themeAccentDim = "#0d3060"
            themeGlow = "#4d9eff"
        }

        wallpaperLines.requestPaint()
        diagonalGrid.requestPaint()

        if (persist !== false)
            userSettings.themeIndex = themeIndex
    }

    Component.onCompleted: {
        applyTheme(userSettings.themeIndex, false)
        systemStats.visible = userSettings.statsOverlayVisible
    }

    Connections {
        target: systemStats
        function onVisibleChanged() {
            userSettings.statsOverlayVisible = systemStats.visible
        }
    }
    property int dockStateVersion: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dockStateVersion++
    }

    function launchDesktopApp(app) {
    if (app.internalAction === "settings") {
        pedSettings.show()
        return
    }

    if (app.internalAction === "gameSettings") {
        gameSettings.show()
        return
    }

    var opened = false
    var isGamingApp = app.gaming === true

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

    if (!opened)
        notifCenter.send("App not found", app.label + " is not installed.", "⚠️")
}

    Rectangle {
        anchors.fill: parent
        color: root.themeBgTop

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: root.themeBgTop }
                GradientStop { position: 0.5; color: root.themeBgMid }
                GradientStop { position: 1.0; color: root.themeBgBottom }
            }
        }

        Canvas {
            id: wallpaperLines
            width: parent.width
            height: parent.height
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.beginPath()
                ctx.moveTo(0, height * 0.3)
                ctx.lineTo(width * 0.35, height * 0.0)
                ctx.lineTo(width * 0.15, height * 0.75)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccentDim
                ctx.lineWidth = 1
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(width * 0.6, height)
                ctx.lineTo(width, height * 0.4)
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccentDim
                ctx.lineWidth = 1
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(width * 0.7, 0)
                ctx.lineTo(width, height * 0.25)
                ctx.lineTo(width * 0.85, 0)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1
                ctx.globalAlpha = 0.15
                ctx.stroke()

                ctx.globalAlpha = 1.0
                ctx.beginPath()
                ctx.moveTo(width * 0.1, height * 0.85)
                ctx.lineTo(width * 0.3, height * 0.6)
                ctx.lineTo(width * 0.45, height)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1
                ctx.globalAlpha = 0.1
                ctx.stroke()
            }
        }

        Rectangle {
            width: 500
            height: 500
            radius: 250
            x: parent.width - 200
            y: -150
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 300
                radius: 150
                color: root.themeGlow
                opacity: 0.05
            }
        }

        Rectangle {
            width: 400
            height: 400
            radius: 200
            x: -150
            y: parent.height - 200
            color: root.themeGlow
            opacity: 0.04
        }

        Repeater {
            model: 30

            delegate: Rectangle {
                property real px: Math.random()
                property real py: Math.random()

                x: px * parent.width
                y: py * parent.height
                width: Math.random() > 0.7 ? 3 : 1.5
                height: width
                radius: width
                color: root.themeAccent
                opacity: Math.random() * 0.4 + 0.1

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.05; duration: Math.random() * 2000 + 1000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: Math.random() * 0.5 + 0.12; duration: Math.random() * 2000 + 1000; easing.type: Easing.InOutSine }
                }
            }
        }

        Canvas {
            id: diagonalGrid
            width: parent.width
            height: parent.height
            opacity: 0.08
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1

                for (var i = -height; i < width + height; i += 80) {
                    ctx.beginPath()
                    ctx.moveTo(i, 0)
                    ctx.lineTo(i + height, height)
                    ctx.stroke()
                }
            }
        }
    }

    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 36
        color: "#111111"
        opacity: 0.0

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: logoText.width + 16
            height: 22
            radius: 6
            color: logoMouse.containsMouse ? "#1e2d45" : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                id: logoText
                anchors.centerIn: parent
                text: "PED OS"
                color: "#ffffff"
                font.pixelSize: 12
                font.letterSpacing: 4
                font.family: root.pedFont
                opacity: 0.7
            }

            MouseArea {
                id: logoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (pedLauncher.visible)
                        pedLauncher.hide()
                    else
                        pedLauncher.show()
                }
            }
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: "#ffffff"
            font.pixelSize: 13
            font.family: root.pedFont
            opacity: 0.8

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }

            Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
                width: 26
                height: 22
                radius: 6
                color: gameMode.active ? "#ff4d00" : "#1a2030"
                border.color: gameMode.active ? "#ff6a00" : "#2a3a55"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "🎮"
                    font.pixelSize: 13
                    opacity: gameMode.active ? 1.0 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gameMode.toggle()
                        systemStats.visible = gameMode.active
                        if (gameMode.active) {
                            notifCenter.send("Game Mode ON", "Performance optimized for gaming.", "🎮")
                            if (!appLauncher.isMangoHudInstalled())
                                notifCenter.send("MangoHud missing", "Install on Arch: sudo pacman -S mangohud lib32-mangohud", "⚠️")
                            if (!appLauncher.isGameModeRunInstalled())
                                notifCenter.send("gamemoderun missing", "Install on Arch: sudo pacman -S gamemode lib32-gamemode", "⚠️")
                        } else {
                            notifCenter.send("Game Mode OFF", "System back to normal.", "💤")
                        }
                    }
                }
            }

            Text {
                text: systemInfo.networkConnected ? "🌐" : "🚫"
                color: systemInfo.networkConnected ? "#4d9eff" : "#ff4d4d"
                font.pixelSize: 13
                opacity: 0.8
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: systemInfo.hasBattery
                text: systemInfo.batteryCharging ? "⚡" : (systemInfo.batteryLevel < 20 ? "🪫" : "🔋")
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: systemInfo.hasBattery
                text: systemInfo.batteryLevel + "%"
                color: systemInfo.batteryLevel < 20 ? "#ff4d4d" : "#ffffff"
                font.pixelSize: 12
                font.family: root.pedFont
                opacity: 0.7
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: dateText
                color: "#ffffff"
                font.pixelSize: 12
                font.family: root.pedFont
                opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                }

                Component.onCompleted: text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
            }
        }

        NumberAnimation on opacity {
            from: 0.0
            to: 0.9
            duration: 800
            easing.type: Easing.OutCubic
            running: true
        }
    }

    Column {
        id: centerLogo
        anchors.centerIn: parent
        spacing: 12
        opacity: 0.0

        SequentialAnimation on opacity {
            running: true
            NumberAnimation { from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PED OS"
            color: "#ffffff"
            font.pixelSize: 48
            font.letterSpacing: 8
            font.family: root.pedFont
            opacity: 0.9
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "gaming on linux, effortless."
            color: root.themeAccent
            font.pixelSize: 14
            font.letterSpacing: 2
            font.family: root.pedFont
            opacity: 0.7
        }
    }

    Item {
        id: dockContainer
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: dockRow.width + 24
        height: 90
        z: 80

        Rectangle {
            id: globalTooltip
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: dockBg.top
            anchors.bottomMargin: 8
            height: 22
            width: globalTooltipText.width + 16
            radius: 8
            color: "#1e1e1e"
            opacity: 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Text {
                id: globalTooltipText
                anchors.centerIn: parent
                text: ""
                color: "#ffffff"
                font.pixelSize: 12
                font.family: root.pedFont
                opacity: 0.9
            }
        }

        Rectangle {
            id: dockBg
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 60
            radius: 16
            color: "#1a1a1a"
            opacity: 0.0

            SequentialAnimation on opacity {
                running: true
                PauseAnimation { duration: 400 }
                NumberAnimation { from: 0.0; to: 0.85; duration: 1000; easing.type: Easing.OutCubic }
            }
        }

        Row {
            id: dockRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: [
                    { icon: "🗂", label: "Files", command: "nautilus", args: [], windowClasses: ["org.gnome.Nautilus", "nautilus", "Nautilus"], processNames: ["nautilus"] },
                    { icon: "🌐", label: "Browser", command: "firefox", args: [], windowClasses: ["firefox", "Firefox", "Navigator.firefox"], processNames: ["firefox"] },
                    { icon: "⚙️", label: "Settings", internalAction: "settings" },
                    { icon: "🖥", label: "Terminal", command: "gnome-terminal", args: [], windowClasses: ["gnome-terminal", "Gnome-terminal"], processNames: ["gnome-terminal-server", "gnome-terminal"] },
                    { icon: "🎮", label: "Steam", command: "steam", args: [], flatpakId: "com.valvesoftware.Steam", windowClasses: ["steam", "Steam"], processNames: ["steam", "steamwebhelper"], gaming: true }
                ]

                delegate: Rectangle {
                    id: dockItem
                    width: dockItemMouse.containsMouse ? 52 : 44
                    height: dockItemMouse.containsMouse ? 52 : 44
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    radius: 12
                    color: dockItemMouse.containsMouse ? "#2a2a2a" : "transparent"

                    property bool active: {
                        root.dockStateVersion

                        var hasWindowClasses = modelData.windowClasses && modelData.windowClasses.length > 0
                        var hasProcessNames = modelData.processNames && modelData.processNames.length > 0

                        if (hasWindowClasses && appLauncher.isWindowOpen(modelData.windowClasses))
                            return true

                        if (hasProcessNames && appLauncher.isProcessRunning(modelData.processNames))
                            return true

                        return false
                    }

                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Behavior on height {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    transform: Translate {
                        id: bounceTranslate
                        y: 0
                    }

                    SequentialAnimation {
                        id: bounceAnim
                        NumberAnimation { target: bounceTranslate; property: "y"; to: -16; duration: 120; easing.type: Easing.OutCubic }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: 0; duration: 120; easing.type: Easing.InBounce }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: -8; duration: 80; easing.type: Easing.OutCubic }
                        NumberAnimation { target: bounceTranslate; property: "y"; to: 0; duration: 80; easing.type: Easing.InBounce }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: dockItemMouse.containsMouse ? 28 : 24
                        font.family: root.pedFont

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    Rectangle {
                        width: dockItem.active ? 6 : 0
                        height: 3
                        radius: 2
                        color: root.themeAccent
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        id: dockItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: function(mouse) {
                            mouse.accepted = true

                            if (mouse.button === Qt.RightButton) {
                                globalTooltip.opacity = 0.0
                                dockActionMenu.showForApp(
                                    modelData,
                                    dockItem.mapToItem(root.contentItem, dockItem.width / 2, 0)
                                )
                                return
                            }

                            dockActionMenu.hideMenu()
                            bounceAnim.start()

                           root.launchDesktopApp(modelData)
                        }

                        onContainsMouseChanged: {
                            if (containsMouse && !dockActionMenu.visible) {
                                globalTooltipText.text = modelData.label
                                globalTooltip.opacity = 1.0
                            } else {
                                globalTooltip.opacity = 0.0
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: dockActionMenu
        width: 150
        height: actionColumn.height + 12
        radius: 8
        color: "#0e1520"
        border.color: "#2a3a55"
        border.width: 1
        visible: false
        z: 180

        property var currentApp: null

        function showForApp(app, point) {
            currentApp = app
            x = Math.max(8, Math.min(root.width - width - 8, point.x - width / 2))
            y = Math.max(44, point.y - height - 10)
            visible = true
        }

        function hideMenu() {
            visible = false
            currentApp = null
        }

        Column {
            id: actionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 6
            spacing: 2

            Rectangle {
                width: parent.width
                height: 34
                color: openMouse.containsMouse ? "#1e2d45" : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: "Open / Focus"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.family: root.pedFont
                }

                MouseArea {
                    id: openMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.launchDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34
                color: closeMouse.containsMouse ? "#3a1f2a" : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: "Close"
                    color: "#ff8a8a"
                    font.pixelSize: 12
                    font.family: root.pedFont
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp) {
                            appLauncher.closeApp(
                                dockActionMenu.currentApp.windowClasses || [],
                                dockActionMenu.currentApp.processNames || []
                            )
                        }

                        dockActionMenu.hideMenu()
                    }
                }
            }
        }
    }

    Launcher {
        id: pedLauncher
        anchors.fill: parent
        z: 100
        settingsPanel: pedSettings
        gameSettingsPanel: gameSettings
    }

    ContextMenu {
        id: contextMenu
        anchors.fill: parent
        z: 150
        onOpenSettingsRequested: pedSettings.show()
    }

MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: 1

        onClicked: function(mouse) {
            dockActionMenu.hideMenu()

            if (mouse.button === Qt.RightButton)
                contextMenu.show(mouse.x, mouse.y)
        }
    }

    NotificationCenter {
        id: notifCenter
        anchors.fill: parent
        z: 120
    }

    LoginScreen {
        id: loginScreen
        anchors.fill: parent
        z: 200

        onLoginSuccess: {
            loginScreen.destroy()
            notifCenter.send("Welcome back!", "PED OS is ready.", "👋")

            if (!userSettings.firstSetupCompleted)
                firstSetup.show()
        }
    }

    FpsOverlay {
        anchors.fill: parent
        z: 130
    }

    SettingsPanel {
        id: pedSettings
        anchors.fill: parent
        z: 190
    }

    GameSettingsPanel {
        id: gameSettings
        anchors.fill: parent
        z: 191
    }

    FirstSetupPanel {
        id: firstSetup
        anchors.fill: parent
        z: 195
    }
}
