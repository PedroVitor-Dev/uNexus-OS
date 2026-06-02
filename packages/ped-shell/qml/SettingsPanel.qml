import QtQuick 2.15

Item {
    id: settingsPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0

    function show() {
        visible = true
        showAnim.start()
    }

    function hide() {
        hideAnim.start()
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
        width: Math.min(820, parent.width - 32)
        height: Math.min(560, parent.height - 72)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Row {
                width: parent.width
                height: 36
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
                        text: "System preferences, language, shell status and about"
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
                height: parent.height - 74
                spacing: 14

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: "Language"

                        SettingsOptionRow {
                            width: parent.width
                            label: "System language"
                            value: "English"
                        }

                        SettingsOptionRow {
                            width: parent.width
                            label: "Region"
                            value: "Auto"
                        }

                        SettingsHint {
                            width: parent.width
                            text: "Language switching is planned for the installer and first boot setup."
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: "Appearance"

                        SettingsOptionRow {
                            width: parent.width
                            label: "Theme"
                            value: root.themeName
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            ThemeButton {
                                label: "Neon"
                                swatch: "#4d9eff"
                                active: root.themeIndex === 0
                                onClicked: root.applyTheme(0, true)
                            }

                            ThemeButton {
                                label: "Violet"
                                swatch: "#b86cff"
                                active: root.themeIndex === 1
                                onClicked: root.applyTheme(1, true)
                            }

                            ThemeButton {
                                label: "Toxic"
                                swatch: "#00ff88"
                                active: root.themeIndex === 2
                                onClicked: root.applyTheme(2, true)
                            }

                            ThemeButton {
                                label: "Ember"
                                swatch: "#ff6a2a"
                                active: root.themeIndex === 3
                                onClicked: root.applyTheme(3, true)
                            }
                        }

                        SettingsOptionRow {
                            width: parent.width
                            label: "Font"
                            value: root.pedFont
                        }

                        SettingsToggle {
                            width: parent.width
                            label: "PED Stats Overlay"
                            detail: systemStats.visible ? "Visible on desktop" : "Hidden"
                            checked: systemStats.visible
                            onClicked: systemStats.visible = !systemStats.visible
                        }
                    }
                }

                Column {
                    width: Math.floor((parent.width - 14) / 2)
                    spacing: 10

                    SettingsSection {
                        width: parent.width
                        title: "System"

                        SettingsOptionRow {
                            width: parent.width
                            label: "Network"
                            value: systemInfo.networkConnected ? "Online" : "Offline"
                        }

                        SettingsOptionRow {
                            width: parent.width
                            label: "Battery"
                            value: systemInfo.hasBattery ? systemInfo.batteryLevel + "%" : "Not available"
                        }
                    }

                    SettingsSection {
                        width: parent.width
                        title: "About"

                        SettingsOptionRow {
                            width: parent.width
                            label: "Name"
                            value: "PED OS"
                        }

                        SettingsOptionRow {
                            width: parent.width
                            label: "Shell"
                            value: "ped-shell 0.1.0"
                        }

                        SettingsOptionRow {
                            width: parent.width
                            label: "License"
                            value: "GPL-3.0"
                        }

                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: 7
                            color: repoMouse.containsMouse ? "#254160" : "#172233"
                            border.color: root.themeAccent
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Copy repository URL"
                                color: "#b7ddff"
                                font.pixelSize: 12
                                font.family: root.pedFont
                            }

                            MouseArea {
                                id: repoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    appLauncher.copyToClipboard("https://github.com/PedroVitor-Dev/Ped-Os")
                                    notifCenter.send("Repository copied", "PED OS repository URL copied.", "INFO")
                                }
                            }
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
                color: root.themeAccent
                font.pixelSize: 11
                font.family: root.pedFont
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
            font.family: root.pedFont
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: optionRow.value
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.pedFont
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
            font.family: root.pedFont
            wrapMode: Text.WordWrap
        }
    }

    component ThemeButton: Rectangle {
        id: themeButton
        property string label: ""
        property color swatch: "#4d9eff"
        property bool active: false
        signal clicked()

        width: Math.floor((parent.width - 24) / 4)
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
            font.family: root.pedFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: themeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: themeButton.clicked()
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
}
