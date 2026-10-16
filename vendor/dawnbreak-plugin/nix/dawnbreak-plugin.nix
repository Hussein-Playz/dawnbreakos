{ lib
, stdenv
, cmake
, pkg-config
, qt6
, libqalculate
, pipewire
, aubio
, libcava
, lm_sensors
}:

stdenv.mkDerivation {
  pname = "dawnbreak-qml-plugin";
  version = "0.1.0";
  dontWrapQtApps = true;
  src = ../.;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtshadertools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtshadertools
    libqalculate
    pipewire
    aubio
    libcava
    lm_sensors
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DINSTALL_QMLDIR=lib/qt6/qml"
  ];

  meta = {
    description = "Dawnbreak QML plugin ported from Caelestia Shell";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
