pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common.functions

Singleton {
    id: root

    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter
    property bool ready: false
    property int readWriteDelay: 50
    property bool blockWrites: false

    Timer {
        id: fileReloadTimer
        interval: root.readWriteDelay
        repeat: false
        onTriggered: configFileView.reload()
    }

    Timer {
        id: fileWriteTimer
        interval: root.readWriteDelay
        repeat: false
        onTriggered: configFileView.writeAdapter()
    }

    FileView {
        id: configFileView
        path: root.filePath
        watchChanges: true
        blockWrites: root.blockWrites
        onFileChanged: fileReloadTimer.restart()
        onAdapterUpdated: fileWriteTimer.restart()
        onLoaded: {
            root.ready = true;
            // Keep the requested tray behavior when migrating an older config.
            if (configOptionsJsonAdapter.tray.invertPinnedItems !== true)
                configOptionsJsonAdapter.tray.invertPinnedItems = true;
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.ready = true;
                writeAdapter();
            }
        }

        JsonAdapter {
            id: configOptionsJsonAdapter

            property JsonObject policies: JsonObject {
                property int weeb: 1
            }

            property JsonObject appearance: JsonObject {
                property JsonObject palette: JsonObject {
                    property string type: "auto"
                }
                property JsonObject transparency: JsonObject {
                    property bool enable: true
                }
                property JsonObject wallpaperTheming: JsonObject {
                    property bool enableAppsAndShell: true
                    property bool enableQtApps: true
                    property bool enableTerminal: true
                    property JsonObject terminalGenerationProps: JsonObject {
                        property bool forceDarkMode: false
                        property int harmonizeThreshold: 100
                        property real harmony: 0.6
                        property real termFgBoost: 0.35
                    }
                }
            }

            property JsonObject background: JsonObject {
                property string thumbnailPath: ""
                property string wallpaperPath: "/home/dawn/Pictures/Wallpapers/LavisMoonOsuBackground.png"
            }

            property JsonObject conflictKiller: JsonObject {
                property bool autoKillNotificationDaemons: true
                property bool autoKillTrays: true
            }

            property JsonObject battery: JsonObject {
                property bool automaticSuspend: true
                property int critical: 10
                property int full: 101
                property int low: 20
                property int suspend: 3
            }

            property JsonObject language: JsonObject {
                property string ui: "en_US"
            }

            property JsonObject launcher: JsonObject {
                property list<string> pinnedApps: [
                    "org.kde.dolphin",
                    "kitty",
                    "cmake-gui"
                ]
            }

            property JsonObject musicRecognition: JsonObject {
                property int interval: 4
                property int timeout: 16
            }

            property JsonObject networking: JsonObject {
                property string userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
            }

            property JsonObject resources: JsonObject {
                property int updateInterval: 3000
            }

            property JsonObject screenRecord: JsonObject {
                property string savePath: "$HOME/Videos"
            }

            property JsonObject screenSnip: JsonObject {
                property string savePath: "$HOME/Pictures/ScreenShots"
            }

            property JsonObject search: JsonObject {
                property string engineBaseUrl: "https://www.google.com/search?q="
                property bool sloppy: false
                property JsonObject prefix: JsonObject {
                    property string action: "/"
                    property string clipboard: ";"
                    property string emojis: ":"
                    property string math: "="
                    property string shellCommand: "$"
                    property string webSearch: "?"
                }
            }

            property JsonObject sidebar: JsonObject {
                property JsonObject quickToggles: JsonObject {
                    property JsonObject android: JsonObject {
                        property int columns: 5
                        property list<var> toggles: [
                            { "size": 2, "type": "network" },
                            { "size": 1, "type": "bluetooth" },
                            { "size": 1, "type": "idleInhibitor" },
                            { "size": 1, "type": "darkMode" },
                            { "size": 1, "type": "mic" },
                            { "size": 1, "type": "audio" },
                            { "size": 1, "type": "colorPicker" }
                        ]
                    }
                }
            }

            property JsonObject time: JsonObject {
                property string format: "h:mm AP"
            }

            property JsonObject tray: JsonObject {
                property bool invertPinnedItems: true
                property list<var> pinnedItems: ["Fcitx"]
            }

            property JsonObject wallpaperSelector: JsonObject {
                property bool useSystemFileDialog: false
            }

            property JsonObject overlay: JsonObject {
                property JsonObject floatingImage: JsonObject {
                    property real scale: 0.5
                }
            }
        }
    }
}
