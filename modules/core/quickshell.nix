{
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    quickshell

    # Qt6 related kits（for slove Qt5Compat problem）
    qt6.qt5compat
    qt6.qtbase
    qt6.qtquick3d
    qt6.qtwayland
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtpositioning

    # alternate options
    # libsForQt5.qt5compat
    kdePackages.kirigami
    kdePackages.kirigami.unwrapped
    kdePackages.qt5compat
    kdePackages.syntax-highlighting
    qt5.qtgraphicaleffects
  ];
    environment.variables = {
      QML_IMPORT_PATH = "$QML_IMPORT_PATH:${pkgs.kdePackages.kirigami}/lib/qt-6/qml";
      QML2_IMPORT_PATH = "$QML2_IMPORT_PATH:${pkgs.kdePackages.kirigami}/lib/qt-6/qml";
    };
  environment.variables.NIXPKGS_QT6_QML_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [
    pkgs.kdePackages.kirigami
    pkgs.qt6.qtpositioning
    pkgs.qt6.qtdeclarative
    pkgs.kdePackages.syntax-highlighting
    pkgs.qt6.qtsvg
    pkgs.qt6.qt5compat
  ];

  # make sure the Qt application is working properly
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}

