import QtQuick 2.15

Item {
    id: firstSetup
    anchors.fill: parent
    visible: false
    opacity: 0.0
    property bool dockActive: false
    property bool loading: false
    property string errorMessage: ""
    property string unavailableMessage: ""
    property bool finishConfirming: false

    function show() {
        hideAnim.stop()
        visible = true
        dockActive = true
        finishConfirming = false
        finishConfirmTimer.stop()
        loading = false
        errorMessage = ""
        unavailableMessage = appLauncher.isInstalled("flatpak") ? "" : root.tr("Flatpak is unavailable, so launcher installs may not work yet.")
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        refreshToken = !refreshToken
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        finishConfirming = false
        finishConfirmTimer.stop()
        hideAnim.start()
    }

    function complete() {
        userSettings.firstSetupCompleted = true
        hide()
        notifCenter.send(root.tr("Setup complete"), root.tr("uNexus gaming setup is ready."), "SETUP")
    }

    function requestComplete() {
        if (!finishConfirming) {
            finishConfirming = true
            finishConfirmTimer.restart()
            return
        }

        finishConfirmTimer.stop()
        finishConfirming = false
        complete()
    }

    Timer {
        id: finishConfirmTimer
        interval: 2600
        repeat: false
        onTriggered: firstSetup.finishConfirming = false
    }

    property bool refreshToken: false

    function setupCompleteReady() {
        refreshToken
        return appLauncher.isInstalled("flatpak") &&
               appLauncher.isMangoHudInstalled() &&
               appLauncher.isGameModeRunInstalled() &&
               (appLauncher.isInstalled("steam") || appLauncher.isFlatpakInstalled("com.valvesoftware.Steam")) &&
               (appLauncher.isInstalled("lutris") || appLauncher.isFlatpakInstalled("net.lutris.Lutris")) &&
               (appLauncher.isInstalled("heroic") || appLauncher.isInstalled("heroicgameslauncher") || appLauncher.isFlatpakInstalled("com.heroicgameslauncher.hgl")) &&
               (appLauncher.isInstalled("bottles") || appLauncher.isFlatpakInstalled("com.usebottles.bottles"))
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: firstSetup; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        NumberAnimation { target: panel; property: "scale"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        NumberAnimation { target: panelSlide; property: "y"; to: 0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: firstSetup; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            NumberAnimation { target: panel; property: "scale"; to: 0.985; duration: root.motionBase; easing.type: Easing.InCubic }
            NumberAnimation { target: panelSlide; property: "y"; to: 10; duration: root.motionBase; easing.type: Easing.InCubic }
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
        width: Math.min(860, parent.width - root.panelMargin * 2)
        height: Math.min(root.compactLayout ? 620 : 590, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1
        transform: Translate { id: panelSlide; y: 0 }

        Column {
            anchors.fill: parent
            anchors.margins: root.panelPadding
            spacing: root.panelGap

            Row {
                width: parent.width
                height: 38
                spacing: 0

                Column {
                    width: parent.width
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

            PanelStateView {
                id: firstSetupStateView
                width: parent.width
                height: visible ? 78 : 0
                visible: firstSetup.loading || firstSetup.errorMessage.length > 0 ||
                         firstSetup.unavailableMessage.length > 0 || firstSetup.setupCompleteReady()
                state: firstSetup.loading ? "loading" : (firstSetup.errorMessage.length > 0 ? "error" : (firstSetup.unavailableMessage.length > 0 ? "unavailable" : "empty"))
                title: firstSetup.loading ? root.tr("Loading setup") :
                       (firstSetup.errorMessage.length > 0 ? root.tr("Setup error") :
                       (firstSetup.unavailableMessage.length > 0 ? root.tr("Setup partially unavailable") : root.tr("No setup steps pending")))
                message: firstSetup.loading ? root.tr("Checking gaming essentials.") :
                         (firstSetup.errorMessage.length > 0 ? firstSetup.errorMessage :
                         (firstSetup.unavailableMessage.length > 0 ? firstSetup.unavailableMessage : root.tr("Your gaming essentials are ready.")))
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                primaryTextColor: root.textPrimary
                secondaryTextColor: root.textMuted
            }

            Row {
                width: parent.width
                height: parent.height - 116 - firstSetupStateView.height
                spacing: root.panelGap

                Column {
                    width: Math.floor((parent.width - root.panelGap) / 2)
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
                            needsRestart: ready && !gameMode.active
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
                    width: Math.floor((parent.width - root.panelGap) / 2)
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
                spacing: root.panelGap

                Rectangle {
                    width: parent.width - doneButton.width - root.panelGap
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

                ControlButton {
                    id: doneButton
                    width: 160
                    height: 38
                    label: firstSetup.finishConfirming ? root.tr("Confirm finish") : root.tr("Finish setup")
                    variant: firstSetup.finishConfirming ? "danger" : "primary"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    onClicked: firstSetup.requestComplete()
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
        property bool needsRestart: false
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
            width: setupRow.ready || setupRow.needsRestart ? setupStatus.width : 92
            height: 22
            radius: 7
            color: setupRow.ready || setupRow.needsRestart ? "transparent" : (copyMouse.containsMouse ? "#254160" : "#172f49")
            border.color: setupRow.ready || setupRow.needsRestart ? "transparent" : root.themeAccent
            border.width: setupRow.ready || setupRow.needsRestart ? 0 : 1

            Text {
                id: statusLabel
                anchors.centerIn: parent
                visible: !setupRow.ready && !setupRow.needsRestart
                text: root.tr("Copy install")
                color: "#b7ddff"
                font.pixelSize: 10
                font.family: root.uiFont
            }

            StatusChip {
                id: setupStatus
                visible: setupRow.ready || setupRow.needsRestart
                anchors.centerIn: parent
                status: setupRow.needsRestart ? "needs-restart" : "ready"
                label: setupRow.needsRestart ? root.tr("needs restart") : root.tr("ready")
                fontFamily: root.uiFont
                accentColor: root.themeAccent
            }

            MouseArea {
                id: copyMouse
                anchors.fill: parent
                enabled: !setupRow.ready && !setupRow.needsRestart && setupRow.command.length > 0
                hoverEnabled: enabled
                onClicked: {
                    appLauncher.copyToClipboard(setupRow.command)
                    notifCenter.send(root.tr("Install command copied"), root.trAppMessage("{app} command copied.", setupRow.label), "SETUP")
                }
            }
        }
    }

    component SetupCommandButton: ControlButton {
        id: commandButton
        property string command: ""

        height: 34
        variant: "subtle"
        fontFamily: root.uiFont
        accentColor: root.themeAccent
        motionDuration: root.motionQuick
        onClicked: {
            appLauncher.copyToClipboard(commandButton.command)
            notifCenter.send(root.tr("Command copied"), root.trLabelMessage("{label} copied.", commandButton.label), "SETUP")
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
