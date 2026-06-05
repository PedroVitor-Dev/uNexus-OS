import QtQuick 2.15

Item {
    id: settingsPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0
    property bool dockActive: false
    property bool loading: false
    property string errorMessage: ""
    property string unavailableMessage: ""
    property string activeSection: "system"

    function show() {
        hideAnim.stop()
        visible = true
        dockActive = true
        activeSection = userSettings.controlCenterSection
        loading = false
        errorMessage = ""
        unavailableMessage = systemInfo.hasBattery ? "" : root.tr("Battery data is unavailable on this device.")
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        hideAnim.start()
    }

    function setSection(section) {
        activeSection = section
        userSettings.controlCenterSection = section
    }

    function resetShortcutsToDefaults() {
        userSettings.launcherShortcut = "Meta+S"
        userSettings.settingsShortcut = "Meta+I"
        userSettings.gameSettingsShortcut = "Meta+Alt+G"
        userSettings.statsShortcut = "Meta+G"
        notifCenter.send(root.tr("Shortcuts restored"), root.tr("Default shortcuts applied."), "SYS")
    }

    function cycleTheme() {
        root.applyTheme((root.themeIndex + 1) % 6, true)
    }

    function toggleGameModeQuick() {
        gameMode.toggle()
        if (gameMode.active) {
            notifCenter.send(root.tr("Game Mode ON"), root.tr("Performance optimized for gaming."), "GAME")
        } else {
            notifCenter.send(root.tr("Game Mode OFF"), root.tr("System back to normal."), "IDLE")
        }
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: settingsPanel; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        SpringAnimation { target: panel; property: "scale"; to: 1.0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
        SpringAnimation { target: panelSlide; property: "y"; to: 0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: settingsPanel; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            SpringAnimation { target: panel; property: "scale"; to: 0.985; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
            SpringAnimation { target: panelSlide; property: "y"; to: 10; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
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
        width: Math.min(860, parent.width - root.panelMargin * 2)
        height: Math.min(root.compactLayout ? 600 : 560, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1
        transform: Translate { id: panelSlide; y: 0 }

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: root.panelPadding
            spacing: root.panelGap

            Row {
                width: parent.width
                height: 36
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 2

                    Text {
                        text: root.tr("uNexus Settings")
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        text: root.tr("System preferences, language, shell status and about")
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
                id: settingsStateView
                width: parent.width
                height: visible ? 78 : 0
                visible: settingsPanel.loading || settingsPanel.errorMessage.length > 0 || settingsPanel.unavailableMessage.length > 0
                state: settingsPanel.loading ? "loading" : (settingsPanel.errorMessage.length > 0 ? "error" : "unavailable")
                title: settingsPanel.loading ? root.tr("Loading settings") : (settingsPanel.errorMessage.length > 0 ? root.tr("Settings error") : root.tr("Some system data is unavailable"))
                message: settingsPanel.loading ? root.tr("Reading saved preferences.") :
                         (settingsPanel.errorMessage.length > 0 ? settingsPanel.errorMessage : settingsPanel.unavailableMessage)
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                primaryTextColor: root.textPrimary
                secondaryTextColor: root.textMuted
            }

            Row {
                width: parent.width
                height: parent.height - 74 - settingsStateView.height
                spacing: root.panelGap

                Rectangle {
                    width: root.compactLayout ? 142 : 170
                    height: parent.height
                    radius: root.radiusLg
                    color: "#101927"
                    border.color: "#223247"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        ControlNavButton { width: parent.width; label: root.tr("System"); value: "system"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                        ControlNavButton { width: parent.width; label: root.tr("Shortcuts"); value: "shortcuts"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                        ControlNavButton { width: parent.width; label: root.tr("Help"); value: "help"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                        ControlNavButton { width: parent.width; label: root.tr("Appearance"); value: "appearance"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                        ControlNavButton { width: parent.width; label: root.tr("Language"); value: "language"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                        ControlNavButton { width: parent.width; label: root.tr("About"); value: "about"; active: settingsPanel.activeSection === value; onClicked: settingsPanel.setSection(value) }
                    }
                }

                Flickable {
                    width: parent.width - (root.compactLayout ? 142 : 170) - root.panelGap
                    height: parent.height
                    contentWidth: width
                    contentHeight: contentColumn.height
                    clip: true

                    Column {
                        id: contentColumn
                        width: parent.width
                        spacing: 10

                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "system"
                        title: root.tr("System")

                        Row {
                            width: parent.width
                            spacing: 8

                            QuickToggle {
                                width: Math.floor((parent.width - 16) / 3)
                                label: root.tr("Stats Overlay")
                                active: systemStats.visible
                                value: systemStats.visible ? root.tr("ON") : root.tr("OFF")
                                onClicked: systemStats.visible = !systemStats.visible
                            }

                            QuickToggle {
                                width: Math.floor((parent.width - 16) / 3)
                                label: root.tr("Game Mode")
                                active: gameMode.active
                                value: gameMode.active ? root.tr("ON") : root.tr("OFF")
                                onClicked: settingsPanel.toggleGameModeQuick()
                            }

                            QuickToggle {
                                width: parent.width - Math.floor((parent.width - 16) / 3) * 2 - 16
                                label: root.tr("Theme")
                                active: true
                                value: root.themeName
                                onClicked: settingsPanel.cycleTheme()
                            }
                        }

                        SettingsOptionRow { width: parent.width; label: root.tr("Network"); value: systemInfo.networkConnected ? root.tr("Online") : root.tr("Offline") }
                        SettingsOptionRow { width: parent.width; label: root.tr("Battery"); value: systemInfo.hasBattery ? systemInfo.batteryLevel + "%" : root.tr("Not available") }
                        SettingsToggle { width: parent.width; label: root.tr("uNexus Stats Overlay"); detail: systemStats.visible ? root.tr("Visible on desktop") : root.tr("Hidden"); checked: systemStats.visible; onClicked: systemStats.visible = !systemStats.visible }
                        SettingsToggle { width: parent.width; label: root.tr("Notifications"); detail: userSettings.notificationsEnabled ? root.tr("Notifications enabled") : root.tr("Notifications disabled"); checked: userSettings.notificationsEnabled; onClicked: userSettings.notificationsEnabled = !userSettings.notificationsEnabled }
                        SettingsActionButton { width: parent.width; label: root.tr("Open First Setup"); onClicked: firstSetup.show() }
                    }

                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "shortcuts"
                        title: root.tr("Keyboard Shortcuts")

                        SettingsHint { width: parent.width; text: root.tr("Customize shortcuts") }
                        ShortcutEditRow { width: parent.width; label: root.tr("Launcher shortcut"); value: userSettings.launcherShortcut; defaultValue: "Meta+S"; onShortcutAccepted: function(sequence) { userSettings.launcherShortcut = sequence } }
                        ShortcutEditRow { width: parent.width; label: root.tr("Settings shortcut"); value: userSettings.settingsShortcut; defaultValue: "Meta+I"; onShortcutAccepted: function(sequence) { userSettings.settingsShortcut = sequence } }
                        ShortcutEditRow { width: parent.width; label: root.tr("Game Settings shortcut"); value: userSettings.gameSettingsShortcut; defaultValue: "Meta+Alt+G"; onShortcutAccepted: function(sequence) { userSettings.gameSettingsShortcut = sequence } }
                        ShortcutEditRow { width: parent.width; label: root.tr("Stats shortcut"); value: userSettings.statsShortcut; defaultValue: "Meta+G"; onShortcutAccepted: function(sequence) { userSettings.statsShortcut = sequence } }
                    }


                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "help"
                        title: root.tr("Shortcut Help")

                        SettingsHint { width: parent.width; text: root.tr("Windows-style shortcuts for daily shell control") }

                        SettingsSubheader { width: parent.width; label: root.tr("Global shortcuts") }
                        ShortcutRow { width: parent.width; label: root.tr("Open Launcher"); keys: userSettings.launcherShortcut }
                        ShortcutRow { width: parent.width; label: root.tr("Open Settings"); keys: userSettings.settingsShortcut }
                        ShortcutRow { width: parent.width; label: root.tr("Toggle Stats Overlay"); keys: userSettings.statsShortcut }
                        ShortcutRow { width: parent.width; label: root.tr("Open Game Settings"); keys: userSettings.gameSettingsShortcut }

                        SettingsSubheader { width: parent.width; label: root.tr("File Manager") }
                        ShortcutRow { width: parent.width; label: root.tr("Copy selected"); keys: "Ctrl+C" }
                        ShortcutRow { width: parent.width; label: root.tr("Cut selected"); keys: "Ctrl+X" }
                        ShortcutRow { width: parent.width; label: root.tr("Paste here"); keys: "Ctrl+V" }
                        ShortcutRow { width: parent.width; label: root.tr("Select all"); keys: "Ctrl+A" }
                        ShortcutRow { width: parent.width; label: root.tr("Rename selected"); keys: "F2" }
                        ShortcutRow { width: parent.width; label: root.tr("Trash selected"); keys: "Delete" }
                        ShortcutRow { width: parent.width; label: root.tr("Open selected"); keys: "Enter" }
                        ShortcutRow { width: parent.width; label: root.tr("Clear selection"); keys: "Esc" }

                        SettingsActionButton { width: parent.width; label: root.tr("Restore default shortcuts"); onClicked: settingsPanel.resetShortcutsToDefaults() }
                    }
                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "appearance"
                        title: root.tr("Appearance")

                        SettingsOptionRow { width: parent.width; label: root.tr("Theme"); value: root.themeName }

                        Grid {
                            width: parent.width
                            columns: 3
                            rowSpacing: 8
                            columnSpacing: 8
                            ThemeButton { label: "Neon"; swatch: "#4d9eff"; active: root.themeIndex === 0; onClicked: root.applyTheme(0, true) }
                            ThemeButton { label: "Violet"; swatch: "#b86cff"; active: root.themeIndex === 1; onClicked: root.applyTheme(1, true) }
                            ThemeButton { label: "Toxic"; swatch: "#00ff88"; active: root.themeIndex === 2; onClicked: root.applyTheme(2, true) }
                            ThemeButton { label: "Ember"; swatch: "#ff6a2a"; active: root.themeIndex === 3; onClicked: root.applyTheme(3, true) }
                            ThemeButton { label: "Aurora"; swatch: "#7cf7ff"; active: root.themeIndex === 4; onClicked: root.applyTheme(4, true) }
                            ThemeButton { label: "Solar"; swatch: "#f4ff52"; active: root.themeIndex === 5; onClicked: root.applyTheme(5, true) }
                        }

                        SettingsSubheader { width: parent.width; label: root.tr("Wallpaper") }
                        SettingsOptionRow { width: parent.width; label: root.tr("Desktop wallpaper"); value: root.wallpaperLabelForId(root.desktopWallpaperId) }

                        Grid {
                            id: wallpaperGrid
                            width: parent.width
                            columns: root.compactLayout ? 1 : 2
                            rowSpacing: 8
                            columnSpacing: 8

                            Repeater {
                                model: root.wallpaperOptions
                                WallpaperButton {
                                    width: root.compactLayout ? wallpaperGrid.width : Math.floor((wallpaperGrid.width - 8) / 2)
                                    label: modelData.label
                                    source: modelData.source
                                    active: root.desktopWallpaperId === modelData.id
                                    onClicked: {
                                        root.setWallpaper(modelData.id, true)
                                        notifCenter.send(root.tr("Wallpaper applied"), root.trLabelMessage("{label} is now active.", modelData.label), "SYS")
                                    }
                                }
                            }
                        }

                        SettingsOptionRow { width: parent.width; label: root.tr("Font"); value: root.uiFont }
                    }

                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "language"
                        title: root.tr("Language")

                        SettingsOptionRow { width: parent.width; label: root.tr("System language"); value: root.languageCode === "pt-BR" ? "Portuguese (Brasil)" : "English" }
                        SettingsOptionRow { width: parent.width; label: root.tr("Region"); value: root.tr("Auto") }

                        Row {
                            width: parent.width
                            spacing: 8
                            LanguageButton { label: "English"; active: root.languageCode === "en"; onClicked: root.setLanguage("en") }
                            LanguageButton { label: "Portugues"; active: root.languageCode === "pt-BR"; onClicked: root.setLanguage("pt-BR") }
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        collapsed: settingsPanel.activeSection !== "about"
                        title: root.tr("About")

                        Rectangle {
                            width: parent.width
                            height: 86
                            radius: 8
                            color: "#172233"
                            border.color: "#223247"
                            border.width: 1

                            Image {
                                anchors.fill: parent
                                anchors.margins: 8
                                source: root.brandLogoSource
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }
                        }

                        SettingsOptionRow { width: parent.width; label: root.tr("Name"); value: "uNexus" }
                        SettingsOptionRow { width: parent.width; label: root.tr("Shell"); value: "unexus-shell 0.1.0" }
                        SettingsOptionRow { width: parent.width; label: root.tr("License"); value: "GPL-3.0" }
                        SettingsActionButton {
                            width: parent.width
                            label: root.tr("Copy repository URL")
                            onClicked: {
                                appLauncher.copyToClipboard("https://github.com/PedroVitor-Dev/uNexus")
                                notifCenter.send(root.tr("Repository copied"), root.tr("uNexus repository URL copied."), "INFO")
                            }
                        }
                    }
                    }
                }
            }
        }
    }

    component ControlNavButton: Rectangle {
        id: navButton
        property string label: ""
        property string value: ""
        property bool active: false
        signal clicked()

        height: 38
        radius: root.radiusMd
        color: active ? "#1e2d45" : (navMouse.containsMouse ? "#172233" : "transparent")
        border.color: active ? root.themeAccent : "transparent"
        border.width: active ? 1 : 0

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            text: navButton.label
            color: navButton.active ? root.textPrimary : root.textMuted
            font.pixelSize: root.textSmall
            font.family: root.uiFont
            font.bold: navButton.active
            elide: Text.ElideRight
        }

        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: navButton.clicked()
        }
    }

    component SettingsActionButton: ControlButton {
        id: actionButton
        height: 34
        variant: "subtle"
        fontFamily: root.uiFont
        accentColor: root.themeAccent
        motionDuration: root.motionQuick
    }

    component SettingsSection: Rectangle {
        id: section
        default property alias content: contentColumn.data
        property string title: ""
        property bool collapsed: false

        visible: !collapsed
        height: collapsed ? 0 : contentColumn.height + 22
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

    component SettingsOptionRow: Rectangle {
        id: optionRow
        property string label: ""
        property string value: ""

        height: 38
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: optionRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: optionRow.value
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
        }
    }

    component SettingsSubheader: Rectangle {
        id: subheader
        property string label: ""

        height: 20
        radius: 0
        color: "transparent"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            text: subheader.label
            color: root.themeAccent
            font.pixelSize: root.textTiny
            font.family: root.uiFont
            font.bold: true
            font.letterSpacing: root.trackingSection
        }
    }

    component ShortcutRow: Rectangle {
        id: shortcutRow
        property string label: ""
        property string keys: ""

        height: 42
        radius: 8
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: keyBadge.left
            anchors.rightMargin: 10
            text: shortcutRow.label
            color: root.textPrimary
            font.pixelSize: 12
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Rectangle {
            id: keyBadge
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: keyText.width + 18
            height: 24
            radius: 7
            color: "#101927"
            border.color: root.themeAccent
            border.width: 1

            Text {
                id: keyText
                anchors.centerIn: parent
                text: shortcutRow.keys
                color: "#b7ddff"
                font.pixelSize: 10
                font.family: root.uiFont
                font.bold: true
            }
        }
    }


    component ShortcutEditRow: Rectangle {
        id: shortcutRow
        property string label: ""
        property string value: ""
        property string defaultValue: ""
        signal shortcutAccepted(string sequence)

        height: 44
        radius: 8
        color: "#172233"

        function applyShortcut() {
            shortcutRow.shortcutAccepted(shortcutInput.text)
            shortcutInput.focus = false
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: shortcutInputBox.left
            anchors.rightMargin: 10
            text: shortcutRow.label
            color: root.textPrimary
            font.pixelSize: 12
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Rectangle {
            id: shortcutInputBox
            anchors.right: applyButton.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: root.compactLayout ? 112 : 136
            height: 28
            radius: 7
            color: "#101927"
            border.color: root.themeAccent
            border.width: 1

            TextInput {
                id: shortcutInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                text: shortcutRow.value
                color: "#b7ddff"
                selectionColor: root.themeAccent
                font.pixelSize: 10
                font.family: root.uiFont
                font.bold: true
                onAccepted: shortcutRow.applyShortcut()
            }
        }

        ControlButton {
            id: applyButton
            anchors.right: resetButton.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 28
            label: root.tr("Apply")
            variant: "primary"
            fontFamily: root.uiFont
            accentColor: root.themeAccent
            motionDuration: root.motionQuick
            onClicked: shortcutRow.applyShortcut()
        }

        ControlButton {
            id: resetButton
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 76
            height: 28
            label: root.tr("Reset")
            variant: "subtle"
            fontFamily: root.uiFont
            accentColor: root.themeAccent
            motionDuration: root.motionQuick
            onClicked: {
                shortcutInput.text = shortcutRow.defaultValue
                shortcutRow.shortcutAccepted(shortcutRow.defaultValue)
            }
        }
    }
    component QuickToggle: Rectangle {
        id: quickToggle
        property string label: ""
        property string value: ""
        property bool active: false
        signal clicked()

        height: 54
        radius: 8
        color: quickMouse.containsMouse ? "#1b2a40" : "#172233"
        border.color: active ? root.themeAccent : "#223247"
        border.width: active ? 2 : 1

        Column {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 3

            Text {
                text: quickToggle.label
                color: root.textMuted
                font.pixelSize: 10
                font.family: root.uiFont
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: quickToggle.value
                color: quickToggle.active ? root.themeAccent : root.textPrimary
                font.pixelSize: 13
                font.family: root.uiFont
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }
        }

        MouseArea {
            id: quickMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: quickToggle.clicked()
        }
    }

    component SettingsHint: Rectangle {
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
            text: hintRow.text
            color: "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            wrapMode: Text.WordWrap
        }
    }

    component WallpaperButton: Rectangle {
        id: wallpaperButton
        property string label: ""
        property string source: ""
        property bool active: false
        signal clicked()

        height: 86
        radius: 8
        clip: true
        color: wallpaperMouse.containsMouse ? "#1b2a40" : "#172233"
        border.color: active ? root.themeAccent : "#223247"
        border.width: active ? 2 : 1

        Image {
            anchors.fill: parent
            anchors.margins: 4
            source: wallpaperButton.source
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            opacity: 0.82
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            color: "#101927"
            opacity: 0.86
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: activeBadge.left
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            text: wallpaperButton.label
            color: root.textPrimary
            font.pixelSize: 11
            font.family: root.uiFont
            font.bold: wallpaperButton.active
            elide: Text.ElideRight
        }

        Rectangle {
            id: activeBadge
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7
            width: 18
            height: 18
            radius: 9
            visible: wallpaperButton.active
            color: root.themeAccent

            Text {
                anchors.centerIn: parent
                text: "OK"
                color: "#071018"
                font.pixelSize: 7
                font.family: root.uiFont
                font.bold: true
            }
        }

        MouseArea {
            id: wallpaperMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wallpaperButton.clicked()
        }
    }
    component ThemeButton: Rectangle {
        id: themeButton
        property string label: ""
        property color swatch: "#4d9eff"
        property bool active: false
        signal clicked()

        width: parent && parent.columns === 3 ? Math.floor((parent.width - 16) / 3) : Math.floor((parent.width - 24) / 4)
        height: 42
        radius: 8
        color: themeMouse.containsMouse ? "#1b2a40" : "#172233"
        border.color: active ? swatch : "#223247"
        border.width: active ? 2 : 1

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: 7
            color: themeButton.swatch
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: themeButton.label
            color: themeButton.active ? "#ffffff" : "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: themeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: themeButton.clicked()
        }
    }

    component LanguageButton: Rectangle {
        id: languageButton
        property string label: ""
        property bool active: false
        signal clicked()

        width: Math.floor((parent.width - 8) / 2)
        height: 36
        radius: 8
        color: languageMouse.containsMouse ? "#1b2a40" : "#172233"
        border.color: active ? root.themeAccent : "#223247"
        border.width: active ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: languageButton.label
            color: languageButton.active ? "#ffffff" : "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: languageMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: languageButton.clicked()
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
}
