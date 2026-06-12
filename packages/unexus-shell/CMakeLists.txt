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
    src/globalshortcuts.cpp
    include/systeminfo.h
    include/gamemode.h
    include/applauncher.h
    include/systemstats.h
    include/usersettings.h
    include/filemanager.h
    include/globalshortcuts.h
)

qt_add_executable(unexus-installer
    ../unexus-installer/src/main.cpp
    ../unexus-installer/src/installerbackend.cpp
    ../unexus-installer/include/installerbackend.h
)

set_source_files_properties(../unexus-installer/qml/Main.qml PROPERTIES
    QT_RESOURCE_ALIAS qml/Main.qml
)

qt_add_qml_module(unexus-shell
    URI UNexusShell
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/DesignTokens.qml
        qml/LiquidGlass.qml
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
        qml/PanelStateView.qml
        qml/StatusChip.qml
        qml/ControlButton.qml
        qml/SegmentedControl.qml
)

qt_add_qml_module(unexus-installer
    URI UNexusInstaller
    VERSION 1.0
    QML_FILES
        ../unexus-installer/qml/Main.qml
)

qt_add_resources(unexus-shell "unexus_brand_assets"
    PREFIX "/UNexusShell"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/../.."
    FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/4.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/SF Black.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/SF White.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/unexus-core.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/particle-drift.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/aurora-ice.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/ember-circuit.png"
)

qt_add_resources(unexus-installer "unexus_installer_assets"
    PREFIX "/UNexusInstaller"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/../.."
    FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/SF White.png"
        "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/unexus-core.png"
)

target_include_directories(unexus-shell PRIVATE include)
target_include_directories(unexus-installer PRIVATE ../unexus-installer/include)

target_compile_definitions(unexus-installer PRIVATE
    UNEXUS_REPO_ROOT="${CMAKE_CURRENT_SOURCE_DIR}/../.."
)

set_target_properties(unexus-installer PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

target_link_libraries(unexus-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

target_link_libraries(unexus-installer PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

install(TARGETS unexus-shell
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(TARGETS unexus-installer
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(PROGRAMS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-session"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-recovery-session"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-recovery-menu"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(PROGRAMS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../scripts/unexus-doctor.sh"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME unexus-doctor
)

install(PROGRAMS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../scripts/install-os.sh"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME unexus-install-os
)

install(PROGRAMS
    "${CMAKE_CURRENT_SOURCE_DIR}/../../scripts/unexusctl.sh"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME unexusctl
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/io.github.PedroVitorDev.uNexusShell.desktop"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/io.github.PedroVitorDev.uNexusInstaller.desktop"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus.desktop"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-recovery.desktop"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/wayland-sessions
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../packaging/linux/unexus-driver-rollback.service"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/systemd/system
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/logo/4.png"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps
    RENAME unexus-shell.png
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/unexus-core.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/particle-drift.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/aurora-ice.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../assets/wallpapers/ember-circuit.png"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unexus/wallpapers
)
