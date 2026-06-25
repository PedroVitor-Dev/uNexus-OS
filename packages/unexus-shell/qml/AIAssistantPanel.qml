import QtQuick 2.15

Item {
    id: aiPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0
    focus: visible

    property bool dockActive: false

    function show() {
        hideAnim.stop()
        visible = true
        dockActive = true
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        messageInput.forceActiveFocus()
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        hideAnim.start()
    }

    function send() {
        var message = messageInput.text.trim()
        if (message.length === 0 || AIAssistantBackend.busy)
            return

        chatModel.append({ role: "user", text: message, streaming: false })
        chatModel.append({ role: "assistant", text: "", streaming: true })
        AIAssistantBackend.sendMessage(message)
        messageInput.text = ""
        chatView.positionViewAtEnd()
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: aiPanel.visible
        onActivated: aiPanel.hide()
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: aiPanel; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        SpringAnimation { target: panel; property: "scale"; to: 1.0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
        SpringAnimation { target: panelSlide; property: "y"; to: 0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: aiPanel; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            SpringAnimation { target: panel; property: "scale"; to: 0.985; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
            SpringAnimation { target: panelSlide; property: "y"; to: 10; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
        }
        ScriptAction { script: aiPanel.visible = false }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: aiPanel.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.58
    }

    Rectangle {
        id: panel
        width: Math.min(940, parent.width - root.panelMargin * 2)
        height: Math.min(660, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 14
        color: "#09101b"
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
                height: 42
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 3

                    Text {
                        text: root.tr("uNexus AI")
                        color: root.textPrimary
                        font.pixelSize: 22
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        text: AIAssistantBackend.networkLocked ? root.tr("100% local - no cloud, no telemetry") : root.tr("Privacy status unavailable")
                        color: root.themeAccent
                        font.pixelSize: 11
                        font.family: root.uiFont
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
                    onClicked: aiPanel.hide()
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#26384d" }

            Rectangle {
                width: parent.width
                height: 72
                radius: 10
                color: "#101927"
                border.color: "#223247"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 7

                    Text {
                        width: parent.width
                        text: root.tr("Local GGUF model path")
                        color: root.textMuted
                        font.pixelSize: 11
                        font.family: root.uiFont
                    }

                    Row {
                        width: parent.width
                        height: 34
                        spacing: 8

                        Rectangle {
                            width: parent.width - startButton.width - stopButton.width - 16
                            height: parent.height
                            radius: 8
                            color: "#050810"
                            border.color: modelPathInput.activeFocus ? root.themeAccent : "#223247"
                            border.width: 1

                            TextInput {
                                id: modelPathInput
                                anchors.fill: parent
                                anchors.margins: 9
                                text: AIAssistantBackend.defaultModelDirectory() + "/model.gguf"
                                color: root.textPrimary
                                selectionColor: root.themeAccent
                                font.family: "monospace"
                                font.pixelSize: 12
                                clip: true
                            }
                        }

                        ControlButton {
                            id: startButton
                            width: 92
                            height: parent.height
                            label: AIAssistantBackend.ready ? root.tr("Ready") : root.tr("Start")
                            variant: "primary"
                            fontFamily: root.uiFont
                            accentColor: root.themeAccent
                            motionDuration: root.motionQuick
                            enabled: !AIAssistantBackend.ready
                            onClicked: AIAssistantBackend.startEngine(modelPathInput.text)
                        }

                        ControlButton {
                            id: stopButton
                            width: 82
                            height: parent.height
                            label: root.tr("Stop")
                            variant: "subtle"
                            fontFamily: root.uiFont
                            accentColor: root.themeAccent
                            motionDuration: root.motionQuick
                            enabled: AIAssistantBackend.ready
                            onClicked: AIAssistantBackend.stopEngine()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height - 42 - 1 - 72 - 46 - root.panelGap * 4
                radius: 10
                color: "#050810"
                border.color: "#223247"
                border.width: 1
                clip: true

                ListView {
                    id: chatView
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 7
                    clip: true
                    model: ListModel { id: chatModel }
                    delegate: AIChatBubble {
                        role: model.role
                        text: model.text
                        streaming: model.streaming === true
                    }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 48
                        visible: chatModel.count === 0
                        text: root.tr("Ask for driver help, gaming setup, recovery steps or shell guidance.")
                        color: root.textMuted
                        font.pixelSize: 13
                        font.family: root.uiFont
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Row {
                width: parent.width
                height: 46
                spacing: 8

                Rectangle {
                    width: parent.width - sendButton.width - clearButton.width - 16
                    height: parent.height
                    radius: 8
                    color: "#101927"
                    border.color: messageInput.activeFocus ? root.themeAccent : "#223247"
                    border.width: 1

                    TextInput {
                        id: messageInput
                        anchors.fill: parent
                        anchors.margins: 12
                        color: root.textPrimary
                        selectionColor: root.themeAccent
                        font.family: root.uiFont
                        font.pixelSize: 13
                        enabled: AIAssistantBackend.ready && !AIAssistantBackend.busy
                        clip: true
                        onAccepted: aiPanel.send()
                    }
                }

                ControlButton {
                    id: sendButton
                    width: 84
                    height: parent.height
                    label: root.tr("Send")
                    variant: "primary"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    enabled: AIAssistantBackend.ready && !AIAssistantBackend.busy
                    onClicked: aiPanel.send()
                }

                ControlButton {
                    id: clearButton
                    width: 84
                    height: parent.height
                    label: root.tr("Clear")
                    variant: "subtle"
                    fontFamily: root.uiFont
                    accentColor: root.themeAccent
                    motionDuration: root.motionQuick
                    onClicked: {
                        chatModel.clear()
                        AIAssistantBackend.clearHistory()
                    }
                }
            }
        }
    }

    Connections {
        target: AIAssistantBackend

        function onTokenReceived(partialText) {
            var idx = chatModel.count - 1
            if (idx >= 0)
                chatModel.setProperty(idx, "text", chatModel.get(idx).text + partialText)
            chatView.positionViewAtEnd()
        }

        function onResponseFinished() {
            var idx = chatModel.count - 1
            if (idx >= 0)
                chatModel.setProperty(idx, "streaming", false)
            chatView.positionViewAtEnd()
        }

        function onErrorOccurred(message) {
            var idx = chatModel.count - 1
            if (idx >= 0 && chatModel.get(idx).streaming === true)
                chatModel.setProperty(idx, "streaming", false)
            chatModel.append({ role: "system", text: message, streaming: false })
            chatView.positionViewAtEnd()
        }

        function onHistoryCleared() {
            chatModel.clear()
        }
    }
}
