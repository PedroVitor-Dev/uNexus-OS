import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

pragma ComponentBehavior: Bound

ApplicationWindow {
    id: root
    visible: true
    width: 980
    height: 640
    minimumWidth: 760
    minimumHeight: 520
    title: "uNexus Installer"
    color: "#070b12"

    property color accent: "#4d9eff"
    property color success: "#00ff88"
    property color warning: "#ffbd7a"
    property color danger: "#ff8a8a"
    property color panel: "#101722"
    property color raised: "#162130"
    property color border: "#26384d"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#8ea4bd"
    property string uiFont: "Exo 2"
    property var backend: installer

    Rectangle {
        anchors.fill: parent
        color: root.color

        Image {
            anchors.fill: parent
            source: "qrc:/UNexusInstaller/assets/wallpapers/unexus-core.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.38
        }

        Rectangle {
            anchors.fill: parent
            color: "#cc070b12"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 286
            Layout.fillHeight: true
            radius: 8
            color: "#d9101722"
            border.color: root.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Image {
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 72
                    source: "qrc:/UNexusInstaller/assets/logo/SF%20White.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    Layout.fillWidth: true
                    text: "Installer"
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 28
                    font.bold: true
                }

                StatusBlock {
                    Layout.fillWidth: true
                    label: "Shell"
                    value: root.backend.installed ? "Installed" : "Not installed"
                    activeColor: root.backend.installed ? root.success : root.warning
                }

                StatusBlock {
                    Layout.fillWidth: true
                    label: "Privileges"
                    value: root.backend.pkexecAvailable ? "pkexec ready" : "pkexec missing"
                    activeColor: root.backend.pkexecAvailable ? root.success : root.danger
                }

                StatusBlock {
                    Layout.fillWidth: true
                    label: "Repository"
                    value: root.backend.setupAvailable ? "Setup scripts found" : "Incomplete checkout"
                    activeColor: root.backend.setupAvailable ? root.success : root.danger
                }

                StatusBlock {
                    Layout.fillWidth: true
                    label: "Diagnostics"
                    value: root.backend.diagnosticsAvailable ? "Doctor available" : "Doctor missing"
                    activeColor: root.backend.diagnosticsAvailable ? root.success : root.warning
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.border
                }

                Text {
                    Layout.fillWidth: true
                    text: root.backend.repoRoot
                    color: root.textSecondary
                    wrapMode: Text.WrapAnywhere
                    font.family: root.uiFont
                    font.pixelSize: 11
                    lineHeight: 1.2
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    text: "Refresh"
                    enabled: !root.backend.busy
                    onClicked: root.backend.refresh()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#df0d1420"
            border.color: root.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: root.backend.statusTitle
                            color: root.textPrimary
                            font.family: root.uiFont
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.backend.statusDetail
                            color: root.textSecondary
                            wrapMode: Text.WordWrap
                            font.family: root.uiFont
                            font.pixelSize: 13
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 116
                        Layout.preferredHeight: 32
                        radius: 6
                        color: root.backend.busy ? "#26384d" : (root.backend.installed ? "#143526" : "#342512")
                        border.color: root.backend.busy ? root.accent : (root.backend.installed ? root.success : root.warning)

                        Text {
                            anchors.centerIn: parent
                            text: root.backend.busy ? "Running" : (root.backend.installed ? "Ready" : "Pending")
                            color: root.textPrimary
                            font.family: root.uiFont
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ActionButton {
                        Layout.fillWidth: true
                        label: root.backend.installed ? "Reinstall" : "Install"
                        enabled: !root.backend.busy && root.backend.pkexecAvailable && root.backend.setupAvailable
                        accentColor: root.accent
                        onClicked: root.backend.install()
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        label: "Repair"
                        enabled: !root.backend.busy && root.backend.pkexecAvailable && root.backend.setupAvailable
                        accentColor: root.success
                        onClicked: root.backend.repair()
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        label: "Diagnose"
                        enabled: !root.backend.busy && root.backend.diagnosticsAvailable
                        accentColor: root.warning
                        onClicked: root.backend.diagnose()
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        label: "Remove"
                        enabled: !root.backend.busy && root.backend.pkexecAvailable && root.backend.setupAvailable && root.backend.installed
                        accentColor: root.danger
                        onClicked: root.backend.uninstall()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.border
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Backend Log"
                        color: root.textPrimary
                        font.family: root.uiFont
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Button {
                        text: "Clear"
                        enabled: !root.backend.busy && root.backend.logText.length > 0
                        onClicked: root.backend.clearLog()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#ee070b12"
                    border.color: root.border
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 12
                        clip: true

                        TextArea {
                            text: root.backend.logText.length > 0 ? root.backend.logText : "No backend output yet."
                            readOnly: true
                            wrapMode: TextEdit.Wrap
                            color: root.backend.logText.length > 0 ? root.textPrimary : root.textSecondary
                            selectedTextColor: "#07101a"
                            selectionColor: root.accent
                            font.family: "monospace"
                            font.pixelSize: 12
                            background: null
                        }
                    }
                }
            }
        }
    }

    component StatusBlock: Rectangle {
        id: statusBlock
        property string label: ""
        property string value: ""
        property color activeColor: root.accent

        height: 58
        radius: 8
        color: root.raised
        border.color: root.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                radius: 5
                color: statusBlock.activeColor
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: statusBlock.label
                    color: root.textSecondary
                    font.family: root.uiFont
                    font.pixelSize: 10
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: statusBlock.value
                    color: root.textPrimary
                    elide: Text.ElideRight
                    font.family: root.uiFont
                    font.pixelSize: 13
                }
            }
        }
    }

    component ActionButton: Button {
        id: actionButton
        property string label: ""
        property color accentColor: root.accent

        text: label
        implicitHeight: 42

        contentItem: Text {
            text: actionButton.text
            color: actionButton.enabled ? root.textPrimary : "#667284"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: root.uiFont
            font.pixelSize: 13
            font.bold: true
        }

        background: Rectangle {
            radius: 8
            color: actionButton.enabled ? (actionButton.down ? "#2a3a55" : "#172233") : "#101722"
            border.color: actionButton.enabled ? actionButton.accentColor : root.border
            border.width: 1
        }
    }
}
