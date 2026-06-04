cmake_minimum_required(VERSION 3.20)
project(unexus-shell VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(GNUInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(unexus-shell
    src/main.cpp
    src/systeminfo.cpp
    src/gamemode.cpp
    src/applauncher.cpp
    src/systemstats.cpp
    src/usersettings.cpp
    src/filemanager.cpp
    include/systeminfo.h
    include/gamemode.h
    include/applauncher.h
    include/systemstats.h
    include/usersettings.h
    include/filemanager.h
)

qt_add_qml_module(unexus-shell
    URI UNexusShell
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Launcher.qml
        qml/LoginScreen.qml
        qml/ContextMenu.qml
        qml/NotificationCenter.qml
        qml/FpsOverlay.qml
        qml/SideDock.qml
        qml/DockButton.qml
        qml/SettingsPanel.qml
        qml/GameSettingsPanel.qml
        qml/FirstSetupPanel.qml
        qml/FilesPanel.qml
)

qt_add_resources(unexus-shell "unexus_brand_assets"
    PREFIX "/UNexusShell"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/../.."
    FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/4.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/SF Black.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/SF White.png"
)

target_include_directories(unexus-shell PRIVATE include)

target_link_libraries(unexus-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

install(TARGETS unexus-shell
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(PROGRAMS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-session"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/io.github.PedroVitorDev.uNexusShell.desktop"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus.desktop"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/wayland-sessions
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/4.png"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps
    RENAME unexus-shell.png
)
