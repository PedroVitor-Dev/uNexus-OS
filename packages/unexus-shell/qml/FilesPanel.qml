import QtQuick 2.15

Item {
    id: filesPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0

    property string currentPath: fileManager.homePath()
    property string selectedPath: ""
    property string selectedName: ""
    property bool selectedIsDir: false
    property var entries: []
    property var places: []
    property string mode: "browse"
    property bool dockActive: false

    function show(path) {
        visible = true
        dockActive = true
        places = fileManager.places()
        loadPath(path && path.length > 0 ? path : currentPath)
        showAnim.start()
    }

    function hide() {
        dockActive = false
        hideAnim.start()
    }

    function loadPath(path) {
        currentPath = path
        pathInput.text = currentPath
        selectedPath = ""
        selectedName = ""
        selectedIsDir = false
        mode = "browse"
        entries = fileManager.listDirectory(currentPath)
    }

    function openSelected() {
        if (selectedPath.length === 0)
            return

        if (selectedIsDir) {
            loadPath(selectedPath)
        } else if (!fileManager.openPath(selectedPath)) {
            notifCenter.send(root.tr("Open failed"), root.tr("No app handled this file."), "FILES")
        }
    }

    function refresh() {
        loadPath(currentPath)
    }

    function submitAction() {
        if (mode === "newFolder") {
            if (fileManager.createFolder(currentPath, actionInput.text)) {
                notifCenter.send(root.tr("Folder created"), actionInput.text, "FILES")
                refresh()
            } else {
                notifCenter.send(root.tr("Folder failed"), root.tr("Could not create folder."), "FILES")
            }
        } else if (mode === "rename" && selectedPath.length > 0) {
            if (fileManager.renamePath(selectedPath, actionInput.text)) {
                notifCenter.send(root.tr("Renamed"), actionInput.text, "FILES")
                refresh()
            } else {
                notifCenter.send(root.tr("Rename failed"), root.tr("Could not rename item."), "FILES")
            }
        }
    }

    NumberAnimation {
        id: showAnim
        target: filesPanel
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 180
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: filesPanel
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 140
            easing.type: Easing.InCubic
        }
        ScriptAction { script: filesPanel.visible = false }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: filesPanel.hide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.55
    }

    Rectangle {
        id: panel
        width: Math.min(980, parent.width - 32)
        height: Math.min(620, parent.height - 72)
        anchors.centerIn: parent
        radius: 14
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Row {
                width: parent.width
                height: 38
                spacing: 10

                Column {
                    width: parent.width - closeButton.width - 10
                    spacing: 2

                    Text {
                        text: root.tr("uNexus Files")
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        text: root.tr("Local files, game folders and quick system places")
                        color: "#8ea4bd"
                        font.pixelSize: 12
                        font.family: root.uiFont
                    }
                }

                ToolButton {
                    id: closeButton
                    label: "X"
                    onClicked: filesPanel.hide()
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#26384d" }

            Row {
                width: parent.width
                height: 38
                spacing: 8

                ToolButton {
                    label: root.tr("UP")
                    onClicked: filesPanel.loadPath(fileManager.parentPath(filesPanel.currentPath))
                }

                Rectangle {
                    width: parent.width - 304
                    height: 34
                    radius: 8
                    color: "#172233"
                    border.color: "#2a3a55"
                    border.width: 1

                    TextInput {
                        id: pathInput
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        color: "#ffffff"
                        selectionColor: root.themeAccent
                        font.pixelSize: 12
                        font.family: root.uiFont
                        clip: true
                        onAccepted: filesPanel.loadPath(text)
                    }
                }

                ToolButton {
                    label: root.tr("GO")
                    onClicked: filesPanel.loadPath(pathInput.text)
                }

                ToolButton {
                    label: root.tr("NEW")
                    onClicked: {
                        filesPanel.mode = "newFolder"
                        actionInput.text = root.tr("New Folder")
                        actionInput.forceActiveFocus()
                        actionInput.selectAll()
                    }
                }

                ToolButton {
                    label: root.tr("REF")
                    onClicked: filesPanel.refresh()
                }
            }

            Rectangle {
                visible: filesPanel.mode !== "browse"
                width: parent.width
                height: visible ? 42 : 0
                radius: 9
                color: "#111a28"
                border.color: "#223247"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8

                    Text {
                        width: 92
                        anchors.verticalCenter: parent.verticalCenter
                        text: filesPanel.mode === "rename" ? root.tr("Rename") : root.tr("New folder")
                        color: root.themeAccent
                        font.pixelSize: 11
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Rectangle {
                        width: parent.width - 250
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 7
                        color: "#172233"

                        TextInput {
                            id: actionInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#ffffff"
                            selectionColor: root.themeAccent
                            font.pixelSize: 12
                            font.family: root.uiFont
                            onAccepted: filesPanel.submitAction()
                        }
                    }

                    ToolButton {
                        label: root.tr("OK")
                        onClicked: filesPanel.submitAction()
                    }

                    ToolButton {
                        label: root.tr("ESC")
                        onClicked: filesPanel.mode = "browse"
                    }
                }
            }

            Row {
                width: parent.width
                height: parent.height - 145 - (filesPanel.mode !== "browse" ? 42 : 0)
                spacing: 12

                Rectangle {
                    width: 170
                    height: parent.height
                    radius: 10
                    color: "#111a28"
                    border.color: "#223247"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        Text {
                            text: root.tr("PLACES")
                            color: root.themeAccent
                            font.pixelSize: 10
                            font.family: root.uiFont
                            font.bold: true
                            opacity: 0.9
                        }

                        Repeater {
                            model: filesPanel.places

                            delegate: PlaceRow {
                                width: parent.width
                                label: root.tr(modelData.label)
                                icon: modelData.icon
                                active: modelData.path === filesPanel.currentPath
                                onClicked: filesPanel.loadPath(modelData.path)
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width - 182
                    height: parent.height
                    radius: 10
                    color: "#101927"
                    border.color: "#223247"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Row {
                            width: parent.width
                            height: 24

                            Text {
                                width: parent.width - selectedActions.width
                                text: root.tr("{count} items").replace("{count}", filesPanel.entries.length)
                                color: "#8ea4bd"
                                font.pixelSize: 11
                                font.family: root.uiFont
                            }

                            Row {
                                id: selectedActions
                                height: parent.height
                                spacing: 6
                                visible: filesPanel.selectedPath.length > 0

                                MiniAction {
                                    label: root.tr("Open")
                                    onClicked: filesPanel.openSelected()
                                }

                                MiniAction {
                                    label: root.tr("Rename")
                                    onClicked: {
                                        filesPanel.mode = "rename"
                                        actionInput.text = filesPanel.selectedName
                                        actionInput.forceActiveFocus()
                                        actionInput.selectAll()
                                    }
                                }

                                MiniAction {
                                    label: root.tr("Trash")
                                    danger: true
                                    onClicked: {
                                        if (fileManager.moveToTrash(filesPanel.selectedPath)) {
                                            notifCenter.send(root.tr("Moved to trash"), filesPanel.selectedName, "FILES")
                                            filesPanel.refresh()
                                        } else {
                                            notifCenter.send(root.tr("Trash failed"), root.tr("Install gio or check permissions."), "FILES")
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#223247" }

                        ListView {
                            id: filesList
                            width: parent.width
                            height: parent.height - 34
                            clip: true
                            spacing: 2
                            model: filesPanel.entries

                            delegate: FileRow {
                                width: filesList.width
                                name: modelData.name
                                path: modelData.path
                                icon: modelData.icon
                                kind: modelData.kind
                                size: modelData.size
                                modified: modelData.modified
                                isDir: modelData.isDir
                                selected: modelData.path === filesPanel.selectedPath
                                onClicked: {
                                    filesPanel.selectedPath = path
                                    filesPanel.selectedName = name
                                    filesPanel.selectedIsDir = isDir
                                }
                                onOpenRequested: {
                                    filesPanel.selectedPath = path
                                    filesPanel.selectedName = name
                                    filesPanel.selectedIsDir = isDir
                                    filesPanel.openSelected()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component ToolButton: Rectangle {
        id: toolButton
        property string label: ""
        signal clicked()

        width: 50
        height: 34
        radius: 8
        color: toolMouse.containsMouse ? "#254160" : "#172233"
        border.color: "#2a3a55"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: toolButton.label
            color: "#ffffff"
            font.pixelSize: 11
            font.family: root.uiFont
            font.bold: true
        }

        MouseArea {
            id: toolMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: toolButton.clicked()
        }
    }

    component MiniAction: Rectangle {
        id: action
        property string label: ""
        property bool danger: false
        signal clicked()

        width: actionText.width + 16
        height: 24
        radius: 7
        color: actionMouse.containsMouse ? (danger ? "#3a1f2a" : "#254160") : "#172233"
        border.color: danger ? "#7a3348" : "#2a3a55"
        border.width: 1

        Text {
            id: actionText
            anchors.centerIn: parent
            text: action.label
            color: action.danger ? "#ff9a9a" : "#b7ddff"
            font.pixelSize: 10
            font.family: root.uiFont
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: action.clicked()
        }
    }

    component PlaceRow: Rectangle {
        id: placeRow
        property string label: ""
        property string icon: ""
        property bool active: false
        signal clicked()

        height: 34
        radius: 8
        color: active ? "#1e2d45" : (placeMouse.containsMouse ? "#172233" : "transparent")

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: placeRow.icon
            color: root.themeAccent
            font.pixelSize: 10
            font.family: root.uiFont
            font.bold: true
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 48
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: placeRow.label
            color: "#ffffff"
            font.pixelSize: 12
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: placeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: placeRow.clicked()
        }
    }

    component FileRow: Rectangle {
        id: fileRow
        property string name: ""
        property string path: ""
        property string icon: ""
        property string kind: ""
        property string size: ""
        property string modified: ""
        property bool isDir: false
        property bool selected: false
        signal clicked()
        signal openRequested()

        height: 42
        radius: 8
        color: selected ? "#1e2d45" : (fileMouse.containsMouse ? "#172233" : "transparent")

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 8
            color: fileRow.isDir ? "#17304a" : "#1a2435"
            border.color: fileRow.isDir ? root.themeAccent : "#2a3a55"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: fileRow.icon
                color: fileRow.isDir ? root.themeAccent : "#8ea4bd"
                font.pixelSize: 9
                font.family: root.uiFont
                font.bold: true
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 46
            anchors.right: kindText.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: fileRow.name
            color: "#ffffff"
            font.pixelSize: 13
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Text {
            id: kindText
            anchors.right: sizeText.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 86
            text: root.tr(fileRow.kind)
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Text {
            id: sizeText
            anchors.right: modifiedText.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 76
            text: fileRow.size
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }

        Text {
            id: modifiedText
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 118
            text: fileRow.modified
            color: "#526a83"
            font.pixelSize: 10
            font.family: root.uiFont
            horizontalAlignment: Text.AlignRight
        }

        MouseArea {
            id: fileMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: fileRow.clicked()
            onDoubleClicked: fileRow.openRequested()
        }
    }
}
