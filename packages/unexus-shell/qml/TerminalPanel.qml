import QtQuick 2.15

Item {
    id: terminalPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0
    focus: visible

    property bool dockActive: false
    property var history: []
    property int historyIndex: -1

    function show() {
        hideAnim.stop()
        visible = true
        dockActive = true
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        commandInput.forceActiveFocus()
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        hideAnim.start()
    }

    function submitCommand() {
        var command = commandInput.text.trim()
        if (command.length === 0)
            return

        history.push(command)
        historyIndex = history.length
        commandRunner.run(command)
        commandInput.text = ""
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: terminalPanel.visible
        onActivated: terminalPanel.hide()
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: terminalPanel; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        SpringAnimation { target: panel; property: "scale"; to: 1.0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
        SpringAnimation { target: panelSlide; property: "y"; to: 0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: terminalPanel; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            SpringAnimation { target: panel; property: "scale"; to: 0.985; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
            SpringAnimation { target: panelSlide; property: "y"; to: 10; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
        }
        ScriptAction { script: terminalPanel.visible = false }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: terminalPanel.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.58
    }

    Rectangle {
        id: panel
        width: Math.min(920, parent.width - root.panelMargin * 2)
        height: Math.min(620, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 14
        color: "#070b12"
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
                height: 38
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 2

                    Text {
                        text: root.tr("uNexus CMD")
                        color: root.textPrimary
                        font.pixelSize: 22
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        text: commandRunner.workingDirectory
                        color: root.textMuted
                        font.pixelSize: 11
                        font.family: root.uiFont
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                ControlButton {
                    id: closeButton
                    width: 72
                    height: 34
                    label: "X"
                    variant: "subtle"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    onClicked: terminalPanel.hide()
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#26384d" }

            Rectangle {
                width: parent.width
                height: parent.height - 122
                radius: 10
                color: "#050810"
                border.color: "#223247"
                border.width: 1
                clip: true

                Flickable {
                    id: outputFlick
                    anchors.fill: parent
                    anchors.margins: 12
                    contentWidth: width
                    contentHeight: outputText.height
                    clip: true

                    Text {
                        id: outputText
                        width: outputFlick.width
                        text: commandRunner.output.length > 0 ? commandRunner.output : root.tr("uNexus CMD ready.") + "\n" + root.tr("Type commands below.")
                        color: commandRunner.output.length > 0 ? "#d7e8ff" : root.textMuted
                        font.family: "monospace"
                        font.pixelSize: 12
                        wrapMode: Text.WrapAnywhere
                    }
                }

                Connections {
                    target: commandRunner
                    function onOutputChanged() {
                        outputFlick.contentY = Math.max(0, outputFlick.contentHeight - outputFlick.height)
                    }
                }
            }

            Row {
                width: parent.width
                height: 38
                spacing: 8

                Rectangle {
                    width: parent.width - runButton.width - stopButton.width - clearButton.width - 24
                    height: parent.height
                    radius: 8
                    color: "#101927"
                    border.color: commandInput.activeFocus ? root.themeAccent : "#223247"
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: "$"
                        color: root.themeAccent
                        font.family: "monospace"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    TextInput {
                        id: commandInput
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.textPrimary
                        selectionColor: root.themeAccent
                        font.family: "monospace"
                        font.pixelSize: 13
                        enabled: !commandRunner.busy
                        clip: true
                        onAccepted: terminalPanel.submitCommand()
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Up && history.length > 0) {
                                historyIndex = Math.max(0, historyIndex - 1)
                                text = history[historyIndex]
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down && history.length > 0) {
                                historyIndex = Math.min(history.length, historyIndex + 1)
                                text = historyIndex < history.length ? history[historyIndex] : ""
                                event.accepted = true
                            }
                        }
                    }
                }

                ControlButton {
                    id: runButton
                    width: 82
                    height: parent.height
                    label: commandRunner.busy ? root.tr("Running") : root.tr("Run")
                    variant: "primary"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    enabled: !commandRunner.busy
                    onClicked: terminalPanel.submitCommand()
                }

                ControlButton {
                    id: stopButton
                    width: 82
                    height: parent.height
                    label: root.tr("Stop")
                    variant: "danger"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    enabled: commandRunner.busy
                    onClicked: commandRunner.stop()
                }

                ControlButton {
                    id: clearButton
                    width: 82
                    height: parent.height
                    label: root.tr("Clear")
                    variant: "subtle"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    onClicked: commandRunner.clear()
                }
            }
        }
    }
}
