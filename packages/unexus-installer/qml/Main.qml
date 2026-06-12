import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

pragma ComponentBehavior: Bound

ApplicationWindow {
    id: root
    visible: true
    width: 1080
    height: 700
    minimumWidth: 860
    minimumHeight: 580
    title: "uNexus Installer"
    color: "#070b12"

    property var backend: installer
    property int pageIndex: 0
    property string selectedAction: backend.installed ? "repair" : "install"
    readonly property color accent: "#38bdf8"
    readonly property color success: "#35f29b"
    readonly property color warning: "#f6c177"
    readonly property color danger: "#ff7b86"
    readonly property color panel: "#0d1420"
    readonly property color raised: "#121d2b"
    readonly property color border: "#26384d"
    readonly property color textPrimary: "#f8fbff"
    readonly property color textSecondary: "#9fb1c8"
    readonly property string uiFont: "Exo 2"

    function statusColor(status) {
        if (status === "ready" || status === "done")
            return root.success
        if (status === "blocked")
            return root.danger
        if (status === "running")
            return root.accent
        return root.warning
    }

    function runSelectedAction() {
        if (selectedAction === "repair")
            backend.repair()
        else if (selectedAction === "diagnose")
            backend.diagnose()
        else if (selectedAction === "remove")
            backend.uninstall()
        else
            backend.install()
        pageIndex = 2
    }

    Rectangle {
        anchors.fill: parent
        color: root.color

        Image {
            anchors.fill: parent
            source: "qrc:/UNexusInstaller/assets/wallpapers/unexus-core.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.32
        }

        Rectangle {
            anchors.fill: parent
            color: "#dc070b12"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 292
            Layout.fillHeight: true
            radius: 8
            color: "#e60b111c"
            border.color: root.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18

                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    source: "qrc:/UNexusInstaller/assets/logo/SF%20White.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    Layout.fillWidth: true
                    text: "uNexus Installer"
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 26
                    font.bold: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StepNav { index: 0; label: "Readiness"; active: root.pageIndex === 0; complete: root.backend.canInstall || root.backend.installed; onClicked: root.pageIndex = 0 }
                    StepNav { index: 1; label: "Options"; active: root.pageIndex === 1; complete: root.selectedAction.length > 0; onClicked: root.pageIndex = 1 }
                    StepNav { index: 2; label: "Install"; active: root.pageIndex === 2; complete: root.backend.progress === 100; onClicked: root.pageIndex = 2 }
                    StepNav { index: 3; label: "Finish"; active: root.pageIndex === 3; complete: root.backend.installed; onClicked: root.pageIndex = 3 }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.border
                }

                Text {
                    Layout.fillWidth: true
                    text: "Target"
                    color: root.textSecondary
                    font.family: root.uiFont
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.backend.repoRoot
                    color: root.textSecondary
                    wrapMode: Text.WrapAnywhere
                    font.family: root.uiFont
                    font.pixelSize: 11
                    lineHeight: 1.15
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
            color: "#e80d1420"
            border.color: root.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: root.backend.statusTitle
                            color: root.textPrimary
                            font.family: root.uiFont
                            font.pixelSize: 24
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

                    Badge {
                        label: root.backend.busy ? "Running" : (root.backend.installed ? "Installed" : "Ready")
                        colorValue: root.backend.busy ? root.accent : (root.backend.installed ? root.success : root.warning)
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.pageIndex

                    ReadinessPage {}
                    OptionsPage {}
                    InstallPage {}
                    FinishPage {}
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "Back"
                        enabled: root.pageIndex > 0 && !root.backend.busy
                        onClicked: root.pageIndex--
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Diagnose"
                        enabled: !root.backend.busy && root.backend.diagnosticsAvailable
                        onClicked: {
                            root.selectedAction = "diagnose"
                            root.runSelectedAction()
                        }
                    }

                    AccentButton {
                        text: root.pageIndex < 1 ? "Continue" : (root.pageIndex === 1 ? "Start" : (root.pageIndex === 2 ? "Finish" : "Done"))
                        enabled: !root.backend.busy && (root.pageIndex !== 1 || root.selectedAction === "diagnose" || root.backend.canInstall)
                        onClicked: {
                            if (root.pageIndex === 1)
                                root.runSelectedAction()
                            else if (root.pageIndex === 2)
                                root.pageIndex = 3
                            else if (root.pageIndex < 3)
                                root.pageIndex++
                            else
                                root.close()
                        }
                    }
                }
            }
        }
    }

    component ReadinessPage: ColumnLayout {
        spacing: 14

        Text {
            Layout.fillWidth: true
            text: "System readiness"
            color: root.textPrimary
            font.family: root.uiFont
            font.pixelSize: 18
            font.bold: true
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            Repeater {
                model: root.backend.readinessChecks

                ReadinessCard {
                    Layout.fillWidth: true
                    label: modelData.label
                    value: modelData.value
                    stateText: modelData.status
                    stateColor: root.statusColor(modelData.status)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: root.raised
            border.color: root.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: "Install scope"
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "This graphical installer installs the uNexus shell, configures the target user, prepares the Hyprland session, sets up Flathub, enables the gaming runtime layer and prepares safe boot defaults. The native disk installer backend is available from the live ISO terminal while the graphical disk flow is being built."
                    color: root.textSecondary
                    wrapMode: Text.WordWrap
                    font.family: root.uiFont
                    font.pixelSize: 13
                    lineHeight: 1.15
                }
            }
        }
    }

    component OptionsPage: ColumnLayout {
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: "Choose action"
            color: root.textPrimary
            font.family: root.uiFont
            font.pixelSize: 18
            font.bold: true
        }

        OptionCard {
            title: root.backend.installed ? "Reinstall uNexus Shell" : "Install uNexus Shell"
            detail: "Build and install the shell, then provision user groups, Hyprland, Flathub, GameMode, MangoHud and selected launchers."
            actionKey: "install"
            selected: root.selectedAction === "install"
            available: root.backend.canInstall
            onPicked: root.selectedAction = actionKey
        }

        OptionCard {
            title: "Repair existing install"
            detail: "Run the same install and provisioning pipeline again, refresh system integration and validate with uNexus Doctor."
            actionKey: "repair"
            selected: root.selectedAction === "repair"
            available: root.backend.canInstall
            onPicked: root.selectedAction = actionKey
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToggleCard {
                Layout.fillWidth: true
                title: "Gaming launchers"
                detail: "Install Steam, Lutris, Heroic and Bottles from Flathub for the target user."
                checked: root.backend.installGamingLaunchers
                onToggled: root.backend.installGamingLaunchers = checked
            }

            ToggleCard {
                Layout.fillWidth: true
                title: "Boot defaults"
                detail: "Prepare uNexus kernel options and write a systemd-boot entry when detected."
                checked: root.backend.configureBootloader
                onToggled: root.backend.configureBootloader = checked
            }
        }

        OptionCard {
            title: "Run diagnostics only"
            detail: "Check installed dependencies, sessions and uNexus state without changing system files."
            actionKey: "diagnose"
            selected: root.selectedAction === "diagnose"
            available: root.backend.diagnosticsAvailable
            onPicked: root.selectedAction = actionKey
        }

        OptionCard {
            title: "Remove installed shell"
            detail: "Remove installed uNexus binaries, sessions, desktop entries and shell icon from the current prefix."
            actionKey: "remove"
            selected: root.selectedAction === "remove"
            available: root.backend.canInstall && root.backend.installed
            danger: true
            onPicked: root.selectedAction = actionKey
        }

        Item { Layout.fillHeight: true }
    }

    component InstallPage: ColumnLayout {
        spacing: 14

        Text {
            Layout.fillWidth: true
            text: "Installation progress"
            color: root.textPrimary
            font.family: root.uiFont
            font.pixelSize: 18
            font.bold: true
        }

        ProgressBar {
            Layout.fillWidth: true
            value: root.backend.progress / 100
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 12
            rowSpacing: 12

            Repeater {
                model: root.backend.installSteps

                StepCard {
                    Layout.fillWidth: true
                    label: modelData.label
                    detail: modelData.detail
                    stateText: modelData.status
                    stateColor: root.statusColor(modelData.status)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#ee070b12"
            border.color: root.border

            ScrollView {
                anchors.fill: parent
                anchors.margins: 12
                clip: true

                TextArea {
                    text: root.backend.logText.length > 0 ? root.backend.logText : "Backend output will appear here."
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

    component FinishPage: ColumnLayout {
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: root.raised
            border.color: root.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Badge {
                    label: root.backend.installed ? "uNexus installed" : "Installer finished"
                    colorValue: root.backend.installed ? root.success : root.warning
                }

                Text {
                    Layout.fillWidth: true
                    text: root.backend.installed ? "Welcome to uNexus" : "Installer finished"
                    color: root.textPrimary
                    wrapMode: Text.WordWrap
                    font.family: root.uiFont
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.backend.installed ? "Pick the uNexus Wayland session from your display manager after logout. These quick actions help validate the install before you switch sessions." : "Review the backend log before retrying."
                    color: root.textSecondary
                    wrapMode: Text.WordWrap
                    font.family: root.uiFont
                    font.pixelSize: 13
                    lineHeight: 1.15
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QuickActionCard {
                        Layout.fillWidth: true
                        title: "Run Doctor"
                        detail: "Validate binaries, sessions and recovery tools."
                        enabled: !root.backend.busy && root.backend.diagnosticsAvailable
                        onClicked: {
                            root.selectedAction = "diagnose"
                            root.runSelectedAction()
                        }
                    }

                    QuickActionCard {
                        Layout.fillWidth: true
                        title: "Clear Log"
                        detail: "Clear backend output after reviewing the install."
                        enabled: root.backend.logText.length > 0
                        onClicked: root.backend.clearLog()
                    }

                    QuickActionCard {
                        Layout.fillWidth: true
                        title: "Update path"
                        detail: "Use Settings > About inside uNexus to choose stable or beta updates."
                        enabled: true
                        onClicked: root.pageIndex = 0
                    }
                }
            }
        }
    }

    component StepNav: Rectangle {
        id: nav
        property int index: 0
        property string label: ""
        property bool active: false
        property bool complete: false
        signal clicked()

        Layout.fillWidth: true
        height: 46
        radius: 8
        color: active ? "#19304a" : root.raised
        border.color: active ? root.accent : root.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: nav.complete ? root.success : (nav.active ? root.accent : "#203047")

                Text {
                    anchors.centerIn: parent
                    text: nav.complete ? "OK" : String(nav.index + 1)
                    color: "#06111a"
                    font.family: root.uiFont
                    font.pixelSize: nav.complete ? 9 : 12
                    font.bold: true
                }
            }

            Text {
                Layout.fillWidth: true
                text: nav.label
                color: root.textPrimary
                font.family: root.uiFont
                font.pixelSize: 13
                font.bold: nav.active
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: nav.clicked()
        }
    }

    component QuickActionCard: Rectangle {
        id: quickCard
        property string title: ""
        property string detail: ""
        property bool enabled: true
        signal clicked()

        Layout.preferredHeight: 118
        radius: 8
        color: enabled ? "#19304a" : "#111927"
        border.color: enabled ? root.accent : root.border
        opacity: enabled ? 1 : 0.55

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: quickCard.title
                color: root.textPrimary
                font.family: root.uiFont
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: quickCard.detail
                color: root.textSecondary
                wrapMode: Text.WordWrap
                font.family: root.uiFont
                font.pixelSize: 12
                lineHeight: 1.1
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: quickCard.enabled && !root.backend.busy
            onClicked: quickCard.clicked()
        }
    }

    component ReadinessCard: Rectangle {
        property string label: ""
        property string value: ""
        property string stateText: ""
        property color stateColor: root.accent

        Layout.preferredHeight: 92
        radius: 8
        color: root.raised
        border.color: root.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: label
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 14
                    font.bold: true
                }

                Badge { label: stateText; colorValue: stateColor }
            }

            Text {
                Layout.fillWidth: true
                text: value
                color: root.textSecondary
                wrapMode: Text.WordWrap
                font.family: root.uiFont
                font.pixelSize: 12
            }
        }
    }

    component OptionCard: Rectangle {
        id: option
        property string title: ""
        property string detail: ""
        property string actionKey: ""
        property bool selected: false
        property bool available: true
        property bool danger: false
        signal picked()

        Layout.fillWidth: true
        Layout.preferredHeight: 92
        radius: 8
        color: selected ? (danger ? "#351922" : "#19304a") : root.raised
        border.color: selected ? (danger ? root.danger : root.accent) : root.border
        opacity: available ? 1 : 0.55

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 11
                color: selected ? (danger ? root.danger : root.accent) : "transparent"
                border.color: selected ? "transparent" : root.border

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    visible: selected
                    color: "#06111a"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: title
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: detail
                    color: root.textSecondary
                    wrapMode: Text.WordWrap
                    font.family: root.uiFont
                    font.pixelSize: 12
                    lineHeight: 1.1
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: option.available && !root.backend.busy
            onClicked: option.picked()
        }
    }

    component ToggleCard: Rectangle {
        id: toggleCard
        property string title: ""
        property string detail: ""
        property bool checked: false
        signal toggled()

        Layout.preferredHeight: 94
        radius: 8
        color: checked ? "#19304a" : root.raised
        border.color: checked ? root.accent : root.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Switch {
                checked: toggleCard.checked
                enabled: !root.backend.busy
                onToggled: {
                    toggleCard.checked = checked
                    toggleCard.toggled()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: toggleCard.title
                    color: root.textPrimary
                    font.family: root.uiFont
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: toggleCard.detail
                    color: root.textSecondary
                    wrapMode: Text.WordWrap
                    font.family: root.uiFont
                    font.pixelSize: 11
                    lineHeight: 1.1
                }
            }
        }
    }

    component StepCard: Rectangle {
        property string label: ""
        property string detail: ""
        property string stateText: ""
        property color stateColor: root.accent

        Layout.preferredHeight: 112
        radius: 8
        color: root.raised
        border.color: stateColor
        border.width: stateText === "running" ? 2 : 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 7

            Badge { label: stateText; colorValue: stateColor }

            Text {
                Layout.fillWidth: true
                text: label
                color: root.textPrimary
                font.family: root.uiFont
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: detail
                color: root.textSecondary
                wrapMode: Text.WordWrap
                font.family: root.uiFont
                font.pixelSize: 11
            }
        }
    }

    component Badge: Rectangle {
        property string label: ""
        property color colorValue: root.accent

        implicitWidth: badgeText.implicitWidth + 18
        implicitHeight: 26
        radius: 6
        color: Qt.rgba(colorValue.r, colorValue.g, colorValue.b, 0.16)
        border.color: colorValue

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: label
            color: root.textPrimary
            font.family: root.uiFont
            font.pixelSize: 11
            font.bold: true
        }
    }

    component AccentButton: Button {
        id: accentButton
        implicitHeight: 40

        contentItem: Text {
            text: accentButton.text
            color: accentButton.enabled ? "#06111a" : "#69778a"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: root.uiFont
            font.pixelSize: 13
            font.bold: true
        }

        background: Rectangle {
            radius: 8
            color: accentButton.enabled ? (accentButton.down ? "#7dd3fc" : root.accent) : "#111927"
            border.color: accentButton.enabled ? root.accent : root.border
        }
    }
}
