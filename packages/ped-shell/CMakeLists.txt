cmake_minimum_required(VERSION 3.20)
project(ped-shell VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(ped-shell
    src/main.cpp
)

qt_add_qml_module(ped-shell
    URI PedShell
    VERSION 1.0
    QML_FILES qml/Main.qml
)

target_include_directories(ped-shell PRIVATE include)

target_link_libraries(ped-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)