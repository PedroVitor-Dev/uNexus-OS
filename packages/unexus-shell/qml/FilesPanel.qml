import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
    property var filteredEntries: []
    property var places: []
    property string sortKey: "name"
    property bool sortAscending: true
    property string searchText: ""
    property string typeFilter: "any"
    property string dateFilter: "any"
    property string sizeFilter: "any"
    property string viewMode: "list"
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
    property bool breadcrumbMenuVisible: false
    property real breadcrumbMenuX: 0
    property real breadcrumbMenuY: 0
    property var breadcrumbMenuEntries: []
    property string pendingPasteMode: ""

    function activeOperationCount() {
        var count = 0
        var operations = fileManager.operationQueue || []
        for (var i = 0; i < operations.length; i++) {
            if (!operations[i].done)
                count++
        }
        return count
    }

    function operationSummary() {
        var operations = fileManager.operationQueue || []
        if (operations.length === 0)
            return root.tr("Operations") + ": -"

        var active = activeOperationCount()
        if (active > 0)
            return root.tr("Operations") + ": " + active + " " + root.tr("running")

        return root.tr("Operations") + ": " + root.tr("idle")
    }

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
        hideBreadcrumbMenu()
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
        hideBreadcrumbMenu()
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

        var active = activeEntries()
        for (var i = 0; i < active.length; i++) {
            paths.push(active[i].path)
            selected.push(active[i])
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
        hideBreadcrumbMenu()
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

    function hideBreadcrumbMenu() {
        breadcrumbMenuVisible = false
    }

    function showBreadcrumbMenu(path, x, y) {
        breadcrumbMenuEntries = fileManager.childDirectories(path)
        breadcrumbMenuX = Math.max(8, Math.min(width - breadcrumbMenu.width - 8, x))
        breadcrumbMenuY = Math.max(8, Math.min(height - breadcrumbMenu.height - 8, y))
        breadcrumbMenuVisible = true
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
        if (fileManager.movePathsToTrashAsync(stringList(selectedPaths)) >= 0) {
            notifCenter.send(root.tr("Trash"), selectionLabel(), "FILES")
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
        if (currentPath === "unexus://game-data")
            return [{ label: "Game Data", path: "unexus://game-data" }]

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
        filteredEntries = sortedEntries(filteredEntries)
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
            filteredEntries = []
            return
        }

        currentPath = path
        pathInput.text = currentPath
        clearSelection()
        hideContextMenu()
        hideBreadcrumbMenu()
        mode = "browse"
        entries = sortedEntries(fileManager.listDirectory(currentPath))
        updateSearch()
        loading = false
    }

    function searchActive() {
        return searchText.trim().length > 0 || typeFilter !== "any" || dateFilter !== "any" || sizeFilter !== "any"
    }

    function activeEntries() {
        return searchActive() ? filteredEntries : entries
    }

    function updateSearch() {
        if (!searchActive()) {
            filteredEntries = []
            return
        }

        filteredEntries = sortedEntries(fileManager.searchIndexed(currentPath, searchText, typeFilter, dateFilter, sizeFilter))
        clearSelection()
    }

    function cycleTypeFilter() {
        var values = ["any", "folder", "image", "video", "text", "pdf", "audio", "archive"]
        typeFilter = values[(values.indexOf(typeFilter) + 1) % values.length]
        updateSearch()
    }

    function cycleDateFilter() {
        var values = ["any", "today", "week", "month"]
        dateFilter = values[(values.indexOf(dateFilter) + 1) % values.length]
        updateSearch()
    }

    function cycleSizeFilter() {
        var values = ["any", "small", "medium", "large"]
        sizeFilter = values[(values.indexOf(sizeFilter) + 1) % values.length]
        updateSearch()
    }

    function typeFilterLabel() {
        if (typeFilter === "folder")
            return root.tr("Folders")
        if (typeFilter === "any")
            return root.tr("Any type")
        return root.tr(typeFilter.charAt(0).toUpperCase() + typeFilter.slice(1))
    }

    function dateFilterLabel() {
        if (dateFilter === "today")
            return root.tr("Today")
        if (dateFilter === "week")
            return root.tr("7 days")
        if (dateFilter === "month")
            return root.tr("30 days")
        return root.tr("Any date")
    }

    function sizeFilterLabel() {
        if (sizeFilter === "small")
            return root.tr("Small")
        if (sizeFilter === "medium")
            return root.tr("Medium")
        if (sizeFilter === "large")
            return root.tr("Large")
        return root.tr("Any size")
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
        pendingPasteMode = clipboardMode
        var operationId = clipboardMode === "cut"
            ? fileManager.movePathsAsync(stringList(clipboardPaths), currentPath)
            : fileManager.copyPathsAsync(stringList(clipboardPaths), currentPath)

        if (operationId >= 0) {
            notifCenter.send(root.tr("Pasted"), root.tr("{count} items").replace("{count}", clipboardPaths.length), "FILES")
        } else {
            pendingPasteMode = ""
            notifCenter.send(root.tr("Paste failed"), root.tr("Could not paste selected items."), "FILES")
        }
    }

    Connections {
        target: fileManager

        function onOperationFinished(id, ok, kind) {
            if (ok) {
                if (kind === "move" && filesPanel.pendingPasteMode === "cut") {
                    filesPanel.clipboardPaths = []
                    filesPanel.clipboardMode = ""
                    filesPanel.pendingPasteMode = ""
                }
                filesPanel.refresh()
            } else if (kind === "trash") {
                notifCenter.send(root.tr("Trash failed"), root.tr("Install gio or check permissions."), "FILES")
            } else {
                notifCenter.send(root.tr("Paste failed"), root.tr("Could not paste selected items."), "FILES")
            }
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
        width: Math.min(1180, parent.width - root.panelMargin * 2)
        height: Math.min(root.compactLayout ? 680 : 700, parent.height - root.panelMargin * 2)
        anchors.centerIn: parent
        radius: 12
        color: "#0e1520"
        border.color: root.themeAccent
        border.width: 1
        transform: Translate { id: panelSlide; y: 0 }

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: root.panelPadding
            spacing: root.compactLayout ? 8 : 10

            Row {
                width: parent.width
                height: 42
                spacing: root.panelGap

                Column {
                    width: parent.width - closeButton.width - root.panelGap
                    spacing: 2

                    Text {
                        text: root.tr("uNexus Files")
                        color: "#ffffff"
                        font.pixelSize: 23
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
                    label: root.tr("New")
                    onClicked: {
                        filesPanel.mode = "newFolder"
                        actionInput.text = root.tr("New Folder")
                        actionInput.forceActiveFocus()
                        actionInput.selectAll()
                    }
                }

                ToolButton {
                    label: root.tr("Refresh")
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
                            onMenuRequested: function(x, y) { filesPanel.showBreadcrumbMenu(modelData.path, x, y) }
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
                height: parent.height - 229 - (filesPanel.mode !== "browse" ? 42 : 0)
                spacing: root.panelGap

                Rectangle {
                    width: root.compactLayout ? 164 : 212
                    height: parent.height
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
                            text: root.tr("Places")
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

                        Rectangle { width: parent.width; height: 1; color: "#223247" }

                        Text {
                            width: parent.width
                            text: root.tr("Queue")
                            color: root.themeAccent
                            font.pixelSize: 10
                            font.family: root.uiFont
                            font.bold: true
                            opacity: 0.9
                        }

                        OperationQueue {
                            width: parent.width
                            operations: fileManager.operationQueue
                        }
                    }
                }

                Rectangle {
                    width: parent.width - (root.compactLayout ? 164 : 212) - root.panelGap
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
                            height: 58
                            spacing: 6

                            Row {
                                width: parent.width
                                height: 24

                                Text {
                                    width: Math.max(120, parent.width - sortActions.width - 8)
                                    text: root.tr("{count} items").replace("{count}", filesPanel.activeEntries().length) + (filesPanel.searchActive() ? " / " + root.tr("filtered") : "")
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

                                    MiniAction {
                                        label: root.tr("List")
                                        active: filesPanel.viewMode === "list"
                                        onClicked: filesPanel.viewMode = "list"
                                    }

                                    MiniAction {
                                        label: root.tr("Grid")
                                        active: filesPanel.viewMode === "grid"
                                        onClicked: filesPanel.viewMode = "grid"
                                    }
                                }
                            }

                            Row {
                                width: parent.width
                                height: 28
                                spacing: 6

                                Rectangle {
                                    width: Math.max(160, parent.width - filterActions.width - 8)
                                    height: 28
                                    radius: 7
                                    color: "#172233"
                                    border.color: filesPanel.searchActive() ? root.themeAccent : "#2a3a55"
                                    border.width: 1

                                    TextInput {
                                        id: searchInput
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: "#ffffff"
                                        selectionColor: root.themeAccent
                                        font.pixelSize: 11
                                        font.family: root.uiFont
                                        clip: true
                                        text: filesPanel.searchText
                                        onTextChanged: {
                                            filesPanel.searchText = text
                                            filesPanel.updateSearch()
                                        }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: root.tr("Search files...")
                                            color: "#526a83"
                                            font.pixelSize: 11
                                            font.family: root.uiFont
                                            visible: searchInput.text.length === 0 && !searchInput.activeFocus
                                        }
                                    }
                                }

                                Row {
                                    id: filterActions
                                    width: childrenRect.width
                                    height: parent.height
                                    spacing: 6

                                    MiniAction { label: filesPanel.typeFilterLabel(); onClicked: filesPanel.cycleTypeFilter() }
                                    MiniAction { label: filesPanel.dateFilterLabel(); onClicked: filesPanel.cycleDateFilter() }
                                    MiniAction { label: filesPanel.sizeFilterLabel(); onClicked: filesPanel.cycleSizeFilter() }
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
                                         filesPanel.unavailableMessage.length > 0 || filesPanel.activeEntries().length === 0
                                state: filesPanel.loading ? "loading" : (filesPanel.errorMessage.length > 0 ? "error" : (filesPanel.unavailableMessage.length > 0 ? "unavailable" : "empty"))
                                title: filesPanel.loading ? root.tr("Loading folder") :
                                       (filesPanel.errorMessage.length > 0 ? root.tr("Folder error") :
                                       (filesPanel.unavailableMessage.length > 0 ? root.tr("Folder unavailable") : (filesPanel.searchActive() ? root.tr("No matches") : root.tr("Folder is empty"))))
                                message: filesPanel.loading ? root.tr("Reading local files.") :
                                         (filesPanel.errorMessage.length > 0 ? filesPanel.errorMessage :
                                         (filesPanel.unavailableMessage.length > 0 ? filesPanel.unavailableMessage : (filesPanel.searchActive() ? root.tr("Try another search or filter.") : root.tr("Create a folder or choose another place."))))
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
                                         filesPanel.unavailableMessage.length > 0 || filesPanel.activeEntries().length === 0
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
                                visible: filesPanel.viewMode === "list" && !filesPanel.loading && filesPanel.errorMessage.length === 0 &&
                                         filesPanel.unavailableMessage.length === 0 && filesPanel.activeEntries().length > 0
                                clip: true
                                spacing: 2
                                model: filesPanel.activeEntries()

                                TapHandler {
                                    acceptedButtons: Qt.RightButton
                                    onTapped: function(point) {
                                        var localX = point.position.x
                                        var localY = point.position.y
                                        var index = filesList.indexAt(localX, localY)
                                        var mapped = filesList.mapToItem(filesPanel, localX, localY)
                                        var active = filesPanel.activeEntries()
                                        if (index >= 0 && index < active.length) {
                                            filesPanel.selectOnly(active[index])
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

                            GridView {
                                id: filesGrid
                                anchors.fill: parent
                                visible: filesPanel.viewMode === "grid" && !filesPanel.loading && filesPanel.errorMessage.length === 0 &&
                                         filesPanel.unavailableMessage.length === 0 && filesPanel.activeEntries().length > 0
                                clip: true
                                cellWidth: 132
                                cellHeight: 118
                                model: filesPanel.activeEntries()

                                TapHandler {
                                    acceptedButtons: Qt.RightButton
                                    onTapped: function(point) {
                                        var index = filesGrid.indexAt(point.position.x, point.position.y)
                                        var mapped = filesGrid.mapToItem(filesPanel, point.position.x, point.position.y)
                                        var active = filesPanel.activeEntries()
                                        if (index >= 0 && index < active.length) {
                                            filesPanel.selectOnly(active[index])
                                            filesPanel.showContextMenu(mapped.x, mapped.y)
                                        } else {
                                            filesPanel.showEmptyContextMenu(mapped.x, mapped.y)
                                        }
                                    }
                                }

                                delegate: FileTile {
                                    width: filesGrid.cellWidth - 8
                                    height: filesGrid.cellHeight - 8
                                    name: modelData.name
                                    path: modelData.path
                                    icon: modelData.icon
                                    kind: modelData.kind
                                    size: modelData.size
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

            Rectangle {
                width: parent.width
                height: 34
                radius: 8
                color: "#101927"
                border.color: "#223247"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    StatusText {
                        text: root.tr("{count} items").replace("{count}", filesPanel.activeEntries().length)
                        Layout.preferredWidth: 84
                        Layout.maximumWidth: 110
                        Layout.fillHeight: true
                    }

                    StatusText {
                        text: filesPanel.selectionLabel()
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StatusText {
                        text: filesPanel.viewMode === "list" ? root.tr("List") : root.tr("Grid")
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: 54
                        Layout.maximumWidth: 70
                        Layout.fillHeight: true
                    }

                    StatusText {
                        visible: filesPanel.searchActive()
                        text: root.tr("Search") + ": " + filesPanel.typeFilterLabel() + " / " + filesPanel.dateFilterLabel() + " / " + filesPanel.sizeFilterLabel()
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StatusText {
                        text: filesPanel.clipboardPaths.length > 0 ? (root.tr("Clipboard") + ": " + root.tr(filesPanel.clipboardMode === "cut" ? "Cut" : "Copy") + " " + filesPanel.clipboardPaths.length) : root.tr("Clipboard") + ": -"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StatusText {
                        text: filesPanel.operationSummary()
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 128
                        Layout.maximumWidth: 170
                        Layout.fillHeight: true
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

    LiquidGlass {
        id: breadcrumbMenu
        x: filesPanel.breadcrumbMenuX
        y: filesPanel.breadcrumbMenuY
        width: 190
        height: Math.min(236, breadcrumbMenuColumn.height + root.spaceMd)
        radius: root.radiusMd
        tintColor: root.surfaceBase
        accentColor: root.themeAccent
        borderColor: root.borderMuted
        materialOpacity: 0.84
        borderOpacity: 0.58
        highlightOpacity: 0.14
        depth: 0.38
        visible: filesPanel.breadcrumbMenuVisible
        z: 255
        clip: true

        Column {
            id: breadcrumbMenuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: root.spaceSm
            spacing: 2

            Text {
                width: parent.width - root.spaceMd * 2
                height: 24
                x: root.spaceMd
                text: filesPanel.breadcrumbMenuEntries.length > 0 ? root.tr("Folders") : root.tr("No folders")
                color: root.themeAccent
                font.pixelSize: root.textSmall
                font.family: root.uiFont
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }

            Repeater {
                model: filesPanel.breadcrumbMenuEntries

                delegate: ContextMenuAction {
                    label: modelData.name
                    onTriggered: {
                        filesPanel.hideBreadcrumbMenu()
                        filesPanel.loadPath(modelData.path)
                    }
                }
            }
        }
    }

    component StatusText: Text {
        color: "#8ea4bd"
        font.pixelSize: 10
        font.family: root.uiFont
        elide: Text.ElideRight
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
    }

    component OperationQueue: Rectangle {
        id: queueRoot
        property var operations: []

        height: operations.length > 0 ? Math.min(164, queueColumn.height + 16) : 86
        visible: true
        radius: 9
        color: "#101927"
        border.color: "#223247"
        border.width: 1

        Column {
            id: queueColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 6

            Text {
                width: parent.width
                text: operations.length > 0 ? root.tr("Operations") : root.tr("No active operations")
                color: operations.length > 0 ? root.themeAccent : root.textMuted
                font.pixelSize: 10
                font.family: root.uiFont
                font.bold: true
            }

            Text {
                width: parent.width
                visible: operations.length === 0
                text: root.tr("Copy, move and trash progress appears here.")
                color: root.textMuted
                font.pixelSize: 10
                font.family: root.uiFont
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: queueRoot.operations

                delegate: Rectangle {
                    width: parent.width
                    height: 34
                    radius: 7
                    color: "#172233"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Row {
                            width: parent.width
                            spacing: 6

                            Text {
                                width: parent.width - progressLabel.width - 6
                                text: root.tr(modelData.kind === "copy" ? "Copy" : (modelData.kind === "move" ? "Move" : "Trash")) + ": " + modelData.label
                                color: modelData.done && !modelData.ok ? "#ff9a9a" : root.textPrimary
                                font.pixelSize: 10
                                font.family: root.uiFont
                                elide: Text.ElideRight
                            }

                            Text {
                                id: progressLabel
                                text: modelData.done ? (modelData.ok ? "OK" : "ERR") : (modelData.current + "/" + modelData.total)
                                color: modelData.done ? (modelData.ok ? "#8dffbf" : "#ff9a9a") : root.textMuted
                                font.pixelSize: 9
                                font.family: root.uiFont
                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 3
                            radius: 2
                            color: "#0e1520"

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(100, modelData.progress || 0)) / 100
                                height: parent.height
                                radius: parent.radius
                                color: modelData.done && !modelData.ok ? "#ff6a6a" : root.themeAccent
                            }
                        }
                    }
                }
            }
        }
    }

    component BreadcrumbButton: Rectangle {
        id: breadcrumbButton
        property string label: ""
        property bool active: false
        signal clicked()
        signal menuRequested(real x, real y)

        width: Math.max(34, breadcrumbText.width + 28)
        height: 22
        radius: 6
        color: active ? "#1e2d45" : (breadcrumbMouse.containsMouse ? "#172233" : "transparent")
        border.color: active ? root.themeAccent : "transparent"
        border.width: active ? 1 : 0

        Text {
            id: breadcrumbText
            anchors.left: parent.left
            anchors.leftMargin: 9
            anchors.right: crumbArrow.left
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            text: breadcrumbButton.label
            color: breadcrumbButton.active ? "#ffffff" : "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Text {
            id: crumbArrow
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: "v"
            color: breadcrumbButton.active ? "#ffffff" : "#526a83"
            font.pixelSize: 9
            font.family: root.uiFont
        }

        MouseArea {
            id: breadcrumbMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                var point = breadcrumbMouse.mapToItem(filesPanel, mouse.x, mouse.y)
                if (mouse.button === Qt.RightButton || mouse.x > breadcrumbButton.width - 18)
                    breadcrumbButton.menuRequested(point.x, point.y + 6)
                else
                    breadcrumbButton.clicked()
            }
        }
    }
    component ToolButton: Rectangle {
        id: toolButton
        property string label: ""
        signal clicked()

        width: Math.max(50, toolText.width + 18)
        height: 34
        radius: 8
        color: toolMouse.containsMouse ? "#254160" : "#172233"
        border.color: "#2a3a55"
        border.width: 1

        Text {
            id: toolText
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
        property bool active: false
        signal clicked()

        width: actionText.width + 16
        height: 24
        radius: 7
        color: active ? "#1e2d45" : (actionMouse.containsMouse ? (danger ? "#3a1f2a" : "#254160") : "#172233")
        border.color: active ? root.themeAccent : (danger ? "#7a3348" : "#2a3a55")
        border.width: 1

        Text {
            id: actionText
            anchors.centerIn: parent
            text: action.label
            color: action.danger ? "#ff9a9a" : "#b7ddff"
            font.pixelSize: 10
            font.family: root.uiFont
            font.bold: action.active
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

    component FileTile: Rectangle {
        id: fileTile
        property string name: ""
        property string path: ""
        property string icon: ""
        property string kind: ""
        property string size: ""
        property bool isDir: false
        property bool selected: false
        property bool cutMarked: false
        signal clicked(var modifiers)
        signal contextRequested(real menuX, real menuY)
        signal openRequested()

        radius: 10
        color: selected ? "#1e2d45" : (tileMouse.containsMouse ? "#172233" : "transparent")
        border.color: selected ? root.themeAccent : "#223247"
        border.width: selected ? 1 : 0
        opacity: cutMarked ? 0.5 : 1.0

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 44
                height: 44
                radius: 12
                color: fileTile.isDir ? "#17304a" : "#1a2435"
                border.color: fileTile.isDir ? root.themeAccent : "#2a3a55"
                border.width: 1

                Rectangle {
                    visible: fileTile.isDir
                    x: 11
                    y: 12
                    width: 16
                    height: 7
                    radius: 3
                    color: root.themeAccent
                    opacity: 0.9
                }

                Rectangle {
                    visible: fileTile.isDir
                    x: 8
                    y: 18
                    width: 28
                    height: 18
                    radius: 4
                    color: root.themeAccent
                    opacity: 0.75
                }

                Text {
                    anchors.centerIn: parent
                    visible: !fileTile.isDir
                    text: fileTile.icon
                    color: "#8ea4bd"
                    font.pixelSize: 10
                    font.family: root.uiFont
                    font.bold: true
                }
            }

            Text {
                width: parent.width
                text: fileTile.name
                color: root.textPrimary
                font.pixelSize: 11
                font.family: root.uiFont
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.tr(fileTile.kind) + (fileTile.isDir || fileTile.size.length === 0 ? "" : " / " + fileTile.size)
                color: root.textMuted
                font.pixelSize: 9
                font.family: root.uiFont
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    var point = tileMouse.mapToItem(filesPanel, mouse.x, mouse.y)
                    fileTile.contextRequested(point.x, point.y)
                    return
                }
                fileTile.clicked(mouse.modifiers)
            }
            onDoubleClicked: fileTile.openRequested()
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
                    visible: previewPaneRoot.selectedCount === 1 && previewPaneRoot.preview.previewMode === "image" && previewPaneRoot.preview.previewSource && previewPaneRoot.preview.previewSource.length > 0
                    source: visible ? previewPaneRoot.preview.previewSource : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 8
                    visible: previewPaneRoot.selectedCount === 1 && previewPaneRoot.preview.previewMode === "text" && previewPaneRoot.preview.textPreview && previewPaneRoot.preview.textPreview.length > 0
                    contentWidth: width
                    contentHeight: textPreviewText.height
                    clip: true

                    Text {
                        id: textPreviewText
                        width: parent.width
                        text: previewPaneRoot.preview.textPreview || ""
                        color: root.textPrimary
                        font.pixelSize: 10
                        font.family: "monospace"
                        wrapMode: Text.WrapAnywhere
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 8
                    color: "#172233"
                    border.color: "#2a3a55"
                    border.width: 1
                    visible: previewPaneRoot.selectedCount === 1 && (previewPaneRoot.preview.previewMode === "pdf" || previewPaneRoot.preview.previewMode === "video")

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        spacing: 7

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: previewPaneRoot.preview.previewMode === "pdf" ? "PDF" : "VID"
                            color: root.themeAccent
                            font.pixelSize: 28
                            font.family: root.uiFont
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            text: previewPaneRoot.preview.previewMode === "pdf" ? root.tr("PDF preview") : root.tr("Video preview")
                            color: root.textPrimary
                            font.pixelSize: 12
                            font.family: root.uiFont
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: previewPaneRoot.preview.textPreview || previewPaneRoot.preview.size || ""
                            color: root.textMuted
                            font.pixelSize: 10
                            font.family: root.uiFont
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    spacing: 8
                    visible: previewPaneRoot.selectedCount !== 1 ||
                             (previewPaneRoot.preview.previewMode === "text" && (!previewPaneRoot.preview.textPreview || previewPaneRoot.preview.textPreview.length === 0)) ||
                             (previewPaneRoot.preview.previewMode !== "image" &&
                              previewPaneRoot.preview.previewMode !== "text" &&
                              previewPaneRoot.preview.previewMode !== "pdf" &&
                              previewPaneRoot.preview.previewMode !== "video")

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
