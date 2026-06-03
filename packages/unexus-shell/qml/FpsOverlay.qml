import QtQuick 2.15

Item {
    id: overlay
    anchors.fill: parent
    visible: systemStats.visible
    z: 130

    Rectangle {
        id: overlayPanel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: 12
        width: 160
        height: statsColumn.height + 20
        radius: 10
        color: "#0a0f1a"
        border.color: "#4d9eff"
        border.width: 1
        opacity: 0.92

        Column {
            id: statsColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 6

            Text {
                text: root.tr("uNexus STATS")
                color: "#4d9eff"
                font.pixelSize: 10
                font.letterSpacing: 2
                font.family: "Exo 2"
                opacity: 0.8
            }

            Rectangle { width: parent.width; height: 1; color: "#4d9eff"; opacity: 0.2 }

            Row {
                spacing: 6
                Text { text: "CPU"; color: "#aaaaaa"; font.pixelSize: 11; font.family: "Exo 2"; width: 35 }
                Text {
                    text: systemStats.cpuUsage + "%"
                    color: systemStats.cpuUsage > 80 ? "#ff4d4d" : systemStats.cpuUsage > 50 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 11
                    font.family: "Exo 2"
                }
            }

Row {
    spacing: 6
    Text { text: "GPU"; color: "#aaaaaa"; font.pixelSize: 11; font.family: "Exo 2"; width: 35 }
    Text {
        text: systemStats.hasGpuStats ? systemStats.gpuUsage + "%" : "N/A"
        color: systemStats.hasGpuStats
               ? (systemStats.gpuUsage > 80 ? "#ff4d4d" : systemStats.gpuUsage > 50 ? "#ffaa00" : "#00ff88")
               : "#777777"
        font.pixelSize: 11
        font.family: "Exo 2"
    }
}

Row {
    spacing: 6
    Text { text: "TEMP"; color: "#aaaaaa"; font.pixelSize: 11; font.family: "Exo 2"; width: 35 }
    Text {
        text: systemStats.hasGpuTemp ? systemStats.gpuTemp + "C" : "N/A"
        color: systemStats.hasGpuTemp
               ? (systemStats.gpuTemp > 85 ? "#ff4d4d" : systemStats.gpuTemp > 70 ? "#ffaa00" : "#00ff88")
               : "#777777"
        font.pixelSize: 11
        font.family: "Exo 2"
    }
}

            Row {
                spacing: 6
                Text { text: "RAM"; color: "#aaaaaa"; font.pixelSize: 11; font.family: "Exo 2"; width: 35 }
                Text {
                    text: systemStats.ramUsage + "%"
                    color: systemStats.ramUsage > 80 ? "#ff4d4d" : systemStats.ramUsage > 50 ? "#ffaa00" : "#00ff88"
                    font.pixelSize: 11
                    font.family: "Exo 2"
                }
            }
        }
    }
}
