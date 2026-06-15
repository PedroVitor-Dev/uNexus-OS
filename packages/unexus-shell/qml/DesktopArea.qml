import QtQuick 2.15

Item {
    id: desktopArea

    property var apps: []
    property string fontFamily: "Exo 2"
    property color accentColor: "#4d9eff"
    property color textColor: "#f8fbff"
    property color mutedTextColor: "#9fb1c8"
    property var iconProvider: null
    property var selectedKeys: []
    property bool rubberSelecting: false
    property real rubberStartX: 0
    property real rubberStartY: 0
    property real rubberCurrentX: 0
    property real rubberCurrentY: 0
    property var rubberBaseKeys: []

    signal launchRequested(var app)
    signal contextRequested(real x, real y)

    function itemKey(app, index) {
        return (app.label || "item") + "-" + index
    }

    function isSelected(key) {
        return selectedKeys.indexOf(key) >= 0
    }

    function selectOnly(key) {
        selectedKeys = [key]
    }

    function toggleSelection(key) {
        var keys = selectedKeys.slice()
        var index = keys.indexOf(key)
        if (index >= 0)
            keys.splice(index, 1)
        else
            keys.push(key)
        selectedKeys = keys
    }

    function clearSelection() {
        selectedKeys = []
    }

    function rectsIntersect(ax, ay, aw, ah, bx, by, bw, bh) {
        return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
    }

    function setSelectionFromKeys(keys) {
        selectedKeys = keys
    }

    function beginRubberSelection(x, y, additive) {
        rubberSelecting = true
        rubberStartX = x
        rubberStartY = y
        rubberCurrentX = x
        rubberCurrentY = y
        rubberBaseKeys = additive ? selectedKeys.slice() : []
        if (!additive)
            clearSelection()
    }

    function updateRubberSelection(x, y) {
        if (!rubberSelecting)
            return

        rubberCurrentX = Math.max(0, Math.min(width, x))
        rubberCurrentY = Math.max(0, Math.min(height, y))

        var left = Math.min(rubberStartX, rubberCurrentX)
        var top = Math.min(rubberStartY, rubberCurrentY)
        var rectWidth = Math.abs(rubberCurrentX - rubberStartX)
        var rectHeight = Math.abs(rubberCurrentY - rubberStartY)
        var keys = rubberBaseKeys.slice()

        for (var i = 0; i < iconRepeater.count; i++) {
            var item = iconRepeater.itemAt(i)
            if (!item)
                continue

            if (rectsIntersect(left, top, rectWidth, rectHeight, item.x, item.y, item.width, item.height) &&
                    keys.indexOf(item.itemKey) < 0) {
                keys.push(item.itemKey)
            }
        }

        setSelectionFromKeys(keys)
    }

    function finishRubberSelection() {
        rubberSelecting = false
        rubberBaseKeys = []
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                desktopArea.contextRequested(mouse.x, mouse.y)
                mouse.accepted = true
                return
            }

            desktopArea.beginRubberSelection(mouse.x, mouse.y, mouse.modifiers & Qt.ControlModifier)
            mouse.accepted = true
        }

        onPositionChanged: function(mouse) {
            if (desktopArea.rubberSelecting)
                desktopArea.updateRubberSelection(mouse.x, mouse.y)
        }

        onReleased: function(mouse) {
            if (desktopArea.rubberSelecting)
                desktopArea.finishRubberSelection()
        }
    }

    Repeater {
        id: iconRepeater
        model: desktopArea.apps

        delegate: DesktopIcon {
            required property int index
            required property var modelData

            x: 82 + Math.floor(index / 7) * 104
            y: 66 + (index % 7) * 104
            itemKey: desktopArea.itemKey(modelData, index)
            label: modelData.label || ""
            iconNames: modelData.iconNames || []
            fallbackIcon: modelData.fallbackIcon || modelData.icon || "app"
            selected: desktopArea.isSelected(itemKey)
            fontFamily: desktopArea.fontFamily
            accentColor: desktopArea.accentColor
            textColor: desktopArea.textColor
            mutedTextColor: desktopArea.mutedTextColor
            iconProvider: desktopArea.iconProvider

            onClicked: function(modifiers) {
                if (modifiers & Qt.ControlModifier)
                    desktopArea.toggleSelection(itemKey)
                else
                    desktopArea.selectOnly(itemKey)
            }

            onOpenRequested: desktopArea.launchRequested(modelData)
            onContextRequested: function(menuX, menuY) { desktopArea.contextRequested(menuX, menuY) }
        }
    }

    Rectangle {
        visible: desktopArea.rubberSelecting
        x: Math.min(desktopArea.rubberStartX, desktopArea.rubberCurrentX)
        y: Math.min(desktopArea.rubberStartY, desktopArea.rubberCurrentY)
        width: Math.abs(desktopArea.rubberCurrentX - desktopArea.rubberStartX)
        height: Math.abs(desktopArea.rubberCurrentY - desktopArea.rubberStartY)
        radius: 2
        color: "#66000000"
        border.color: "#aa38bdf8"
        border.width: 1
        z: 40
    }

    component DesktopIcon: Item {
        id: iconRoot

        property string itemKey: ""
        property string label: ""
        property var iconNames: []
        property string fallbackIcon: "app"
        property bool selected: false
        property string fontFamily: "Exo 2"
        property color accentColor: "#4d9eff"
        property color textColor: "#f8fbff"
        property color mutedTextColor: "#9fb1c8"
        property var iconProvider: null

        signal clicked(var modifiers)
        signal openRequested()
        signal contextRequested(real x, real y)

        width: 86
        height: 92

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: iconRoot.selected ? "#55101927" : (iconMouse.containsMouse ? "#33101927" : "transparent")
            border.color: iconRoot.selected ? iconRoot.accentColor : "transparent"
            border.width: iconRoot.selected ? 1 : 0
        }

        Image {
            id: resolvedIcon
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8
            width: 40
            height: 40
            source: iconRoot.iconProvider ? iconRoot.iconProvider.findIcon(iconRoot.iconNames) : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: source.toString().length > 0
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8
            width: 40
            height: 40
            radius: 10
            visible: !resolvedIcon.visible
            color: "#172233"
            border.color: iconRoot.selected ? iconRoot.accentColor : "#2a3a55"

            Text {
                anchors.centerIn: parent
                text: iconRoot.fallbackIcon.slice(0, 3).toUpperCase()
                color: iconRoot.accentColor
                font.family: iconRoot.fontFamily
                font.pixelSize: 10
                font.bold: true
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            y: 54
            height: 34
            text: iconRoot.label
            color: iconRoot.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            font.family: iconRoot.fontFamily
            font.pixelSize: 11
            font.bold: iconRoot.selected
        }

        MouseArea {
            id: iconMouse
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true

            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    iconRoot.clicked(mouse.modifiers)
                    var point = mapToItem(desktopArea, mouse.x, mouse.y)
                    iconRoot.contextRequested(point.x, point.y)
                    return
                }
                iconRoot.clicked(mouse.modifiers)
            }

            onDoubleClicked: iconRoot.openRequested()
        }
    }
}
