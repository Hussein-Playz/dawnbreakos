pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Dawnbreak.Config
import "components"
import "modules/dashboard"
import "modules"

Item {
    id: root

    property bool opened: false
    property bool shortcutActive: false
    property bool dashboardHovered: false

    Timer {
        id: hoverCloseTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (!root.dashboardHovered && !root.shortcutActive)
                root.opened = false;
        }
    }

    function toggleFromShortcut(): void {
        if (opened) {
            opened = false;
            shortcutActive = false;
        } else {
            opened = true;
            shortcutActive = true;
        }
    }

    function showFromHover(): void {
        if (!Config.dashboard.enabled || !Config.dashboard.showOnHover || opened)
            return;

        shortcutActive = false;
        opened = true;
    }

    // Initialize the upstream font and the dashboard's weather/media services.
    GSFLoader {}
    ServiceLoader {}

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: hoverTrigger
            required property ShellScreen modelData

            visible: Config.dashboard.enabled && Config.dashboard.showOnHover
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 8
            color: "transparent"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:dawnbreakDashboardHover"

            // MouseArea reliably receives pointer entry on the thin top-edge
            // overlay even when the normal bar is on a higher layer.
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: {
                    hoverCloseTimer.stop();
                    root.showFromHover();
                }
                onExited: {
                    if (!root.shortcutActive)
                        hoverCloseTimer.start();
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: panel
            required property ShellScreen modelData

            visible: root.opened && Config.dashboard.enabled
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: dashboardPosition.y + dashboard.implicitHeight + 12
            color: "transparent"

            // Overlay layer plus Ignore exclusion means this window draws over
            // applications without reserving desktop space or shifting tiled windows.
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:dawnbreakDashboard"

            ScreenState {
                id: screenState
                modelData: panel.modelData
                dashboard: root.opened
            }

            Item {
                id: dashboardPosition
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                // Leave room for the bar at the top, then center the dashboard
                // in the available screen width instead of pinning it to x=0.
                y: Tokens.sizes.bar.innerWidth + Tokens.padding.large + Config.border.thickness
                width: parent.width
                height: dashboard.implicitHeight

                Wrapper {
                    id: dashboard
                    anchors.top: parent.top
                    // anchors.topMargin: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    screenState: screenState

                    HoverHandler {
                        onHoveredChanged: {
                            root.dashboardHovered = hovered;
                            if (hovered) {
                                hoverCloseTimer.stop();
                                if (root.shortcutActive)
                                    root.shortcutActive = false;
                            } else if (!root.shortcutActive) {
                                hoverCloseTimer.start();
                            }
                        }
                    }
                }
            }
        }
    }
}
