import QtQuick 2.15

Item {
    id: settingsPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0

    property bool toolsRefresh: false
    property bool dockActive: false
    property bool loading: false
    property string errorMessage: ""
    property string unavailableMessage: ""

    function show() {
        hideAnim.stop()
        visible = true
        dockActive = true
        loading = false
        errorMessage = ""
        var missingTools = []
        if (!appLauncher.isMangoHudInstalled())
            missingTools.push("MangoHud")
        if (!appLauncher.isGameModeRunInstalled())
            missingTools.push("GameModeRun")
        unavailableMessage = missingTools.length > 0 ? root.tr("Missing runtime tools: ") + missingTools.join(", ") : ""
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        toolsRefresh = !toolsRefresh
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        hideAnim.start()
    }

    function toggleGameMode() {
        gameMode.toggle()
        if (gameMode.active) {
            notifCenter.send(root.tr("Game Mode ON"), root.tr("Performance optimized for gaming."), "GAME")
        } else {
            notifCenter.send(root.tr("Game Mode OFF"), root.tr("System back to normal."), "IDLE")
        }
    }

    function runtimeReadyCount() {
        var count = 0
        if (appLauncher.isMangoHudInstalled())
            count++
        if (appLauncher.isGameModeRunInstalled())
            count++
        return count
    }

    function launcherReadyCount() {
        var count = 0
        if (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam"))
            count++
        if (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris"))
            count++
        if (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl"))
            count++
        if (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles"))
            count++
        return count
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: settingsPanel; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        NumberAnimation { target: panel; property: "scale"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        NumberAnimation { target: panelSlide; property: "y"; to: 0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: settingsPanel; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            NumberAnimation { target: panel; property: "scale"; to: 0.985; duration: root.motionBase; easing.type: Easing.InCubic }
            NumberAnimation { target: panelSlide; property: "y"; to: 10; duration: root.motionBase; easing.type: Easing.InCubic }
        }
        ScriptAction { script: settingsPanel.visible = false }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: settingsPanel.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.55
    }

    Rectangle {
        id: panel
        width: Math.min(800, parent.width - root.panelMargin * 2)
        height: Math.min(root.compactLayout ? 600 : 560, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: "#2d5f8f"
        border.width: 1
        transform: Translate { id: panelSlide; y: 0 }

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: root.panelPadding
            spacing: root.panelGap

            Row {
                width: parent.width
                height: 34
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 2

                    Text {
                        text: root.tr("Game Settings")
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        text: root.tr("Launchers, overlays and performance tools")
                        color: "#8ea4bd"
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                }

                Rectangle {
                    id: closeButton
                    width: 32
                    height: 32
                    radius: 8
                    color: closeMouse.containsMouse ? "#2a3445" : "#172233"
                    border.color: "#2a3a55"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "X"
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.family: root.uiFont
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: settingsPanel.hide()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#26384d" }

            PanelStateView {
                id: gameSettingsStateView
                width: parent.width
                height: visible ? 78 : 0
                visible: settingsPanel.loading || settingsPanel.errorMessage.length > 0 || settingsPanel.unavailableMessage.length > 0
                state: settingsPanel.loading ? "loading" : (settingsPanel.errorMessage.length > 0 ? "error" : "unavailable")
                title: settingsPanel.loading ? root.tr("Loading game settings") : (settingsPanel.errorMessage.length > 0 ? root.tr("Game settings error") : root.tr("Runtime tools unavailable"))
                message: settingsPanel.loading ? root.tr("Checking gaming tools.") :
                         (settingsPanel.errorMessage.length > 0 ? settingsPanel.errorMessage : settingsPanel.unavailableMessage)
                fontFamily: root.uiFont
                accentColor: "#2d5f8f"
                primaryTextColor: root.textPrimary
                secondaryTextColor: root.textMuted
            }

            Row {
                id: dashboardRow
                width: parent.width
                height: 76
                spacing: root.panelGap

                DashboardCard {
                    width: Math.floor((parent.width - root.panelGap * 2) / 3)
                    title: root.tr("Game Mode")
                    value: gameMode.active ? root.tr("ON") : root.tr("OFF")
                    detail: gameMode.active ? root.tr("Performance optimized for gaming.") : root.tr("Use normal system behavior")
                    active: gameMode.active
                }

                DashboardCard {
                    width: Math.floor((parent.width - root.panelGap * 2) / 3)
                    title: root.tr("Stats Overlay")
                    value: systemStats.visible ? root.tr("ON") : root.tr("OFF")
                    detail: systemStats.visible ? root.tr("CPU, RAM, GPU and temperature visible") : root.tr("Overlay hidden")
                    active: systemStats.visible
                }

                DashboardCard {
                    width: parent.width - Math.floor((parent.width - root.panelGap * 2) / 3) * 2 - root.panelGap * 2
                    title: root.tr("Runtime")
                    value: settingsPanel.runtimeReadyCount() + "/2"
                    detail: root.tr("Gaming Launchers") + ": " + settingsPanel.launcherReadyCount() + "/4"
                    active: settingsPanel.runtimeReadyCount() === 2
                }
            }

            Row {
                width: parent.width
                height: parent.height - 72 - gameSettingsStateView.height - dashboardRow.height - root.panelGap
                spacing: root.panelGap

                Column {
                    width: Math.floor((parent.width - root.panelGap) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: root.tr("Performance")

                        SettingsToggle {
                            width: parent.width
                            label: root.tr("Game Mode")
                            detail: gameMode.active ? root.tr("gamemoded optimizations enabled") : root.tr("Use normal system behavior")
                            checked: gameMode.active
                            onClicked: settingsPanel.toggleGameMode()
                        }

                        SettingsToggle {
                            width: parent.width
                            label: root.tr("uNexus Stats Overlay")
                            detail: systemStats.visible ? root.tr("CPU, RAM, GPU and temperature visible") : root.tr("Overlay hidden")
                            checked: systemStats.visible
                            onClicked: systemStats.visible = !systemStats.visible
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: root.tr("Runtime Tools")

                        SettingsStatusRow {
                            width: parent.width
                            label: "MangoHud"
                            installed: settingsPanel.toolsRefresh ? appLauncher.isMangoHudInstalled() : appLauncher.isMangoHudInstalled()
                        }

                        SettingsStatusRow {
                            width: parent.width
                            label: "GameModeRun"
                            installed: settingsPanel.toolsRefresh ? appLauncher.isGameModeRunInstalled() : appLauncher.isGameModeRunInstalled()
                            running: gameMode.active
                        }

                        ControlButton {
                            width: parent.width
                            height: 34
                            label: root.tr("Copy Steam launch options")
                            variant: "subtle"
                            fontFamily: root.uiFont
                            accentColor: root.themeAccent
                            motionDuration: root.motionQuick
                            onClicked: {
                                appLauncher.copyToClipboard("mangohud gamemoderun %command%")
                                notifCenter.send(root.tr("Launch options copied"), root.tr("Paste into Steam game launch options."), "GAME")
                            }
                        }
                    }
                }

                Column {
                    width: Math.floor((parent.width - root.panelGap) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: root.tr("Gaming Launchers")

                        SettingsInstallRow {
                            width: parent.width
                            label: "Steam"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam")) : (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam"))
                            running: appLauncher.isWindowOpen(["steam", "Steam"]) || appLauncher.isProcessRunning(["steam"])
                            installCommand: "flatpak install -y flathub com.valvesoftware.Steam"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Lutris"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris")) : (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris"))
                            running: appLauncher.isWindowOpen(["lutris", "Lutris"]) || appLauncher.isProcessRunning(["lutris"])
                            installCommand: "flatpak install -y flathub net.lutris.Lutris"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Heroic"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl")) : (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl"))
                            running: appLauncher.isWindowOpen(["heroic", "Heroic", "com.heroicgameslauncher.hgl"]) || appLauncher.isProcessRunning(["heroic", "heroicgameslauncher"])
                            installCommand: "flatpak install -y flathub com.heroicgameslauncher.hgl"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Bottles"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles")) : (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles"))
                            running: appLauncher.isWindowOpen(["bottles", "Bottles", "com.usebottles.bottles"]) || appLauncher.isProcessRunning(["bottles"])
                            installCommand: "flatpak install -y flathub com.usebottles.bottles"
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: root.tr("Shell")

                        SettingsInfoRow {
                            width: parent.width
                            label: root.tr("Network")
                            value: systemInfo.networkConnected ? root.tr("Online") : root.tr("Offline")
                        }

                        SettingsInfoRow {
                            width: parent.width
                            label: root.tr("Battery")
                            value: systemInfo.hasBattery ? systemInfo.batteryLevel + "%" : root.tr("Not available")
                        }
                    }
                }
            }
        }
    }

    component DashboardCard: Rectangle {
        id: dashboardCard
        property string title: ""
        property string value: ""
        property string detail: ""
        property bool active: false

        height: 76
        radius: root.radiusLg
        color: active ? "#14281f" : "#111a28"
        border.color: active ? "#2d8f62" : "#223247"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 3

            Text {
                text: dashboardCard.title
                color: root.textMuted
                font.pixelSize: root.textTiny
                font.family: root.uiFont
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: dashboardCard.value
                color: dashboardCard.active ? "#00ff88" : root.textPrimary
                font.pixelSize: 20
                font.family: root.uiFont
                font.bold: true
            }

            Text {
                text: dashboardCard.detail
                color: root.textMuted
                font.pixelSize: root.textTiny
                font.family: root.uiFont
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }

    component SettingsSection: Rectangle {
        id: section
        default property alias content: contentColumn.data
        property string title: ""

        height: contentColumn.height + 22
        radius: 10
        color: "#111a28"
        border.color: "#223247"
        border.width: 1

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 8

            Text {
                text: section.title
                color: "#4d9eff"
                font.pixelSize: 11
                font.family: root.uiFont
                font.letterSpacing: 1
            }
        }
    }

    component SettingsToggle: Rectangle {
        id: toggleRow
        property string label: ""
        property string detail: ""
        property bool checked: false
        signal clicked()

        height: 48
        radius: 8
        color: toggleMouse.containsMouse ? "#1b2a40" : "#172233"

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: toggleTrack.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: toggleRow.label
                color: "#ffffff"
                font.pixelSize: 13
                font.family: root.uiFont
            }

            Text {
                text: toggleRow.detail
                color: "#8ea4bd"
                font.pixelSize: 10
                font.family: root.uiFont
                elide: Text.ElideRight
                width: parent.width
            }
        }

        Rectangle {
            id: toggleTrack
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 42
            height: 22
            radius: 11
            color: toggleRow.checked ? "#1f8f5a" : "#2a3445"
            border.color: toggleRow.checked ? "#00ff88" : "#516070"
            border.width: 1

            Rectangle {
                width: 16
                height: 16
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                x: toggleRow.checked ? parent.width - width - 3 : 3
                color: "#ffffff"

                Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }
        }

        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: toggleRow.clicked()
        }
    }

    component SettingsStatusRow: Rectangle {
        id: statusRow
        property string label: ""
        property bool installed: false
        property bool running: false
        property bool needsRestart: false

        height: 36
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: statusRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        StatusChip {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            status: statusRow.running ? "running" : (statusRow.needsRestart ? "needs-restart" : (statusRow.installed ? "installed" : "missing"))
            label: statusRow.running ? root.tr("running") : (statusRow.needsRestart ? root.tr("needs restart") : (statusRow.installed ? root.tr("installed") : root.tr("missing")))
            fontFamily: root.uiFont
            accentColor: root.themeAccent
        }
    }

    component SettingsInstallRow: Rectangle {
        id: installRow
        property string label: ""
        property bool installed: false
        property bool running: false
        property bool needsRestart: false
        property string installCommand: ""

        height: 42
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: installRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        Rectangle {
            id: installButton
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: installRow.installed || installRow.running || installRow.needsRestart ? installStatus.width : 92
            height: 22
            radius: 7
            color: installRow.installed || installRow.running || installRow.needsRestart ? "transparent" : (installMouse.containsMouse ? "#254160" : "#172f49")
            border.color: installRow.installed || installRow.running || installRow.needsRestart ? "transparent" : "#2d5f8f"
            border.width: installRow.installed || installRow.running || installRow.needsRestart ? 0 : 1

            Text {
                id: installedLabel
                anchors.centerIn: parent
                visible: !installRow.installed && !installRow.running && !installRow.needsRestart
                text: root.tr("Copy install")
                color: "#b7ddff"
                font.pixelSize: 10
                font.family: root.uiFont
            }

            StatusChip {
                id: installStatus
                visible: installRow.installed || installRow.running || installRow.needsRestart
                anchors.centerIn: parent
                status: installRow.running ? "running" : (installRow.needsRestart ? "needs-restart" : "installed")
                label: installRow.running ? root.tr("running") : (installRow.needsRestart ? root.tr("needs restart") : root.tr("installed"))
                fontFamily: root.uiFont
                accentColor: root.themeAccent
            }

            MouseArea {
                id: installMouse
                anchors.fill: parent
                enabled: !installRow.installed && !installRow.running && !installRow.needsRestart && installRow.installCommand.length > 0
                hoverEnabled: enabled
                onClicked: {
                    appLauncher.copyToClipboard(installRow.installCommand)
                    notifCenter.send(root.tr("Install command copied"), root.trAppMessage("{app} Flatpak command copied.", installRow.label), "SETUP")
                }
            }
        }
    }
    component SettingsInfoRow: Rectangle {
        id: infoRow
        property string label: ""
        property string value: ""

        height: 36
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.value
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
        }
    }
}
