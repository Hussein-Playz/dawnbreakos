pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common.widgets

Scope {
    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: GlobalStates.barOpen && !GlobalStates.screenLocked
            required property ShellScreen modelData

            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: Appearance.sizes.baseBarHeight + Appearance.sizes.hyprlandGapsOut
                WlrLayershell.namespace: "quickshell:bar"
                implicitHeight: Appearance.sizes.barHeight + Appearance.rounding.screenRounding
                color: "transparent"

                anchors {
                    top: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: hoverMaskRegion
                }

                Component.onCompleted: GlobalFocusGrab.addPersistent(barRoot)
                Component.onDestruction: GlobalFocusGrab.removePersistent(barRoot)

                Item {
                    anchors.fill: parent

                    Item {
                        id: hoverMaskRegion
                        anchors {
                            fill: barContent
                            topMargin: -2
                            bottomMargin: -2
                        }
                    }

                    BarContent {
                        id: barContent
                        implicitHeight: Appearance.sizes.barHeight
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "bar"

        function toggle(): void {
            GlobalStates.barOpen = !GlobalStates.barOpen
        }

        function close(): void {
            GlobalStates.barOpen = false
        }

        function open(): void {
            GlobalStates.barOpen = true
        }
    }

    GlobalShortcut {
        name: "barToggle"
        description: "Toggles bar on press"
        onPressed: GlobalStates.barOpen = !GlobalStates.barOpen
    }

    GlobalShortcut {
        name: "barOpen"
        description: "Opens bar on press"
        onPressed: GlobalStates.barOpen = true
    }

    GlobalShortcut {
        name: "barClose"
        description: "Closes bar on press"
        onPressed: GlobalStates.barOpen = false
    }
}
