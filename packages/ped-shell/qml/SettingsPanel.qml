import QtQuick 2.15

Item {
    id: settingsPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0

    property bool toolsRefresh: false

    function show() {
        visible = true
        toolsRefresh = !toolsRefresh
        showAnim.start()
    }

    function hide() {
        hideAnim.start()
    }

    function toggleGameMode() {
        gameMode.toggle()
        if (gameMode.active) {
            notifCenter.send("Game Mode ON", "Performance optimized for gaming.", "GAME")
        } else {
            notifCenter.send("Game Mode OFF", "System back to normal.", "IDLE")
        }
    }

    NumberAnimation {
        id: showAnim
        target: settingsPanel
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 180
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: settingsPanel
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 140
            easing.type: Easing.InCubic
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
        width: Math.min(760, parent.width - 32)
        height: Math.min(560, parent.height - 72)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: "#2d5f8f"
        border.width: 1

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Row {
                width: parent.width
                height: 34
                spacing: 10

                Column {
                    width: parent.width - closeButton.width - 10
                    spacing: 2

                    Text {
                        text: "PED Settings"
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.family: root.pedFont
                        font.bold: true
                    }

                    Text {
                        text: "Gaming tools, performance overlay and shell behavior"
                        color: "#8ea4bd"
                        font.pixelSize: 12
                        font.family: root.pedFont
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
                        font.family: root.pedFont
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

            Row {
                width: parent.width
                height: parent.height - 72
                spacing: 14

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: "Performance"

                        SettingsToggle {
                            width: parent.width
                            label: "Game Mode"
                            detail: gameMode.active ? "gamemoded optimizations enabled" : "Use normal system behavior"
                            checked: gameMode.active
                            onClicked: settingsPanel.toggleGameMode()
                        }

                        SettingsToggle {
                            width: parent.width
                            label: "PED Stats Overlay"
                            detail: systemStats.visible ? "CPU, RAM, GPU and temperature visible" : "Overlay hidden"
                            checked: systemStats.visible
                            onClicked: systemStats.visible = !systemStats.visible
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: "Runtime Tools"

                        SettingsStatusRow {
                            width: parent.width
                            label: "MangoHud"
                            installed: settingsPanel.toolsRefresh ? appLauncher.isMangoHudInstalled() : appLauncher.isMangoHudInstalled()
                        }

                        SettingsStatusRow {
                            width: parent.width
                            label: "GameModeRun"
                            installed: settingsPanel.toolsRefresh ? appLauncher.isGameModeRunInstalled() : appLauncher.isGameModeRunInstalled()
                        }

                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: 7
                            color: copyMouse.containsMouse ? "#254160" : "#172233"
                            border.color: "#2d5f8f"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Copy Steam launch options"
                                color: "#b7ddff"
                                font.pixelSize: 12
                                font.family: root.pedFont
                            }

                            MouseArea {
                                id: copyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    appLauncher.copyToClipboard("mangohud gamemoderun %command%")
                                    notifCenter.send("Launch options copied", "Paste into Steam game launch options.", "GAME")
                                }
                            }
                        }
                    }
                }

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: "Gaming Launchers"

                        SettingsInstallRow {
                            width: parent.width
                            label: "Steam"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam")) : (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam"))
                            installCommand: "flatpak install -y flathub com.valvesoftware.Steam"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Lutris"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris")) : (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris"))
                            installCommand: "flatpak install -y flathub net.lutris.Lutris"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Heroic"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl")) : (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl"))
                            installCommand: "flatpak install -y flathub com.heroicgameslauncher.hgl"
                        }

                        SettingsInstallRow {
                            width: parent.width
                            label: "Bottles"
                            installed: settingsPanel.toolsRefresh ? (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles")) : (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles"))
                            installCommand: "flatpak install -y flathub com.usebottles.bottles"
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: "Shell"

                        SettingsInfoRow {
                            width: parent.width
                            label: "Network"
                            value: systemInfo.networkConnected ? "Online" : "Offline"
                        }

                        SettingsInfoRow {
                            width: parent.width
                            label: "Battery"
                            value: systemInfo.hasBattery ? systemInfo.batteryLevel + "%" : "Not available"
                        }
                    }
                }
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
                font.family: root.pedFont
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
                font.family: root.pedFont
            }

            Text {
                text: toggleRow.detail
                color: "#8ea4bd"
                font.pixelSize: 10
                font.family: root.pedFont
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
            font.family: root.pedFont
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: statusLabel.width + 14
            height: 20
            radius: 7
            color: statusRow.installed ? "#0d3020" : "#2a1010"

            Text {
                id: statusLabel
                anchors.centerIn: parent
                text: statusRow.installed ? "installed" : "missing"
                color: statusRow.installed ? "#00ff88" : "#ff6b6b"
                font.pixelSize: 10
                font.family: root.pedFont
            }
        }
    }

    component SettingsInstallRow: Rectangle {
        id: installRow
        property string label: ""
        property bool installed: false
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
            font.family: root.pedFont
        }

        Rectangle {
            id: installButton
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: installRow.installed ? installedLabel.width + 14 : 92
            height: 22
            radius: 7
            color: installRow.installed ? "#0d3020" : (installMouse.containsMouse ? "#254160" : "#172f49")
            border.color: installRow.installed ? "transparent" : "#2d5f8f"
            border.width: installRow.installed ? 0 : 1

            Text {
                id: installedLabel
                anchors.centerIn: parent
                text: installRow.installed ? "installed" : "Copy install"
                color: installRow.installed ? "#00ff88" : "#b7ddff"
                font.pixelSize: 10
                font.family: root.pedFont
            }

            MouseArea {
                id: installMouse
                anchors.fill: parent
                enabled: !installRow.installed && installRow.installCommand.length > 0
                hoverEnabled: enabled
                onClicked: {
                    appLauncher.copyToClipboard(installRow.installCommand)
                    notifCenter.send("Install command copied", installRow.label + " Flatpak command copied.", "SETUP")
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
            font.family: root.pedFont
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.value
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.pedFont
        }
    }
}
