import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    width: 1280
    height: 720
    title: root.tr("uNexus Shell")
    color: "#0a0a0a"

    DesignTokens {
        id: tokens
    }

    property string uiFont: tokens.fontFamily
    property string brandLogoSource: "qrc:/UNexusShell/assets/logo/SF%20White.png"
    property string desktopWallpaperId: "unexus-core"
    property string desktopWallpaperSource: "qrc:/UNexusShell/assets/wallpapers/unexus-core.png"
    property var wallpaperOptions: [
        { id: "unexus-core", label: "uNexus Core", source: "qrc:/UNexusShell/assets/wallpapers/unexus-core.png" },
        { id: "particle-drift", label: "Particle Drift", source: "qrc:/UNexusShell/assets/wallpapers/particle-drift.png" },
        { id: "aurora-ice", label: "Aurora Ice", source: "qrc:/UNexusShell/assets/wallpapers/aurora-ice.png" },
        { id: "ember-circuit", label: "Ember Circuit", source: "qrc:/UNexusShell/assets/wallpapers/ember-circuit.png" }
    ]
    // Core visual language
    property int spaceXs: tokens.space.xs
    property int spaceSm: tokens.space.sm
    property int spaceMd: tokens.space.md
    property int spaceLg: tokens.space.lg
    property int spaceXl: tokens.space.xl
    property int spaceXxl: tokens.space.xxl
    property int spaceSection: tokens.space.section
    property bool compactLayout: width < tokens.layout.compactBreakpointWidth || height < tokens.layout.compactBreakpointHeight
    property int panelMargin: compactLayout ? tokens.layout.panelMarginCompact : tokens.layout.panelMargin
    property int panelPadding: compactLayout ? tokens.layout.panelPaddingCompact : tokens.layout.panelPadding
    property int panelGap: compactLayout ? tokens.layout.panelGapCompact : tokens.layout.panelGap
    property int panelTopMargin: compactLayout ? tokens.layout.panelTopMarginCompact : tokens.layout.panelTopMargin
    property int multiMonitorEdgeMargin: width >= 1800 ? tokens.layout.multiMonitorEdgeMargin : spaceMd
    property int multiMonitorTopMargin: compactLayout ? tokens.layout.multiMonitorTopMarginCompact : tokens.layout.multiMonitorTopMargin
    property int controlHeight: compactLayout ? tokens.layout.compactControlHeight : tokens.layout.controlHeight
    property int rowHeight: tokens.layout.rowHeight
    property int denseRowHeight: tokens.layout.denseRowHeight
    property int toolbarHeight: tokens.layout.toolbarHeight
    property int radiusSm: tokens.radius.sm
    property int radiusMd: tokens.radius.md
    property int radiusLg: tokens.radius.lg
    property int radiusXl: tokens.radius.xl
    property int radiusDock: tokens.radius.dock
    property int borderHairline: tokens.border.hairline
    property int motionInstant: tokens.motion.instant
    property int motionQuick: tokens.motion.quick
    property int motionBase: tokens.motion.base
    property int motionExpressive: tokens.motion.expressive
    property int motionEntrance: tokens.motion.entrance
    property int motionHover: tokens.motion.hover
    property int motionPress: tokens.motion.press
    property int motionFadeIn: tokens.motion.fadeIn
    property int motionFadeOut: tokens.motion.fadeOut
    property real motionPanelSpring: tokens.motion.panelSpring
    property real motionPanelDamping: tokens.motion.panelDamping
    property real motionPanelEpsilon: tokens.motion.panelEpsilon
    property real motionDockSpring: tokens.motion.dockSpring
    property real motionDockDamping: tokens.motion.dockDamping
    property real motionDockEpsilon: tokens.motion.dockEpsilon
    property real motionControlSpring: tokens.motion.controlSpring
    property real motionControlDamping: tokens.motion.controlDamping
    property int textMicro: tokens.type.micro
    property int textTiny: tokens.type.tiny
    property int textSmall: tokens.type.small
    property int textBody: tokens.type.body
    property int textUi: tokens.type.ui
    property int textLg: tokens.type.lg
    property int textTitle: tokens.type.title
    property int textDisplay: tokens.type.display
    property int textHero: tokens.type.hero
    property real lineTight: tokens.type.lineTight
    property real lineNormal: tokens.type.lineNormal
    property real lineRelaxed: tokens.type.lineRelaxed
    property int weightRegular: tokens.type.weightRegular
    property int weightMedium: tokens.type.weightMedium
    property int weightSemibold: tokens.type.weightSemibold
    property int weightBold: tokens.type.weightBold
    property int trackingNone: tokens.type.trackingNone
    property int trackingSection: tokens.type.trackingSection
    property int trackingBrand: tokens.type.trackingBrand
    property color surfaceBase: tokens.surface.base
    property color surfacePanel: tokens.surface.panel
    property color surfaceRaised: tokens.surface.raised
    property color surfaceHover: tokens.surface.hover
    property color surfaceStrongHover: tokens.surface.strongHover
    property color borderSubtle: tokens.border.subtle
    property color borderMuted: tokens.border.muted
    property color textPrimary: tokens.text.primary
    property color textSecondary: tokens.text.secondary
    property color textMuted: tokens.text.muted
    property color shadowSoft: tokens.shadow.soft

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
    property bool captureMode: false
    property string captureScene: "login"
    property bool startupLoading: true
    property bool startupMinimumElapsed: false
    property bool startupBackendsReady: false
    property string startupStatus: "Starting uNexus"

    property var ptBr: ({
        "uNexus Files": "Arquivos uNexus",
        "File Manager": "Gerenciador de Arquivos",
        "Browser": "Navegador",
        "uNexus Settings": "Configurações uNexus",
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
        "Window": "Janela",
        "Focus": "Focar",
        "Close": "Fechar",
        "Confirm close": "Confirmar fechar",
        "Maximize": "Maximizar",
        "Move": "Mover",
        "Minimize": "Minimizar",
        "Restore": "Restaurar",
        "Minimized": "Minimizadas",
        "left": "esquerda",
        "right": "direita",
        "up": "cima",
        "down": "baixo",
        "center": "centro",
        "panel": "painel",
        "Copy": "Copiar",
        "MangoHud not found": "MangoHud não encontrado",
        "Launching without MangoHud overlay.": "Abrindo sem overlay do MangoHud.",
        "GameMode not found": "GameMode não encontrado",
        "Launching without gamemoderun.": "Abrindo sem gamemoderun.",
        "App not found": "App não encontrado",
        "{app} is not installed.": "{app} não está instalado.",
        "Welcome back!": "Bem-vindo de volta!",
        "uNexus is ready.": "uNexus está pronto.",
        "Starting uNexus": "Iniciando uNexus",
        "Preparing system backends": "Preparando backends do sistema",
        "Loading desktop": "Carregando desktop",
        "Game Mode ON": "Modo Jogo ligado",
        "Performance optimized for gaming.": "Desempenho otimizado para jogos.",
        "MangoHud missing": "MangoHud ausente",
        "gamemoderun missing": "gamemoderun ausente",
        "Install on Arch: sudo pacman -S mangohud lib32-mangohud": "Instale no Arch: sudo pacman -S mangohud lib32-mangohud",
        "Install on Arch: sudo pacman -S gamemode lib32-gamemode": "Instale no Arch: sudo pacman -S gamemode lib32-gamemode",
        "Game Mode OFF": "Modo Jogo desligado",
        "System back to normal.": "Sistema voltou ao normal.",
        "minimized": "minimizado",
        "System preferences, language, shell status and about": "Preferências do sistema, idioma, status do shell e sobre",
        "Language": "Idioma",
        "System language": "Idioma do sistema",
        "Region": "Região",
        "Auto": "Automático",
        "Appearance": "Aparência",
        "Theme": "Tema",
        "Font": "Fonte",
        "Wallpaper": "Papel de parede",
        "Desktop wallpaper": "Papel de parede da area de trabalho",
        "Wallpaper applied": "Papel de parede aplicado",
        "{label} is now active.": "{label} esta ativo.",
        "uNexus Stats Overlay": "Overlay de estatísticas uNexus",
        "Shortcuts": "Atalhos",
        "Keyboard Shortcuts": "Atalhos do Teclado",
        "Help": "Ajuda",
        "Shortcut Help": "Ajuda de atalhos",
        "Windows-style shortcuts for daily shell control": "Atalhos no estilo Windows para controle diario do shell",
        "Global shortcuts": "Atalhos globais",
        "File Manager": "Gerenciador de Arquivos",
        "Open Launcher": "Abrir launcher",
        "Open Settings": "Abrir configuracoes",
        "Toggle Stats Overlay": "Alternar overlay de stats",
        "Copy selected": "Copiar selecionado",
        "Cut selected": "Recortar selecionado",
        "Paste here": "Colar aqui",
        "Select all": "Selecionar tudo",
        "Rename selected": "Renomear selecionado",
        "Trash selected": "Enviar para lixeira",
        "Open selected": "Abrir selecionado",
        "Clear selection": "Limpar selecao",
        "Restore default shortcuts": "Restaurar atalhos padrao",
        "Shortcuts restored": "Atalhos restaurados",
        "Default shortcuts applied.": "Atalhos padrao aplicados.",
        "Customize shortcuts": "Personalizar atalhos",
        "Notifications": "Notificacoes",
        "Notifications enabled": "Notificacoes ativas",
        "Notifications disabled": "Notificacoes desativadas",
        "Launcher shortcut": "Atalho do launcher",
        "Settings shortcut": "Atalho das configuracoes",
        "Game Settings shortcut": "Atalho dos jogos",
        "Stats shortcut": "Atalho das estatisticas",
        "Bug Reporter shortcut": "Atalho do relatorio de bug",
        "Prepare Bug Report": "Preparar relatorio de bug",
        "Bug report prepared": "Relatorio de bug preparado",
        "Bug report failed": "Falha ao preparar relatorio",
        "Report path copied. Review it before opening GitHub.": "Caminho copiado. Revise antes de abrir no GitHub.",
        "Update channel": "Canal de atualizacao",
        "Stable": "Estavel",
        "Beta": "Beta",
        "Updates": "Atualizacoes",
        "Prepare bug report": "Preparar relatorio de bug",
        "Reset": "Redefinir",
        "Apply": "Aplicar",
        "Launcher": "Launcher",
        "Visible on desktop": "Visível na área de trabalho",
        "Hidden": "Oculto",
        "System": "Sistema",
        "Hardware": "Hardware",
        "GPU": "GPU",
        "VRAM": "VRAM",
        "Driver": "Driver",
        "Active driver": "Driver ativo",
        "Recommended drivers": "Drivers recomendados",
        "Driver Wizard": "Assistente de drivers",
        "Driver Wizard failed": "Falha no assistente de drivers",
        "Driver switch started. Reboot after it finishes.": "Troca de driver iniciada. Reinicie quando terminar.",
        "Could not start privileged driver switch.": "Nao foi possivel iniciar a troca privilegiada de driver.",
        "Driver switch confirmation started.": "Confirmacao da troca de driver iniciada.",
        "Could not start privileged confirmation.": "Nao foi possivel iniciar a confirmacao privilegiada.",
        "Driver rollback started.": "Rollback de driver iniciado.",
        "Could not start privileged rollback.": "Nao foi possivel iniciar o rollback privilegiado.",
        "Driver plan is unavailable.": "Plano de driver indisponivel.",
        "Confirm": "Confirmar",
        "Rollback": "Rollback",
        "Kernel": "Kernel",
        "Mesa": "Mesa",
        "Network": "Rede",
        "Online": "Online",
        "Offline": "Offline",
        "Battery": "Bateria",
        "Not available": "Indisponível",
        "Open First Setup": "Abrir configuração inicial",
        "Open Game Settings": "Abrir configurações de jogos",
        "About": "Sobre",
        "Name": "Nome",
        "Type": "Tipo",
        "Date": "Data",
        "Size": "Tamanho",
        "Shell": "Shell",
        "License": "Licença",
        "Copy repository URL": "Copiar URL do repositório",
        "Repository copied": "Repositório copiado",
        "uNexus repository URL copied.": "URL do repositório do uNexus copiada.",
        "Search apps...": "Buscar apps...",
        "All": "Tudo",
        "Gaming": "Jogos",
        "Media": "Mídia",
        "panel": "painel",
        "installed": "instalado",
        "not installed": "não instalado",
        "uNexus Files subtitle": "Arquivos locais, pastas de jogos e atalhos do sistema",
        "Local files, game folders and quick system places": "Arquivos locais, pastas de jogos e atalhos do sistema",
        "PLACES": "LOCAIS",
        "Places": "Locais",
        "Queue": "Fila",
        "Operations": "Operacoes",
        "No active operations": "Sem operacoes ativas",
        "Copy, move and trash progress appears here.": "Progresso de copiar, mover e enviar para a lixeira aparece aqui.",
        "running": "em execucao",
        "idle": "ocioso",
        "filtered": "filtrado",
        "{count} items": "{count} itens",
        "Open": "Abrir",
        "Dismiss": "Descartar",
        "Silence 1h": "Silenciar 1h",
        "Silenced": "Silenciado",
        "Notification queue": "Fila de notificacoes",
        "Notifications silenced for 1h.": "Notificacoes silenciadas por 1h.",
        "Open, dismiss or silence alerts.": "Abra, descarte ou silencie alertas.",
        "queued": "na fila",
        "Notification timeout": "Tempo das notificacoes",
        "Rename": "Renomear",
        "Trash": "Lixeira",
        "Confirm trash": "Confirmar lixeira",
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
        "No selection": "Nada selecionado",
        "{count} selected": "{count} selecionados",
        "Copied": "Copiado",
        "Cut": "Recortado",
        "Pasted": "Colado",
        "Paste failed": "Falha ao colar",
        "Could not paste selected items.": "Nao foi possivel colar os itens selecionados.",
        "Preview": "Previa",
        "Created": "Criado",
        "Extension": "Extensao",
        "Contains": "Contem",
        "Selected": "Selecionado",
        "Clipboard": "Area de transferencia",
        "List": "Lista",
        "Grid": "Grade",
        "Operations": "Operacoes",
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
        "Game Data": "Dados de jogos",
        "SAVE": "SAVE",
        "Search": "Busca",
        "Search files...": "Buscar arquivos...",
        "No matches": "Nenhum resultado",
        "Try another search or filter.": "Tente outra busca ou filtro.",
        "Folders": "Pastas",
        "No folders": "Sem pastas",
        "Any type": "Qualquer tipo",
        "Any date": "Qualquer data",
        "Any size": "Qualquer tamanho",
        "Today": "Hoje",
        "7 days": "7 dias",
        "30 days": "30 dias",
        "Small": "Pequeno",
        "Medium": "Medio",
        "Large": "Grande",
        "Image": "Imagem",
        "Video": "Video",
        "Audio": "Audio",
        "Text": "Texto",
        "Archive": "Arquivo compactado",
        "PDF": "PDF",
        "PDF preview": "Previa de PDF",
        "Video preview": "Previa de video",
        "Game Settings subtitle": "Launchers, overlays e ferramentas de desempenho",
        "Launchers, overlays and performance tools": "Launchers, overlays e ferramentas de desempenho",
        "Performance": "Desempenho",
        "Game Mode": "Modo Jogo",
        "gamemoded optimizations enabled": "Otimizações do gamemoded ativadas",
        "Use normal system behavior": "Usar comportamento normal do sistema",
        "CPU, RAM, GPU and temperature visible": "CPU, RAM, GPU e temperatura visíveis",
        "Overlay hidden": "Overlay oculto",
        "Runtime Tools": "Ferramentas de execução",
        "Gaming Launchers": "Launchers de jogos",
        "Copy install": "Copiar instalação",
        "Install command copied": "Comando de instalação copiado",
        "Install": "Instalar",
        "Installing": "Instalando",
        "Flatpak install started": "Instalacao Flatpak iniciada",
        "Flatpak install failed": "Instalacao Flatpak falhou",
        "Installing {app} from Flathub.": "Instalando {app} pelo Flathub.",
        "Flatpak is unavailable or could not start.": "Flatpak nao esta disponivel ou nao conseguiu iniciar.",
        "{app} Flatpak command copied.": "Comando Flatpak do {app} copiado.",
        "{app} command copied.": "Comando do {app} copiado.",
        "missing": "ausente",
        "running": "em execucao",
        "needs restart": "precisa reiniciar",
        "ready": "pronto",
        "Setup complete": "Configuração concluída",
        "uNexus gaming setup is ready.": "A configuração de jogos do uNexus está pronta.",
        "uNexus desktop setup is ready.": "A configuração inicial do uNexus está pronta.",
        "Check gaming essentials and prepare uNexus for play": "Confira os essenciais de jogos e prepare o uNexus",
        "Review system defaults, recovery basics and gaming essentials": "Revise padrões do sistema, recuperação e essenciais de jogos",
        "Runtime": "Execução",
        "Recommended": "Recomendado",
        "Your core desktop essentials are ready.": "Os essenciais do desktop estão prontos.",
        "Timezone": "Fuso horário",
        "Keyboard": "Teclado",
        "Open language settings": "Abrir idioma",
        "Copy timezone command": "Copiar comando de fuso",
        "Copy keyboard command": "Copiar comando de teclado",
        "Open update settings": "Abrir atualizações",
        "Install Flatpak apps from Flathub for consistent game launcher support across uNexus builds.": "Instale apps Flatpak pelo Flathub para manter os launchers de jogos consistentes nas builds do uNexus.",
        "Copy Flathub setup": "Copiar setup do Flathub",
        "Game Launchers": "Launchers de jogos",
        "You can reopen this checklist later from uNexus Settings.": "Você pode reabrir esta checklist depois pelas Configurações uNexus.",
        "Finish setup": "Finalizar setup",
        "Confirm finish": "Confirmar finalizar",
        "Command copied": "Comando copiado",
        "{label} copied.": "{label} copiado.",
        "Change Wallpaper": "Trocar papel de parede",
        "Settings": "Configurações",
        "Store": "Loja",
        "Camera": "Câmera",
        "Notes": "Notas",
        "Open Files": "Abrir arquivos",
        "Paste": "Colar",
        "Refresh": "Atualizar",
        "Refresh Shell": "Atualizar shell",
        "Open Terminal": "Abrir Terminal",
        "Shell refreshed": "Shell atualizado",
        "Desktop state refreshed.": "Estado da area de trabalho atualizado.",
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
        "uNexus Shell": "Shell uNexus",
        "uNexus STATS": "ESTATÍSTICAS uNexus",
        "Loading apps": "Carregando apps",
        "Checking available apps and launchers.": "Verificando apps e launchers disponiveis.",
        "Launcher error": "Erro no launcher",
        "Launcher unavailable": "Launcher indisponivel",
        "No apps found": "Nenhum app encontrado",
        "Try another search or category.": "Tente outra busca ou categoria.",
        "Reset search": "Limpar busca",
        "No folder selected.": "Nenhuma pasta selecionada.",
        "Places unavailable": "Locais indisponiveis",
        "Common folders could not be loaded.": "Nao foi possivel carregar as pastas comuns.",
        "Loading folder": "Carregando pasta",
        "Reading local files.": "Lendo arquivos locais.",
        "Folder error": "Erro na pasta",
        "Folder unavailable": "Pasta indisponivel",
        "Folder is empty": "A pasta esta vazia",
        "Create a folder or choose another place.": "Crie uma pasta ou escolha outro local.",
        "Battery data is unavailable on this device.": "Dados de bateria indisponiveis neste dispositivo.",
        "Loading settings": "Carregando configuracoes",
        "Reading saved preferences.": "Lendo preferencias salvas.",
        "Settings error": "Erro nas configuracoes",
        "Some system data is unavailable": "Alguns dados do sistema estao indisponiveis",
        "Missing runtime tools: ": "Ferramentas de runtime ausentes: ",
        "Loading game settings": "Carregando configuracoes de jogos",
        "Checking gaming tools.": "Verificando ferramentas de jogos.",
        "Game settings error": "Erro nas configuracoes de jogos",
        "Runtime tools unavailable": "Ferramentas de runtime indisponiveis",
        "Flatpak is unavailable, so launcher installs may not work yet.": "Flatpak esta indisponivel, entao instalacoes de launchers talvez ainda nao funcionem.",
        "Loading setup": "Carregando setup",
        "Checking gaming essentials.": "Verificando essenciais de jogos.",
        "Setup error": "Erro no setup",
        "Setup partially unavailable": "Setup parcialmente indisponivel",
        "No setup steps pending": "Nenhuma etapa pendente",
        "Your gaming essentials are ready.": "Seus essenciais de jogos estao prontos.",
        "ON": "LIGADO",
        "OFF": "DESLIGADO",
        "Stats Overlay": "Overlay de estatisticas",
        "Gaming tools ready": "Ferramentas de jogos prontas",
        "Workspaces": "Areas de trabalho",
        "No windows": "Sem janelas",
        "Window moved": "Janela movida",
        "Window moved to workspace {label}.": "Janela movida para area {label}.",
        "Window minimized": "Janela minimizada",
        "Window maximized": "Janela maximizada",
        "Window closed": "Janela fechada"
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

    function wallpaperSourceForId(id) {
        for (var i = 0; i < wallpaperOptions.length; i++) {
            if (wallpaperOptions[i].id === id)
                return wallpaperOptions[i].source
        }

        return wallpaperOptions[0].source
    }

    function wallpaperLabelForId(id) {
        for (var i = 0; i < wallpaperOptions.length; i++) {
            if (wallpaperOptions[i].id === id)
                return wallpaperOptions[i].label
        }

        return wallpaperOptions[0].label
    }

    function setWallpaper(id, persist) {
        var normalizedId = id || "unexus-core"
        var matched = false
        for (var i = 0; i < wallpaperOptions.length; i++) {
            if (wallpaperOptions[i].id === normalizedId) {
                matched = true
                break
            }
        }

        if (!matched)
            normalizedId = "unexus-core"

        desktopWallpaperId = normalizedId
        desktopWallpaperSource = wallpaperSourceForId(normalizedId)

        if (persist !== false)
            userSettings.wallpaperId = desktopWallpaperId
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
        } else if (index === 4) {
            themeName = "Aurora Ice"
            themeBgTop = "#021018"
            themeBgMid = "#062433"
            themeBgBottom = "#03151f"
            themeAccent = "#7cf7ff"
            themeAccentDim = "#124a54"
            themeGlow = "#d6ff7a"
        } else if (index === 5) {
            themeName = "Solar Punk"
            themeBgTop = "#101006"
            themeBgMid = "#1d240b"
            themeBgBottom = "#070b05"
            themeAccent = "#f4ff52"
            themeAccentDim = "#4b5415"
            themeGlow = "#2dff9a"
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
        startupStatus = "Preparing system backends"
        languageCode = userSettings.languageCode
        localeVersion++
        applyTheme(userSettings.themeIndex, false)
        setWallpaper(userSettings.wallpaperId, false)
        systemStats.visible = userSettings.statsOverlayVisible
        startupBackendProbe.start()
        startupMinimumTimer.start()
    }

    function updateStartupLoading() {
        if (!startupLoading)
            return

        if (startupBackendsReady && startupMinimumElapsed) {
            startupStatus = "Loading desktop"
            startupHideTimer.start()
        }
    }

    Timer {
        id: startupBackendProbe
        interval: 120
        repeat: false
        onTriggered: {
            systemInfo.networkConnected
            systemInfo.kernelVersion
            systemStats.visible
            appLauncher.isInstalled("unexusctl")
            startupBackendsReady = true
            root.updateStartupLoading()
        }
    }

    Timer {
        id: startupMinimumTimer
        interval: 1200
        repeat: false
        onTriggered: {
            startupMinimumElapsed = true
            root.updateStartupLoading()
        }
    }

    Timer {
        id: startupHideTimer
        interval: 260
        repeat: false
        onTriggered: root.startupLoading = false
    }

    Connections {
        target: systemStats
        function onVisibleChanged() {
            userSettings.statsOverlayVisible = systemStats.visible
        }
    }

    function toggleLauncher() {
        dockActionMenu.hideMenu()

        if (unexusLauncher.visible) {
            unexusLauncher.hide()
            return
        }

        unexusLauncher.show()
    }

    function toggleSettingsPanel() {
        dockActionMenu.hideMenu()

        if (unexusSettings.visible) {
            unexusSettings.hide()
        } else {
            if (unexusLauncher.visible)
                unexusLauncher.hide()
            unexusSettings.show()
        }
    }

    function toggleGameSettingsPanel() {
        dockActionMenu.hideMenu()

        if (gameSettings.visible) {
            gameSettings.hide()
        } else {
            if (unexusLauncher.visible)
                unexusLauncher.hide()
            gameSettings.show()
        }
    }

    function toggleStatsOverlay() {
        systemStats.visible = !systemStats.visible
    }

    function prepareBugReport() {
        var report = appLauncher.prepareBugReport(userSettings.updateChannel)
        if (report.ok) {
            notifCenter.send(root.tr("Bug report prepared"), root.tr("Report path copied. Review it before opening GitHub."), "BUG")
            if (report.issueUrl && report.issueUrl.length > 0 && !appLauncher.launch("xdg-open", [report.issueUrl]))
                appLauncher.launch("gio", ["open", report.issueUrl])
        } else {
            notifCenter.send(root.tr("Bug report failed"), report.error || "", "BUG")
        }
    }

    function captureSetScene(scene) {
        captureMode = true
        captureScene = scene
        startupLoading = false
        setWallpaper("unexus-core", false)

        dockActionMenu.hideMenu()
        contextMenu.hide()

        unexusLauncher.visible = false
        unexusLauncher.opacity = 0.0
        unexusSettings.visible = false
        unexusSettings.opacity = 0.0
        unexusSettings.dockActive = false
        gameSettings.visible = false
        gameSettings.opacity = 0.0
        gameSettings.dockActive = false
        unexusFiles.visible = false
        unexusFiles.opacity = 0.0
        unexusFiles.dockActive = false
        firstSetup.visible = false
        firstSetup.opacity = 0.0
        firstSetup.dockActive = false

        if (scene === "launcher") {
            unexusLauncher.show()
        } else if (scene === "files") {
            unexusFiles.show()
        } else if (scene === "settings") {
            unexusSettings.show()
        } else if (scene === "settings-appearance") {
            unexusSettings.show()
            unexusSettings.setSection("appearance")
        } else if (scene === "game-settings") {
            gameSettings.show()
        } else if (scene === "first-setup") {
            firstSetup.show()
        } else if (scene === "desktop-particle-drift") {
            setWallpaper("particle-drift", false)
        } else if (scene === "desktop-aurora-ice") {
            setWallpaper("aurora-ice", false)
        } else if (scene === "desktop-ember-circuit") {
            setWallpaper("ember-circuit", false)
        }
    }

    function handleGlobalShortcut(action) {
        if (loginScreen && loginScreen.visible)
            return

        if (action === "launcher")
            toggleLauncher()
        else if (action === "settings")
            toggleSettingsPanel()
        else if (action === "stats")
            toggleStatsOverlay()
        else if (action === "gameSettings")
            toggleGameSettingsPanel()
        else if (action === "bugReport")
            prepareBugReport()
    }

    function refreshDesktopState() {
        dockStateVersion++
        panelStateVersion++
        wallpaperLines.requestPaint()
        diagonalGrid.requestPaint()
        notifCenter.send(root.tr("Shell refreshed"), root.tr("Desktop state refreshed."), "SYS")
    }

    Connections {
        target: globalShortcuts
        function onActionRequested(action) { root.handleGlobalShortcut(action) }
    }

    Shortcut {
        sequence: userSettings.launcherShortcut
        context: Qt.ApplicationShortcut
        enabled: !loginScreen || !loginScreen.visible
        onActivated: root.toggleLauncher()
    }

    Shortcut {
        sequence: userSettings.settingsShortcut
        context: Qt.ApplicationShortcut
        enabled: !loginScreen || !loginScreen.visible
        onActivated: root.toggleSettingsPanel()
    }

    Shortcut {
        sequence: userSettings.gameSettingsShortcut
        context: Qt.ApplicationShortcut
        enabled: !loginScreen || !loginScreen.visible
        onActivated: root.toggleGameSettingsPanel()
    }

    Shortcut {
        sequence: userSettings.statsShortcut
        context: Qt.ApplicationShortcut
        enabled: !loginScreen || !loginScreen.visible
        onActivated: root.toggleStatsOverlay()
    }

    Shortcut {
        sequence: userSettings.bugReportShortcut
        context: Qt.ApplicationShortcut
        enabled: !loginScreen || !loginScreen.visible
        onActivated: root.prepareBugReport()
    }

    property var systemDockApps: [
        { icon: "files", fallbackIcon: "files", iconNames: ["system-file-manager", "org.gnome.Nautilus", "nautilus"], label: "uNexus Files", internalAction: "files" },
        { icon: "browser", fallbackIcon: "browser", iconNames: ["brave-browser", "brave", "com.brave.Browser"], label: "Browser", command: "brave-browser", args: [], flatpakId: "com.brave.Browser", windowClasses: ["brave-browser", "Brave-browser", "brave", "Brave", "com.brave.Browser"], processNames: ["brave", "brave-browser"] },
        { icon: "settings", fallbackIcon: "settings", iconNames: ["preferences-system", "org.gnome.Settings", "gnome-control-center"], label: "uNexus Settings", internalAction: "settings" },
        { icon: "terminal", fallbackIcon: "terminal", iconNames: ["utilities-terminal", "org.gnome.Terminal", "gnome-terminal"], label: "Terminal", command: "gnome-terminal", args: [], windowClasses: ["gnome-terminal", "Gnome-terminal"], processNames: ["gnome-terminal-server", "gnome-terminal"] }
    ]

    property var gameDockApps: [
        { icon: "steam", fallbackIcon: "steam", iconNames: ["steam", "com.valvesoftware.Steam"], label: "Steam", command: "steam", args: [], flatpakId: "com.valvesoftware.Steam", windowClasses: ["steam", "Steam"], processNames: ["steam", "steamwebhelper"], gaming: true },
        { icon: "lutris", fallbackIcon: "lutris", iconNames: ["lutris", "net.lutris.Lutris"], label: "Lutris", command: "lutris", args: [], flatpakId: "net.lutris.Lutris", windowClasses: ["lutris", "Lutris"], processNames: ["lutris"], gaming: true },
        { icon: "heroic", fallbackIcon: "heroic", iconNames: ["com.heroicgameslauncher.hgl", "heroic", "heroicgameslauncher"], label: "Heroic", command: "heroic", args: [], flatpakId: "com.heroicgameslauncher.hgl", windowClasses: ["heroic", "Heroic", "com.heroicgameslauncher.hgl"], processNames: ["heroic", "heroicgameslauncher"], gaming: true },
        { icon: "bottles", fallbackIcon: "bottles", iconNames: ["com.usebottles.bottles", "bottles"], label: "Bottles", command: "bottles", args: [], flatpakId: "com.usebottles.bottles", windowClasses: ["bottles", "Bottles", "com.usebottles.bottles"], processNames: ["bottles"], gaming: true },
        { icon: "game-settings", fallbackIcon: "game-settings", iconNames: ["applications-games", "input-gaming", "preferences-desktop-gaming"], label: "Game Settings", internalAction: "gameSettings" }
    ]
    property int dockStateVersion: 0
    property int panelStateVersion: 0
    property int workspaceStateVersion: 0
    property bool workspaceSwitcherOpen: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            dockStateVersion++
            workspaceStateVersion++
        }
    }

    function workspaceModel() {
        workspaceStateVersion
        var items = appLauncher.workspaces()
        return items.slice(0, root.compactLayout ? 5 : 8)
    }

    function workspaceDetailModel() {
        workspaceStateVersion
        var workspaces = workspaceModel()
        var windows = appLauncher.workspaceWindows()
        var minimized = appLauncher.minimizedWindows()

        for (var i = 0; i < workspaces.length; i++) {
            workspaces[i].clients = []
            for (var j = 0; j < windows.length; j++) {
                if (windows[j].workspaceId === workspaces[i].id)
                    workspaces[i].clients.push(windows[j])
            }
        }

        if (minimized.length > 0) {
            workspaces.push({
                id: -1,
                name: root.tr("Minimized"),
                windows: minimized.length,
                monitor: "",
                active: false,
                special: true,
                clients: minimized
            })
        }

        return workspaces
    }

    function focusWorkspace(workspaceId) {
        if (appLauncher.focusWorkspace(workspaceId)) {
            workspaceStateVersion++
            dockStateVersion++
        }
    }

    function focusWindowAddress(address) {
        if (appLauncher.focusWindowAddress(address)) {
            workspaceSwitcherOpen = false
            workspaceStateVersion++
            dockStateVersion++
        }
    }

    function minimizeWindowAddress(address) {
        if (appLauncher.minimizeWindowAddress(address)) {
            workspaceStateVersion++
            dockStateVersion++
            notifCenter.send(root.tr("Window minimized"), "", "SYS")
            return true
        }

        return false
    }

    function restoreWindowAddress(address) {
        if (appLauncher.restoreWindowAddress(address)) {
            workspaceSwitcherOpen = false
            workspaceStateVersion++
            dockStateVersion++
            return true
        }

        return false
    }

    function maximizeWindowAddress(address) {
        if (appLauncher.maximizeWindowAddress(address)) {
            workspaceSwitcherOpen = false
            workspaceStateVersion++
            dockStateVersion++
            notifCenter.send(root.tr("Window maximized"), "", "SYS")
            return true
        }

        return false
    }

    function closeWindowAddress(address) {
        if (appLauncher.closeWindowAddress(address)) {
            workspaceStateVersion++
            dockStateVersion++
            notifCenter.send(root.tr("Window closed"), "", "SYS")
            return true
        }

        return false
    }

    function moveWindowAddressToWorkspace(address, workspaceId, workspaceLabel) {
        if (appLauncher.moveWindowAddressToWorkspace(address, workspaceId)) {
            workspaceStateVersion++
            dockStateVersion++
            notifCenter.send(root.tr("Window moved"), root.trLabelMessage("Window moved to workspace {label}.", workspaceLabel), "SYS")
            return true
        }

        return false
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
            return panelDockState(unexusFiles, stateVersion)

        if (app.internalAction === "settings")
            return panelDockState(unexusSettings, stateVersion)

        if (app.internalAction === "gameSettings")
            return panelDockState(gameSettings, stateVersion)

        if (app.internalAction === "firstSetup")
            return panelDockState(firstSetup, stateVersion)

        return ""
    }

    function launchDesktopApp(app) {
    if (app.internalAction === "settings") {
        unexusSettings.show()
        return
    }

    if (app.internalAction === "files") {
        unexusFiles.show()
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
            notifCenter.send(root.tr("MangoHud not found"), root.tr("Launching without MangoHud overlay."), "⚠️", root.tr("Open Game Settings"), function() {
                gameSettings.show()
            })

        if (!appLauncher.isGameModeRunInstalled())
            notifCenter.send(root.tr("GameMode not found"), root.tr("Launching without gamemoderun."), "⚠️", root.tr("Open Game Settings"), function() {
                gameSettings.show()
            })

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
        notifCenter.send(root.tr("App not found"), root.trAppMessage("{app} is not installed.", app.label), "⚠️", root.tr("Open First Setup"), function() {
            firstSetup.show()
        })
}

    function closeDesktopApp(app) {
        if (app.internalAction === "settings") {
            unexusSettings.hide()
            root.panelStateVersion++
            root.dockStateVersion++
            return
        }

        if (app.internalAction === "files") {
            unexusFiles.hide()
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
        root.workspaceStateVersion++
        root.dockStateVersion++
    }

    function focusDesktopApp(app) {
        if (!app)
            return false

        if (app.internalAction) {
            root.launchDesktopApp(app)
            return true
        }

        var focused = appLauncher.focusWindow(app.windowClasses || [])
        if (focused) {
            root.workspaceStateVersion++
            root.dockStateVersion++
        }

        return focused
    }

    function maximizeDesktopApp(app) {
        if (!app || app.internalAction)
            return false

        var maximized = appLauncher.maximizeWindow(app.windowClasses || [])
        if (maximized) {
            root.workspaceStateVersion++
            root.dockStateVersion++
        }

        return maximized
    }

    function moveDesktopApp(app) {
        if (!app || app.internalAction)
            return false

        var moved = appLauncher.moveWindowToNextWorkspace(app.windowClasses || [])
        root.workspaceStateVersion++
        root.dockStateVersion++
        return moved
    }

    function minimizeOrRestoreDesktopApp(app) {
        if (!app)
            return false

        if (app.internalAction) {
            if (app.internalAction === "settings")
                unexusSettings.visible ? unexusSettings.hide() : unexusSettings.show()
            else if (app.internalAction === "files")
                unexusFiles.visible ? unexusFiles.hide() : unexusFiles.show()
            else if (app.internalAction === "gameSettings")
                gameSettings.visible ? gameSettings.hide() : gameSettings.show()
            else if (app.internalAction === "firstSetup")
                firstSetup.visible ? firstSetup.hide() : firstSetup.show()

            root.panelStateVersion++
            root.dockStateVersion++
            return true
        }

        var hidden = appLauncher.isWindowHidden(app.windowClasses || [])
        var ok = hidden ? appLauncher.restoreWindow(app.windowClasses || []) : appLauncher.minimizeWindow(app.windowClasses || [])
        root.workspaceStateVersion++
        root.dockStateVersion++
        return ok
    }

    Rectangle {
        anchors.fill: parent
        color: root.themeBgTop

        Image {
            anchors.fill: parent
            source: root.desktopWallpaperSource
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            opacity: 0.78
        }

        Rectangle {
            anchors.fill: parent
            opacity: 0.46
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
            radius: root.radiusSm
            color: logoMouse.containsMouse ? root.surfaceHover : "transparent"

            Behavior on color {
                ColorAnimation { duration: root.motionBase }
            }

            Text {
                id: logoText
                anchors.centerIn: parent
                text: "uNexus"
                color: root.textPrimary
                font.pixelSize: root.textSmall
                font.letterSpacing: 4
                font.family: root.uiFont
                opacity: 0.7
            }

            MouseArea {
                id: logoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (unexusLauncher.visible)
                        unexusLauncher.hide()
                    else
                        unexusLauncher.show()
                }
            }
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            color: "#ffffff"
            font.pixelSize: 13
            font.family: root.uiFont
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
            id: workspaceStrip
            anchors.left: parent.left
            anchors.leftMargin: root.compactLayout ? 108 : 124
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                width: root.compactLayout ? 88 : 112
                height: 22
                radius: root.radiusSm
                color: workspaceMouse.containsMouse || root.workspaceSwitcherOpen ? root.surfaceHover : "transparent"
                border.color: root.workspaceSwitcherOpen ? root.themeAccent : root.borderSubtle
                border.width: root.workspaceSwitcherOpen ? 1 : 0

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.tr("Workspaces")
                    color: root.textPrimary
                    font.pixelSize: root.textTiny
                    font.family: root.uiFont
                    font.bold: root.workspaceSwitcherOpen
                    elide: Text.ElideRight
                    width: parent.width - 16
                }

                MouseArea {
                    id: workspaceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.workspaceSwitcherOpen = !root.workspaceSwitcherOpen
                }
            }

            Repeater {
                model: root.workspaceModel()

                delegate: Rectangle {
                    width: modelData.active ? 30 : 22
                    height: 18
                    radius: root.radiusSm
                    color: modelData.active ? root.themeAccentDim : (modelData.windows > 0 ? root.surfaceRaised : "transparent")
                    border.color: modelData.active ? root.themeAccent : (modelData.windows > 0 ? root.borderMuted : root.borderSubtle)
                    border.width: modelData.active ? 1 : 0
                    opacity: modelData.active ? 1.0 : (modelData.windows > 0 ? 0.74 : 0.36)

                    Behavior on width { NumberAnimation { duration: root.motionQuick; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: root.motionQuick } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.id
                        color: modelData.active ? root.textPrimary : root.textMuted
                        font.pixelSize: root.textTiny
                        font.family: root.uiFont
                        font.bold: modelData.active
                    }

                    Rectangle {
                        visible: modelData.windows > 0
                        anchors.right: parent.right
                        anchors.rightMargin: 3
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        width: 3
                        height: 3
                        radius: 2
                        color: modelData.active ? root.themeAccent : root.textMuted
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.focusWorkspace(modelData.id)
                            root.workspaceSwitcherOpen = true
                        }
                    }
                }
            }
        }

        LiquidGlass {
            id: workspaceSwitcher
            width: Math.min(root.width - 32, root.compactLayout ? 520 : 960)
            height: root.workspaceSwitcherOpen ? 230 : 0
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: root.compactLayout ? 8 : 116
            radius: root.radiusLg
            tintColor: root.surfaceBase
            accentColor: root.themeAccent
            borderColor: root.borderMuted
            materialOpacity: 0.82
            borderOpacity: 0.58
            highlightOpacity: 0.16
            depth: 0.42
            visible: root.workspaceSwitcherOpen
            opacity: root.workspaceSwitcherOpen ? 1.0 : 0.0
            clip: true
            z: 300

            Behavior on opacity { NumberAnimation { duration: root.motionQuick } }
            Behavior on height { NumberAnimation { duration: root.motionQuick; easing.type: Easing.OutCubic } }

            Row {
                id: workspaceCards
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 8

                Repeater {
                    model: root.workspaceDetailModel()

                    delegate: Rectangle {
                        id: workspaceCard
                        property var workspaceData: modelData
                        property var clients: modelData.clients || []

                        width: Math.max(root.compactLayout ? 86 : 104, Math.floor((workspaceSwitcher.width - 20 - 8 * Math.max(0, root.workspaceDetailModel().length - 1)) / Math.max(1, root.workspaceDetailModel().length)))
                        height: 206
                        radius: root.radiusMd
                        color: workspaceDrop.containsDrag ? root.surfaceStrongHover : (modelData.active ? root.themeAccentDim : root.surfaceRaised)
                        border.color: workspaceDrop.containsDrag ? root.themeAccent : (modelData.active ? root.themeAccent : root.borderMuted)
                        border.width: modelData.active || workspaceDrop.containsDrag ? 1 : 0

                        DropArea {
                            id: workspaceDrop
                            anchors.fill: parent
                            keys: ["unexus-window"]
                            onDropped: function(drop) {
                                if (!workspaceCard.workspaceData.special && drop.source && drop.source.windowAddress)
                                    root.moveWindowAddressToWorkspace(drop.source.windowAddress, workspaceCard.workspaceData.id, workspaceCard.workspaceData.name)
                            }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            Row {
                                width: parent.width
                                height: 20

                                Text {
                                    width: parent.width - 36
                                    text: workspaceCard.workspaceData.name || workspaceCard.workspaceData.id
                                    color: root.textPrimary
                                    font.pixelSize: root.textSmall
                                    font.family: root.uiFont
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 36
                                    horizontalAlignment: Text.AlignRight
                                    text: workspaceCard.clients.length
                                    color: workspaceCard.workspaceData.active ? root.themeAccent : root.textMuted
                                    font.pixelSize: root.textTiny
                                    font.family: root.uiFont
                                    font.bold: workspaceCard.workspaceData.active
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: root.borderSubtle
                            }

                            Text {
                                visible: workspaceCard.clients.length === 0
                                width: parent.width
                                height: 148
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: root.tr("No windows")
                                color: root.textMuted
                                font.pixelSize: root.textTiny
                                font.family: root.uiFont
                            }

                            Flow {
                                visible: workspaceCard.clients.length > 0
                                width: parent.width
                                height: 148
                                spacing: 5

                                Repeater {
                                    model: workspaceCard.clients

                                    delegate: Rectangle {
                                        id: windowThumb
                                        property string windowAddress: modelData.address || ""

                                        width: Math.max(50, Math.min(parent.width, (parent.width - 5) / 2))
                                        height: Math.max(42, Math.min(68, 34 + Math.round((modelData.height || 500) / Math.max(1, modelData.width || 800) * 34)))
                                        radius: root.radiusSm
                                        color: windowDrag.containsMouse || windowDrag.drag.active ? root.surfaceHover : "#101927"
                                        border.color: windowDrag.drag.active ? root.themeAccent : root.borderMuted
                                        border.width: 1
                                        Drag.active: windowDrag.drag.active
                                        Drag.keys: ["unexus-window"]
                                        Drag.source: windowThumb
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2

                                        Text {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 6
                                            anchors.rightMargin: 58
                                            text: modelData.title && modelData.title.length > 0 ? modelData.title : modelData.className
                                            color: root.textPrimary
                                            font.pixelSize: 9
                                            font.family: root.uiFont
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Row {
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.topMargin: 4
                                            anchors.rightMargin: 4
                                            spacing: 3
                                            z: 4

                                            WindowThumbAction {
                                                symbol: modelData.minimized ? "↗" : "-"
                                                label: modelData.minimized ? root.tr("Restore") : root.tr("Minimize")
                                                onClicked: modelData.minimized ? root.restoreWindowAddress(windowThumb.windowAddress) : root.minimizeWindowAddress(windowThumb.windowAddress)
                                            }

                                            WindowThumbAction {
                                                visible: !modelData.minimized
                                                symbol: "□"
                                                label: root.tr("Maximize")
                                                onClicked: root.maximizeWindowAddress(windowThumb.windowAddress)
                                            }

                                            WindowThumbAction {
                                                symbol: "×"
                                                label: root.tr("Close")
                                                danger: true
                                                onClicked: root.closeWindowAddress(windowThumb.windowAddress)
                                            }
                                        }

                                        Text {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 6
                                            text: modelData.className || root.tr("Window")
                                            color: root.textMuted
                                            font.pixelSize: 8
                                            font.family: root.uiFont
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            id: windowDrag
                                            anchors.fill: parent
                                            drag.target: windowThumb
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.minimized ? root.restoreWindowAddress(windowThumb.windowAddress) : root.focusWindowAddress(windowThumb.windowAddress)
                                            onReleased: {
                                                windowThumb.x = 0
                                                windowThumb.y = 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Rectangle {
                width: 26
                height: 22
                radius: root.radiusSm
                color: gameMode.active ? "#ff4d00" : root.surfaceRaised
                border.color: gameMode.active ? "#ff6a00" : root.borderMuted
                border.width: root.borderHairline
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
                                notifCenter.send(root.tr("MangoHud missing"), root.tr("Install on Arch: sudo pacman -S mangohud lib32-mangohud"), "⚠️", root.tr("Open Game Settings"), function() { gameSettings.show() })
                            if (!appLauncher.isGameModeRunInstalled())
                                notifCenter.send(root.tr("gamemoderun missing"), root.tr("Install on Arch: sudo pacman -S gamemode lib32-gamemode"), "⚠️", root.tr("Open Game Settings"), function() { gameSettings.show() })
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
                color: systemInfo.batteryLevel < 20 ? "#ff4d4d" : root.textPrimary
                font.pixelSize: root.textSmall
                font.family: root.uiFont
                opacity: 0.7
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: dateText
                color: root.textPrimary
                font.pixelSize: root.textSmall
                font.family: root.uiFont
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

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(360, root.width * 0.28)
            height: Math.max(120, width * 0.56)
            source: root.brandLogoSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.92
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Open Source. Linux Powered. Gamer Focused."
            color: root.themeAccent
            font.pixelSize: 14
            font.letterSpacing: 2
            font.family: root.uiFont
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
        fontFamily: root.uiFont
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
        accentColor: root.themeAccent
        panelColor: root.surfacePanel
        fontFamily: root.uiFont
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
        x: dockActionMenu.x + root.spaceXs
        y: dockActionMenu.y + root.spaceSm
        width: dockActionMenu.width
        height: dockActionMenu.height
        radius: dockActionMenu.radius
        color: root.shadowSoft
        opacity: dockActionMenu.visible ? 0.35 : 0.0
        visible: dockActionMenu.visible
        z: dockActionMenu.z - 1
    }

    LiquidGlass {
        id: dockActionMenu
        width: 190
        height: actionColumn.height + 12
        radius: root.radiusMd
        tintColor: root.surfaceBase
        accentColor: root.themeAccent
        borderColor: root.borderMuted
        materialOpacity: 0.78
        borderOpacity: 0.58
        highlightOpacity: 0.16
        depth: 0.40
        visible: false
        z: 180

        property var currentApp: null
        property string currentSide: ""
        property bool closeConfirming: false
        property var previewInfo: ({})

        function showForApp(app, point, side) {
            currentApp = app
            currentSide = side || ""
            closeConfirming = false
            previewInfo = app && app.windowClasses ? appLauncher.windowPreviewDirection(app.windowClasses) : ({ direction: "panel", available: false })
            closeConfirmTimer.stop()
            x = Math.max(8, Math.min(root.width - width - 8, point.x - width / 2))
            y = Math.max(44, point.y - height - 10)
            visible = true
        }

        function hideMenu() {
            visible = false
            currentApp = null
            currentSide = ""
            closeConfirming = false
            previewInfo = ({})
            closeConfirmTimer.stop()
        }

        Timer {
            id: closeConfirmTimer
            interval: 2600
            repeat: false
            onTriggered: dockActionMenu.closeConfirming = false
        }

        Column {
            id: actionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: root.radiusSm
            spacing: 2

            Column {
                width: parent.width
                height: 42
                spacing: 2

                Text {
                    width: parent.width - root.spaceLg
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dockActionMenu.currentApp ? root.tr(dockActionMenu.currentApp.label) : root.tr("Window")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width - root.spaceLg
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.tr("Preview") + ": " + root.tr(dockActionMenu.previewInfo.direction || "center")
                    color: root.textMuted
                    font.pixelSize: root.textTiny
                    font.family: root.uiFont
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                width: parent.width - root.spaceMd
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.borderSubtle
            }

            Rectangle {
                width: parent.width
                height: 34
                color: openMouse.containsMouse ? root.surfaceHover : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.spaceMd
                    text: root.tr("Open")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
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
                color: focusMouse.containsMouse ? root.surfaceHover : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.spaceMd
                    text: root.tr("Focus")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                }

                MouseArea {
                    id: focusMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.focusDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34
                color: minimizeMouse.containsMouse ? root.surfaceHover : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.spaceMd
                    text: dockActionMenu.currentApp && !dockActionMenu.currentApp.internalAction && appLauncher.isWindowHidden(dockActionMenu.currentApp.windowClasses || []) ? root.tr("Restore") : root.tr("Minimize")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                }

                MouseArea {
                    id: minimizeMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.minimizeOrRestoreDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34
                opacity: dockActionMenu.currentApp && !dockActionMenu.currentApp.internalAction ? 1.0 : 0.45
                color: maximizeMouse.containsMouse ? root.surfaceHover : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.spaceMd
                    text: root.tr("Maximize")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                }

                MouseArea {
                    id: maximizeMouse
                    anchors.fill: parent
                    enabled: dockActionMenu.currentApp && !dockActionMenu.currentApp.internalAction
                    hoverEnabled: enabled

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.maximizeDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34
                opacity: dockActionMenu.currentApp && !dockActionMenu.currentApp.internalAction ? 1.0 : 0.45
                color: moveMouse.containsMouse ? root.surfaceHover : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.spaceMd
                    text: root.tr("Move")
                    color: root.textPrimary
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                }

                MouseArea {
                    id: moveMouse
                    anchors.fill: parent
                    enabled: dockActionMenu.currentApp && !dockActionMenu.currentApp.internalAction
                    hoverEnabled: enabled

                    onClicked: {
                        if (dockActionMenu.currentApp)
                            root.moveDesktopApp(dockActionMenu.currentApp)

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
                    anchors.leftMargin: root.spaceMd
                    text: dockActionMenu.closeConfirming ? root.tr("Confirm close") : root.tr("Close")
                    color: "#ff8a8a"
                    font.pixelSize: root.textSmall
                    font.family: root.uiFont
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (!dockActionMenu.closeConfirming) {
                            dockActionMenu.closeConfirming = true
                            closeConfirmTimer.restart()
                            return
                        }

                        if (dockActionMenu.currentApp)
                            root.closeDesktopApp(dockActionMenu.currentApp)

                        dockActionMenu.hideMenu()
                    }
                }
            }
        }
    }

    Launcher {
        id: unexusLauncher
        anchors.fill: parent
        z: 100
        settingsPanel: unexusSettings
        gameSettingsPanel: gameSettings
        filesPanel: unexusFiles
    }

    component WindowThumbAction: Rectangle {
        id: thumbAction

        property string symbol: ""
        property string label: ""
        property bool danger: false

        signal clicked()

        width: 15
        height: 15
        radius: 4
        color: actionMouse.containsMouse ? (danger ? "#4a1f2a" : root.surfaceStrongHover) : "#172233"
        border.color: danger ? "#7a3348" : root.borderMuted
        border.width: 1
        opacity: actionMouse.containsMouse ? 1.0 : 0.9

        Text {
            anchors.centerIn: parent
            text: thumbAction.symbol
            color: thumbAction.danger ? "#ff8a8a" : root.textPrimary
            font.pixelSize: 9
            font.family: root.uiFont
            font.bold: true
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: function(mouse) {
                mouse.accepted = true
                thumbAction.clicked()
            }
        }

        ToolTip.visible: actionMouse.containsMouse
        ToolTip.text: thumbAction.label
        ToolTip.delay: 450
    }

    ContextMenu {
        id: contextMenu
        anchors.fill: parent
        z: 150
        onOpenFilesRequested: unexusFiles.show()
        onOpenSettingsRequested: unexusSettings.show()
        onOpenGameSettingsRequested: gameSettings.show()
        onOpenTerminalRequested: {
            if (!appLauncher.launchFirstAvailable(["kitty", "alacritty", "gnome-terminal", "xterm"]))
                notifCenter.send(root.tr("App not found"), root.trAppMessage("{app} is not installed.", "Terminal"), "TERM", root.tr("Open First Setup"), function() {
                    firstSetup.show()
                })
        }
        onRefreshShellRequested: root.refreshDesktopState()
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
        notificationsEnabled: userSettings.notificationsEnabled
        anchors.fill: parent
        z: 120
        timeoutMs: userSettings.notificationTimeoutSeconds * 1000
    }

    LoginScreen {
        id: loginScreen
        anchors.fill: parent
        z: 200
        visible: !root.captureMode || root.captureScene === "login"
        opacity: visible ? 1.0 : 0.0

        onLoginSuccess: {
            loginScreen.destroy()
            notifCenter.send(root.tr("Welcome back!"), root.tr("uNexus is ready."), "👋")

            if (!userSettings.firstSetupCompleted)
                firstSetup.show()
        }
    }

    FpsOverlay {
        anchors.fill: parent
        z: 130
    }

    SettingsPanel {
        id: unexusSettings
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
        id: unexusFiles
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

    Rectangle {
        id: startupScreen
        anchors.fill: parent
        z: 260
        visible: opacity > 0.0
        opacity: root.startupLoading ? 1.0 : 0.0
        color: "#050810"

        Behavior on opacity {
            NumberAnimation { duration: 360; easing.type: Easing.InOutCubic }
        }

        Canvas {
            id: startupGrid
            anchors.fill: parent
            opacity: 0.24
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = root.themeAccent
                ctx.globalAlpha = 0.18
                ctx.lineWidth = 1

                var step = 56
                for (var x = -step; x < width + step; x += step) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x + height * 0.45, height)
                    ctx.stroke()
                }

                ctx.globalAlpha = 0.1
                for (var y = 0; y < height; y += step) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(460, parent.width * 0.62)
            height: width
            radius: width / 2
            color: "transparent"
            border.color: root.themeAccent
            border.width: 1
            opacity: 0.22

            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 5200
                loops: Animation.Infinite
                running: startupScreen.visible
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 18

            Image {
                id: startupLogo
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(340, startupScreen.width * 0.34)
                height: Math.max(104, width * 0.54)
                source: root.brandLogoSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.96
                scale: 1.0

                SequentialAnimation on scale {
                    running: startupScreen.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.985; to: 1.035; duration: 920; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.035; to: 0.985; duration: 920; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                id: startupProgressTrack
                property real sweepX: -width * 0.36

                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(260, startupScreen.width * 0.36)
                height: 3
                radius: 2
                color: "#172233"
                clip: true

                Rectangle {
                    width: parent.width * 0.36
                    height: parent.height
                    radius: parent.radius
                    color: root.themeAccent
                    opacity: 0.9
                    x: startupProgressTrack.sweepX
                }

                NumberAnimation on sweepX {
                    from: -startupProgressTrack.width * 0.36
                    to: startupProgressTrack.width
                    duration: 1050
                    loops: Animation.Infinite
                    running: startupScreen.visible
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.tr(root.startupStatus)
                color: root.textSecondary
                font.pixelSize: root.textSmall
                font.family: root.uiFont
                font.bold: true
                opacity: 0.82
            }
        }
    }
}
