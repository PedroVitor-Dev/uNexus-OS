import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: loginScreen
    anchors.fill: parent
    visible: true
    opacity: 1.0

    signal loginSuccess()

    // Wallpaper igual ao desktop
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: root.themeBgTop }
            GradientStop { position: 0.5; color: root.themeBgMid }
            GradientStop { position: 1.0; color: root.themeBgBottom }
        }

        Rectangle {
            width: 600
            height: 600
            radius: 300
            x: -150
            y: 80
            color: "transparent"
            border.color: root.themeAccentDim
            border.width: 1
            opacity: 0.4
        }

        Rectangle {
            width: 400
            height: 400
            radius: 200
            x: parent.width - 250
            y: parent.height - 300
            color: "transparent"
            border.color: root.themeAccentDim
            border.width: 1
            opacity: 0.3
        }

        Rectangle {
            width: 300
            height: 300
            radius: 150
            x: -80
            y: 200
            color: root.themeAccentDim
            opacity: 0.6
        }

        Rectangle {
            width: 250
            height: 250
            radius: 125
            x: parent.width - 180
            y: 100
            color: root.themeBgMid
            opacity: 0.5
        }
    }

    // Conteúdo central
    Column {
        anchors.centerIn: parent
        spacing: 20

        // Avatar
        Rectangle {
            width: 96
            height: 96
            radius: 48
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1a2030"
            border.color: root.themeAccent
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 42
            }
        }

        // Nome do usuário
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Pedro"
            color: "#ffffff"
            font.pixelSize: 20
            font.letterSpacing: 2
            opacity: 0.9
        }

        // Campo de senha
        Rectangle {
            width: 280
            height: 44
            radius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1a2030"
            border.color: passwordInput.activeFocus ? root.themeAccent : "#2a3a55"
            border.width: 1

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

        TextInput {
    id: passwordInput
    anchors.left: parent.left
    anchors.right: enterBtn.left
    anchors.leftMargin: 16
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    color: "#ffffff"
    font.pixelSize: 15
    echoMode: TextInput.Password
    passwordCharacter: "●"
    focus: true

    Keys.onReturnPressed: doLogin()
    Keys.onEnterPressed: doLogin()
}

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                color: "#ffffff"
                font.pixelSize: 15
                opacity: 0.3
                visible: passwordInput.text.length === 0
            }

            // Botão entrar
            Rectangle {
                id: enterBtn
                width: 36
                height: 36
                radius: 8
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                color: enterMouse.containsMouse ? root.themeAccent : "#1e2d45"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "→"
                    color: "#ffffff"
                    font.pixelSize: 18
                    opacity: 0.9
                }

                MouseArea {
                    id: enterMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: doLogin()
                }
            }
        }

        // Erro de senha
        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Wrong password. Try again."
            color: "#ff4d4d"
            font.pixelSize: 12
            opacity: 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // Hora no topo
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 60
        text: Qt.formatDateTime(new Date(), "hh:mm")
        color: "#ffffff"
        font.pixelSize: 64
        font.letterSpacing: 4
        opacity: 0.9

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm")
        }
    }

    // Data no topo
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 140
        text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
        color: "#ffffff"
        font.pixelSize: 16
        font.letterSpacing: 2
        opacity: 0.5
    }

    function doLogin() {
        if (passwordInput.text === "1234" || passwordInput.text === "") {
            hideAnim.start()
        } else {
            errorText.opacity = 1.0
            shakeAnim.start()
            errorTimer.start()
        }
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation {
            target: loginScreen
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 600
            easing.type: Easing.InCubic
        }
        ScriptAction { script: { loginScreen.visible = false; loginScreen.loginSuccess() } }
    }

    // Shake no erro
    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: loginScreen; property: "x"; to: 10;  duration: 50 }
        NumberAnimation { target: loginScreen; property: "x"; to: -10; duration: 50 }
        NumberAnimation { target: loginScreen; property: "x"; to: 6;   duration: 50 }
        NumberAnimation { target: loginScreen; property: "x"; to: -6;  duration: 50 }
        NumberAnimation { target: loginScreen; property: "x"; to: 0;   duration: 50 }
    }

    Timer {
        id: errorTimer
        interval: 2000
        onTriggered: errorText.opacity = 0.0
    }
}