cmake_minimum_required(VERSION 3.24)

# Standalone Dawnbreak QML plugin port of Caelestia Shell's plugin.
# Qt 6.9+ is required by the upstream source.
project(DawnbreakPlugin VERSION 0.1.0 LANGUAGES CXX)
set(VERSION "${PROJECT_VERSION}")
set(GIT_REVISION "source-port")

include(GNUInstallDirs)
include(CTest)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

set(INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/dawnbreak" CACHE STRING "Dawnbreak library install directory")
set(INSTALL_QMLDIR "${CMAKE_INSTALL_LIBDIR}/qt6/qml" CACHE STRING "Qt QML module install directory")

add_compile_definitions(
    QT_NO_CAST_FROM_ASCII
    QT_NO_CAST_TO_ASCII
    QT_NO_CAST_FROM_BYTEARRAY
)

find_package(Qt6 6.9 REQUIRED COMPONENTS ShaderTools Core Qml Gui Quick QuickControls2 Concurrent Sql Network DBus)
find_package(PkgConfig REQUIRED)
pkg_check_modules(Qalculate IMPORTED_TARGET libqalculate REQUIRED)
pkg_check_modules(Pipewire IMPORTED_TARGET libpipewire-0.3 REQUIRED)
pkg_check_modules(Aubio IMPORTED_TARGET aubio REQUIRED)
pkg_check_modules(Cava IMPORTED_TARGET libcava QUIET)
if(NOT Cava_FOUND)
    pkg_check_modules(Cava IMPORTED_TARGET cava REQUIRED)
endif()

add_subdirectory(plugin)
