import QtQuick 2.15
import UNexus.System 1.0

Rectangle {
    id: panel

    width: parent ? parent.width : 360
    height: content.height + 20
    radius: 10
    color: "#111a28"
    border.color: gpuDriverManager.state === GpuDriverManager.NeedsAction ? "#f6c177" : "#223247"
    border.width: 1

    Component.onCompleted: gpuDriverManager.refresh()

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        Row {
            width: parent.width
            height: 22
            spacing: 8

            Text {
                width: parent.width - statusPill.width - 8
                anchors.verticalCenter: parent.verticalCenter
                text: root.tr("GPU Driver Manager")
                color: root.themeAccent
                font.pixelSize: 11
                font.family: root.uiFont
                font.letterSpacing: 1
                font.bold: true
                elide: Text.ElideRight
            }

            Rectangle {
                id: statusPill
                width: statusText.width + 16
                height: 22
                radius: 7
                color: gpuDriverManager.state === GpuDriverManager.NeedsAction ? "#332717" :
                       (gpuDriverManager.state === GpuDriverManager.Error ? "#351922" : "#172233")
                border.color: gpuDriverManager.state === GpuDriverManager.NeedsAction ? "#f6c177" :
                              (gpuDriverManager.state === GpuDriverManager.Error ? "#ff7b86" : root.themeAccent)
                border.width: 1

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: gpuDriverManager.state === GpuDriverManager.Detecting ? root.tr("detecting") :
                          (gpuDriverManager.state === GpuDriverManager.NeedsAction ? root.tr("action") :
                          (gpuDriverManager.state === GpuDriverManager.Installing ? root.tr("installing") :
                          (gpuDriverManager.state === GpuDriverManager.RebootRequired ? root.tr("reboot") :
                          (gpuDriverManager.state === GpuDriverManager.Error ? root.tr("error") : root.tr("ready")))))
                    color: root.textPrimary
                    font.pixelSize: 10
                    font.family: root.uiFont
                    font.bold: true
                }
            }
        }

        Text {
            width: parent.width
            text: gpuDriverManager.summary
            color: root.textPrimary
            font.pixelSize: 13
            font.family: root.uiFont
            font.bold: true
            wrapMode: Text.WordWrap
        }

        Text {
            width: parent.width
            text: gpuDriverManager.gpuName + " / " + root.tr("Driver") + ": " + gpuDriverManager.activeDriver
            color: "#8ea4bd"
            font.pixelSize: 11
            font.family: root.uiFont
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: gpuDriverManager.recommendedPackages.length > 0
            text: root.tr("Packages") + ": " + gpuDriverManager.recommendedPackages
            color: "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            wrapMode: Text.WordWrap
        }

        Text {
            width: parent.width
            text: gpuDriverManager.detail
            color: gpuDriverManager.secureBootActive ? "#f6c177" : "#8ea4bd"
            font.pixelSize: 10
            font.family: root.uiFont
            wrapMode: Text.WordWrap
            maximumLineCount: 4
            elide: Text.ElideRight
        }

        Row {
            width: parent.width
            height: 34
            spacing: 8

            ControlButton {
                width: Math.floor((parent.width - 16) / 3)
                height: parent.height
                label: root.tr("Refresh")
                variant: "subtle"
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                motionDuration: root.motionQuick
                enabled: !gpuDriverManager.busy
                onClicked: gpuDriverManager.refresh()
            }

            ControlButton {
                width: Math.floor((parent.width - 16) / 3)
                height: parent.height
                label: gpuDriverManager.state === GpuDriverManager.Installing ? root.tr("Installing") : root.tr("Install")
                variant: gpuDriverManager.installRecommended ? "primary" : "subtle"
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                motionDuration: root.motionQuick
                enabled: gpuDriverManager.installRecommended && !gpuDriverManager.busy
                opacity: enabled ? 1.0 : 0.45
                onClicked: gpuDriverManager.installRecommendedDriver()
            }

            ControlButton {
                width: parent.width - Math.floor((parent.width - 16) / 3) * 2 - 16
                height: parent.height
                label: root.tr("Reboot")
                variant: gpuDriverManager.state === GpuDriverManager.RebootRequired ? "primary" : "subtle"
                fontFamily: root.uiFont
                accentColor: root.themeAccent
                motionDuration: root.motionQuick
                enabled: gpuDriverManager.state === GpuDriverManager.RebootRequired
                opacity: enabled ? 1.0 : 0.45
                onClicked: gpuDriverManager.rebootNow()
            }
        }

        Rectangle {
            width: parent.width
            height: gpuDriverManager.lastOutput.length > 0 ? 66 : 0
            visible: height > 0
            radius: 8
            color: "#0e1520"
            border.color: "#223247"
            clip: true

            Text {
                anchors.fill: parent
                anchors.margins: 8
                text: gpuDriverManager.lastOutput
                color: "#8ea4bd"
                font.pixelSize: 9
                font.family: "monospace"
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                maximumLineCount: 4
            }
        }
    }
}
