import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: filesPanel
    anchors.fill: parent
    visible: false
    opacity: 0.0
    focus: visible

    property string currentPath: fileManager.homePath()
    property string selectedPath: ""
    property string selectedName: ""
    property bool selectedIsDir: false
    property var selectedPaths: []
    property var selectedEntries: []
    property var clipboardPaths: []
    property string clipboardMode: ""
    property var entries: []
    property var places: []
    property string sortKey: "name"
    property bool sortAscending: true
    property string mode: "browse"
    property bool dockActive: false
    property bool loading: false
    property string errorMessage: ""
    property string unavailableMessage: ""
    property string trashConfirmPath: ""
    property string deleteConfirmToken: ""
    property bool contextMenuVisible: false
    property real contextMenuX: 0
    property real contextMenuY: 0

    function show(path) {
        hideAnim.stop()
        visible = true
        forceActiveFocus()
        dockActive = true
        opacity = 0.0
        panel.scale = 0.985
        panelSlide.y = 14
        places = fileManager.places()
        loadPath(path && path.length > 0 ? path : currentPath)
        showAnim.start()
    }

    function hide() {
        if (!visible)
            return
        showAnim.stop()
        dockActive = false
        trashConfirmPath = ""
        deleteConfirmToken = ""
        trashConfirmTimer.stop()
        hideContextMenu()
        hideAnim.start()
    }

    function selectionCount() {
        return selectedPaths.length
    }

    function clearSelection() {
        selectedPath = ""
        selectedName = ""
        selectedIsDir = false
        selectedPaths = []
        selectedEntries = []
        trashConfirmPath = ""
        deleteConfirmToken = ""
        hideContextMenu()
    }

    function selectOnly(entry) {
        selectedPath = entry.path
        selectedName = entry.name
        selectedIsDir = entry.isDir
        selectedPaths = [entry.path]
        selectedEntries = [entry]
    }

    function toggleSelection(entry) {
        var paths = selectedPaths.slice()
        var selected = selectedEntries.slice()
        var index = paths.indexOf(entry.path)

        if (index >= 0) {
            paths.splice(index, 1)
            selected.splice(index, 1)
        } else {
            paths.push(entry.path)
            selected.push(entry)
        }

        selectedPaths = paths
        selectedEntries = selected

        if (selected.length > 0) {
            var last = selected[selected.length - 1]
            selectedPath = last.path
            selectedName = last.name
            selectedIsDir = last.isDir
        } else {
            selectedPath = ""
            selectedName = ""
            selectedIsDir = false
        }
    }

    function selectAllEntries() {
        var paths = []
        var selected = []

        for (var i = 0; i < entries.length; i++) {
            paths.push(entries[i].path)
            selected.push(entries[i])
        }

        selectedPaths = paths
        selectedEntries = selected

        if (selected.length > 0) {
            var last = selected[selected.length - 1]
            selectedPath = last.path
            selectedName = last.name
            selectedIsDir = last.isDir
        }
    }

    function handleEntryClick(entry, modifiers) {
        hideContextMenu()
        if (modifiers & Qt.ControlModifier || modifiers & Qt.ShiftModifier)
            toggleSelection(entry)
        else
            selectOnly(entry)
    }

    function selectionLabel() {
        if (selectionCount() === 0)
            return root.tr("No selection")
        if (selectionCount() === 1)
            return selectedName
        return root.tr("{count} selected").replace("{count}", selectionCount())
    }

    function currentPreview() {
        if (selectionCount() !== 1)
            return ({})
        return fileManager.previewInfo(selectedPath)
    }

    function stringList(paths) {
        var result = []
        for (var i = 0; i < paths.length; i++)
            result.push(String(paths[i]))
        return result
    }


    function showContextMenu(x, y) {
        contextMenuX = Math.max(8, Math.min(width - fileContextMenu.width - 8, x))
        contextMenuY = Math.max(8, Math.min(height - fileContextMenu.height - 8, y))
        contextMenuVisible = true
    }

    function hideContextMenu() {
        contextMenuVisible = false
    }

    function showEmptyContextMenu(x, y) {
        clearSelection()
        showContextMenu(x, y)
    }

    function beginRenameSelected() {
        if (selectionCount() !== 1)
            return

        hideContextMenu()
        mode = "rename"
        actionInput.text = selectedName
        actionInput.forceActiveFocus()
        actionInput.selectAll()
    }
    function requestTrashSelected() {
        if (selectionCount() === 0)
            return

        var token = selectedPaths.join("|")
        if (deleteConfirmToken !== token) {
            deleteConfirmToken = token
            trashConfirmPath = selectedPath
            trashConfirmTimer.restart()
            return
        }

        trashConfirmTimer.stop()
        trashConfirmPath = ""
        deleteConfirmToken = ""
        hideContextMenu()
        if (fileManager.movePathsToTrash(stringList(selectedPaths))) {
            notifCenter.send(root.tr("Moved to trash"), selectionLabel(), "FILES")
            refresh()
        } else {
            notifCenter.send(root.tr("Trash failed"), root.tr("Install gio or check permissions."), "FILES")
        }
    }

    Timer {
        id: trashConfirmTimer
        interval: 2600
        repeat: false
        onTriggered: {
            filesPanel.trashConfirmPath = ""
            filesPanel.deleteConfirmToken = ""
        }
    }

    Shortcut {
        sequence: "Ctrl+C"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.copySelected()
    }

    Shortcut {
        sequence: "Ctrl+X"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.cutSelected()
    }

    Shortcut {
        sequence: "Ctrl+V"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.pasteClipboard()
    }

    Shortcut {
        sequence: "Ctrl+A"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.selectAllEntries()
    }

    Shortcut {
        sequence: "Delete"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.requestTrashSelected()
    }

    Shortcut {
        sequence: "Return"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse"
        onActivated: filesPanel.openSelected()
    }

    Shortcut {
        sequence: "F2"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible && filesPanel.mode === "browse" && filesPanel.selectionCount() === 1
        onActivated: {
            filesPanel.mode = "rename"
            actionInput.text = filesPanel.selectedName
            actionInput.forceActiveFocus()
            actionInput.selectAll()
        }
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        enabled: filesPanel.visible
        onActivated: {
            if (filesPanel.mode !== "browse") {
                filesPanel.mode = "browse"
            } else {
                filesPanel.clearSelection()
            }
        }
    }

    function displayNameForPath(path) {
        if (!path || path === "/")
            return "/"

        var clean = path
        while (clean.length > 1 && clean.endsWith("/"))
            clean = clean.slice(0, -1)

        var parts = clean.split("/")
        return parts.length > 0 && parts[parts.length - 1].length > 0 ? parts[parts.length - 1] : clean
    }

    function breadcrumbParts() {
        var clean = currentPath || "/"
        while (clean.length > 1 && clean.endsWith("/"))
            clean = clean.slice(0, -1)

        if (clean === "/")
            return [{ label: "/", path: "/" }]

        var parts = clean.split("/")
        var result = [{ label: "/", path: "/" }]
        var built = ""

        for (var i = 0; i < parts.length; i++) {
            if (parts[i].length === 0)
                continue

            built += "/" + parts[i]
            result.push({ label: parts[i], path: built })
        }

        return result
    }

    function valueForSort(entry) {
        if (sortKey === "kind")
            return (entry.kind || "").toLowerCase()
        if (sortKey === "size")
            return entry.isDir ? -1 : (entry.size || "").toLowerCase()
        if (sortKey === "modified")
            return entry.modified || ""
        return (entry.name || "").toLowerCase()
    }

    function sortedEntries(items) {
        var list = items ? items.slice() : []
        list.sort(function(a, b) {
            if (a.isDir !== b.isDir)
                return a.isDir ? -1 : 1

            var left = valueForSort(a)
            var right = valueForSort(b)
            if (left < right)
                return sortAscending ? -1 : 1
            if (left > right)
                return sortAscending ? 1 : -1
            return 0
        })
        return list
    }

    function sortBy(key) {
        if (sortKey === key) {
            sortAscending = !sortAscending
        } else {
            sortKey = key
            sortAscending = true
        }
        entries = sortedEntries(entries)
    }

    function sortLabel(key, label) {
        return root.tr(label) + (sortKey === key ? (sortAscending ? " ^" : " v") : "")
    }

    function loadPath(path) {
        loading = true
        errorMessage = ""
        unavailableMessage = ""
        if (!path || path.length === 0) {
            loading = false
            unavailableMessage = root.tr("No folder selected.")
            entries = []
            return
        }

        currentPath = path
        pathInput.text = currentPath
        clearSelection()
        hideContextMenu()
        mode = "browse"
        entries = sortedEntries(fileManager.listDirectory(currentPath))
        loading = false
    }

    function openSelected() {
        if (selectionCount() !== 1 || selectedPath.length === 0)
            return

        if (selectedIsDir) {
            loadPath(selectedPath)
        } else if (!fileManager.openPath(selectedPath)) {
            notifCenter.send(root.tr("Open failed"), root.tr("No app handled this file."), "FILES")
        }
    }

    function copySelected() {
        if (selectionCount() === 0)
            return

        clipboardPaths = selectedPaths.slice()
        clipboardMode = "copy"
        hideContextMenu()
        notifCenter.send(root.tr("Copied"), selectionLabel(), "FILES")
    }

    function cutSelected() {
        if (selectionCount() === 0)
            return

        clipboardPaths = selectedPaths.slice()
        clipboardMode = "cut"
        hideContextMenu()
        notifCenter.send(root.tr("Cut"), selectionLabel(), "FILES")
    }

    function pasteClipboard() {
        if (clipboardPaths.length === 0)
            return

        hideContextMenu()
        var ok = clipboardMode === "cut"
            ? fileManager.movePaths(stringList(clipboardPaths), currentPath)
            : fileManager.copyPaths(stringList(clipboardPaths), currentPath)

        if (ok) {
            notifCenter.send(root.tr("Pasted"), root.tr("{count} items").replace("{count}", clipboardPaths.length), "FILES")
            if (clipboardMode === "cut") {
                clipboardPaths = []
                clipboardMode = ""
            }
            refresh()
        } else {
            notifCenter.send(root.tr("Paste failed"), root.tr("Could not paste selected items."), "FILES")
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

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: filesPanel; property: "opacity"; to: 1.0; duration: root.motionExpressive; easing.type: Easing.OutCubic }
        SpringAnimation { target: panel; property: "scale"; to: 1.0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
        SpringAnimation { target: panelSlide; property: "y"; to: 0; spring: root.motionPanelSpring; damping: root.motionPanelDamping; epsilon: root.motionPanelEpsilon }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation { target: filesPanel; property: "opacity"; to: 0.0; duration: root.motionBase; easing.type: Easing.InCubic }
            SpringAnimation { target: panel; property: "scale"; to: 0.985; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
            SpringAnimation { target: panelSlide; property: "y"; to: 10; spring: root.motionPanelSpring; damping: 0.42; epsilon: root.motionPanelEpsilon }
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
        width: Math.min(1040, parent.width - root.panelMargin * 2)
        height: Math.min(root.compactLayout ? 640 : 620, parent.height - root.panelMargin * 2)
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
            spacing: root.compactLayout ? 8 : 12

            Row {
                width: parent.width
                height: 38
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 2

                    Text {
                        text: root.tr("File Manager")
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
                spacing: root.spaceSm

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
                width: parent.width
                height: 30
                radius: 8
                color: "#111a28"
                border.color: "#223247"
                border.width: 1
                clip: true

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 4

                    Repeater {
                        model: { filesPanel.currentPath; return filesPanel.breadcrumbParts() }

                        delegate: BreadcrumbButton {
                            label: modelData.label
                            active: modelData.path === filesPanel.currentPath
                            onClicked: filesPanel.loadPath(modelData.path)
                        }
                    }
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
                height: parent.height - 187 - (filesPanel.mode !== "browse" ? 42 : 0)
                spacing: root.panelGap

                Rectangle {
                    width: root.compactLayout ? 150 : 170
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

                        PanelStateView {
                            width: parent.width
                            height: 104
                            visible: filesPanel.places.length === 0
                            state: "unavailable"
                            title: root.tr("Places unavailable")
                            message: root.tr("Common folders could not be loaded.")
                            fontFamily: root.uiFont
                            accentColor: root.themeAccent
                            primaryTextColor: root.textPrimary
                            secondaryTextColor: root.textMuted
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
                    width: parent.width - (root.compactLayout ? 150 : 170) - root.panelGap
                    height: parent.height
                    radius: 10
                    color: "#101927"
                    border.color: "#223247"
                    border.width: 1

                    Item {
                        anchors.fill: parent
                        anchors.margins: 10
                        anchors.rightMargin: previewPane.visible ? 230 : 10

                        Column {
                            id: filesHeader
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 24
                            spacing: 4

                            Row {
                                width: parent.width
                                height: 24

                                Text {
                                    width: Math.max(120, parent.width - sortActions.width - 8)
                                    text: root.tr("{count} items").replace("{count}", filesPanel.entries.length)
                                    color: "#8ea4bd"
                                    font.pixelSize: 11
                                    font.family: root.uiFont
                                }

                                Row {
                                    id: sortActions
                                    width: childrenRect.width
                                    height: parent.height
                                    spacing: 6

                                    MiniAction {
                                        label: { filesPanel.sortKey; filesPanel.sortAscending; return filesPanel.sortLabel("name", "Name") }
                                        onClicked: filesPanel.sortBy("name")
                                    }

                                    MiniAction {
                                        label: { filesPanel.sortKey; filesPanel.sortAscending; return filesPanel.sortLabel("kind", "Type") }
                                        onClicked: filesPanel.sortBy("kind")
                                    }

                                    MiniAction {
                                        label: { filesPanel.sortKey; filesPanel.sortAscending; return filesPanel.sortLabel("modified", "Date") }
                                        onClicked: filesPanel.sortBy("modified")
                                    }

                                    MiniAction {
                                        label: { filesPanel.sortKey; filesPanel.sortAscending; return filesPanel.sortLabel("size", "Size") }
                                        onClicked: filesPanel.sortBy("size")
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: filesSeparator
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: filesHeader.bottom
                            anchors.topMargin: 8
                            height: 1
                            color: "#223247"
                        }

                        Item {
                            id: filesContentArea
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: filesSeparator.bottom
                            anchors.topMargin: 8
                            anchors.bottom: parent.bottom

                            PanelStateView {
                                anchors.fill: parent
                                visible: filesPanel.loading || filesPanel.errorMessage.length > 0 ||
                                         filesPanel.unavailableMessage.length > 0 || filesPanel.entries.length === 0
                                state: filesPanel.loading ? "loading" : (filesPanel.errorMessage.length > 0 ? "error" : (filesPanel.unavailableMessage.length > 0 ? "unavailable" : "empty"))
                                title: filesPanel.loading ? root.tr("Loading folder") :
                                       (filesPanel.errorMessage.length > 0 ? root.tr("Folder error") :
                                       (filesPanel.unavailableMessage.length > 0 ? root.tr("Folder unavailable") : root.tr("Folder is empty")))
                                message: filesPanel.loading ? root.tr("Reading local files.") :
                                         (filesPanel.errorMessage.length > 0 ? filesPanel.errorMessage :
                                         (filesPanel.unavailableMessage.length > 0 ? filesPanel.unavailableMessage : root.tr("Create a folder or choose another place.")))
                                actionLabel: filesPanel.loading ? "" : root.tr("Refresh")
                                fontFamily: root.uiFont
                                accentColor: root.themeAccent
                                primaryTextColor: root.textPrimary
                                secondaryTextColor: root.textMuted
                                onActionRequested: filesPanel.refresh()
                            }

                            MouseArea {
                                anchors.fill: parent
                                visible: filesPanel.loading || filesPanel.errorMessage.length > 0 ||
                                         filesPanel.unavailableMessage.length > 0 || filesPanel.entries.length === 0
                                acceptedButtons: Qt.RightButton
                                z: 18
                                onClicked: function(mouse) {
                                    var point = mapToItem(filesPanel, mouse.x, mouse.y)
                                    filesPanel.showEmptyContextMenu(point.x, point.y)
                                }
                            }

                            ListView {
                                id: filesList
                                anchors.fill: parent
                                visible: !filesPanel.loading && filesPanel.errorMessage.length === 0 &&
                                         filesPanel.unavailableMessage.length === 0 && filesPanel.entries.length > 0
                                clip: true
                                spacing: 2
                                model: filesPanel.entries

                                TapHandler {
                                    acceptedButtons: Qt.RightButton
                                    onTapped: function(point) {
                                        var localX = point.position.x
                                        var localY = point.position.y
                                        var index = filesList.indexAt(localX, localY)
                                        var mapped = filesList.mapToItem(filesPanel, localX, localY)
                                        if (index >= 0 && index < filesPanel.entries.length) {
                                            filesPanel.selectOnly(filesPanel.entries[index])
                                            filesPanel.showContextMenu(mapped.x, mapped.y)
                                        } else {
                                            filesPanel.showEmptyContextMenu(mapped.x, mapped.y)
                                        }
                                    }
                                }

                                delegate: FileRow {
                                    width: filesList.width
                                    name: modelData.name
                                    path: modelData.path
                                    icon: modelData.icon
                                    kind: modelData.kind
                                    size: modelData.size
                                    modified: modelData.modified
                                    isDir: modelData.isDir
                                    selected: filesPanel.selectedPaths.indexOf(modelData.path) >= 0
                                    cutMarked: filesPanel.clipboardMode === "cut" && filesPanel.clipboardPaths.indexOf(modelData.path) >= 0
                                    onClicked: function(modifiers) { filesPanel.handleEntryClick(modelData, modifiers) }
                                    onContextRequested: function(menuX, menuY) {
                                        filesPanel.selectOnly(modelData)
                                        filesPanel.showContextMenu(menuX, menuY)
                                    }
                                    onOpenRequested: {
                                        filesPanel.selectOnly(modelData)
                                        filesPanel.openSelected()
                                    }
                                }
                            }
                        }
                    }

                    PreviewPane {
                        id: previewPane
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        width: 214
                        visible: filesPanel.selectionCount() > 0
                        preview: filesPanel.currentPreview()
                        selectedCount: filesPanel.selectionCount()
                        selectionText: filesPanel.selectionLabel()
                    }
                }
            }
        }
    }


    LiquidGlass {
        id: fileContextMenu
        x: filesPanel.contextMenuX
        y: filesPanel.contextMenuY
        width: 168
        height: contextMenuColumn.height + root.spaceMd
        radius: root.radiusMd
        tintColor: root.surfaceBase
        accentColor: root.themeAccent
        borderColor: root.borderMuted
        materialOpacity: 0.82
        borderOpacity: 0.58
        highlightOpacity: 0.14
        depth: 0.38
        visible: filesPanel.contextMenuVisible
        z: 260

        Column {
            id: contextMenuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: root.spaceSm
            spacing: 2

            ContextMenuAction { label: root.tr("Open"); enabled: filesPanel.selectionCount() === 1; onTriggered: { filesPanel.hideContextMenu(); filesPanel.openSelected() } }
            ContextMenuAction { label: root.tr("Copy"); enabled: filesPanel.selectionCount() > 0; onTriggered: filesPanel.copySelected() }
            ContextMenuAction { label: root.tr("Cut"); enabled: filesPanel.selectionCount() > 0; onTriggered: filesPanel.cutSelected() }
            ContextMenuAction { label: root.tr("Paste"); enabled: filesPanel.clipboardPaths.length > 0; onTriggered: filesPanel.pasteClipboard() }
            Rectangle { width: parent.width - root.spaceMd; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: root.borderSubtle }
            ContextMenuAction { label: root.tr("Rename"); enabled: filesPanel.selectionCount() === 1; onTriggered: filesPanel.beginRenameSelected() }
            ContextMenuAction { label: filesPanel.deleteConfirmToken === filesPanel.selectedPaths.join("|") && filesPanel.selectionCount() > 0 ? root.tr("Confirm trash") : root.tr("Trash"); enabled: filesPanel.selectionCount() > 0; danger: true; onTriggered: filesPanel.requestTrashSelected() }
        }
    }
    component BreadcrumbButton: Rectangle {
        id: breadcrumbButton
        property string label: ""
        property bool active: false
        signal clicked()

        width: Math.max(28, breadcrumbText.width + 18)
        height: 22
        radius: 6
        color: active ? "#1e2d45" : (breadcrumbMouse.containsMouse ? "#172233" : "transparent")
        border.color: active ? root.themeAccent : "transparent"
        border.width: active ? 1 : 0

        Text {
            id: breadcrumbText
            anchors.centerIn: parent
            text: breadcrumbButton.label
            color: breadcrumbButton.active ? "#ffffff" : "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: breadcrumbMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: breadcrumbButton.clicked()
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
            enabled: action.enabled
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


    component ContextMenuAction: Rectangle {
        id: menuAction
        property string label: ""
        property bool danger: false
        signal triggered()

        width: parent.width
        height: 32
        color: actionMouse.containsMouse && enabled ? (danger ? "#3a1f2a" : root.surfaceHover) : "transparent"
        opacity: enabled ? 1.0 : 0.42

        Text {
            anchors.left: parent.left
            anchors.leftMargin: root.spaceMd
            anchors.verticalCenter: parent.verticalCenter
            text: menuAction.label
            color: menuAction.danger ? "#ff9a9a" : root.textPrimary
            font.pixelSize: root.textSmall
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            enabled: menuAction.enabled
            hoverEnabled: enabled
            onClicked: menuAction.triggered()
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
        property bool cutMarked: false
        signal clicked(var modifiers)
        signal contextRequested(real menuX, real menuY)
        signal openRequested()

        height: 42
        radius: 8
        color: selected ? "#1e2d45" : (fileMouse.containsMouse ? "#172233" : "transparent")
        opacity: cutMarked ? 0.5 : 1.0

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

            Rectangle {
                visible: fileRow.isDir
                x: 7
                y: 7
                width: 10
                height: 5
                radius: 2
                color: root.themeAccent
                opacity: 0.9
            }

            Rectangle {
                visible: fileRow.isDir
                x: 5
                y: 11
                width: 18
                height: 12
                radius: 3
                color: root.themeAccent
                opacity: 0.75
            }

            Text {
                anchors.centerIn: parent
                visible: !fileRow.isDir
                text: fileRow.icon
                color: "#8ea4bd"
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    var point = fileMouse.mapToItem(filesPanel, mouse.x, mouse.y)
                    fileRow.contextRequested(point.x, point.y)
                    return
                }
                fileRow.clicked(mouse.modifiers)
            }
            onDoubleClicked: fileRow.openRequested()
        }
    }

    component PreviewPane: Rectangle {
        id: previewPaneRoot
        property var preview: ({})
        property int selectedCount: 0
        property string selectionText: ""

        radius: 10
        color: "#111a28"
        border.color: "#223247"
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Text {
                width: parent.width
                text: root.tr("Preview")
                color: root.themeAccent
                font.pixelSize: 10
                font.family: root.uiFont
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 142
                radius: 9
                color: "#0e1520"
                border.color: "#223247"
                border.width: 1
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    visible: previewPaneRoot.selectedCount === 1 && previewPaneRoot.preview.previewSource && previewPaneRoot.preview.previewSource.length > 0
                    source: visible ? previewPaneRoot.preview.previewSource : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    spacing: 8
                    visible: previewPaneRoot.selectedCount !== 1 || !previewPaneRoot.preview.previewSource || previewPaneRoot.preview.previewSource.length === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: previewPaneRoot.selectedCount === 1 ? (previewPaneRoot.preview.icon || "DOC") : previewPaneRoot.selectedCount
                        color: root.themeAccent
                        font.pixelSize: previewPaneRoot.selectedCount === 1 ? 24 : 32
                        font.family: root.uiFont
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        text: previewPaneRoot.selectedCount === 1 ? root.tr(previewPaneRoot.preview.kind || "File") : root.tr("{count} selected").replace("{count}", previewPaneRoot.selectedCount)
                        color: root.textMuted
                        font.pixelSize: 11
                        font.family: root.uiFont
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                width: parent.width
                text: previewPaneRoot.selectionText
                color: root.textPrimary
                font.pixelSize: 13
                font.family: root.uiFont
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Column {
                width: parent.width
                spacing: 6
                visible: previewPaneRoot.selectedCount === 1

                PreviewInfoRow { width: parent.width; label: root.tr("Type"); value: root.tr(previewPaneRoot.preview.kind || "-") }
                PreviewInfoRow { width: parent.width; label: root.tr("Size"); value: previewPaneRoot.preview.size || "-" }
                PreviewInfoRow { width: parent.width; label: root.tr("Date"); value: previewPaneRoot.preview.modified || "-" }
                PreviewInfoRow { width: parent.width; label: root.tr("Created"); value: previewPaneRoot.preview.created || "-" }
                PreviewInfoRow { width: parent.width; label: root.tr("Extension"); value: previewPaneRoot.preview.extension || "-" }
                PreviewInfoRow {
                    width: parent.width
                    visible: previewPaneRoot.preview.childSummary && previewPaneRoot.preview.childSummary.length > 0
                    label: root.tr("Contains")
                    value: previewPaneRoot.preview.childSummary || "-"
                }
            }

            Column {
                width: parent.width
                spacing: 6
                visible: previewPaneRoot.selectedCount > 1

                PreviewInfoRow { width: parent.width; label: root.tr("Selected"); value: previewPaneRoot.selectedCount }
                PreviewInfoRow { width: parent.width; label: root.tr("Clipboard"); value: filesPanel.clipboardPaths.length > 0 ? root.tr(filesPanel.clipboardMode === "cut" ? "Cut" : "Copy") : "-" }
            }
        }
    }

    component PreviewInfoRow: Rectangle {
        id: infoRow
        property string label: ""
        property string value: ""

        height: 30
        radius: 7
        color: "#172233"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.label
            color: root.textMuted
            font.pixelSize: 10
            font.family: root.uiFont
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 74
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.value
            color: root.textPrimary
            font.pixelSize: 10
            font.family: root.uiFont
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }
}
