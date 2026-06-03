import QtQuick 2.15

Item {
    id: firstSetup
    anchors.fill: parent
    visible: false
    opacity: 0.0
    property bool dockActive: false

    function show() {
        visible = true
        dockActive = true
        refreshToken = !refreshToken
        showAnim.start()
    }

    function hide() {
        dockActive = false
        hideAnim.start()
    }

    function complete() {
        userSettings.firstSetupCompleted = true
        hide()
        notifCenter.send(root.tr("Setup complete"), root.tr("uNexus gaming setup is ready."), "SETUP")
    }

    property bool refreshToken: false

    NumberAnimation {
        id: showAnim
        target: firstSetup
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 220
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: firstSetup
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 160
            easing.type: Easing.InCubic
        }
        ScriptAction { script: firstSetup.visible = false }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.62
    }

    Rectangle {
        id: panel
        width: Math.min(820, parent.width - 32)
        height: Math.min(590, parent.height - 56)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Row {
                width: parent.width
                height: 44
                spacing: 10

                Rectangle {
                    width: 42
                    height: 42
                    radius: 11
                    color: "#172233"
                    border.color: root.themeAccent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "uNexus"
                        color: root.themeAccent
                        font.pixelSize: 11
                        font.bold: true
                        font.family: root.uiFont
                    }
                }

                Column {
                    width: parent.width - 52
                    spacing: 2

                    Text {
                        text: root.tr("First Setup")
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.bold: true
                        font.family: root.uiFont
                    }

                    Text {
                        text: root.tr("Check gaming essentials and prepare uNexus for play")
                        color: "#8ea4bd"
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#26384d" }

            Row {
                width: parent.width
                height: parent.height - 116
                spacing: 14

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SetupSection {
                        width: parent.width
                        title: root.tr("Runtime")

                        SetupRow {
                            width: parent.width
                            label: "Flatpak"
                            ready: firstSetup.refreshToken ? appLauncher.isInstalled("flatpak") : appLauncher.isInstalled("flatpak")
                            command: "sudo pacman -S flatpak"
                        }

                        SetupRow {
                            width: parent.width
                            label: "MangoHud"
                            ready: firstSetup.refreshToken ? appLauncher.isMangoHudInstalled() : appLauncher.isMangoHudInstalled()
                            command: "sudo pacman -S mangohud lib32-mangohud"
                        }

                        SetupRow {
                            width: parent.width
                            label: "GameMode"
                            ready: firstSetup.refreshToken ? appLauncher.isGameModeRunInstalled() : appLauncher.isGameModeRunInstalled()
                            command: "sudo pacman -S gamemode lib32-gamemode"
                        }
                    }

                    SetupSection {
                        width: parent.width
                        title: root.tr("Recommended")

                        SetupHint {
                            width: parent.width
                            text: root.tr("Install Flatpak apps from Flathub for consistent game launcher support across uNexus builds.")
                        }

                        SetupCommandButton {
                            width: parent.width
                            label: root.tr("Copy Flathub setup")
                            command: "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
                        }
                    }
                }

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SetupSection {
                        width: parent.width
                        title: root.tr("Game Launchers")

                        SetupRow {
                            width: parent.width
                            label: "Steam"
                            ready: firstSetup.refreshToken ? (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam")) : (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam"))
                            command: "flatpak install -y flathub com.valvesoftware.Steam"
                        }

                        SetupRow {
                            width: parent.width
                            label: "Lutris"
                            ready: firstSetup.refreshToken ? (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris")) : (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris"))
                            command: "flatpak install -y flathub net.lutris.Lutris"
                        }

                        SetupRow {
                            width: parent.width
                            label: "Heroic"
                            ready: firstSetup.refreshToken ? (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl")) : (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl"))
                            command: "flatpak install -y flathub com.heroicgameslauncher.hgl"
                        }

                        SetupRow {
                            width: parent.width
                            label: "Bottles"
                            ready: firstSetup.refreshToken ? (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles")) : (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles"))
                            command: "flatpak install -y flathub com.usebottles.bottles"
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 40
                spacing: 10

                Rectangle {
                    width: parent.width - doneButton.width - 10
                    height: 38
                    radius: 8
                    color: "#101927"
                    border.color: "#24364c"
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.tr("You can reopen this checklist later from uNexus Settings.")
                        color: "#8ea4bd"
                        font.pixelSize: 11
                        font.family: root.uiFont
                    }
                }

                Rectangle {
                    id: doneButton
                    width: 160
                    height: 38
                    radius: 8
                    color: doneMouse.containsMouse ? root.themeAccent : "#172f49"
                    border.color: root.themeAccent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.tr("Finish setup")
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.family: root.uiFont
                        font.bold: true
                    }

                    MouseArea {
                        id: doneMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: firstSetup.complete()
                    }
                }
            }
        }
    }

    component SetupSection: Rectangle {
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
                color: root.themeAccent
                font.pixelSize: 11
                font.family: root.uiFont
                font.letterSpacing: 1
            }
        }
    }

    component SetupRow: Rectangle {
        id: setupRow
        property string label: ""
        property bool ready: false
        property string command: ""

        height: 42
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: setupRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: setupRow.ready ? statusLabel.width + 14 : 92
            height: 22
            radius: 7
            color: setupRow.ready ? "#0d3020" : (copyMouse.containsMouse ? "#254160" : "#172f49")
            border.color: setupRow.ready ? "transparent" : root.themeAccent
            border.width: setupRow.ready ? 0 : 1

            Text {
                id: statusLabel
                anchors.centerIn: parent
                text: setupRow.ready ? root.tr("ready") : root.tr("Copy install")
                color: setupRow.ready ? "#00ff88" : "#b7ddff"
                font.pixelSize: 10
                font.family: root.uiFont
            }

            MouseArea {
                id: copyMouse
                anchors.fill: parent
                enabled: !setupRow.ready && setupRow.command.length > 0
                hoverEnabled: enabled
                onClicked: {
                    appLauncher.copyToClipboard(setupRow.command)
                    notifCenter.send(root.tr("Install command copied"), root.trAppMessage("{app} command copied.", setupRow.label), "SETUP")
                }
            }
        }
    }

    component SetupCommandButton: Rectangle {
        id: commandButton
        property string label: ""
        property string command: ""

        height: 34
        radius: 7
        color: commandMouse.containsMouse ? "#254160" : "#172233"
        border.color: root.themeAccent
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: root.tr(commandButton.label)
            color: "#b7ddff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        MouseArea {
            id: commandMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                appLauncher.copyToClipboard(commandButton.command)
                notifCenter.send(root.tr("Command copied"), root.trLabelMessage("{label} copied.", commandButton.label), "SETUP")
            }
        }
    }

    component SetupHint: Rectangle {
        id: hintRow
        property string text: ""

        height: hintText.height + 18
        radius: 8
        color: "#101927"
        border.color: "#24364c"
        border.width: 1

        Text {
            id: hintText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            text: root.tr(hintRow.text)
            color: "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            wrapMode: Text.WordWrap
        }
    }
}
