import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    width: 1280
    height: 720
    title: root.tr("PED OS Shell")
    color: "#0a0a0a"

    property string pedFont: "Exo 2"
    property int themeIndex: 0
    property string themeName: "Neon Blue"
    property color themeBgTop: "#04050d"
    property color themeBgMid: "#080b18"
    property color themeBgBottom: "#050810"
    property color themeAccent: "#4d9eff"
    property color themeAccentDim: "#0d3060"
    property color themeGlow: "#4d9eff"
    property string languageCode: "en"
    property int localeVersion: 0

    property var ptBr: ({
        "PED Files": "Arquivos PED",
        "Browser": "Navegador",
        "PED Settings": "Configurações PED",
        "Terminal": "Terminal",
        "First Setup": "Configuração Inicial",
        "Steam": "Steam",
        "Lutris": "Lutris",
        "Heroic": "Heroic",
        "Bottles": "Bottles",
        "Game Settings": "Configurações de Jogos",
        "SYSTEM": "SISTEMA",
        "GAMES": "JOGOS",
        "Open / Focus": "Abrir / Focar",
        "Close": "Fechar",
        "Copy Options": "Copiar Opções",
        "Launch options copied": "Opções de inicialização copiadas",
        "Paste into Steam game launch options.": "Cole nas opções de inicialização do jogo na Steam.",
        "MangoHud not found": "MangoHud não encontrado",
        "Launching without MangoHud overlay.": "Abrindo sem overlay do MangoHud.",
        "GameMode not found": "GameMode não encontrado",
        "Launching without gamemoderun.": "Abrindo sem gamemoderun.",
        "App not found": "App não encontrado",
        "{app} is not installed.": "{app} não está instalado.",
        "Welcome back!": "Bem-vindo de volta!",
        "PED OS is ready.": "PED OS está pronto.",
        "Game Mode ON": "Modo Jogo ligado",
        "Performance optimized for gaming.": "Desempenho otimizado para jogos.",
        "MangoHud missing": "MangoHud ausente",
        "gamemoderun missing": "gamemoderun ausente",
        "Install on Arch: sudo pacman -S mangohud lib32-mangohud": "Instale no Arch: sudo pacman -S mangohud lib32-mangohud",
        "Install on Arch: sudo pacman -S gamemode lib32-gamemode": "Instale no Arch: sudo pacman -S gamemode lib32-gamemode",
        "Game Mode OFF": "Modo Jogo desligado",
        "System back to normal.": "Sistema voltou ao normal.",
        "gaming on linux, effortless.": "jogar no linux, sem esforço.",
        "minimized": "minimizado",
        "System preferences, language, shell status and about": "Preferências do sistema, idioma, status do shell e sobre",
        "Language": "Idioma",
        "System language": "Idioma do sistema",
        "Region": "Região",
        "Auto": "Automático",
        "Appearance": "Aparência",
        "Theme": "Tema",
        "Font": "Fonte",
        "PED Stats Overlay": "Overlay de estatísticas PED",
        "Visible on desktop": "Visível na área de trabalho",
        "Hidden": "Oculto",
        "System": "Sistema",
        "Network": "Rede",
        "Online": "Online",
        "Offline": "Offline",
        "Battery": "Bateria",
        "Not available": "Indisponível",
        "Open First Setup": "Abrir configuração inicial",
        "About": "Sobre",
        "Name": "Nome",
        "Shell": "Shell",
        "License": "Licença",
        "Copy repository URL": "Copiar URL do repositório",
        "Repository copied": "Repositório copiado",
        "PED OS repository URL copied.": "URL do repositório do PED OS copiada.",
        "Search apps...": "Buscar apps...",
        "All": "Tudo",
        "Gaming": "Jogos",
        "Media": "Mídia",
        "panel": "painel",
        "installed": "instalado",
        "not installed": "não instalado",
        "Copy opts": "Copiar opções",
        "PED Files subtitle": "Arquivos locais, pastas de jogos e atalhos do sistema",
        "Local files, game folders and quick system places": "Arquivos locais, pastas de jogos e atalhos do sistema",
        "PLACES": "LOCAIS",
        "{count} items": "{count} itens",
        "Open": "Abrir",
        "Rename": "Renomear",
        "Trash": "Lixeira",
        "New folder": "Nova pasta",
        "Folder created": "Pasta criada",
        "Folder failed": "Falha ao criar pasta",
        "Could not create folder.": "Não foi possível criar a pasta.",
        "Renamed": "Renomeado",
        "Rename failed": "Falha ao renomear",
        "Could not rename item.": "Não foi possível renomear o item.",
        "Open failed": "Falha ao abrir",
        "No app handled this file.": "Nenhum app abriu este arquivo.",
        "Moved to trash": "Movido para a lixeira",
        "Trash failed": "Falha ao mover para a lixeira",
        "Install gio or check permissions.": "Instale o gio ou verifique permissões.",
        "Home": "Início",
        "Desktop": "Área de Trabalho",
        "Documents": "Documentos",
        "Downloads": "Downloads",
        "Pictures": "Imagens",
        "Music": "Música",
        "Videos": "Vídeos",
        "Games": "Jogos",
        "Steam Library": "Biblioteca Steam",
        "Game Settings subtitle": "Launchers, overlays e ferramentas de desempenho",
        "Launchers, overlays and performance tools": "Launchers, overlays e ferramentas de desempenho",
        "Performance": "Desempenho",
        "Game Mode": "Modo Jogo",
        "gamemoded optimizations enabled": "Otimizações do gamemoded ativadas",
        "Use normal system behavior": "Usar comportamento normal do sistema",
        "CPU, RAM, GPU and temperature visible": "CPU, RAM, GPU e temperatura visíveis",
        "Overlay hidden": "Overlay oculto",
        "Runtime Tools": "Ferramentas de execução",
        "Copy Steam launch options": "Copiar opções da Steam",
        "Gaming Launchers": "Launchers de jogos",
        "Copy install": "Copiar instalação",
        "Install command copied": "Comando de instalação copiado",
        "{app} Flatpak command copied.": "Comando Flatpak do {app} copiado.",
        "{app} command copied.": "Comando do {app} copiado.",
        "missing": "ausente",
        "ready": "pronto",
        "Setup complete": "Configuração concluída",
        "PED OS gaming setup is ready.": "A configuração de jogos do PED OS está pronta.",
        "Check gaming essentials and prepare PED OS for play": "Confira os essenciais de jogos e prepare o PED OS",
        "Runtime": "Execução",
        "Recommended": "Recomendado",
        "Install Flatpak apps from Flathub for consistent game launcher support across PED OS builds.": "Instale apps Flatpak pelo Flathub para manter os launchers de jogos consistentes nas builds do PED OS.",
        "Copy Flathub setup": "Copiar setup do Flathub",
        "Game Launchers": "Launchers de jogos",
        "You can reopen this checklist later from PED Settings.": "Você pode reabrir esta checklist depois pelas Configurações PED.",
        "Finish setup": "Finalizar setup",
        "Command copied": "Comando copiado",
        "{label} copied.": "{label} copiado.",
        "Change Wallpaper": "Trocar papel de parede",
        "Settings": "Configurações",
        "Store": "Loja",
        "Camera": "Câmera",
        "Notes": "Notas",
        "Paste": "Colar",
        "Refresh": "Atualizar",
        "Open Terminal": "Abrir Terminal",
        "Password": "Senha",
        "Wrong password. Try again.": "Senha incorreta. Tente de novo.",
        "UP": "SUBIR",
        "GO": "IR",
        "NEW": "NOVA",
        "REF": "ATUAL",
        "OK": "OK",
        "ESC": "ESC",
        "New Folder": "Nova Pasta",
        "Folder": "Pasta",
        "Image": "Imagem",
        "Video": "Vídeo",
        "Audio": "Áudio",
        "Document": "Documento",
        "Archive": "Arquivo compactado",
        "Executable": "Executável",
        "File": "Arquivo",
        "PED OS Shell": "Shell PED OS",
        "PED STATS": "ESTATÍSTICAS PED"
    })

    function tr(text) {
        localeVersion
        if (languageCode === "pt-BR" && ptBr[text])
            return ptBr[text]
        return text
    }

    function trAppMessage(template, appLabel) {
        return tr(template).replace("{app}", tr(appLabel))
    }

    function trLabelMessage(template, label) {
        return tr(template).replace("{label}", tr(label))
    }

    function setLanguage(code) {
        languageCode = code === "pt-BR" ? "pt-BR" : "en"
        userSettings.languageCode = languageCode
        localeVersion++
    }

    function applyTheme(index, persist) {
        themeIndex = index

        if (index === 1) {
            themeName = "Cyber Violet"
            themeBgTop = "#0b0414"
            themeBgMid = "#150a2a"
            themeBgBottom = "#06040d"
            themeAccent = "#b86cff"
            themeAccentDim = "#3a1a66"
            themeGlow = "#ff4df0"
        } else if (index === 2) {
            themeName = "Toxic Green"
            themeBgTop = "#03100b"
            themeBgMid = "#071b12"
            themeBgBottom = "#020807"
            themeAccent = "#00ff88"
            themeAccentDim = "#0b4a31"
            themeGlow = "#9dff00"
        } else if (index === 3) {
            themeName = "Ember Core"
            themeBgTop = "#120606"
            themeBgMid = "#24100a"
            themeBgBottom = "#090404"
            themeAccent = "#ff6a2a"
            themeAccentDim = "#5a2413"
            themeGlow = "#ffcc33"
        } else {
            themeName = "Neon Blue"
            themeBgTop = "#04050d"
            themeBgMid = "#080b18"
            themeBgBottom = "#050810"
            themeAccent = "#4d9eff"
            themeAccentDim = "#0d3060"
            themeGlow = "#4d9eff"
        }

        wallpaperLines.requestPaint()
        diagonalGrid.requestPaint()

        if (persist !== false)
            userSettings.themeIndex = themeIndex
    }

    Component.onCompleted: {
        languageCode = userSettings.languageCode
        localeVersion++
        applyTheme(userSettings.themeIndex, false)
        systemStats.visible = userSettings.statsOverlayVisible
    }

    Connections {
        target: systemStats
        function onVisibleChanged() {
            userSettings.statsOverlayVisible = systemStats.visible
        }
    }
    property var systemDockApps: [
        { icon: "F", iconNames: ["system-file-manager", "org.gnome.Nautilus", "nautilus"], label: "PED Files", internalAction: "files" },
        { icon: "W", iconNames: ["firefox", "org.mozilla.firefox"], label: "Browser", command: "firefox", args: [], windowClasses: ["firefox", "Firefox", "Navigator.firefox"], processNames: ["firefox"] },
        { icon: "S", iconNames: ["preferences-system", "org.gnome.Settings", "gnome-control-center"], label: "PED Settings", internalAction: "settings" },
        { icon: ">_", iconNames: ["utilities-terminal", "org.gnome.Terminal", "gnome-terminal"], label: "Terminal", command: "gnome-terminal", args: [], windowClasses: ["gnome-terminal", "Gnome-terminal"], processNames: ["gnome-terminal-server", "gnome-terminal"] },
        { icon: "OK", iconNames: ["preferences-system-symbolic", "emblem-default"], label: "First Setup", internalAction: "firstSetup" }
    ]

    property var gameDockApps: [
        { icon: "ST", iconNames: ["steam", "com.valvesoftware.Steam"], label: "Steam", command: "steam", args: [], flatpakId: "com.valvesoftware.Steam", windowClasses: ["steam", "Steam"], processNames: ["steam", "steamwebhelper"], gaming: true },
        { icon: "LU", iconNames: ["lutris", "net.lutris.Lutris"], label: "Lutris", command: "lutris", args: [], flatpakId: "net.lutris.Lutris", windowClasses: ["lutris", "Lutris"], processNames: ["lutris"], gaming: true },
        { icon: "HE", iconNames: ["com.heroicgameslauncher.hgl", "heroic", "heroicgameslauncher"], label: "Heroic", command: "heroic", args: [], flatpakId: "com.heroicgameslauncher.hgl", windowClasses: ["heroic", "Heroic", "com.heroicgameslauncher.hgl"], processNames: ["heroic", "heroicgameslauncher"], gaming: true },
        { icon: "BO", iconNames: ["com.usebottles.bottles", "bottles"], label: "Bottles", command: "bottles", args: [], flatpakId: "com.usebottles.bottles", windowClasses: ["bottles", "Bottles", "com.usebottles.bottles"], processNames: ["bottles"], gaming: true },
        { icon: "GS", iconNames: ["applications-games", "input-gaming"], label: "Game Settings", internalAction: "gameSettings" }
    ]
    property int dockStateVersion: 0
    property int panelStateVersion: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dockStateVersion++
    }

    function panelDockState(panel, stateVersion) {
        stateVersion

        if (!panel || !panel.dockActive)
            return "closed"

        return "active"
    }

    function internalDockState(app, stateVersion) {
        stateVersion

        if (!app || !app.internalAction)
            return ""

        if (app.internalAction === "files")
            return panelDockState(pedFiles, stateVersion)

        if (app.internalAction === "settings")
            return panelDockState(pedSettings, stateVersion)

        if (app.internalAction === "gameSettings")
            return panelDockState(gameSettings, stateVersion)

        if (app.internalAction === "firstSetup")
            return panelDockState(firstSetup, stateVersion)

        return ""
    }

    function launchDesktopApp(app) {
    if (app.internalAction === "settings") {
        pedSettings.show()
        return
    }

    if (app.internalAction === "files") {
        pedFiles.show()
        return
    }

    if (app.internalAction === "gameSettings") {
        gameSettings.show()
        return
    }

    if (app.internalAction === "firstSetup") {
        firstSetup.show()
        return
    }

    var opened = false
    var isGamingApp = app.gaming === true

    if (isGamingApp && gameMode.active) {
        if (!appLauncher.isMangoHudInstalled())
            notifCenter.send(root.tr("MangoHud not found"), root.tr("Launching without MangoHud overlay."), "⚠️")

        if (!appLauncher.isGameModeRunInstalled())
            notifCenter.send(root.tr("GameMode not found"), root.tr("Launching without gamemoderun."), "⚠️")

        opened = appLauncher.focusOrLaunchGame(
            app.windowClasses || [],
            app.command || "",
            app.args || [],
            app.flatpakId || "",
            true,
            true
        )
    } else if (app.windowClasses && app.windowClasses.length > 0) {
        opened = appLauncher.focusOrLaunch(
            app.windowClasses,
            app.command || "",
            app.args || [],
            app.flatpakId || ""
        )
    } else {
        if (app.command && app.command.length > 0)
            opened = appLauncher.launch(app.command, app.args || [])

        if (!opened && app.flatpakId && app.flatpakId.length > 0)
            opened = appLauncher.launch("flatpak", ["run", app.flatpakId])
    }

    if (!opened)
        notifCenter.send(root.tr("App not found"), root.trAppMessage("{app} is not installed.", app.label), "⚠️")
}

    function closeDesktopApp(app) {
        if (app.internalAction === "settings") {
            pedSettings.hide()
            root.panelStateVersion++
            root.dockStateVersion++
            return
        }

        if (app.internalAction === "files") {
            pedFiles.hide()
            root.panelStateVersion++
            root.dockStateVersion++
            return
        }

        if (app.internalAction === "gameSettings") {
            gameSettings.hide()
            root.panelStateVersion++
            root.dockStateVersion++
            return
        }

        if (app.internalAction === "firstSetup") {
            firstSetup.hide()
            root.panelStateVersion++
            root.dockStateVersion++
            return
        }

        appLauncher.closeApp(app.windowClasses || [], app.processNames || [])
        root.dockStateVersion++
    }

    Rectangle {
        anchors.fill: parent
        color: root.themeBgTop

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: root.themeBgTop }
                GradientStop { position: 0.5; color: root.themeBgMid }
                GradientStop { position: 1.0; color: root.themeBgBottom }
            }
        }

        Canvas {
            id: wallpaperLines
            width: parent.width
            height: parent.height
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.beginPath()
                ctx.moveTo(0, height * 0.3)
                ctx.lineTo(width * 0.35, height * 0.0)
                ctx.lineTo(width * 0.15, height * 0.75)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccentDim
                ctx.lineWidth = 1
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(width * 0.6, height)
                ctx.lineTo(width, height * 0.4)
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccentDim
                ctx.lineWidth = 1
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(width * 0.7, 0)
                ctx.lineTo(width, height * 0.25)
                ctx.lineTo(width * 0.85, 0)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1
                ctx.globalAlpha = 0.15
                ctx.stroke()

                ctx.globalAlpha = 1.0
                ctx.beginPath()
                ctx.moveTo(width * 0.1, height * 0.85)
                ctx.lineTo(width * 0.3, height * 0.6)
                ctx.lineTo(width * 0.45, height)
                ctx.closePath()
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1
                ctx.globalAlpha = 0.1
                ctx.stroke()
            }
        }

        Rectangle {
            width: 500
            height: 500
            radius: 250
            x: parent.width - 200
            y: -150
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 300
                height: 300
                radius: 150
                color: root.themeGlow
                opacity: 0.05
            }
        }

        Rectangle {
            width: 400
            height: 400
            radius: 200
            x: -150
            y: parent.height - 200
            color: root.themeGlow
            opacity: 0.04
        }

        Repeater {
            model: 30

            delegate: Rectangle {
                property real px: Math.random()
                property real py: Math.random()

                x: px * parent.width
                y: py * parent.height
                width: Math.random() > 0.7 ? 3 : 1.5
                height: width
                radius: width
                color: root.themeAccent
                opacity: Math.random() * 0.4 + 0.1

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.05; duration: Math.random() * 2000 + 1000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: Math.random() * 0.5 + 0.12; duration: Math.random() * 2000 + 1000; easing.type: Easing.InOutSine }
                }
            }
        }

        Canvas {
            id: diagonalGrid
            width: parent.width
            height: parent.height
            opacity: 0.08
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = root.themeAccent
                ctx.lineWidth = 1

                for (var i = -height; i < width + height; i += 80) {
                    ctx.beginPath()
                    ctx.moveTo(i, 0)
                    ctx.lineTo(i + height, height)
                    ctx.stroke()
                }
            }
        }
    }

    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 36
        color: "#111111"
        opacity: 0.0

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: logoText.width + 16
            height: 22
            radius: 6
            color: logoMouse.containsMouse ? "#1e2d45" : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                id: logoText
                anchors.centerIn: parent
                text: "PED OS"
                color: "#ffffff"
                font.pixelSize: 12
                font.letterSpacing: 4
                font.family: root.pedFont
                opacity: 0.7
            }

            MouseArea {
                id: logoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (pedLauncher.visible)
                        pedLauncher.hide()
                    else
                        pedLauncher.show()
                }
            }
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: "#ffffff"
            font.pixelSize: 13
            font.family: root.pedFont
            opacity: 0.8

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }

            Component.onCompleted: text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
                width: 26
                height: 22
                radius: 6
                color: gameMode.active ? "#ff4d00" : "#1a2030"
                border.color: gameMode.active ? "#ff6a00" : "#2a3a55"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "🎮"
                    font.pixelSize: 13
                    opacity: gameMode.active ? 1.0 : 0.5
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gameMode.toggle()
                        systemStats.visible = gameMode.active
                        if (gameMode.active) {
                            notifCenter.send(root.tr("Game Mode ON"), root.tr("Performance optimized for gaming."), "🎮")
                            if (!appLauncher.isMangoHudInstalled())
                                notifCenter.send(root.tr("MangoHud missing"), root.tr("Install on Arch: sudo pacman -S mangohud lib32-mangohud"), "⚠️")
                            if (!appLauncher.isGameModeRunInstalled())
                                notifCenter.send(root.tr("gamemoderun missing"), root.tr("Install on Arch: sudo pacman -S gamemode lib32-gamemode"), "⚠️")
                        } else {
                            notifCenter.send(root.tr("Game Mode OFF"), root.tr("System back to normal."), "💤")
                        }
                    }
                }
            }

            Text {
                text: systemInfo.networkConnected ? "🌐" : "🚫"
                color: systemInfo.networkConnected ? "#4d9eff" : "#ff4d4d"
                font.pixelSize: 13
                opacity: 0.8
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: systemInfo.hasBattery
                text: systemInfo.batteryCharging ? "⚡" : (systemInfo.batteryLevel < 20 ? "🪫" : "🔋")
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: systemInfo.hasBattery
                text: systemInfo.batteryLevel + "%"
                color: systemInfo.batteryLevel < 20 ? "#ff4d4d" : "#ffffff"
                font.pixelSize: 12
                font.family: root.pedFont
                opacity: 0.7
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: dateText
                color: "#ffffff"
                font.pixelSize: 12
                font.family: root.pedFont
                opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateText.text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                }

                Component.onCompleted: text = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
            }
        }

        NumberAnimation on opacity {
            from: 0.0
            to: 0.9
            duration: 800
            easing.type: Easing.OutCubic
            running: true
        }
    }

    Column {
        id: centerLogo
        anchors.centerIn: parent
        spacing: 12
        opacity: 0.0

        SequentialAnimation on opacity {
            running: true
            NumberAnimation { from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PED OS"
            color: "#ffffff"
            font.pixelSize: 48
            font.letterSpacing: 8
            font.family: root.pedFont
            opacity: 0.9
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.tr("gaming on linux, effortless.")
            color: root.themeAccent
            font.pixelSize: 14
            font.letterSpacing: 2
            font.family: root.pedFont
            opacity: 0.7
        }
    }

    SideDock {
        id: systemDock
        side: "left"
        title: root.tr("SYSTEM")
        apps: root.systemDockApps
        accentColor: root.themeAccent
        panelColor: "#111111"
        fontFamily: root.pedFont
        dockStateVersion: root.dockStateVersion
        appStateVersion: root.panelStateVersion
        localeVersion: root.localeVersion
        appStateProvider: root.internalDockState
        actionMenuVisible: dockActionMenu.visible
        actionMenuSide: dockActionMenu.currentSide
        z: 80
        onLaunchRequested: function(app) {
            dockActionMenu.hideMenu()
            root.launchDesktopApp(app)
        }
        onActionMenuRequested: function(app, point, side) {
            dockActionMenu.showForApp(app, point, side)
        }
    }

    SideDock {
        id: gameDock
        side: "right"
        title: root.tr("GAMES")
        apps: root.gameDockApps
        accentColor: "#ff8a3d"
        panelColor: "#16110e"
        fontFamily: root.pedFont
        dockStateVersion: root.dockStateVersion
        appStateVersion: root.panelStateVersion
        localeVersion: root.localeVersion
        appStateProvider: root.internalDockState
        actionMenuVisible: dockActionMenu.visible
        actionMenuSide: dockActionMenu.currentSide
        z: 80
        onLaunchRequested: function(app) {
            dockActionMenu.hideMenu()
            root.launchDesktopApp(app)
        }
        onActionMenuRequested: function(app, point, side) {
            dockActionMenu.showForApp(app, point, side)
        }
    }

    Rectangle {
        id: dockActionMenu
        width: 150
        height: actionColumn.height + 12
        radius: 8
        color: "#0e1520"
        border.color: "#2a3a55"
        border.width: 1
        visible: false
        z: 180

        property var currentApp: null
        property string currentSide: ""

        function showForApp(app, point, side) {
            currentApp = app
            currentSide = side || ""
            x = Math.max(8, Math.min(root.width - width - 8, point.x - width / 2))
            y = Math.max(44, point.y - height - 10)
            visible = true
        }

        function hideMenu() {
            visible = false
            currentApp = null
            currentSide = ""
        }

        Column {
            id: actionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 6
            spacing: 2

            Rectangle {
                width: parent.width
                height: 34
                color: openMouse.containsMouse ? "#1e2d45" : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: root.tr("Open / Focus")
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.family: root.pedFont
                }

                MouseArea {
                    id: openMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.launchDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34
                color: closeMouse.containsMouse ? "#3a1f2a" : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: root.tr("Close")
                    color: "#ff8a8a"
                    font.pixelSize: 12
                    font.family: root.pedFont
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.closeDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                visible: dockActionMenu.currentApp !== null && dockActionMenu.currentApp.gaming === true
                width: parent.width
                height: 34
                color: copyOptionsMouse.containsMouse ? "#2c2417" : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: root.tr("Copy Options")
                    color: "#ffbd7a"
                    font.pixelSize: 12
                    font.family: root.pedFont
                }

                MouseArea {
                    id: copyOptionsMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        appLauncher.copyToClipboard("mangohud gamemoderun %command%")
                        notifCenter.send(root.tr("Launch options copied"), root.tr("Paste into Steam game launch options."), "🎮")
                        dockActionMenu.hideMenu()
                    }
                }
            }
        }
    }

    Launcher {
        id: pedLauncher
        anchors.fill: parent
        z: 100
        settingsPanel: pedSettings
        gameSettingsPanel: gameSettings
        filesPanel: pedFiles
    }

    ContextMenu {
        id: contextMenu
        anchors.fill: parent
        z: 150
        onOpenSettingsRequested: pedSettings.show()
    }

MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: 1

        onClicked: function(mouse) {
            dockActionMenu.hideMenu()

            if (mouse.button === Qt.RightButton)
                contextMenu.show(mouse.x, mouse.y)
        }
    }

    NotificationCenter {
        id: notifCenter
        anchors.fill: parent
        z: 120
    }

    LoginScreen {
        id: loginScreen
        anchors.fill: parent
        z: 200

        onLoginSuccess: {
            loginScreen.destroy()
            notifCenter.send(root.tr("Welcome back!"), root.tr("PED OS is ready."), "👋")

            if (!userSettings.firstSetupCompleted)
                firstSetup.show()
        }
    }

    FpsOverlay {
        anchors.fill: parent
        z: 130
    }

    SettingsPanel {
        id: pedSettings
        anchors.fill: parent
        z: 190
        onDockActiveChanged: {
            root.panelStateVersion++
            root.dockStateVersion++
        }
    }

    GameSettingsPanel {
        id: gameSettings
        anchors.fill: parent
        z: 191
        onDockActiveChanged: {
            root.panelStateVersion++
            root.dockStateVersion++
        }
    }

    FilesPanel {
        id: pedFiles
        anchors.fill: parent
        z: 192
        onDockActiveChanged: {
            root.panelStateVersion++
            root.dockStateVersion++
        }
    }

    FirstSetupPanel {
        id: firstSetup
        anchors.fill: parent
        z: 195
        onDockActiveChanged: {
            root.panelStateVersion++
            root.dockStateVersion++
        }
    }
}
